% ?-s_new,[-'jpn_bup_chart_parser.pl'],test.
% jpn_bup_chart_parser.pl
% Japanese bottom up chart parser

%refer to
% http://www.brawer.ch/prolog/botUpChartParsing.pdf
% http://www.cs.bham.ac.uk/~pjh/publications/ngc_90.pdf
% http://www.jaist.ac.jp/~kshirai/lec/i223/04a.pdf
% http://www.ircl.yamanashi.ac.jp/~ysuzuki/public/algorithm3/20101118s.pdf
:- dynamic(arc/6).


test :-
	Morph = [[ '健','名詞'],['が','助詞'],['直美','名詞'],['を','助詞'], ['愛する','動詞'] ],
	make_dict(Morph),
	parse('文',['健','が','直美','を','愛する']).


%% 
make_dict([]):-!.
make_dict([[A1,A2|_]|L]):-assert(dict(A1,A2)),make_dict(L).


% // parse(+Symbol, +String)
parse(Symbol, String):-
	start_chart(String,1,Vn),
	foreach(arc(ID,1,Vn,Symbol,_,[]), (write_listnl(['Found parse: Edge #',ID])) ),
	write_arc(String),
	abolish(arc,6),
	true.
parse(_,_):-abolish(arc,6).

% // start_chart(+StartVertex, -EndVertex, +SentenceList)
start_chart([],E,E).
start_chart([W|L],S,E):-
	SS is S + 1,
	foreach(dict(W,Cat),add_arc( arc(_,S,SS,Cat,[lex(W)],[])) ),
	start_chart(L,SS,E).

% 既存弧
add_arc(Edge):-Edge,!,write('Ignoring: '),write_arc(Edge).

% 不活性弧
add_arc(Edge):-
	Edge = arc(ID,V1,V2,C,_,[]),new_id(ID),
	asserta(Edge),write_arc(Edge),
	foreach(phrase([C|CL],LHS),add_arc(arc(_,V1,V1,LHS,[],[C|CL]))),
	foreach(arc(_,V0,V1,LeftC,LeftF,[C|LeftTF]),add_arc(arc(_,V0,V2,LeftC,[ID|LeftF],LeftTF))).

% 活性弧
%InactiveEdgeID =InID
add_arc(Edge):-
	Edge = arc(ID,V0,V1,Cat,F,[M1|ML]),new_id(ID),
	asserta(Edge),write_arc(Edge),
	foreach(arc(InID,V1,V2,M1,_,[]),add_arc(arc(_,V0,V2,Cat,[InID|F],ML))).

% write_arc(+Edge)
write_arc(arc(ID,V1,V2,Category,Found,ToFind)):-
	write_list([ID,':<',V1,',',V2,'> ',Category,' --> ']),
	write_arc2(Found),write(' . '),write_arc2(ToFind),nl.
write_arc2([]).
write_arc2([A|L]):-write(A),tab(1),write_arc2(L).

% foreach(+X, +Y)
foreach(X,Y):-X,once(Y),fail.
foreach(_,_).

% new_id(-ID)
:-e_register(0,_,0).
new_id(Result):-
	e_register(0,LastID,LastID),
	Result is LastID + 1,
	e_register(0,LastID,Result).


write_arc(Sen):-
	arc(N,_,_,'文',T,[]),
	write_arc(T,0,Sen,Call),
	write(Sen),nl,
	write(N),tab(1),write('文'),nl,
	calls(Call),nl,fail.
write_arc(_):-!.

calls([]):-!.
calls([A|L]):-call(A),calls(L).

write_arc([],_,[],[]):-!.
write_arc([lex(W)],_,[],[]).
write_arc(A,Tab,SSen,Call):-
	arc(A,_,_,Cat,Tree,_),!,
%	tab(Tab),write_listnl([A,' ',Cat,' ',Tree]),
	( Tree = [lex(W)] -> 
	   SSen = [W] ,
	   Call =[tab(Tab),write_listnl([A,' ',Cat,' ',Tree])] ; 
	   write_arc(Tree,Tab,SSen,LCall),
	   Call = [tab(Tab),write_listnl([A,' ',Cat,' ',Tree])|LCall]
	 ).

