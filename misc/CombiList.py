#!/usr/bin/env python

class CombiList:

    def  __init__(self, l1, l2):
        self.l1 = l1
        self.l2 = l2
        self.combs = []
        _l1 = l1
        i = 0
        while i < len(l1):
            self.combine([],[],_l1,l2)
            _l1 = self.rotate(_l1,1)
            i += 1


    def rotate(self, l, n):
        return l[n:] + l[:n]
    
    
    def combine(self, _l1, _l2, l1, l2):
        """ Given two lists ['A','B','C'], ['P','Q','R'], this function will return
            a list containing all possible combinations of mapping between items: 
            ['A', 'B', 'C'] -> ['P', 'Q', 'R']
            ['A', 'B', 'C'] -> ['P', 'R', 'Q']
            ['B', 'C', 'A'] -> ['P', 'Q', 'R']
            ['B', 'C', 'A'] -> ['P', 'R', 'Q']
            ['C', 'A', 'B'] -> ['P', 'Q', 'R']
            ['C', 'A', 'B'] -> ['P', 'R', 'Q']
        """
        l1_tail = l1[1:]
        l2_tail = l2[1:]
        if len(l2) == 1:
            l1_items = _l1 + [l1[0]] + l1_tail
            l2_items = _l2 + [l2[0]] + l2_tail
            self.combs.append([l1_items,l2_items])
    
        i = 0
        l2__ = l2_tail
        __l1 = _l1 + [l1[0]]
        __l2 = _l2 + [l2[0]]
        while i < len(l2_tail):
            self.combine(__l1,__l2,l1_tail,l2__)
            l2__ = self.rotate(l2__,1)
            i += 1
    
    
def combine_lists(l1, l2):
    c = CombiList(l1,l2)
    return c


if __name__ == "__main__":
    a = ['A','B','C']
    b = ['P','Q','R']
    c = combine_lists(a,b)
    print "combinations: "
    for l in c.combs:
        p,q = l
        print "%s -> %s" % (p,q) 
