#!/bin/bash

wrkdir=$1

usage() {
  echo "$0 <work directory>"
  exit 1
}

[ -z "$wrkdir" ] && usage

if [ -d "$wrkdir" ];then 
  rm -Rf $wrkdir/*
else
  mkdir -p $wrkdir
fi

css_test_version="20110323"
w3c_url="http://test.csswg.org/suites/css2.1/${css_test_version}.zip"
logf="css.log"
> $logf

abspath=$(readlink -f $0)
basedir=$(dirname $abspath)

# download css files from w3c site
setup_tests() {
  echo "=> Downloading ${w3c_url} ..."
  wget $w3c_url -O $wrkdir/${css_test_version}.zip
  #cp /var/tmp/${css_test_version}.zip $wrkdir
  unzip -q $wrkdir/${css_test_version}.zip -d $wrkdir
  echo "=> css tests are located here: $wrkdir/${css_test_version}"
}

# extract the css style blocks
extract_css_blocks() 
{
   f="$1"
   tf=$(mktemp)
   cat $f | sed -n '/<style type="text\/css">/,/<\/style>/p' > $tf
   cssf_prefix="$outdir/$(basename $f)"
   i=0
   bstyle_line_no=""
   estyle_line_no=""
   while read -r line; do  
     i=$((i+1))
     #echo "[$i]=> $line"
     bstyle=$(echo "$line" | egrep '<style>|<style.*type="text/css">')
     if [ ! -z "$bstyle" ];then 
       bstyle_line_no=$i
       #echo "bstyle found: $bstyle_line_no"
     fi
     estyle=$(echo "$line" | grep '</style>')
     if [ ! -z "$estyle" ];then
       estyle_line_no=$i
       cssf=${cssf_prefix}_$estyle_line_no
       #echo "estyle found: $estyle_line_no"
       #echo ": $bstyle_line_no , $estyle_line_no"
       if [ $estyle_line_no -eq $bstyle_line_no ]; then
         sed -n "${bstyle_line_no},${estyle_line_no}"p $f \
         | sed -e 's/.*<style.*type="text\/css">//' -e 's/.*<style>//' -e 's/<\/style>.*//' > $cssf
       elif [ $estyle_line_no -gt $bstyle_line_no ]; then
         sed -n "${bstyle_line_no},${estyle_line_no}"p $f \
         | sed -e 's/.*<style.*type="text\/css">//' -e 's/.*<style>//' -e 's/<\/style>.*//' > $cssf
       else
         echo "ERROR: possibly $estyle_line_no < $bstyle_line_no"
         exit 1
       fi
       cat $cssf | sed -e 's/Ahem/monospace/g' | $parser 2>/dev/null
       echo "$cssf => $?" >> $logf
       printf "."
     fi
   done < $f
  [ -f $tf ] && rm $tf
}

# find invalid css from the test suite
invalid_css() {
  invalidf=$1
  chapter_list="$wrkdir/${css_test_version}/html4/chapter-[0-9]*.html"
  for f in $(ls $chapter_list | sort -V); do 
      echo "=> $f" 
      cat $f |  grep -B 2 ' class="invalid" title="Tests Invalid CSS"' \
      | awk 'NR%2' | egrep -o 'href=".*.htm"|class="invalid"' \
      | paste - - |  sed -e 's/"//g' | sed -e 's/href=//' -e 's/\s*class=/:/'
      echo ""
  done > $invalidf
}


#####
setup_tests 

# build css parser
make -C $basedir clean && make -C $basedir
if [ $? != 0 ]; then 
  echo "Make failed for generating css parser!"
  exit 1
fi

parser="$basedir/css"

echo "=> parsing css files..."
outdir="$wrkdir/${css_test_version}_css_files"
[ ! -d $outdir ] && mkdir -p $outdir
cd $wrkdir
for f in $(find $wrkdir/${css_test_version}/html4 -name "*.htm"); do
  extract_css_blocks $f 
done

echo "=> finding invalid css files.."
invalid_css_file="invalid.css"
invalid_css $invalid_css_file

parse_fail="${logf}.parse_fail"
grep  '=> 1' $logf | awk -F/ '{print $NF}' | awk '{print $1}'

tmpf=$(mktemp)
echo "tmpf: $tmpf"
for j in $(cat $parse_fail); do 
    f=$(echo $j | cut -d. -f1) 
    inv=$(grep -w "^$f" $invalid_css_file | uniq | cut -d: -f2 | grep -o invalid); 
    chapter_list="$wrkdir/${css_test_version}/html4/chapter-[0-9]*.html"
    chapter=$(grep -H -w "${f}.htm" $chapter_list | head -1 | grep -o 'chapter-[0-9]*')
    echo "$chapter,$f,$inv"; 
done > $tmpf

out_csv="css_parse_fail_invalid.csv"
cat $tmpf | sort -t, -k1 -V > $out_csv
[ -f $tmpf ] && rm $tmpf
echo "=> css files with failed parse: $out_csv"