write_arc([A|L],T,SSSen,CCCall):-
	TT is T + 1,
	write_arc(A,TT,Sen,Call),
	write_arc(L,T,SSen,CCall),
	append(SSen,Sen,SSSen),
	append(Call,CCall,CCCall),!.
	


% 句の定義
last_phrase(文).
phrase([名詞,動詞],動詞句).
phrase([名詞,名詞],名詞句).
phrase([名詞,助詞],名詞句).
phrase([名詞,接尾辞],名詞句).
phrase([名詞,助動詞],名詞句).
phrase([接頭辞,名詞],名詞句).
phrase([接頭辞,名詞句],名詞句).
phrase([動詞,名詞],名詞句).
phrase([動詞,代名詞],名詞句).
phrase([動詞,助動詞],動詞句).
phrase([動詞,助詞],動詞句).
phrase([代名詞,助詞],名詞句).
phrase([形容詞,名詞],名詞句).
phrase([形容詞,名詞句],名詞句).
phrase([形容詞,動詞],動詞句).
phrase([形容詞,助詞],形容詞句).
phrase([形容詞,連体詞],連体詞句).
phrase([形状詞,助詞],形容詞句).
phrase([連体詞,名詞],名詞句).
phrase([連体詞,代名詞],名詞句).
phrase([副詞,副詞],副詞句).
phrase([副詞,助詞],副詞句).
phrase([副詞,形容詞],形容詞句).
phrase([副詞,名詞],名詞句).
phrase([副詞,動詞],動詞句).

phrase([名詞句,助詞],名詞句).
phrase([名詞句,助動詞],名詞句).
phrase([名詞句,名詞],名詞句).
phrase([名詞句,名詞句],名詞句).
phrase([名詞句,動詞],動詞句).
phrase([名詞句,動詞句],動詞句).
phrase([名詞句,連体詞],連体詞句).
phrase([名詞句,形容詞],形容詞句).
phrase([名詞句,形容詞句],形容詞句).
phrase([名詞句,接尾辞],名詞句).
phrase([動詞句,名詞],名詞句).
phrase([動詞句,名詞句],名詞句).
phrase([動詞句,動詞],動詞句).
phrase([動詞句,代名詞],名詞句).
phrase([動詞句,助詞],動詞句).
phrase([動詞句,助動詞],動詞句).
phrase([動詞句,動詞句],動詞句).
phrase([副詞句,形容詞],形容詞句).
phrase([副詞句,名詞],名詞句).
phrase([副詞句,動詞],動詞句).
phrase([形容詞句,動詞],動詞句).

phrase([名詞句,動詞],文).
phrase([名詞句,動詞句],文).
phrase([名詞句,名詞],文).
phrase([名詞句,名詞句],文).
phrase([名詞句,助動詞],文).
phrase([名詞句,形容詞],文).
phrase([名詞句,形容詞句],文).
phrase([名詞句,接尾辞],文).
phrase([動詞句,動詞句],文).
phrase([動詞句,名詞],文).
phrase([動詞句,名詞句],文).
phrase([形容詞,名詞句],文).
phrase([連体詞,名詞],文).
phrase([連体詞句,名詞],文).
phrase([連体詞,代名詞],文).
phrase([連体詞句,代名詞],文).
phrase([副詞,名詞句],文).
phrase([副詞句,動詞句],文).

