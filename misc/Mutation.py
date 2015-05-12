#! /usr/bin/env python

# Copyright (c) 2012 King's College London
# created by Laurence Tratt and Naveneetha Vasudevan
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

""" Grammar Mutation:
empty: identify rule with no empty alts, pick a rule randonly, add an empty alt
mutate: pick a rule randonly, pick one of its alts randomly, pick one its 
symbols randomly, and mutate
insert - same logic as 'mutate' but insert a symbol at a random position
delete - same logic as 'mutate' but delete a symbol at a random position
switch - pick a rule randomly, pick only alts with at least two symbols, 
pick two positions randomly. and switch symbols.
"""

import random
import CFG, Lexer
import Utils

def empty(cfg):
    """ Add an empty alternative (only to rules without empty alt) """
    non_empty_keys = []
    for r in cfg.rules:
        e = False
        for seq in r.seqs:
            if len(seq) == 0:
                e = True
                break
                
        if not e:
            non_empty_keys.append(r.name)
                
    #print "non_empty_keys: " , non_empty_keys
    key = random.choice(non_empty_keys)
    rule = cfg.get_rule(key)
    print "-- " , rule
    rule.seqs.append([])
    print "++ " , rule


def add(cfg, tok):
    """ Add a (random) symbol to an (random) alternative """
    keys = [rule.name for rule in cfg.rules]
    key = random.choice(keys)
    rule = cfg.get_rule(key)
    i = random.randint(0, len(rule.seqs)-1)
    seq =  rule.seqs[i]
    print "-- " , rule
    # we use 'len(seq)' as we can add sym at the end too
    j = random.randint(0, len(seq))
    seq.insert(j, tok)
    print "++ " , rule


def mutate(cfg, tok):
    """ Update a (random) symbol to an (random) alternative """
    keys = [rule.name for rule in cfg.rules]
    key = random.choice(keys)
    rule = cfg.get_rule(key)
    non_empty_seqs = []
    for i, s in enumerate(rule.seqs):
        if len(s) > 0:
            non_empty_seqs.append(i)

    print "-- " , rule
    seq = rule.seqs[random.choice(non_empty_seqs)]
    j = random.randint(0, len(seq)-1)
    seq[j] = tok
    print "++ " , rule


def delete(cfg):
    """ Delete a (random) symbol to an (random) alternative
        Possible only for non empty alternatives
    """
    keys = [rule.name for rule in cfg.rules]
    key = random.choice(keys)
    rule = cfg.get_rule(key)
    non_empty_seqs = []
    for i, s in enumerate(rule.seqs):
        if len(s) > 0:
            non_empty_seqs.append(i)

    print "-- " , rule
    seq = rule.seqs[random.choice(non_empty_seqs)]
    j = random.randint(0, len(seq)-1)
    del seq[j]
    print "++ " , rule


def switch(cfg):
    """ Switch symbols in an (random) alternative """
    keys = []
    for r in cfg.rules:
        for seq in r.seqs:
            if len(seq) >= 2:
                keys.append(r.name)
                break

    key = random.choice(keys)
    rule = cfg.get_rule(key)
    print "-- " , rule
    seqs = [x for x in rule.seqs if len(x) >= 2]
    seq = random.choice(seqs)
    i,j = random.sample(xrange(len(seq)),2)
    # switch the tokens seq[i] <-> seq[j]
    t = seq[i]
    seq[i] = seq[j]
    seq[j] = t
    print "++ " , rule



def mutate_cfg(gp, lp, type):
    lex = Lexer.parse(open(lp, "r").read())
    cfg = CFG.parse(lex, open(gp, "r").read())
    sym_toks = Utils.sym_tokens(gp)

    _cfg = cfg.clone()

    if type == 'empty':
        empty(_cfg)
    elif type == 'add':
        tok = Utils.randomTok(cfg, lex, sym_toks)
        add(_cfg, tok)
    elif type == 'mutate':
        tok = Utils.randomTok(cfg, lex, sym_toks)
        mutate(_cfg, tok)
    elif type == 'delete':
        delete(_cfg)
    elif type == 'switch':
        switch(_cfg)
    else:
        assert "mutation type '%s' is not supported" % type

    return _cfg
