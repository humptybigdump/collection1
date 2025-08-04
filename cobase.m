getCobase::usage="syntax {cobas1, cobas2, cobas3} = getCobase[ bas1, bas2, bas3]; being given   3 base vectors  calculates  3 cobase vectors " ;
getCovariantTransformation::usage="syntax   \n A33  = getCovariantTransformation[ {From1,From2,From3}, {to1,to2,to3}]; \n takes 'from' and 'to' basis vectoren and returns the covariant transformation matrix. \n The upper index is the second one, i.e.  A33_i^j "  ;
getContravariantTransformation::usage="syntax   \n B33  = getContravariantTransformation[{From1,From2,From3},{to1,to2,to3}]; \n takes 'from' and 'to' basis vectoren and returns the contravariant transformation matrix. \n The upper index is the second one , i.e.  B33_i^j  " ;
getGLL::usage = "syntax  \n gg = getGLL[{g1,g2,g3}] \n  takes basis vectors (with lower indices) and returns metric matrix (with lower indices g_{ij} )"  ;
getGHH::usage = "syntax  \n gg = getGHH[{g1,g2,g3}] \n  takes basis vectors (with lower indices) and returns reciprocal metric matrix (with upper indices g^{ij) } " ;
contract::usage ="1.syntax \n contract[ic, jc, aList, bList] \n multiplication with a single contraction over ic-th index in aList and jc-th index in bList \n2.syntax \n contract[ic, jc, aList] \n returns what remains of aList after contraction of ic-th and  j-th indices ";


getCobase[ {a1_List, a2_List, a3_List}] := Module[{gg,ggi,b1,b2,b3},
                   gg = {{a1.a1, a1.a2, a1.a3},{a2.a1, a2.a2, a2.a3}, {a3.a1, a3.a2, a3.a3}};
                   ggi = Inverse[gg];
                   {ggi[[1,1]]*a1+ ggi[[1,2]]*a2 +  ggi[[1,3]] a3,
                    ggi[[2,1]]*a1+ ggi[[2,2]]*a2  + ggi[[2,3]] a3,
                    ggi[[3,1]]*a1+ ggi[[3,2]]*a2  + ggi[[3,3]] a3}
];

getCovariantTransformation[ {G1_List, G2_List, G3_List}, {g1_List , g2_List, g3_List} ] := Module[{C1,C2,C3  },
                                  {C1,C2,C3} = getCobase[ {G1 , G2 , G3 }]  ;
                                  {{g1.C1,g1.C2,g1.C3},
                                   {g2.C1,g2.C2,g2.C3},
                                   {g3.C1,g3.C2,g3.C3}}
                           ];
getContravariantTransformation[ {G1_List, G2_List, G3_List}, {g1_List , g2_List, g3_List} ] := Module[{c1,c2,c3  },
                                    {c1,c2,c3} = getCobase[{g1,g2,g3}]  ;
                                    {{G1.c1,G1.c2,G1.c3},
                                     {G2.c1,G2.c2,G2.c3},
                                     {G3.c1,G3.c2,G3.c3}}
                                  ];

getGLL[ {a1_List, a2_List, a3_List}] := Module[{xLocal},
                   {{a1.a1, a1.a2, a1.a3},{a2.a1, a2.a2, a2.a3}, {a3.a1, a3.a2, a3.a3}}
                  ];

getGHH[ {a1_List, a2_List, a3_List}] := Module[{b1,b2,b3},
                   {b1,b2,b3} = getCobase[{a1,a2,a3}]  ;
                   {{b1.b1, b1.b2, b1.b3},{b2.b1, b2.b2, b2.b3}, {b3.b1, b3.b2, b3.b3}}
                  ];

contract[ic_, jc_, a_List, b_List] :=   Module[{adim, bdim, fullout },
                                                adim = Dimensions[a]; bdim=Dimensions[b];
                                                If[ic < 1 || jc < 1, Print[ "cannot contract a nonpositive index " ]; Return[]; ];
                                                If[ic > Length[adim] || jc > Length[bdim],
                                                                     Print[ "at least contract index is out of range" ]; Return[]; ];
                                                If[adim[ic] != bdim[jc],
                                                                     Print[ "cannot contract, incompatible sizes" ]; Return[]; ];
                                                fullout = Outer[Times, a, b] ;
                                                contract[ic, Length[adim] + jc, fullout]
                                                ];