/*
||?-s_new,[-'jpn_bup_chart_parser.pl'],test.
1:<1,2> 名詞 --> lex(健)  .
2:<1,1> 動詞句 -->  . 名詞 動詞
3:<1,2> 動詞句 --> 1  . 動詞
4:<1,1> 名詞句 -->  . 名詞 名詞
5:<1,2> 名詞句 --> 1  . 名詞
6:<1,1> 名詞句 -->  . 名詞 助詞
7:<1,2> 名詞句 --> 1  . 助詞
8:<1,1> 名詞句 -->  . 名詞 接尾辞
9:<1,2> 名詞句 --> 1  . 接尾辞
10:<1,1> 名詞句 -->  . 名詞 助動詞
11:<1,2> 名詞句 --> 1  . 助動詞
Ignoring: 11:<1,2> 名詞句 --> 1  . 助動詞
Ignoring: 9:<1,2> 名詞句 --> 1  . 接尾辞
Ignoring: 7:<1,2> 名詞句 --> 1  . 助詞
Ignoring: 5:<1,2> 名詞句 --> 1  . 名詞
Ignoring: 3:<1,2> 動詞句 --> 1  . 動詞
12:<2,3> 助詞 --> lex(が)  .
13:<1,3> 名詞句 --> 12 1  .
14:<1,1> 名詞句 -->  . 名詞句 助詞
15:<1,3> 名詞句 --> 13  . 助詞
16:<1,1> 名詞句 -->  . 名詞句 助動詞
17:<1,3> 名詞句 --> 13  . 助動詞
18:<1,1> 名詞句 -->  . 名詞句 名詞
19:<1,3> 名詞句 --> 13  . 名詞
20:<1,1> 名詞句 -->  . 名詞句 名詞句
21:<1,3> 名詞句 --> 13  . 名詞句
22:<1,1> 動詞句 -->  . 名詞句 動詞
23:<1,3> 動詞句 --> 13  . 動詞
24:<1,1> 動詞句 -->  . 名詞句 動詞句
25:<1,3> 動詞句 --> 13  . 動詞句
26:<1,1> 連体詞句 -->  . 名詞句 連体詞
27:<1,3> 連体詞句 --> 13  . 連体詞
28:<1,1> 形容詞句 -->  . 名詞句 形容詞
29:<1,3> 形容詞句 --> 13  . 形容詞
30:<1,1> 形容詞句 -->  . 名詞句 形容詞句
31:<1,3> 形容詞句 --> 13  . 形容詞句
32:<1,1> 名詞句 -->  . 名詞句 接尾辞
33:<1,3> 名詞句 --> 13  . 接尾辞
34:<1,1> 文 -->  . 名詞句 動詞
35:<1,3> 文 --> 13  . 動詞
36:<1,1> 文 -->  . 名詞句 動詞句
37:<1,3> 文 --> 13  . 動詞句
38:<1,1> 文 -->  . 名詞句 名詞
39:<1,3> 文 --> 13  . 名詞
40:<1,1> 文 -->  . 名詞句 名詞句
41:<1,3> 文 --> 13  . 名詞句
42:<1,1> 文 -->  . 名詞句 助動詞
43:<1,3> 文 --> 13  . 助動詞
44:<1,1> 文 -->  . 名詞句 形容詞
45:<1,3> 文 --> 13  . 形容詞
46:<1,1> 文 -->  . 名詞句 形容詞句
47:<1,3> 文 --> 13  . 形容詞句
48:<1,1> 文 -->  . 名詞句 接尾辞
49:<1,3> 文 --> 13  . 接尾辞
Ignoring: 49:<1,3> 文 --> 13  . 接尾辞
Ignoring: 47:<1,3> 文 --> 13  . 形容詞句
Ignoring: 45:<1,3> 文 --> 13  . 形容詞
Ignoring: 43:<1,3> 文 --> 13  . 助動詞
Ignoring: 41:<1,3> 文 --> 13  . 名詞句
Ignoring: 39:<1,3> 文 --> 13  . 名詞
Ignoring: 37:<1,3> 文 --> 13  . 動詞句
Ignoring: 35:<1,3> 文 --> 13  . 動詞
Ignoring: 33:<1,3> 名詞句 --> 13  . 接尾辞
Ignoring: 31:<1,3> 形容詞句 --> 13  . 形容詞句
Ignoring: 29:<1,3> 形容詞句 --> 13  . 形容詞
Ignoring: 27:<1,3> 連体詞句 --> 13  . 連体詞
Ignoring: 25:<1,3> 動詞句 --> 13  . 動詞句
Ignoring: 23:<1,3> 動詞句 --> 13  . 動詞
Ignoring: 21:<1,3> 名詞句 --> 13  . 名詞句
Ignoring: 19:<1,3> 名詞句 --> 13  . 名詞
Ignoring: 17:<1,3> 名詞句 --> 13  . 助動詞
Ignoring: 15:<1,3> 名詞句 --> 13  . 助詞
50:<3,4> 名詞 --> lex(直美)  .
51:<3,3> 動詞句 -->  . 名詞 動詞
52:<3,4> 動詞句 --> 50  . 動詞
53:<3,3> 名詞句 -->  . 名詞 名詞
54:<3,4> 名詞句 --> 50  . 名詞
55:<3,3> 名詞句 -->  . 名詞 助詞
56:<3,4> 名詞句 --> 50  . 助詞
57:<3,3> 名詞句 -->  . 名詞 接尾辞
58:<3,4> 名詞句 --> 50  . 接尾辞
59:<3,3> 名詞句 -->  . 名詞 助動詞
60:<3,4> 名詞句 --> 50  . 助動詞
Ignoring: 60:<3,4> 名詞句 --> 50  . 助動詞
Ignoring: 58:<3,4> 名詞句 --> 50  . 接尾辞
Ignoring: 56:<3,4> 名詞句 --> 50  . 助詞
Ignoring: 54:<3,4> 名詞句 --> 50  . 名詞
Ignoring: 52:<3,4> 動詞句 --> 50  . 動詞
61:<1,4> 文 --> 50 13  .
62:<1,4> 名詞句 --> 50 13  .
Ignoring: 14:<1,1> 名詞句 -->  . 名詞句 助詞
Ignoring: 16:<1,1> 名詞句 -->  . 名詞句 助動詞
Ignoring: 18:<1,1> 名詞句 -->  . 名詞句 名詞
Ignoring: 20:<1,1> 名詞句 -->  . 名詞句 名詞句
Ignoring: 22:<1,1> 動詞句 -->  . 名詞句 動詞
Ignoring: 24:<1,1> 動詞句 -->  . 名詞句 動詞句
Ignoring: 26:<1,1> 連体詞句 -->  . 名詞句 連体詞
Ignoring: 28:<1,1> 形容詞句 -->  . 名詞句 形容詞
Ignoring: 30:<1,1> 形容詞句 -->  . 名詞句 形容詞句
Ignoring: 32:<1,1> 名詞句 -->  . 名詞句 接尾辞
Ignoring: 34:<1,1> 文 -->  . 名詞句 動詞
Ignoring: 36:<1,1> 文 -->  . 名詞句 動詞句
Ignoring: 38:<1,1> 文 -->  . 名詞句 名詞
Ignoring: 40:<1,1> 文 -->  . 名詞句 名詞句
Ignoring: 42:<1,1> 文 -->  . 名詞句 助動詞
Ignoring: 44:<1,1> 文 -->  . 名詞句 形容詞
Ignoring: 46:<1,1> 文 -->  . 名詞句 形容詞句
Ignoring: 48:<1,1> 文 -->  . 名詞句 接尾辞
63:<1,4> 文 --> 62  . 接尾辞
64:<1,4> 文 --> 62  . 形容詞句
65:<1,4> 文 --> 62  . 形容詞
66:<1,4> 文 --> 62  . 助動詞
67:<1,4> 文 --> 62  . 名詞句
68:<1,4> 文 --> 62  . 名詞
69:<1,4> 文 --> 62  . 動詞句
70:<1,4> 文 --> 62  . 動詞
71:<1,4> 名詞句 --> 62  . 接尾辞
72:<1,4> 形容詞句 --> 62  . 形容詞句
73:<1,4> 形容詞句 --> 62  . 形容詞
74:<1,4> 連体詞句 --> 62  . 連体詞
75:<1,4> 動詞句 --> 62  . 動詞句
76:<1,4> 動詞句 --> 62  . 動詞
77:<1,4> 名詞句 --> 62  . 名詞句
78:<1,4> 名詞句 --> 62  . 名詞
79:<1,4> 名詞句 --> 62  . 助動詞
80:<1,4> 名詞句 --> 62  . 助詞
81:<4,5> 助詞 --> lex(を)  .
82:<1,5> 名詞句 --> 81 62  .
Ignoring: 14:<1,1> 名詞句 -->  . 名詞句 助詞
Ignoring: 16:<1,1> 名詞句 -->  . 名詞句 助動詞
Ignoring: 18:<1,1> 名詞句 -->  . 名詞句 名詞
Ignoring: 20:<1,1> 名詞句 -->  . 名詞句 名詞句
Ignoring: 22:<1,1> 動詞句 -->  . 名詞句 動詞
Ignoring: 24:<1,1> 動詞句 -->  . 名詞句 動詞句
Ignoring: 26:<1,1> 連体詞句 -->  . 名詞句 連体詞
Ignoring: 28:<1,1> 形容詞句 -->  . 名詞句 形容詞
Ignoring: 30:<1,1> 形容詞句 -->  . 名詞句 形容詞句
Ignoring: 32:<1,1> 名詞句 -->  . 名詞句 接尾辞
Ignoring: 34:<1,1> 文 -->  . 名詞句 動詞
Ignoring: 36:<1,1> 文 -->  . 名詞句 動詞句
Ignoring: 38:<1,1> 文 -->  . 名詞句 名詞
Ignoring: 40:<1,1> 文 -->  . 名詞句 名詞句
Ignoring: 42:<1,1> 文 -->  . 名詞句 助動詞
Ignoring: 44:<1,1> 文 -->  . 名詞句 形容詞
Ignoring: 46:<1,1> 文 -->  . 名詞句 形容詞句
Ignoring: 48:<1,1> 文 -->  . 名詞句 接尾辞
83:<1,5> 文 --> 82  . 接尾辞
84:<1,5> 文 --> 82  . 形容詞句
85:<1,5> 文 --> 82  . 形容詞
86:<1,5> 文 --> 82  . 助動詞
87:<1,5> 文 --> 82  . 名詞句
88:<1,5> 文 --> 82  . 名詞
89:<1,5> 文 --> 82  . 動詞句
90:<1,5> 文 --> 82  . 動詞
91:<1,5> 名詞句 --> 82  . 接尾辞
92:<1,5> 形容詞句 --> 82  . 形容詞句
93:<1,5> 形容詞句 --> 82  . 形容詞
94:<1,5> 連体詞句 --> 82  . 連体詞
95:<1,5> 動詞句 --> 82  . 動詞句
96:<1,5> 動詞句 --> 82  . 動詞
97:<1,5> 名詞句 --> 82  . 名詞句
98:<1,5> 名詞句 --> 82  . 名詞
99:<1,5> 名詞句 --> 82  . 助動詞
100:<1,5> 名詞句 --> 82  . 助詞
101:<3,5> 名詞句 --> 81 50  .
102:<3,3> 名詞句 -->  . 名詞句 助詞
103:<3,5> 名詞句 --> 101  . 助詞
104:<3,3> 名詞句 -->  . 名詞句 助動詞
105:<3,5> 名詞句 --> 101  . 助動詞
106:<3,3> 名詞句 -->  . 名詞句 名詞
107:<3,5> 名詞句 --> 101  . 名詞
108:<3,3> 名詞句 -->  . 名詞句 名詞句
109:<3,5> 名詞句 --> 101  . 名詞句
110:<3,3> 動詞句 -->  . 名詞句 動詞
111:<3,5> 動詞句 --> 101  . 動詞
112:<3,3> 動詞句 -->  . 名詞句 動詞句
113:<3,5> 動詞句 --> 101  . 動詞句
114:<3,3> 連体詞句 -->  . 名詞句 連体詞
115:<3,5> 連体詞句 --> 101  . 連体詞
116:<3,3> 形容詞句 -->  . 名詞句 形容詞
117:<3,5> 形容詞句 --> 101  . 形容詞
118:<3,3> 形容詞句 -->  . 名詞句 形容詞句
119:<3,5> 形容詞句 --> 101  . 形容詞句
120:<3,3> 名詞句 -->  . 名詞句 接尾辞
121:<3,5> 名詞句 --> 101  . 接尾辞
122:<3,3> 文 -->  . 名詞句 動詞
123:<3,5> 文 --> 101  . 動詞
124:<3,3> 文 -->  . 名詞句 動詞句
125:<3,5> 文 --> 101  . 動詞句
126:<3,3> 文 -->  . 名詞句 名詞
127:<3,5> 文 --> 101  . 名詞
128:<3,3> 文 -->  . 名詞句 名詞句
129:<3,5> 文 --> 101  . 名詞句
130:<3,3> 文 -->  . 名詞句 助動詞
131:<3,5> 文 --> 101  . 助動詞
132:<3,3> 文 -->  . 名詞句 形容詞
133:<3,5> 文 --> 101  . 形容詞
134:<3,3> 文 -->  . 名詞句 形容詞句
135:<3,5> 文 --> 101  . 形容詞句
136:<3,3> 文 -->  . 名詞句 接尾辞
137:<3,5> 文 --> 101  . 接尾辞
Ignoring: 137:<3,5> 文 --> 101  . 接尾辞
Ignoring: 135:<3,5> 文 --> 101  . 形容詞句
Ignoring: 133:<3,5> 文 --> 101  . 形容詞
Ignoring: 131:<3,5> 文 --> 101  . 助動詞
Ignoring: 129:<3,5> 文 --> 101  . 名詞句
Ignoring: 127:<3,5> 文 --> 101  . 名詞
Ignoring: 125:<3,5> 文 --> 101  . 動詞句
Ignoring: 123:<3,5> 文 --> 101  . 動詞
Ignoring: 121:<3,5> 名詞句 --> 101  . 接尾辞
Ignoring: 119:<3,5> 形容詞句 --> 101  . 形容詞句
Ignoring: 117:<3,5> 形容詞句 --> 101  . 形容詞
Ignoring: 115:<3,5> 連体詞句 --> 101  . 連体詞
Ignoring: 113:<3,5> 動詞句 --> 101  . 動詞句
Ignoring: 111:<3,5> 動詞句 --> 101  . 動詞
Ignoring: 109:<3,5> 名詞句 --> 101  . 名詞句
Ignoring: 107:<3,5> 名詞句 --> 101  . 名詞
Ignoring: 105:<3,5> 名詞句 --> 101  . 助動詞
Ignoring: 103:<3,5> 名詞句 --> 101  . 助詞
138:<1,5> 文 --> 101 13  .
139:<1,5> 名詞句 --> 101 13  .
Ignoring: 14:<1,1> 名詞句 -->  . 名詞句 助詞
Ignoring: 16:<1,1> 名詞句 -->  . 名詞句 助動詞
Ignoring: 18:<1,1> 名詞句 -->  . 名詞句 名詞
Ignoring: 20:<1,1> 名詞句 -->  . 名詞句 名詞句
Ignoring: 22:<1,1> 動詞句 -->  . 名詞句 動詞
Ignoring: 24:<1,1> 動詞句 -->  . 名詞句 動詞句
Ignoring: 26:<1,1> 連体詞句 -->  . 名詞句 連体詞
Ignoring: 28:<1,1> 形容詞句 -->  . 名詞句 形容詞
Ignoring: 30:<1,1> 形容詞句 -->  . 名詞句 形容詞句
Ignoring: 32:<1,1> 名詞句 -->  . 名詞句 接尾辞
Ignoring: 34:<1,1> 文 -->  . 名詞句 動詞
Ignoring: 36:<1,1> 文 -->  . 名詞句 動詞句
Ignoring: 38:<1,1> 文 -->  . 名詞句 名詞
Ignoring: 40:<1,1> 文 -->  . 名詞句 名詞句
Ignoring: 42:<1,1> 文 -->  . 名詞句 助動詞
Ignoring: 44:<1,1> 文 -->  . 名詞句 形容詞
Ignoring: 46:<1,1> 文 -->  . 名詞句 形容詞句
Ignoring: 48:<1,1> 文 -->  . 名詞句 接尾辞
140:<1,5> 文 --> 139  . 接尾辞
141:<1,5> 文 --> 139  . 形容詞句
142:<1,5> 文 --> 139  . 形容詞
143:<1,5> 文 --> 139  . 助動詞
144:<1,5> 文 --> 139  . 名詞句
145:<1,5> 文 --> 139  . 名詞
146:<1,5> 文 --> 139  . 動詞句
147:<1,5> 文 --> 139  . 動詞
148:<1,5> 名詞句 --> 139  . 接尾辞
149:<1,5> 形容詞句 --> 139  . 形容詞句
150:<1,5> 形容詞句 --> 139  . 形容詞
151:<1,5> 連体詞句 --> 139  . 連体詞
152:<1,5> 動詞句 --> 139  . 動詞句
153:<1,5> 動詞句 --> 139  . 動詞
154:<1,5> 名詞句 --> 139  . 名詞句
155:<1,5> 名詞句 --> 139  . 名詞
156:<1,5> 名詞句 --> 139  . 助動詞
157:<1,5> 名詞句 --> 139  . 助詞
158:<5,6> 動詞 --> lex(愛する)  .
159:<5,5> 名詞句 -->  . 動詞 名詞
160:<5,6> 名詞句 --> 158  . 名詞
161:<5,5> 名詞句 -->  . 動詞 代名詞
162:<5,6> 名詞句 --> 158  . 代名詞
163:<5,5> 動詞句 -->  . 動詞 助動詞
164:<5,6> 動詞句 --> 158  . 助動詞
165:<5,5> 動詞句 -->  . 動詞 助詞
166:<5,6> 動詞句 --> 158  . 助詞
Ignoring: 166:<5,6> 動詞句 --> 158  . 助詞
Ignoring: 164:<5,6> 動詞句 --> 158  . 助動詞
Ignoring: 162:<5,6> 名詞句 --> 158  . 代名詞
Ignoring: 160:<5,6> 名詞句 --> 158  . 名詞
167:<1,6> 動詞句 --> 158 139  .
168:<1,1> 名詞句 -->  . 動詞句 名詞
169:<1,6> 名詞句 --> 167  . 名詞
170:<1,1> 名詞句 -->  . 動詞句 名詞句
171:<1,6> 名詞句 --> 167  . 名詞句
172:<1,1> 動詞句 -->  . 動詞句 動詞
173:<1,6> 動詞句 --> 167  . 動詞
174:<1,1> 名詞句 -->  . 動詞句 代名詞
175:<1,6> 名詞句 --> 167  . 代名詞
176:<1,1> 動詞句 -->  . 動詞句 助詞
177:<1,6> 動詞句 --> 167  . 助詞
178:<1,1> 動詞句 -->  . 動詞句 助動詞
179:<1,6> 動詞句 --> 167  . 助動詞
180:<1,1> 動詞句 -->  . 動詞句 動詞句
181:<1,6> 動詞句 --> 167  . 動詞句
182:<1,1> 文 -->  . 動詞句 動詞句
183:<1,6> 文 --> 167  . 動詞句
184:<1,1> 文 -->  . 動詞句 名詞
185:<1,6> 文 --> 167  . 名詞
186:<1,1> 文 -->  . 動詞句 名詞句
187:<1,6> 文 --> 167  . 名詞句
Ignoring: 187:<1,6> 文 --> 167  . 名詞句
Ignoring: 185:<1,6> 文 --> 167  . 名詞
Ignoring: 183:<1,6> 文 --> 167  . 動詞句
Ignoring: 181:<1,6> 動詞句 --> 167  . 動詞句
Ignoring: 179:<1,6> 動詞句 --> 167  . 助動詞
Ignoring: 177:<1,6> 動詞句 --> 167  . 助詞
Ignoring: 175:<1,6> 名詞句 --> 167  . 代名詞
Ignoring: 173:<1,6> 動詞句 --> 167  . 動詞
Ignoring: 171:<1,6> 名詞句 --> 167  . 名詞句
Ignoring: 169:<1,6> 名詞句 --> 167  . 名詞
188:<1,6> 文 --> 158 139  .
189:<3,6> 文 --> 158 101  .
190:<3,6> 動詞句 --> 158 101  .
191:<3,3> 名詞句 -->  . 動詞句 名詞
192:<3,6> 名詞句 --> 190  . 名詞
193:<3,3> 名詞句 -->  . 動詞句 名詞句
194:<3,6> 名詞句 --> 190  . 名詞句
195:<3,3> 動詞句 -->  . 動詞句 動詞
196:<3,6> 動詞句 --> 190  . 動詞
197:<3,3> 名詞句 -->  . 動詞句 代名詞
198:<3,6> 名詞句 --> 190  . 代名詞
199:<3,3> 動詞句 -->  . 動詞句 助詞
200:<3,6> 動詞句 --> 190  . 助詞
201:<3,3> 動詞句 -->  . 動詞句 助動詞
202:<3,6> 動詞句 --> 190  . 助動詞
203:<3,3> 動詞句 -->  . 動詞句 動詞句
204:<3,6> 動詞句 --> 190  . 動詞句
205:<3,3> 文 -->  . 動詞句 動詞句
206:<3,6> 文 --> 190  . 動詞句
207:<3,3> 文 -->  . 動詞句 名詞
208:<3,6> 文 --> 190  . 名詞
209:<3,3> 文 -->  . 動詞句 名詞句
210:<3,6> 文 --> 190  . 名詞句
Ignoring: 210:<3,6> 文 --> 190  . 名詞句
Ignoring: 208:<3,6> 文 --> 190  . 名詞
Ignoring: 206:<3,6> 文 --> 190  . 動詞句
Ignoring: 204:<3,6> 動詞句 --> 190  . 動詞句
Ignoring: 202:<3,6> 動詞句 --> 190  . 助動詞
Ignoring: 200:<3,6> 動詞句 --> 190  . 助詞
Ignoring: 198:<3,6> 名詞句 --> 190  . 代名詞
Ignoring: 196:<3,6> 動詞句 --> 190  . 動詞
Ignoring: 194:<3,6> 名詞句 --> 190  . 名詞句
Ignoring: 192:<3,6> 名詞句 --> 190  . 名詞
211:<1,6> 文 --> 190 13  .
212:<1,6> 動詞句 --> 190 13  .
Ignoring: 168:<1,1> 名詞句 -->  . 動詞句 名詞
Ignoring: 170:<1,1> 名詞句 -->  . 動詞句 名詞句
Ignoring: 172:<1,1> 動詞句 -->  . 動詞句 動詞
Ignoring: 174:<1,1> 名詞句 -->  . 動詞句 代名詞
Ignoring: 176:<1,1> 動詞句 -->  . 動詞句 助詞
Ignoring: 178:<1,1> 動詞句 -->  . 動詞句 助動詞
Ignoring: 180:<1,1> 動詞句 -->  . 動詞句 動詞句
Ignoring: 182:<1,1> 文 -->  . 動詞句 動詞句
Ignoring: 184:<1,1> 文 -->  . 動詞句 名詞
Ignoring: 186:<1,1> 文 -->  . 動詞句 名詞句
213:<1,6> 文 --> 212  . 名詞句
214:<1,6> 文 --> 212  . 名詞
215:<1,6> 文 --> 212  . 動詞句
216:<1,6> 動詞句 --> 212  . 動詞句
217:<1,6> 動詞句 --> 212  . 助動詞
218:<1,6> 動詞句 --> 212  . 助詞
219:<1,6> 名詞句 --> 212  . 代名詞
220:<1,6> 動詞句 --> 212  . 動詞
221:<1,6> 名詞句 --> 212  . 名詞句
222:<1,6> 名詞句 --> 212  . 名詞
223:<1,6> 動詞句 --> 158 82  .
Ignoring: 168:<1,1> 名詞句 -->  . 動詞句 名詞
Ignoring: 170:<1,1> 名詞句 -->  . 動詞句 名詞句
Ignoring: 172:<1,1> 動詞句 -->  . 動詞句 動詞
Ignoring: 174:<1,1> 名詞句 -->  . 動詞句 代名詞
Ignoring: 176:<1,1> 動詞句 -->  . 動詞句 助詞
Ignoring: 178:<1,1> 動詞句 -->  . 動詞句 助動詞
Ignoring: 180:<1,1> 動詞句 -->  . 動詞句 動詞句
Ignoring: 182:<1,1> 文 -->  . 動詞句 動詞句
Ignoring: 184:<1,1> 文 -->  . 動詞句 名詞
Ignoring: 186:<1,1> 文 -->  . 動詞句 名詞句
224:<1,6> 文 --> 223  . 名詞句
225:<1,6> 文 --> 223  . 名詞
226:<1,6> 文 --> 223  . 動詞句
227:<1,6> 動詞句 --> 223  . 動詞句
228:<1,6> 動詞句 --> 223  . 助動詞
229:<1,6> 動詞句 --> 223  . 助詞
230:<1,6> 名詞句 --> 223  . 代名詞
231:<1,6> 動詞句 --> 223  . 動詞
232:<1,6> 名詞句 --> 223  . 名詞句
233:<1,6> 名詞句 --> 223  . 名詞
234:<1,6> 文 --> 158 82  .
Found parse: Edge #234
Found parse: Edge #211
Found parse: Edge #188
yes
*/
