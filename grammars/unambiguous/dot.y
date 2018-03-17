%token ID_TK N_TK NE_TK E_TK SE_TK S_TK SW_TK W_TK NW_TK C_TK UNDERSCORE_TK SUBGRAPH_TK GRAPH_TK DIGRAPH_TK EDGE_TK NODE_TK STRICT_TK EDGEOP_TK

%%

graph : strict_opt graph_or_subgraph opt_id '{' stmt_list_opt '}'
;

strict_opt: | STRICT_TK 
;

graph_or_subgraph: GRAPH_TK | DIGRAPH_TK
;

opt_id: | ID_TK
;

stmt_list_opt: | stmt_list
;

stmt_list: stmt semi_colon_opt stmt_list_opt
;

semi_colon_opt: | ';'
;

stmt: 
    node_stmt
|	edge_stmt
|	attr_stmt
|	ID_TK'=' ID_TK
|	subgraph
;

attr_stmt: graph_node_edge attr_list
;

graph_node_edge: GRAPH_TK | NODE_TK | EDGE_TK
;

attr_list: '[' a_list_opt ']' attr_list_opt 
;

a_list_opt: | a_list
;

a_list:	ID_TK '=' ID_TK semicolon_or_comma_opt a_list_opt 
;

semicolon_or_comma_opt: | semicolon_or_comma 
;

semicolon_or_comma: ';' | ','
;

edge_stmt: node_id_or_subgraph edgerhs attr_list_opt 
;

edgerhs_opt: | edgerhs
;

edgerhs: EDGEOP_TK node_id_or_subgraph edgerhs_opt
;

node_id_or_subgraph: node_id | subgraph
;

node_stmt: node_id attr_list_opt 
;

attr_list_opt: | attr_list
;

node_id: ID_TK port_opt
;

port_opt: | port
;

port: ':' ID_TK colon_compass_opt | colon_compass
;

colon_compass_opt: | colon_compass
;

colon_compass: ':' compass_pt
;

subgraph: subgraph_id_opt '{' stmt_list '}'
;

subgraph_id_opt : | SUBGRAPH_TK opt_id
;

compass_pt:	N_TK | NE_TK | E_TK | SE_TK | S_TK | SW_TK | W_TK | NW_TK | C_TK | UNDERSCORE_TK
;