contract[ic_, jc_, a_List] :=   Module[{adim, adim2, n, i,nsum,w } ,
                                      adim = Dimensions[a]; n = ArrayDepth[a]; nsum=adim[[ic]];
                                      If[ic < 1 || jc < 1, Print[ " cannot contract item: a nonpositive index " ]; Return[]; ];
                                      If[ ic ==  jc,  Print[ "contraction indices must be different" ]; Return[]; ];
                                      If[ adim[[ic]] != adim[[jc]],   Print[ "cannot contract item: incompatible sizes" ]; Return[]; ];
                                      If[ n >  8,  Print[ "Rank of contracted item  should be <= 8 in this implementation" ]; Return[]; ];

                                      If[ ic > jc , {ic, jc } = {jc, ic} ] ;
                                      (* 2 *)
                                      If[ n == 2 &&  ic==1 && jc==2, w = Sum[ a[[i,i]],{i,1,nsum}] ]     ;
                                      (* 3 *)
                                      If[ n == 3 &&  ic==1 && jc==2, w = Sum[ a[[i,i,All]],{i,1,nsum}] ] ;
                                      If[ n == 3 &&  ic==1 && jc==3, w = Sum[ a[[i,All,i]],{i,1,nsum}] ] ;
                                      If[ n == 3 &&  ic==2 && jc==3, w = Sum[ a[[All,i,i]],{i,1,nsum}] ] ;
                                      (* 4 *)
                                      If[ n == 4 &&  ic==1 && jc==2, w = Sum[ a[[i,i,All,All]],{i,1,nsum}] ]  ;
                                      If[ n == 4 &&  ic==1 && jc==3, w = Sum[ a[[i,All,i,All]],{i,1,nsum}] ]  ;
                                      If[ n == 4 &&  ic==1 && jc==4, w = Sum[ a[[i,All,All,i]],{i,1,nsum}] ]  ;
                                      If[ n == 4 &&  ic==2 && jc==3, w = Sum[ a[[All,i,i,All]],{i,1,nsum}] ]  ;
                                      If[ n == 4 &&  ic==2 && jc==4, w = Sum[ a[[All,i,All,i]],{i,1,nsum}] ]  ;
                                      If[ n == 4 &&  ic==3 && jc==4, w = Sum[ a[[All,All,i,i]],{i,1,nsum}] ]  ;
                                      (* 5 *)
                                      If[ n == 5 &&  ic==1 && jc==2, w = Sum[ a[[i,i,All,All,All]],{i,1,nsum}] ]  ;
                                      If[ n == 5 &&  ic==1 && jc==3, w = Sum[ a[[i,All,i,All,All]],{i,1,nsum}] ]  ;
                                      If[ n == 5 &&  ic==1 && jc==4, w = Sum[ a[[i,All,All,i,All]],{i,1,nsum}] ]  ;
                                      If[ n == 5 &&  ic==1 && jc==5, w = Sum[ a[[i,All,All,All,i]],{i,1,nsum}] ]  ;
                                      If[ n == 5 &&  ic==2 && jc==3, w = Sum[ a[[All,i,i,All,All]],{i,1,nsum}] ]  ;
                                      If[ n == 5 &&  ic==2 && jc==4, w = Sum[ a[[All,i,All,i,All]],{i,1,nsum}] ]  ;
                                      If[ n == 5 &&  ic==2 && jc==5, w = Sum[ a[[All,i,All,All,i]],{i,1,nsum}] ]  ;
                                      If[ n == 5 &&  ic==3 && jc==4, w = Sum[ a[[All,All,i,i,All]],{i,1,nsum}] ]  ;
                                      If[ n == 5 &&  ic==3 && jc==5, w = Sum[ a[[All,All,i,All,i]],{i,1,nsum}] ]  ;
                                      If[ n == 5 &&  ic==4 && jc==5, w = Sum[ a[[All,All,All,i,i]],{i,1,nsum}] ]  ;
                                      (* 6 *)
                                      If[ n == 6 &&  ic==1 && jc==2, w = Sum[ a[[i,i,All,All,All,All]],{i,1,nsum}] ]  ;
                                      If[ n == 6 &&  ic==1 && jc==3, w = Sum[ a[[i,All,i,All,All,All]],{i,1,nsum}] ]  ;
                                      If[ n == 6 &&  ic==1 && jc==4, w = Sum[ a[[i,All,All,i,All,All]],{i,1,nsum}] ]  ;
                                      If[ n == 6 &&  ic==1 && jc==5, w = Sum[ a[[i,All,All,All,i,All]],{i,1,nsum}] ]  ;
                                      If[ n == 6 &&  ic==1 && jc==6, w = Sum[ a[[i,All,All,All,All,i]],{i,1,nsum}] ]  ;
                                      If[ n == 6 &&  ic==2 && jc==3, w = Sum[ a[[All,i,i,All,All,All]],{i,1,nsum}] ]  ;
                                      If[ n == 6 &&  ic==2 && jc==4, w = Sum[ a[[All,i,All,i,All,All]],{i,1,nsum}] ]  ;
                                      If[ n == 6 &&  ic==2 && jc==5, w = Sum[ a[[All,i,All,All,i,All]],{i,1,nsum}] ]  ;
                                      If[ n == 6 &&  ic==2 && jc==6, w = Sum[ a[[All,i,All,All,All,i]],{i,1,nsum}] ]  ;
                                      If[ n == 6 &&  ic==3 && jc==4, w = Sum[ a[[All,All,i,i,All,All]],{i,1,nsum}] ]  ;
                                      If[ n == 6 &&  ic==3 && jc==5, w = Sum[ a[[All,All,i,All,i,All]],{i,1,nsum}] ]  ;
                                      If[ n == 6 &&  ic==3 && jc==6, w = Sum[ a[[All,All,i,All,All,i]],{i,1,nsum}] ]  ;
                                      If[ n == 6 &&  ic==4 && jc==5, w = Sum[ a[[All,All,All,i,i,All]],{i,1,nsum}] ]  ;
                                      If[ n == 6 &&  ic==4 && jc==6, w = Sum[ a[[All,All,All,i,All,i]],{i,1,nsum}] ]  ;
                                      If[ n == 6 &&  ic==5 && jc==6, w = Sum[ a[[All,All,All,All,i,i]],{i,1,nsum}] ]  ;


                                       (* 7 *)
                                      If[ n == 7 &&  ic==1 && jc==2, w = Sum[ a[[i,i,All,All,All,All,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 7 &&  ic==1 && jc==3, w = Sum[ a[[i,All,i,All,All,All,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 7 &&  ic==1 && jc==4, w = Sum[ a[[i,All,All,i,All,All,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 7 &&  ic==1 && jc==5, w = Sum[ a[[i,All,All,All,i,All,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 7 &&  ic==1 && jc==6, w = Sum[ a[[i,All,All,All,All,i,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 7 &&  ic==1 && jc==7, w = Sum[ a[[i,All,All,All,All,All,i ]],{i,1,nsum}] ]  ;
                                      If[ n == 7 &&  ic==2 && jc==3, w = Sum[ a[[All,i,i,All,All,All,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 7 &&  ic==2 && jc==4, w = Sum[ a[[All,i,All,i,All,All,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 7 &&  ic==2 && jc==5, w = Sum[ a[[All,i,All,All,i,All,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 7 &&  ic==2 && jc==6, w = Sum[ a[[All,i,All,All,All,i,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 7 &&  ic==2 && jc==7, w = Sum[ a[[All,i,All,All,All,All,i ]],{i,1,nsum}] ]  ;
                                      If[ n == 7 &&  ic==3 && jc==4, w = Sum[ a[[All,All,i,i,All,All,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 7 &&  ic==3 && jc==5, w = Sum[ a[[All,All,i,All,i,All,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 7 &&  ic==3 && jc==6, w = Sum[ a[[All,All,i,All,All,i,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 7 &&  ic==3 && jc==7, w = Sum[ a[[All,All,i,All,All,All,i ]],{i,1,nsum}] ]  ;
                                      If[ n == 7 &&  ic==4 && jc==5, w = Sum[ a[[All,All,All,i,i,All,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 7 &&  ic==4 && jc==6, w = Sum[ a[[All,All,All,i,All,i,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 7 &&  ic==4 && jc==7, w = Sum[ a[[All,All,All,i,All,All,i ]],{i,1,nsum}] ]  ;
                                      If[ n == 7 &&  ic==5 && jc==6, w = Sum[ a[[All,All,All,All,i,i,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 7 &&  ic==5 && jc==7, w = Sum[ a[[All,All,All,All,i,All,i ]],{i,1,nsum}] ]  ;
                                      If[ n == 7 &&  ic==6 && jc==7, w = Sum[ a[[All,All,All,All,All,i,i ]],{i,1,nsum}] ]  ;

                                       (* 8 *)
                                      If[ n == 8 &&  ic==1 && jc==2, w = Sum[ a[[i,i,All,All,All,All,All,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 8 &&  ic==1 && jc==3, w = Sum[ a[[i,All,i,All,All,All,All,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 8 &&  ic==1 && jc==4, w = Sum[ a[[i,All,All,i,All,All,All,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 8 &&  ic==1 && jc==5, w = Sum[ a[[i,All,All,All,i,All,All,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 8 &&  ic==1 && jc==6, w = Sum[ a[[i,All,All,All,All,i,All,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 8 &&  ic==1 && jc==7, w = Sum[ a[[i,All,All,All,All,All,i,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 8 &&  ic==1 && jc==8, w = Sum[ a[[i,All,All,All,All,All,All,i ]],{i,1,nsum}] ]  ;
                                      If[ n == 8 &&  ic==2 && jc==3, w = Sum[ a[[All,i,i,All,All,All,All,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 8 &&  ic==2 && jc==4, w = Sum[ a[[All,i,All,i,All,All,All,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 8 &&  ic==2 && jc==5, w = Sum[ a[[All,i,All,All,i,All,All,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 8 &&  ic==2 && jc==6, w = Sum[ a[[All,i,All,All,All,i,All,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 8 &&  ic==2 && jc==7, w = Sum[ a[[All,i,All,All,All,All,i,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 8 &&  ic==2 && jc==8, w = Sum[ a[[All,i,All,All,All,All,All,i ]],{i,1,nsum}] ]  ;
                                      If[ n == 8 &&  ic==3 && jc==4, w = Sum[ a[[All,All,i,i,All,All,All,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 8 &&  ic==3 && jc==5, w = Sum[ a[[All,All,i,All,i,All,All,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 8 &&  ic==3 && jc==6, w = Sum[ a[[All,All,i,All,All,i,All,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 8 &&  ic==3 && jc==7, w = Sum[ a[[All,All,i,All,All,All,i,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 8 &&  ic==3 && jc==8, w = Sum[ a[[All,All,i,All,All,All,All,i ]],{i,1,nsum}] ]  ;
                                      If[ n == 8 &&  ic==4 && jc==5, w = Sum[ a[[All,All,All,i,i,All,All,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 8 &&  ic==4 && jc==6, w = Sum[ a[[All,All,All,i,All,i,All,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 8 &&  ic==4 && jc==7, w = Sum[ a[[All,All,All,i,All,All,i,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 8 &&  ic==4 && jc==8, w = Sum[ a[[All,All,All,i,All,All,All,i ]],{i,1,nsum}] ]  ;
                                      If[ n == 8 &&  ic==5 && jc==6, w = Sum[ a[[All,All,All,All,i,i,All,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 8 &&  ic==5 && jc==7, w = Sum[ a[[All,All,All,All,i,All,i,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 8 &&  ic==5 && jc==8, w = Sum[ a[[All,All,All,All,i,All,All,i ]],{i,1,nsum}] ]  ;
                                      If[ n == 8 &&  ic==6 && jc==7, w = Sum[ a[[All,All,All,All,All,i,i,All ]],{i,1,nsum}] ]  ;
                                      If[ n == 8 &&  ic==6 && jc==8, w = Sum[ a[[All,All,All,All,All,i,All,i ]],{i,1,nsum}] ]  ;
                                      If[ n == 8 &&  ic==7 && jc==8, w = Sum[ a[[All,All,All,All,All,All,i,i ]],{i,1,nsum}] ]  ;

                                      w
                                      ];






aa = {{1,2},{3,5}}; bb = {7,9,4};  mm = Outer[Times, aa,bb,aa]; contractItem[1, 2, mm]


(*
vstretchF[la_]:= {{1,0,0},{0,1+la,0},{0,0,1}};
hstrechF[la_] := {{1+la,0,0},{0,1,0},{0,0,1}};
hshearF[la_] :=  {{1,la,0},{0,1,0},{0,0,1}};
vshearF[la_] :=  {{1,0,0},{la,0,0},{0,0,1}};
*)



(*przyklad (wszystkie skladowe w prabazie kartezjanskiej) *)

a1 = {1/10 , 1, 1/10 }; a2 = {1 , 1/10,  1/10}; a3 = {1/10, 1/10, 1} ; coordSystem1 = {a1,a2,a3};
a4 = {2/10 , 8/10, 0}; a5 = {12/10 , 2/10, 0} ;  a6 = {0 , 0, 1}     ; coordSystem2 = {a4,a5,a6};

{b1, b2, b3} =  getCobase[ coordSystem1 ]   (*pierwsza baza i kobaza*)
{b4, b5, b6} =  getCobase[ coordSystem2 ]   (*druga baza i kobaza *)

(* MatrixForm[Outer[Times, a1, b1] + Outer[Times, a2, b2] + Outer[Times, a3, b3]]           sumowanie po numerach wektorow bazowch*)
(* MatrixForm[{{a1.b1, a1.b2, a1.b3},  {a2.b1, a2.b2, a2.b3},  {a3.b1, a3.b2,  a3.b3}}]   sumowanie po wyrazach wektorow bazowch*)



