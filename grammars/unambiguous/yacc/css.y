/*
 * CSS grammar in BNF
 * For original grammar, refer to http://www.w3.org/TR/CSS21/grammar.html
 */

%token CHARSET_SYM STRING S CDO CDC URI MEDIA_SYM IMPORT_SYM IDENT PAGE_SYM HASH INCLUDES DASHMATCH FUNCTION IMPORTANT_SYM NUMBER PERCENTAGE LENGTH EMS EXS ANGLE TIME FREQ SC_TK COLON_TK

%%

stylesheet : stylesheet_opt_1 cdo_cdc_multi  stylesheet_imports_multi stylesheet_tail_multi
  ;

stylesheet_opt_1 : CHARSET_SYM STRING SC_TK | 
  ;

cdo_cdc : S | CDO | CDC
  ;

stylesheet_imports : import cdo_cdc_s_multi
  ;

cdo_cdc_s : CDO S_multi | CDC S_multi
  ;

S_multi : | S S_multi
  ;

cdo_cdc_multi : | cdo_cdc cdo_cdc_multi
  ;
  
stylesheet_imports_multi : | stylesheet_imports stylesheet_imports_multi
  ; 

cdo_cdc_s_multi : | cdo_cdc_s cdo_cdc_s_multi
  ;

stylesheet_tail : stylesheet_parts cdo_cdc_s_multi 
  ;
  
stylesheet_parts : ruleset | media | page
  ;
  
stylesheet_tail_multi :  | stylesheet_tail stylesheet_tail_multi
  ;
  
import : IMPORT_SYM S_multi string_or_uri S_multi media_list_opt SC_TK S_multi
  ;
  
media_list_opt : | media_list
  ;
  
string_or_uri : STRING | URI
  ;
  
media : MEDIA_SYM S_multi media_list '{' S_multi ruleset_multi '}' S_multi
  ;
  
ruleset_multi : | ruleset ruleset_multi
  ;
  
media_list : medium media_list_tail_multi
  ;
  
media_list_tail : ',' S_multi medium
  ;
  
media_list_tail_multi : | media_list_tail media_list_tail_multi
  ;
  
medium : IDENT S_multi
  ;
  
page : PAGE_SYM S_multi pseudo_page_opt '{' S_multi declaration_opt declaration_multi '}' S_multi
  ;
  
pseudo_page_opt : | pseudo_page
  ;
  
declaration_opt : | declaration
  ;

declaration_tail : SC_TK S_multi declaration_opt
  ;
  
declaration_multi : | declaration_tail declaration_multi
  ;
  
pseudo_page : COLON_TK IDENT S_multi
  ;
  
operator : '/' S_multi | ',' S_multi
  ;
  
combinator : '+' S_multi  | '>' S_multi
  ;
  
unary_operator : '-' | '+'
  ;
  
property : IDENT S_multi
  ;
  
ruleset : selector multi_addl_selector '{' S_multi declaration_opt declaration_multi '}' S_multi
  ;

addl_selector : ',' S_multi selector
  ;

multi_addl_selector : | addl_selector multi_addl_selector
  ;

selector : simple_selector selector_tail_opt
  ;

combinator_opt : | combinator
  ;

selector_tail_opt :  | selector_tail
  ;

selector_tail : combinator selector | S S_multi selector_tail_2_opt
  ;

selector_tail_2_opt : | selector_tail_2
  ;
  
selector_tail_2 : combinator_opt selector
  ;
  
simple_selector : element_name  simple_selector_tail_multi
  | simple_selector_tail simple_selector_tail_multi 
  ;

simple_selector_tail :  HASH | class | attrib | pseudo
  ;

simple_selector_tail_multi : | simple_selector_tail simple_selector_tail_multi
  ;

class  : SC_TK IDENT
  ;
  
element_name : IDENT | '*'
  ;
  
attrib : '[' S_multi IDENT S_multi attrib_tail_opt ']'
  ;
  
attrib_includes : '=' | INCLUDES | DASHMATCH
  ;

attrib_tail_opt : | attrib_includes S_multi id_or_string S_multi
  ;
  
id_or_string :  IDENT | STRING
  ;
   
pseudo : COLON_TK pseudo_tail
  ;
  
pseudo_tail : IDENT | FUNCTION S_multi pseudo_tail_2_opt ')'
  ;

pseudo_tail_2_opt : | IDENT S_multi 
  ;

declaration : property COLON_TK S_multi expr prio_opt
  ;
  
prio_opt : | prio
  ;
  
prio : IMPORTANT_SYM S_multi
  ;
  
expr : term expr_tail_multi
  ;
  
operator_opt : | operator
  ;
  
expr_tail : operator_opt term
  ;
  
expr_tail_multi : | expr_tail expr_tail_multi
  ;
  
term : unary_operator_opt term_types
  | STRING S_multi | IDENT S_multi | URI S_multi | hexcolor | function
  ;

term_types : NUMBER S_multi | PERCENTAGE S_multi | LENGTH S_multi | EMS S_multi | EXS S_multi | ANGLE S_multi | TIME S_multi | FREQ S_multi
  ;
  
unary_operator_opt : | unary_operator
  ;
  
function  : FUNCTION S_multi expr ')' S_multi
  ;

hexcolor : HASH S_multi
  ;