(* ::Package:: *)

(*  Rules  for  tensors in form of 3x3 arrays.  By A. Niemunis

Installation:
1) go to the directory shown by the Mathematica's  global variable $UserBaseDirectory.   It should be something like
   C:\Dokumente und Einstellungen\xxx\Anwendungsdaten\Mathematica\   or   C:\Windows\xxx\Application Data\Mathematica\
   where 'xxx' is your user name  under windows
2) go deeper to the subdirectory \Applications\ and make a new directory  Tensor there
3) copy this file (= bnova.m) to the new directory.
4) Begin a Mathematica session with:    Needs["Tensor`bnova`"]

   
   2020:        voigt-conversion  convert,  convertCart2Spher ... for change of coordinate system 
   11.08.2020   projOn, restprojOn,  different cross aniso xA,   st33 with random numbers,  
   11.08.2020  stressResponse3Dstar and ..responsePstarQstar  for anisotropic mat,  coaxialQ, axisymm23Q, externalHashProduct, doubleCrossProduct  hausholderMatrix  
   11.08.2020  hausholderMatrix, givensRotate, vectorQ, squareMQ, symmMQ
   02.01.2022 getXAniso repaired n -> 1/n 
   07.09.2022 isoPQ extended, plotCircleT, plotCircleL   
  18.09.2022 getStrain and getStressDiv for Spherical and Cylindrical coordinates added (with symmetry rules) 
  27.09.2022 added tensorial3[] = extended version of tensorial[] 
  05.10.2022 added: componentwise, where , symbolVariables, makeList
  19.10.2022 added rotationTensorInverse 
  25.10.2022 added solveLinear99 for mixed control and small symmetries 
  14.4.2023 addes replaceSubexpr by Jon McLoone 
 *)

BeginPackage["Tensor`bnova`"]



solveLinear99::usage=" syntax {u,rhs} = solveLinear99[ K_?t3333Q ,u_?t33Q, rhs_?t33Q , ifu_, OptionsPattern[] ] ;  
                        Solves a linear system of equations K : u = rhs  with unknowns on both sides, that is 
                        the unknown are components of u and complementary components of rhs.  
                        solveLinear99 can handle singularities in K due to small symmetries. 
ARGUMENTS: K_?t3333Q  = stiffness tensor usually jacobiMatrix 
           u_?t33Q,    = strain tensor  (numerical input only)
           rhs_?t33Q   = stress tensor  (numerical input only)
            ifu        = a 3x3 matrix with True where u is prescribed   
OPTIONS:  verbose -> False  
OUTPUT: {u33solve, rhs33solve } full numerical tensors that satisfy the equation    
";

replaceSubexpr::usage=" {simplifiedExpr, rules} = replaceSubexpr[{expr_, {}}, n_Integer, leaf_Integer] 
   find n repeated subexpressions in the expr and replaces them by a symbol. 
 ARGUMENTS: 
  expr = expression to be simplified using unique variable names 
  n    = number of subexpressions to be find 
  leaf = the minimum number of indivisible components inside the subexpressions 
OUTPUT: 
 simplifiedExpr    containing new variable names for subexpression 
 rules     converting variable names to subexpressions i.e. simplifiedExpr //. rules gives the original expr
 ";


hausholderMatrix::usage=" hausholderMatrix[from, to] returns the reflection matrix from from to to (possibly with scaling)"; 

givensRotate::usage=" Syntax 1:  givensRotate[a] finds  maximum off-diagonal element in a and returns Givens-rotated a. 
                      Syntax 2: givensRotate[a,p,q] returns Givens-rotated a after which  a\[LeftDoubleBracket]p,q\[RightDoubleBracket] = a\[LeftDoubleBracket]q,p\[RightDoubleBracket] = 0 " ; 

coaxialQ::usage="coaxialQ[a ,  b] test of coaxiality via comutativity a.b = b.a  wherein a,b are t33 or t3333   " ;
axisymm23Q::usage="axisymm23Q[aa]   axial symmetry query,  t33 should  have the form diag(a,b,b)" ;
projOn::usage="projOn[a , b  ] returns projection of a onto the direction of b.  Both a and b are of type t3, t33, t333 or t3333 ";
restprojOn::usage="  restprojOn[a , b  ] returns the rest of a after projection of a onto the direction of b. Both  a and b are of type   t3, t33, t333 or t3333
                     restprojOn[a , b , c] returns the rest of a after projection of a onto the plane spanned by b and c (not necessarily orthogonal) 
                      All three arguments a,b,c  must be of the same type t3, t33, t333 or t3333 ";  
externalHashProduct::usage=" externalHashProduct[a_?t33Q,b_?t33Q]  := (ricci ~colon~( tpose23( a ~out~ b) ))~colon~ricci  
                        denoted as a xx b  according to https://de.wikipedia.org/wiki/Formelsammlung_Tensoralgebra" ;
doubleCrossProduct::usage="doubleCrossProduct[a_?t33Q,b_?t33Q]  := ( tr[a]tr[b] -( a~colon~b)) delta +a .b + b.a  - tr[a] b - tr[b]a 
                     denoted as  a#b according  to https://de.wikipedia.org/wiki/Formelsammlung_Tensoralgebra   ";                   
                    
theReal::usage = "Syntax: theReal[], theReal[a], or theReal[aList]  declares all Variables, 
                  a Variable or a List of Variables as Real via  Assumptions " ;
thePositiveReal::usage = "Syntax:  thePositiveReal[a], or thePositiveReal[aList]  declares  , 
                          a Variable or a List of Variables as Real and > 0 via  Assumptions " ;

st33::usage = "Syntax: st33[a]  or st33[2.7]  or st33[]  or st33[{a,b,c}] 
                   similar to Array[a,{3,3}] but creates a symmetric  matrix  
                 {{a[1, 1], a[1, 2], a[1, 3]}, {a[1, 2], a[2, 2], a[2, 3]},  {a[1, 3], a[2, 3], a[3, 3]}} ;  
                  if a = {u,v,w} then DiagonalMatrix[{u,v,w}] 
                  if a is a number  then all components are RandomReal[-a,a] and symmetrized with symm12  
                  see other generators:  ast33, st3333     " ;
                  
 
st3333::usage = "   E3333  = st3333[ a , symmMajor -> True, verbose -> True ]  or  E3333  = st3333[ 2.8 , symmMajor -> True ] 
                     generates a general  3333 tensor with minor symmetries and major symmetry 
                     unless  prevented by the option symmMajor 
                     see other generators:  ast33, st33   " ;                  
                  
                  
ast33::usage = "Syntax: ast33[a]  or ast33[2.7]  or ast33[]  or ast33[{a,b,c}] 
                 similar to Array[a,{3,3}] but creates a symmetric  matrix  
                 {{a[1, 1], a[1, 2], a[1, 3]}, {a[1, 2], a[2, 2], a[2, 3]},  {a[1, 3], a[2, 3], a[3, 3]}} ;   
                  if a = {u,v,w} then DiagonalMatrix[{u,v,w}] 
                  if a is a number  then all components are RandomReal[-a,a] and antimmetrized with symm12 
                   see other generators:  st33, st3333  "  ;                  
                  
ricci::usage = "Syntax: ricci   
                    generates a 3x3x3  matrix defined by the permutation symbol" ;
Ricci::usage = "Syntax: Ricci   
                generates a 3x3x3  matrix defined by the permutation symbol" ;
delta::usage = "Syntax: delta   
                 generates a 3x3   matrix defined by the Kronecker's symbol" ;
\[Delta]::usage ="  Syntax: \[Delta]  
                 generates a 3x3   matrix defined by the Kronecker's symbol" ;
                 

                 
                 
                                                  
z3::usage=" z3 is a zero array of dimension 3;  z3[i] is zero everywhere but the component i  is 1   " ; 
z33::usage=" z33 is a zero array 3 x 3;  z33[i,j] is zero everywhere but the component ij is 1 " ; 
z333::usage=" z333 is a zero array 3 x 3 x 3 ;  z333[i,j,k] is zero everywhere but the component ijk is 1 " ;  
z3333::usage=" z3333 is a zero array 3 x 3 x 3 x 3 ;  z333[i,j,k,l] is zero everywhere but the component ijkl is 1   " ;   
one3::usage="   is zero everywhere but the component i  is 1   " ; 
one33::usage="   zero everywhere but the component ij is 1 " ; 
one333::usage="    is zero everywhere but the component ijk is 1 " ;  
one3333::usage="   is zero everywhere but the component ijkl is 1   " ; 

colon::usage = "Syntax: colon[a,b] or  a ~colon~ b   
                multiplication with two dummy indices a:b. The tensors a, b  can be of 2-nd to sixth rank 
                A multiplication of 2-nd rank tensors with Ricci is also possible.  
                See also colon3  colon4 and hatcolon. " ;
colon3::usage = "Syntax: colon3[a,b] or  a ~colon3~ b   
                multiplication with three dummy indices a_ijk b_ijk. The tensors a, b  must be of 3-rd  rank 
                See also colon ,colon4 and hatcolon. " ;
colon4::usage = "Syntax: colon4[a,b] or  a ~colon4~ b   
                multiplication with  four dummy indices a_ijk b_ijk. The tensors a, b  must be of 4-rd  rank 
                See also colon ,colon3 and hatcolon. " ;                                
approx::usage = "Syntax: approx[a,b] or  (a ~approx~ b)   
                 A logical function returns True if the objects are almost equal  (difference less than 10^-12)
 ARGUMENTS:       pair of numbers or 
                  pair of lists of numbers or 
                  pairs of the following matrices t33Q, t3333Q t99Q)  " ;
out::usage = "Syntax: out[a,b] or  a ~out~ b   
                dyadic multiplication  a b. The tensors a, b should be tensors of  1-st or 2-nd  rank 
                See also hatcolon, colon, zout, zoutSym " ;
zout::usage = "Syntax: zout[a,b] or  a ~zout~ b   
                dyadic multiplication  a ~out~ b followed by the tpose23 transposition.   The tensors a, b should be tensors of 2-nd  rank 
                See also hatcolon, colon,  out, zoutSym " ;
zoutSym::usage = "Syntax: zoutSym[a,b] or  a ~zoutSym~ b   
                dyadic multiplication  a ~out~ b followed by transposition tpose23  and symmetrized with tpose24 tpose34 transpositions.   
                The tensors a, b should be tensors of 2-nd  rank as used by Itskov. 
                See also hatcolon, colon,  out, zout  " ;
hatcolon::usage =" Syntax: hatcolon[a,b] or  a ~hatcolon~ b   
                multiplication a_ijklmn b_kl with two middle dummy indices kl. The tensor a must be of sixth rank and b  is of 2-nd rank " ;
deviator::usage = "Syntax: deviator[a]        
                     returns the deviatoric portion of the sym. 3x3 matrix a    
                    Accepts also the diagonal form {a,b,c}";
dev::usage = "Syntax: dev[a]   
               returns the deviatoric portion of the sym. 3x3 matrix a"  ;
contract::usage = "Syntax: contract[A, i, j]  
                   returns  tensor A contracted over indices number i and j.  
                    The initial rank of A should be in the range 2 to 6.  
                   The returned tensor has the rank of A reduced  by two. 
                   Be careful using nested contract commands:   
                   the positions of indices to be contracted  may be changed by the internal contractions ";
tr::usage = "Syntax: tr[a]  \n      returns the trace  of the  3x3 matrix a, i.e. a_ii. 
             Accepts also the diagonal form {a,b,c}"  ;
norm2::usage = "Syntax: norm2[t3]  ,norm2[t33] norm2[t3333]
                returns the square of the norm of the argument , 
                  t3_i t3_i  or   t33_ij t33_ij or  t3333_ijkl   t3333_ijkl  (in the last case based on ~colon4~ ) "  ;
qubic::usage = "Syntax: qubic[a]  
                returns the invariant a_ij a_jk a_ki of the sym. 3x3 matrix a "  ;
scalar::usage = "Syntax: scalar[a,b] or scalar[x,y,z]\n returns the scalar product a_ij b_ij   
                  or x_ij y_jk z_ki of 3x3 matrices. Accepts also the diagonal form {a,b,c} ";
normalized::usage = "Syntax: normalized[a]  \n    returns the   normalized argument,  
                     i.e. the 3x3 matrix a/Sqrt[ a_ij a_ij ]. Accepts also the diagonal form {a,b,c}  
                      if norm of argument is zero than the argument is returned, e.g. normalized[{0,0,0}] is {0,0,0} and not indeterminate"  ;
hated::usage = "Syntax: hated[T]   
                returns the  tensorial  argument T devided by its trace,  
                 i.e. the 3x3 matrix T/tr[T]. Accepts also the diagonal form {a,b,c} "  ;

i1::usage = "Syntax: i1[a] 
              invariant of the 3x3 tensor a, i.e. tr[a]. Accepts also the diagonal form {a,b,c}  ";
i2::usage = "Syntax: i2[a] 
              invariant of the 3x3 tensor a, i.e. (norm2[a] - tr[a]^2 )/2.  
              Accepts also the diagonal form {a,b,c}";
i3::usage = "Syntax :i3[a] 
             invariant of the 3x3 tensor a, i.e. Det[a]. Accepts also the diagonal form {a,b,c} ";
j2::usage = "Syntax: j2[a]  
             invariant of the deviator of the 3x3 tensor a,  i.e. (1/2)* norm2[deviator[x]].  
              Accepts also the diagonal form {a,b,c}  ";
j3::usage = "Syntax: j3[a] 
             invariant of the deviator of the 3x3 tensor a  i.e. Det[deviator[x]]. 
             Accepts also the diagonal form {a,b,c} ";


where::usage=" Tresult = where[test, TTrue, TFalse ] applies a conditional action to individual components  
ARGUMENTS  test = a test function  i==j or  a string \"i<j\" (dont use i<=j or i>=j ) 
                   or logical matrix of the same dimensions as  TTrue and  TFalse  
                  formally two arguments must be used in the test so use \"i + 0 j == 3\" (apostrofes are necessary) to apply a condition   
           TTrue  = array with values  copied to the the Tresult if the test is True   
           TFalse = array with values  copied to the the Tresult if the test is False    
RETURNS :  Tresult = array with   with values  copied from TTrue or Tfalse depending on the test 
";
componentwise::usage=" Tensor3 = componentwise[ pureFunction , Tensor1 , Tensor2 ] threads the pureFunction through all  pairs of components 
ARGUMENTS  pure =  pure two-argument functions  for example logical  (#1>#2)& or arithmetical #1^#2& 
           Tensor1 = array with components treated as #1 
           Tensor1 = array with components treated as #2 
RETURNS :  Tensor3 = array with results from pure function
";    

symbolVariables::usage=" symbolVariables[expression] splits expression (any InputForm) into a list of symbols replacing arithmetic operators (+.-,*,/,...) 
                   and test operators (==, <, <=, ...) by separators.    Uses internally makeList[]. 
ARGUMENT :  expression = accepts InputForm or a string 
RETURNS  : a list of symbolic variables  encountered in expr without repetitions                  
";    

makeList::usage=" makeList[expression ] creates a list of items replacing various operators  (+.-,*,/,...) or (==, <, <=, ...)  
                   in exprpression  by separators (commas)
ARGUMENT :  expr = expression in InputForm or a string 
RETURNS  : a list of atomic variables or numbers encountered in expr 
" ;    


tpose::usage = "Syntax: tpose[a,order, fromOrder-> True] \n transposition of the indices  of a 333 or 3333 or 333333 tensor according to the order, defautlt fromOrder is True  \n
                     e.g. 2*identity4sym == tpose[(delta~out~delta),{1,3,2,4}]+tpose[(delta~out~delta),{1,4,2,3}]";
tpose12::usage = "Syntax: tpose12[a] \n transposition of the indices 1 and 2 of a 333 or 3333 or 333333 tensor. Compose carefully, e.g. tpose12[tpose23[Bijkl]] = Bjkil and not Bkijl, see tpose[] ";
tpose23::usage = "Syntax: tpose23[a] \n transposition of the indices 2 and 3 of a  333 or 3333 or 333333  tensor. Compose carefully, e.g. tpose12[tpose23[Bijkl]] = Bjkil and not Bkijl, see tpose[]  ";
tpose34::usage = "Syntax: tpose34[a] \n transposition of the indices 3 and 4 of a 3333 or 333333  tensor. Compose carefully, e.g. tpose12[tpose23[Bijkl]] = Bjkil and not Bkijl, see tpose[]   ";
tpose14::usage = "Syntax: tpose14[a] \n transposition of the indices 1 and 4 of a 3333 or 333333 tensor. Compose carefully, e.g. tpose12[tpose23[Bijkl]] = Bjkil and not Bkijl, see tpose[]   ";
tpose24::usage = "Syntax: tpose24[a] \n transposition of the indices 2 and 4 of a 3333 or 333333 tensor. Compose carefully, e.g. tpose12[tpose23[Bijkl]] = Bjkil and not Bkijl, see tpose[]   ";
tpose13::usage = "Syntax: tpose13[a] \n transposition of the indices 1 and 3 of a  333 or 3333 or 333333 tensor. Compose carefully, e.g. tpose12[tpose23[Bijkl]] = Bjkil and not Bkijl, see tpose[]   ";
tpose15::usage = "Syntax: tpose12[a] \n transposition of the indices 1 and 5 of a 333333 tensor. Compose carefully, e.g. tpose12[tpose23[Bijkl]] = Bjkil and not Bkijl, see tpose[]  ";
tpose25::usage = "Syntax: tpose12[a] \n transposition of the indices 2 and 5 of a 333333 tensor. Compose carefully, e.g. tpose12[tpose23[Bijkl]] = Bjkil and not Bkijl, see tpose[]  ";
tpose35::usage = "Syntax: tpose12[a] \n transposition of the indices 3 and 5 of a 333333 tensor. Compose carefully, e.g. tpose12[tpose23[Bijkl]] = Bjkil and not Bkijl, see tpose[]  ";
tpose45::usage = "Syntax: tpose12[a] \n transposition of the indices 4 and 5 of a 333333 tensor. Compose carefully, e.g. tpose12[tpose23[Bijkl]] = Bjkil and not Bkijl, see tpose[]  ";
tpose16::usage = "Syntax: tpose23[a] \n transposition of the indices 1 and 6 of a  333333  tensor. Compose carefully, e.g. tpose12[tpose23[Bijkl]] = Bjkil and not Bkijl, see tpose[]  ";
tpose26::usage = "Syntax: tpose23[a] \n transposition of the indices 2 and 6 of a  333333  tensor. Compose carefully, e.g. tpose12[tpose23[Bijkl]] = Bjkil and not Bkijl, see tpose[]  ";
tpose36::usage = "Syntax: tpose23[a] \n transposition of the indices 3 and 6 of a  333333  tensor. Compose carefully, e.g. tpose12[tpose23[Bijkl]] = Bjkil and not Bkijl, see tpose[]  ";
tpose46::usage = "Syntax: tpose23[a] \n transposition of the indices 4 and 6 of a  333333  tensor. Compose carefully, e.g. tpose12[tpose23[Bijkl]] = Bjkil and not Bkijl, see tpose[]  ";
tpose56::usage = "Syntax: tpose23[a] \n transposition of the indices 5 and 6 of a  333333  tensor. Compose carefully, e.g. tpose12[tpose23[Bijkl]] = Bjkil and not Bkijl, see tpose[]  ";

tpose13i24::usage = "Syntax tpose13i24[a] \n transposition of the indices 1 and 3 and also  2 and 4  of a 3333 tensor";

symm12::usage = "Syntax: symm12[a] \n symmetrization wrt the indices 1 and 2 of a 3333 tensor ";
symm34::usage = "Syntax: symm34[a] \n symmetrization wrt the indices 3 and 4 of a 3333 tensor  ";
symm23::usage = "Syntax: symm23[a] \n symmetrization wrt the indices 2 and 3 of a 3333 tensor ";
symm14::usage = "Syntax: symm14[a] \n symmetrization wrt the indices 1 and 4 of a 3333 tensor  ";
symm24::usage = "Syntax: symm24[a] \n symmetrization wrt the indices 2 and 4 of a 3333 tensor  ";
symm13::usage = "Syntax: tsymm13[a] \n symmetrization wrt the indices 1 and 3 of a 3333 tensor  ";
symm13i24::usage = "Syntax symm13i24[a] \n symmetrization wrtf the indices 1 and 3 and also  2 and 4  of a 3333 tensor";
symmEl::usage="Syntax symmEl[a]   two minor symmetries and the major symmetry (like in elastic stiffness) are imposed on a 3333 tensor  ";


realQ::usage=" Syntax realQ[ x ]  works also with  lists and arrays. True means all components are numerical and real ";
numberQ::usage=" Syntax numberQ[ x ] similar to NumberQ but works also with  lists and arrays. True means all components are numerical ";
anyNumberQ::usage=" Syntax numberQ[ x ] similar to NumberQ but works also with  lists and arrays. True means that at least one component is numerical ";
allNumberQ::usage=" Syntax numberQ[ x ] similar to NumberQ but works also with  lists and arrays. True means all components are numerical ";
symbolQ::usage = "Syntax: symbolQ[t_]:=\[Not]NumberQ[t] but works also with  lists and arrays. True means that at least one component is symbolic  ";
anySymbolQ::usage = "Syntax: symbolQ[t_]:=\[Not]NumberQ[t] but works also with  lists and arrays. True means that at least one component is symbolic  ";
allSymbolQ::usage = "Syntax: symbolQ[t_]:=\[Not]NumberQ[t] but works also with  lists and arrays. True means that all component are symbolic  ";

tQ::usage=" Syntax tQ[ x ] True if argument x has dimensions 3x3 or 3 ";
t2Q::usage = "Syntax: t2Q[x]  tests if x is a 2:1  matrix  ";
vectorQ::usage= "vectorQ[x] tests if x is a 1D list "; 
squareMQ::usage = "squareMQ[x] tests whether x is a square matrix ";
symmMQ::usage = "symmMQ[x] tests whether x is a symmetric square matrix   " ;  
t22Q::usage = "Syntax: t22Q[x]  tests if x is a 2:2  matrix  " ;
t3Q::usage = "Syntax: t3Q[x]  tests if x is a 3:1  matrix  ";
t33Q ::usage = "Syntax: t33Q[x]  tests if x is a  3:3 matrix ";
t333Q::usage = "Syntax: t333Q[x]  tests if x is a  3:3:3  matrix ";
t3333Q::usage = "Syntax: t3333Q[x]  tests if x is a  3:3:3:3  matrix ";
t9Q::usage = "Syntax: t9Q[x]  tests if x is a  9:1  matrix ";
t6Q::usage = "Syntax: t6Q[x]  tests if x is a  6:1  matrix ";
t99Q::usage = "Syntax: t99Q[x]  tests if x is a  9:9   matrix ";
t66Q::usage = "Syntax: t99Q[x]  tests if x is a  6:6   matrix ";
t33333Q::usage = "Syntax: t33333Q[x]  tests if x is a  3:3:3:3:3  matrix ";
t333333Q::usage = "Syntax: t333333Q[x]   tests if x is a  3:3:3:3:3:3  matrix ";
t3333333Q::usage = "Syntax: t3333333Q[x]   tests if x is a  3:3:3:3:3:3:3  matrix ";
t33333333Q::usage = "Syntax: t33333333Q[x]   tests if x is a  3:3:3:3:3:3:3:3  matrix ";
numericQ::usage = "Syntax numericQ[expr] similar to NumericQ from Mma but exteded for lists ";
atomSymbolQ::usage = "Syntax:  atomSymbolQ[a] tests if a is symbolic and atomic object (suitable as a name in st33) " ;

identity4::usage = "Syntax:   identity4  
                    writes the identity tensor 3333  identity4_ijkl = delta_ik delta_jl "   ;
antimetry4::usage = "Syntax:  skewA = antimetry4 ~colon~ A ;
                      returns  the antimetrization tensor 3333 
                        identity4_ijkl = ( delta_ik delta_jl -  delta_il delta_jk ) /2 
                       see also symmetry4  identity4sym transposer4 "   ;
symmetry4::usage = "Syntax: symmA =  symmetry4  ~colon~ A  ;
                      returns  the  symmetrization  tensor 3333 
                        symmetry4_ijkl =  ( delta_ik delta_jl +  delta_il delta_jk ) /2    
                       see also antimetry4 identity4sym transposer4  "   ;    
transposer4::usage ="  Syntax: AT = transposer4  ~colon~ A ; 
                        returns  the  transposition  tensor 3333 
                        transposer_ijkl =   delta_il delta_jk 
                        see also  antimetry4 symmetry4  identity4sym
";                                           
                       
identity4sym::usage = "Syntax:  unit4sym  
                       returns the identity matrix3333 
                      identity4sym_ijkl = ( delta_ik delta_jl + delta_il delta_jk )/2";
deviatorer::usage = "Syntax: deviatorer or deviatorer4  
                      returns a 3333-matrix  such that devT =  deviatorer4sym ~colon~ T; 
                      deviatorer_ijkl= delta_ik delta_jl-(1/3) delta_ij delta_kl ";
deviatorer4::usage = "Syntax: deviatorer or deviatorer4 
                      returns a 3333-matrix  such that devT =  deviatorer4sym ~colon~ T; 
                      deviatorer_ijkl= delta_ik delta_jl-(1/3) delta_ij delta_kl ";

deviatorer4sym::usage = "Syntax: deviatorer4sym 
                          returns a 3333-matrix  such that devT =  deviatorer4sym ~colon~ T; 
                         deviatorer_ijkl= (delta_ik delta_jl + delta_il delta_jk)/2 -(1/3) delta_ij delta_kl ";

deviatorer33::usage = "Syntax: deviatorer   returns a 33 -matrix  that extracts a deviator from a t3 form of stress ";

matrixForm::usage = "Syntax: matrixForm[a] \n  writes a 3x3x3x3 tensor in a 9x9 MatrixForm.  
                      The columns and the lines are numbered as follows:  11,22,33,12,21,13,31,23,32" ;
transfer99::usage = "Syntax: transfer99[a3333] or transfer99[a33] 
                      transfers a tensor 3x3x3x3  or 3x3  
                       to a matrix 9x9 or  to a vector 9 respectively. See also transfer99i  and matrixForm.  
                      The columns and the lines are numbered as follows:  11,22,33,12,21,13,31,23,32" ;
transfer99i::usage = "Syntax transfer99i[a99]  or transfer99i[a9]  
                       transfers a 9x9  matrix   to  a 3x3x3x3  tensor  
                      or a  9 vector to a 3x3 tensor. See also transfer99 and matrixForm.
                      The columns and the lines are numbered as follows:  11,22,33,12,21,13,31,23,32" ;
RoscoeP::usage = "Syntax:  RoscoeP[x] \n  calculates Roscoe's stress invariant p = -tr[x]/3.  
                  Accepts also the diagonal form x={a,b,c}  Argument x must have mechanical signs  
                   (tension positive)" ;
RoscoeQ::usage = "Syntax:  RoscoeQ[x]  
                  calculates Roscoe's  stress invariant q  = Sqrt[(3/2)*norm2[deviator[x]].  
                  Accepts also the diagonal form x={a,b,c} and  gives sign in the axisymmetric case x={a,b,b} " ;
RoscoeEpsilonV::usage = "Syntax:  RoscoeEpsilonV[x] 
                        calculates Roscoe's strain invariant epsilonV = -tr[x].  
                  Accepts also the diagonal form {a,b,c}  Argument x must have mechanical signs  
                   (tension positive) " ;
RoscoeEpsilonQ::usage = "Syntax RoscoeEpsilonQ[x]  \n  calculates  strain invariant epsilonq  = Sqrt[(2/3)*norm2[deviator[x]]].  
                  Accepts also the diagonal form {a,b,c} and  gives sign to the axisymmetric case {a,b,b}  
                  Argument x must have mechanical signs (tension positive)" ;
isomorphicP::usage = "obsolete, changed to  isoP[x] \n  calculates isometric invariant  P = -tr[x]/Sqrt[3] of a tensor x.  
                  Accepts also the diagonal form x={a,b,c}.  Argument x must have mechanical signs \n
                   (tension positive)  " ;
isoP::usage = "Syntax:  isoP[x] \n  calculates isometric invariant  P = -tr[x]/Sqrt[3] of a tensor x.  
                  Accepts also the diagonal form x={a,b,c}.  Argument x must have mechanical signs  
                   (tension positive)  " ;                   
          
isomorphicQ::usage = "obsolete, changed to isoQ[a]    calculates isometric  invariant Q  = Sqrt[norm2[deviator[a]]] 
                  Accepts also the diagonal form x={a,b,c} and  gives sign in the axisymmetric case x={a,b,b} " ;
                  
isoQ::usage = "Syntax:  isoQ[a]  \n  calculates isometric invariant Q  = Sqrt[norm2[deviator[a]]]. \
                  Accepts also the diagonal form x={a,b,c} and  gives sign in the axisymmetric case x={a,b,b} " ;                  
                  
onev::usage = "onev normalized second rank identity tensor, e.g. P = -onev ~colon~ T gives isometric pressure, see also onevstar " ;
onevstar::usage = " onevstar  normalized second rank deviatoric tensor, e.g. Q =  onevstar ~colon~ T gives isometric deviarotic stress (Q  with sign) if T is axisymmetric. \
                     see also onev " ;


LodeTheta::usage = "Syntax:  LodeTheta[a] \n calculates Lode angle  \n \
                     theta  = (1/3) * ArcCos[ -3*Sqrt[3]*j3[x]/(2* (j2[x])^(3/2)  )].\
                      Accepts also the diagonal form {a,b,c}   Argument x must have mechanical signs \n
                    (tension positive) " ;
tensorial::usage = "Syntax:  tensorial[func, aa]  executes the following sequence of actions on aa: 
                      -- aa is rotated to the diagonal form,  (usually a vector with three components)
                      -- func is applied to each eigenvalue and written to FFF 
                      -- diagonal form FFF  is unrotated.    
                    Examples:  tensorial[#^3 &, a] or tensorial[Sqrt, aa] .... 
                    In Mma 10 or later tensorial[ Log, aa]  tensorial[ Exp, a]  tensorial[ Sqrt, aa] uses Mma intrinsic functions 
                     MatrixLog, MatrixExp, MatrixPower where possible because it works better with symbolic components of aa. 
                     Using Mma 10 or later one should use MatrixFunction[ , aa]  
                     See also tensorial3[ ] and tensorialfD[]  
  " ;
  
tensorial3::usage = "Syntax:   fA33 = tensorial3[ userFunc , mat, A33]  applies  userFunc[] to sorted eigenvalues of A33: 
                     ARGUMENTS:    
                      -- A33  = original 3x3 matrix (larger matrices A99  have not been tested yet )
                              A33 is rotated to the diagonal form. The diagonal  terms are extracted and sorted from the smallest  to the largest 
                              i.e. TTT = {t,m,T}  with   t<m<T
                             The eigenvectors are sorted simultaneously with the corresponding eigenvalues to be later used  for unrotation 
                      -- userFunc = name of the function that operates on principal values   
                               The user's function  will be used as follows
                               RRR = userFunc[TTT, mat]  
                               it takes  TTT as argument and returns RRR =  list of 3 components   
                      -- mat = list of material parameters which can be sent via tensorial3 to userFunc if necessary. 
                               Otherwise set mat = {}.     
                     OUTPUT:    userFunc  returns  RRR   and this is converted to the diagonal 3x3 matrix. 
                                Finally,  this matrix  is unrotated to fA33  using the sorted eigenvectors of A33             
                                 
                      ADVANTAGE OVER tensorial[]: 
                      Each component of RRR  may be a DIFFERENT function of calculated from ALL eigenvalues TTT       
                     For example, userFunc[TTT_, mat_] :=  {TTT\[LeftDoubleBracket]1\[RightDoubleBracket]+ TTT\[LeftDoubleBracket]2\[RightDoubleBracket], 0, TTT\[LeftDoubleBracket]3\[RightDoubleBracket] + TTT\[LeftDoubleBracket]2\[RightDoubleBracket] * mat\[LeftDoubleBracket]1\[RightDoubleBracket]}; 
                     sets the intermediate principal stress to zero and modifies only the extreme eigenvalues.  
                     See also tensorial[  ] and tensorialfD[]    
  " ;
   
tensorialfD::usage = "Syntax  tensorialfD[func, A] \n  returns Frechet derivative of func(A) wrt tensor A  
                     e.g. tensorialfD[#^3 &, aa] or tensorialfD[Sqrt, aa] or tensorialfD[Log, aa]   
                     Example: 
                     b=  tensorial[Exp, a ] ; tensorialfD[ Log, b] ~colon~ tensorialfD[Exp, a] //transfer99//Chop //MatrixForm 
                     See also tensorial[] and tensorial3[] 
" ;
                      
decomposeVRU::usage = "Syntax {v,r,u} = decomposeVRU[F]  
                        polar decomposition of  F,  
                        In simple cases an analytical result is attempted  " ;
inverse99::usage = "Syntax:  ai99 = inverse99[a99]  or ai3333 = inverse99[a3333]
                       inverts a 9x9 Matrix or a 3x3x3x3 NUMERICAL matrix  
                       handling singularities from minor symmetries  
                       i.e. for the case that the rows (and columns) 4 and 5 or 6 and 7  or 8 and 9 are identical  
                       If only columns or only rows are identical then error is returned. Aborts if other singularities encountered  
                       see also inverseSM for Sherman Morisson formula";
inverseSM::usage = "Syntax: inverseSM[A, u,  v] or inversedSM[Ainv, u,  v]  uses Sherman Morrison formula and returns   
                    (A + u v)^-1 =  Ainv  - Ainv.u v.Ainv / ( 1+ v.Ainv.u)  
                   see also inverse99  "
inversedSM::usage = "Syntax inverseSM[A, u,  v] or inversedSM[Ainv, u,  v]  uses Sherman Morrison formula and returns  
                   (A + u v)^-1 =  Ainv  - Ainv.u v.Ainv / ( 1+ v.Ainv.u)  
                   A=3333-matrix, u=33-matrix, v=33-matrix \n\      
                    see also inverse99 "
iE33::usage = "Syntax  iE33[e,n]  or iE[ ] \n  returns a 33-matrix in the form  
                     of isotropic elastic stiffness for principal components, 
                    OPTION : useLambda -> False returns stiffness expressed with Lame constant \[Lambda] and \[Nu]   
                     see also iC33[ ],  iE[] and iC[]" ;
iC33::usage = "Syntax  iC33[e,n]  or iC[ ]  
                returns a 33-matrix with isotropic elastic compliance for principal components, 
                see also iE33[ ],  iE[] and iC[]" ;
iE::usage = "Syntax: iE[e,n] or iE[ ] 
              returns a 3x3x3x3-matrix  of isotropic elastic stiffness. " ;
iC::usage = "Syntax: iC[e,n]  or iC[ ] 
               returns a 3x3x3x3-matrix  of isotropic elastic compliance" ;
isoPQ::usage = "Syntax: isoPQ[A] returns isometric PQ components of  A. 
                If A is an axisymmetric mechanical tensor t33Q  or t3Q  of the form {a,b,b} then 
                 {AP,AQ}  is returned (mech. signs assumed in original A).  
                If A is tensor t3333Q that interrelates axisymmetric mechanical tensors of the form {a,b,b} 
                 then the matrix {{APP,APQ},{AQP,AQQ}} is returned  
                see also isoPQgeot[]  " ;
isoPQgeot::usage = "Syntax: isoPQgeot[A] returns isometric PQ components of A. Geotechnical signs assumed in original A. 
                     If A is an axisymmetric geotechnical tensor t33Q  or t3Q  of the form {a,b,b} then 
                      {AP,AQ}  is returned (mech. signs assumed in original A).  
                     If A is tensor t3333Q that interrelates axisymmetric geotechnical tensors of the form {a,b,b} then 
                      the matrix {{APP,APQ},{AQP,AQQ}} is returned   
                   see also isoPQ[]  " ;


symm::usage = "Syntax: symm12[a],symm34[a],symm23[a],symm14[a],symm24[a],symm13[a] or symm13i24[a].  
      These commands symmetrize (wrt the chosen indices) the tensor a (of 2nd 3rd or 4-th order).  
      For 2nd order tensor symm12[a] = symm[a]. 
      Elastic minor and major symmetries can be imposed by symmEl[a]" ;

aRot::usage = "Syntax:  aRot12[t] aRot13[t] aRot23[t] returns the directional cosine matrix 33 for active plane rotation
 by t [radians]  in the plane x1-x2, x1-x3 or x2-x3, see also pRot"  ;
 aRot12::usage = "Syntax:  aRot12[t] aRot13[t] aRot23[t] returns the directional cosine matrix 33 for active plane rotation
 by t [radians]  in  x1-x2, see also pRot"  ;
 aRot13::usage = "Syntax:  aRot12[t] aRot13[t] aRot23[t] returns the directional cosine matrix 33 for active plane rotation
 by t [radians]  in   x1-x3, see also pRotate"  ;
 aRot23::usage = "Syntax:  aRot12[t] aRot13[t] aRot23[t] returns the directional cosine matrix 33 for active plane rotation
 by t [radians]  in   x2-x3, see also pRot"  ;
pRot::usage = "Syntax:  pRot12[t] pRot13[t] pRot23[t] returns the directional cosine matrix 33 for passive plane rotation
 by t [radians]  in the plane x1-x2, x1-x3 or x2-x3, see also aRot" ;
pRot12::usage = "Syntax:  pRot12[t] pRot13[t] pRot23[t] returns the directional cosine matrix 33 for passive plane rotation
 by t [radians]  in  x1-x2, see also aRot" ;
 pRot13::usage = "Syntax:  pRot12[t] pRot13[t] pRot23[t] returns the directional cosine matrix 33 for passive plane rotation
 by t [radians]  in   x1-x3, see also aRot" ;
 pRot23::usage = "Syntax:  pRot12[t] pRot13[t] pRot23[t] returns the directional cosine matrix 33 for passive plane rotation
 by t [radians]  in  x2-x3, see also aRot" ;
rotateTensor::usage = "Syntax:  rotateTensor[T, a] actively rotates tensor T   of rank 1 to 4 (t3, t33, t333 or t3333) using a 33 rotation matrix a.
    Active rotation means that the coordinate system does not change and the object is rotated by a. 
    Passive rotation means that the coordinate system is rotated by a and the object does not change.  
    The components of the object are simply expressed in the rotated basis. 
    For passive rotation use rotateTensor[T, Transpose[a]].        
    Summation is performed over the second index of a, e.g.  T'_ij  = a_ik a_jl  T_kl.  Directional cosine matrix a can be
    calculated with aRot for active rotation or pRot for passive rotation. See also rotationTensor and rotationTensorInverse ";

 
rotationTensor::usage=" Syntax:  rotationTensor[f_?t3Q, t_?t3Q ] or
                                 rotationTensor[f_?t3Q, t_?t3Q, \[Beta]_ ] or
                                  rotationTensor[f_?t33Q, t_?t33Q ] or 
                                  rotationTensor[f_?t33Q, t_?t33Q, \[Beta]_ ] or 
                                  rotationTensor[ {angle, axis_?t3Q} ]    
         Returns a rotation tensor R  for  the operation:  
          t=R.f  or t=R~colon~f or R for the rotation about axis by angle radians 
          using generalized Euler Rodriguez formula.  
          Possibly ony a portion (by  angle \[Beta] in radians) of this rotation is calculated if \[Beta] is defined. 
          Do not mix it up with rotateTensor or aRot or pRot.
          See also rotationTensorInverse[] and  
          for vectors Mma internal RotationTransform[] ";
          
rotationTensorInverse::usage=" Syntax:  {angle, axis}  = rotationTensorInverse[R_?t33Q   ]  
         Returns angle of rotation and axis of rotation that correspond to the rotation tensor R.   
          See also  rotateTensor or aRot12.. or pRot12..   rotationTensor[] and  Mma internal RotationTransform[]
            ";          
          
          

xiE::usage = "Syntax:    xiE[Eh,Ev,nh,nhv,Gv, mm ] or  xiE[ mm ] or xiE[] returns a 3333 cross-isotropic stiffness
              with axial isotropy wrt mm, default mm = {0,0,1}, i.e. Index h = x1,x2, index v = x3  sedimentation mm = {0,0,1}.
              Possible also  xiEr[ mm ] (based on alternative algorithm) ";

xiEr::usage = "Syntax:     xiEr[ mm ]  xiEr[ Ev_,Eh_,nh_,nhv_,Gv_, mm_?t3Q  ]  returns a 3333 cross-isotropic stiffness with cross-anisotropy wrt mm.  
               In the first syntax the parameters Eh,Ev,nh,nhv,Gv treated as globals. 
               See also  xiE[ mm ] (based on alternative algorithm) ";
              
xiCr::usage = "Syntax:  xiCr[ mm ] or  xiCr[ Ev_,Eh_,nh_,nhv_,Gv_,mm_?t3Q  ]   returns a 3333 cross-isotropic compliance  with cross anisotropy wrt mm. 
        In the first syntax parameters Eh,Ev,nh,nhv,Gv treated as globals ";      	      

xiC::usage = "Syntax:    xiC[Eh,Ev,nh,nhv,Gv, mm ] or  xiC[ mm ] or xiC[] returns a 3333 cross-isotropic compliance \n \
              with axial isotropy wrt mm, default mm = {0,0,1} ";

xiEgeot::usage = "Syntax: xiEgeot[ Ev, nh , a, mm ]  or   xiEgeot[ Ev, nh , a, n, mm ]    returns a simplified (geotechnical) 3333 cross-isotropic
            stiffness with axial isotropy wrt vector mm according to Graham and Houlsby's  paper in Geotechnique 1983,
            possibly  enhanced with exponent n   (after Niemunis+Staszewska).
            index h (=horizontal) perpendicular to sedimentation mm,  
            index v (= vertical) along sedimentation mm " ;
             
             
xiCgeotShort::usage = "Syntax:   xiCgeotShort[ Ev_, nh_, a_, mm_?t3Q  ]	xiCgeotShort[ Ev_, nh_, a_, n_, mm_?t3Q  ] returns a simplified (geotechnical) 3333 cross-isotropic
           compliance with axial isotropy wrt vector mm according to Graham and Houlsby's  paper in Geotechnique 1983,
            possibly  enhanced with exponent n (after Niemunis+Staszewska).
           index h (=horizontal) perpendicular to sedimentation mm,  
           index v (= vertical) along sedimentation mm " ;
             
             
             
xiEgeotShort::usage = "Syntax:  xiEgeotShort[ Ev_, nh_, a_, mm_?t3Q  ] or	xiEgeotShort[ Ev_, nh_, a_, n_, mm_?t3Q  ]  returns a  3333 cross-isotropic stiffness.
          Arguments:   
            a = alpha parameter for simplified anisotropy  after Graham+Houlsby in Geotechnique 1983,
            n=beta = optional exponent after Niemunis+Staszewska 2021 
            mm = direction of sedimentation   
            index h (=horizontal) perpendicular to sedimentation mm,  
            index v (= vertical) along sedimentation mm 
            It is identical as xiEgeot but uses xiEr ";       
             
epE::usage="epE[  iE_ , nb_,mb_, K_] returns elastoplastic stiffness. 
              Arguments: 
              iE =  elastic stiffness (4th order tensor) (not necessarily isotropic) 
              nb = loading direction (unit 2nd order tensor)
              mb = flow direction  (unit 2nd order tensor)
              K = hardening modulus
"; 
  
                                                     
getXAniso::usage = "Syntax Q3333= getXAniso[a,mm] or Q3333= getXAniso[a,n,mm]  
                     returns  the   pure-cross-anisotropy tensor Q3333 (with large symmetry) after Niemunis+Grandas+Wichtmann  2016   
                   It  generates cross anisotropic stiffness   Eaniso3333 = Q3333 : Eiso3333 : Q3333   from isotropic stiffness  Eiso3333
                   Eaniso333  the the simplified cross-anisotropy tensor by Graham+Houlsby  or its extended version by Niemunis+Staszewska 2021           
                   The arguments are 
                    a = alpha = anisotropy parameter by  Graham+Houlsby  
                    n =  n=1/beta optional exponential parameter from  paper       
                    mm -  direction of sedimentation 
                    Repaired 30.12.2021 n -> 1/n" ;

iEVermeer::usage = "Syntax iEVermeer[T ,props  ] returns hyperelastic stiffness by Vermeer for stress T (tension positive) using props = {G_ref, p_ref, \[Beta]} \n \
            Props is optional and in iEVermeer[T] the default values props = {75000, 200, 0.25 } are used, see also iCVermeer[T,props ] " ;

iCVermeer::usage = "Syntax: iCVermeer[T ,props  ] returns hyperelastic compliance by Vermeer for stress T (tension positive) using props = {G_ref, p_ref, \[Beta]} \n \
            Props is optional and in iCVermeer[T] the default values props = {75000, 200, 0.25 } are used " ;
iCNiemunis::usage = "Syntax: iCNiemunis[T ,props  ] returns hyperelastic compliance by Niemunis for stress T (tension positive) using props = {c,\[Alpha],n} \n \
            Props is optional and in iCNiemunis[T] the default values props = {1.517*10^-4,0.1,0.6} are used, see also iENiemunis[T,props ] " ;
            
iCGehring::usage = "Syntax: iCGehring[T ,props  ] returns hyperelastic compliance by Gehring for stress T (tension positive) using props = {c,\[Alpha],n,cL} \n \
            Props is optional and in iCGehring[T] the default values props = {{0.02097,0.55855,1,0.0096279}} are used " ;

iEHoulsby::usage = "Syntax:  iEHoulsby[ T_?t33Q, props_:{ 0.6, 10, 0.25 ,100 }]  hyperelastic stiffness by Houlsby at stress T
                       {n, k, nu, pa} = props;     Houlsby Amorosi Rojas 2005, no homogeneity  " ;

iELiu::usage = "Syntax:  iELiu[ eps_?t33Q, props_:{100,1.666}]  hyperelastic stiffness by Liu  at strain eps
                          {B, x }= props;    Jiang + Liu 2003  granular elasticity version cubic , max friction 17\[Degree] = convexity limit ";

orthoE::usage = "Syntax: orthoE[] or orthoE[ m , n ]  Returns orthotropic stiffness using global variables {E1,E2,E3, G1,G2,G3,n12,n13,n23}
             as material constants. Orinentation of orthotropic axes may be given as vectors m (default ={1,0,0}) and n (default = {0,1,0}) " ;  
             
orthoC::usage = "Syntax: orthoC[] or orthoC[ m , n ]  Returns orthotropic compliance using global variables {E1,E2,E3, G1,G2,G3,n12,n13,n23}
             as material constants. Orinentation of orthotropic axes may be given as vectors m (default ={1,0,0}) and n (default = {0,1,0}) " ;               

pradhanTriaxPlot::usage = "Syntax:  pradhanTriaxPlot[path,  sfi] produces Pradhan dilatancy plot with horizontal lines for M_C and M_E if sfi > 0.
                    The optional parameter sfi  = sin \[Phi]_c  is by default sfi = 0. \n \
                    Transpose[path]  = {pathT, pathEps, ... } should contain a list of states with at least two components being full stress and strain tensors
                     see also   pqTriaxPlot,  deviatoricPlot, isoTriaxPlot  " ;

pqTriaxPlot::usage = "Syntax:  pqTriaxPlot[path_, sfi_:0] produces  plots of stress and strain paths 
                       in p-q and eps_vol - eps_q planes and lines for M_C and M_E if sfi > 0. 
                    The optional parameter sfi  = sin \[Phi]_c  is by default sfi = 0. 
                    Only triaxial states in the diagonal form  DiagonalMatrix[ {Ta, Tr,Tr} ]  and   DiagonalMatrix[ {epsa, epsr,epsr} ] are  accepted.
                     Values q and eps_q may be negative. 
                    Transpose[path]  = {pathT, pathEps, ... } should contain a list of states with at least two components being full stress and strain tensors
                     see also   deviatoricPlot, isoTriaxPlot, pradhanTriaxPlot " ;

deviatoricPlot::usage = "Syntax: deviatoricPlot[path, sfi , p0, verbose-> False, criterion ->  \"MN\" , principal-> True] produces deviatoric plot of the stress path. 
                    ARGUMENTS:   path = states  a chronological list of calculated states; see documentation of states 
                                          each record of states should begin with full stress tensor  
                                 sfi  = sin \[Phi]   for the decoration plot of yield surface given by the option criterion     Matsuoka Nakai  or Mohr Coulomb
                                 p0 =   pressure  for  yield criterion if p0 < 1 then p0 = -tr[T]/3 with T from the last record of the path
                    OPTIONS:  verbose = for debugging 
                              criterion ->  \"MN\" = Matsuoka Nakai by default (also \"MC\" = Mohr Coulomb and 
                                            \"DPsmall\"  \"DPextension\" \"DPcompression\" Drucker Prager are implemented)
                              principal -> True  causes diagonalization of  the stress (first in path) before it is plotted. 
                                                  the principal stresses are sorted.  
                                        -> False  takes the  diagonal components of stress (first in path) 
                               every -> 10 is used to plot Red points every 10 calculated states from the path       
                     Tension planes are plotted too. 
                     see also   pqTriaxPlot,    isoTriaxPlot, pradhanTriaxPlot "  ;

isoTriaxPlot::usage = "Syntax:  isoTriaxPlot[path, sfi] produces  plots of stress and strain paths 
                       in isometric P-Q and eps_P - eps_Q planes and lines for M_C and M_E if sfi > 0 
                    The optional parameter sfi  = sin \[Phi]_c  is by default sfi = 0. 
                    Only triaxial states in the diagonal form  DiagonalMatrix[ {Ta, Tr,Tr} ]  and   DiagonalMatrix[ {epsa, epsr,epsr} ] are  accepted.
                    Values Q and eps_Q may be negative.
                    Transpose[path]  = {pathT, pathEps, ... } should contain a list of states with at least two components 
                     being t33Q stress and strain tensors.  
                     see also   pqTriaxPlot,  deviatoricPlot,  pradhanTriaxPlot ";
                     
isoPlot::usage = "Syntax:  isoPlot[path, sfi] produces PQ-plots of  stress and strain paths 
                    in isometric P-Q (and eps_P - eps_Q if included in path) diagrams.  
                     Decoration lines  Q = M_C * P and  Q = M_E P  are plotted if sfi > 0 
                    The optional parameter sfi  = sin \[Phi]_c  is by default sfi = 0. 
                   Full t33Q tensors possibly with off-diagonal components are  accepted.
                    Values Q and eps_Q are nonnegative.
                    See also   pqTriaxPlot,  deviatoricPlot,  pradhanTriaxPlot ";                   

stressResponsePQ::usage = "Syntax:  stressResponsePQ[ constitutiveUpdate, state,  params, disturbance] a response envelope  in isomoprphic P-Q
                      space is plotted using a constitutive model's name constitutiveUpdate[state, de, params ] with strain increment de.
                      The costitutive model takes the state = {T,eps, ... }  and returns the updated state obtained with de and params, e.g.
                      constitutiveUpdate[ state_, de_,params_]:=Module[{T,dT,eps},{T,eps} = state[[1;;2]]; dT=iEVermeer[T]~colon~de; {T+dT, eps+de, ....} ]
                      stressResponsePQ[constitutiveUpdate, {-100*delta ,0*delta, .... }, {  }   ]  \n \
                      Various increments de of length disrurbance (defaut = 0.001) are tried out in the module stressResponsePQ. Red point corresponds   \n \
                      to de of isotropic compression.  See also stressResponsePstarQstar,  stressResponse3D,stressResponse3Dstar. "  ;
                      
stressResponsePstarQstar::usage = "Syntax:  stressResponsePQ[ constitutiveUpdate, state,  params, disturbance] a response envelope  in isomoprphic Pstar-Qstar
                      space is plotted using a constitutive model's name constitutiveUpdate[state, de, params ] with strain increment de.
                      Strain increments are also plotted and basis vectors ePstar, eQstar are given.
					  This costitutive model takes the state = {T,eps, ... }  and returns the response with de and updated state obtained and params, e.g.
                      constitutiveUpdate[ state_, de_, params_]:=Module[{T,dT,eps},{T,eps} = state[[1;;2]]; dT=iEVermeer[T]~colon~de; {T+dT, eps+de,... } ]
                      stressResponseDPstarDQstar[constitutiveUpdate, {-100*delta ,0*delta, ... }, {  }   ]  \n \
                      Pstar-Qstar space is obtained as orthogonalized stress responses for isotropic and deviatoric strain perturbations, respectively,
                      to plot response envelopes in the case of complex superposed anisotropy, so soleley the responses \[CapitalDelta]Pstar, \[CapitalDelta]Qstar are plotted.                      
                      The initial stress state cannot be plotted in Pstar-Qstar because it is not coaxial with the stress responses for complex superposed anisotropy.
                      Various increments de of length disrurbance (defaut = 0.001) are tried out in the module stressResponsePstarQstar. Red point corresponds   \n \
                      to de of isotropic compression.  See also stressResponsePQ, stressResponse3D, stressResponse3Dstar. "  ;                      

 stressResponse3D::usage = "Syntax:  stressResponse3D[ constitutiveUpdate, state,  params, disturbance] a response envelope in the space of   \n \
                      principal stresses T1,T2,T3  is plotted using a constitutive model constitutiveUpdate[state, de, params ] with strain increment de.      
                      This costitutive model takes the state = {T,eps, ... }  and returns the updated state obtained with de and params. \n \
                      Various increments de, each of identical length = disrurbance (defaut = 0.001),  are tried out in the module  stressResponse3D 
                      Red point corresponds to de of isotropic compression. See also stressResponsePQ, stressResponsePstarQstar and stressResponse3Dstar  " ;                                           
                                  
stressResponse3Dstar::usage = "Syntax:  stressResponse3Dstar[ constitutiveUpdate, state,  params, disturbance] a response envelope  in isomoprphic Pstar-Qstar-Rstar
                      space is plotted using a constitutive model's name constitutiveUpdate[state, de, params ] with strain increment de.
                      Strain increments are also plotted and basis vectors ePstar, eQstar, eRstar are given.
                      This costitutive model takes the state = {T,eps, ... }  and returns the response with de and updated state obtained and params, e.g.
                      constitutiveUpdate[ state_, de_, params_]:=Module[{T,dT,eps},{T,eps} = state[[1;;2]]; dT=iEVermeer[T]~colon~de; {T+dT, eps+de, ...} ]
                      stressResponse3Dstar[constitutiveUpdate, {-100*delta ,0*delta, ... }, {  }   ]  \n \
                      Pstar-Qstar-Rstar space is obtained as orthogonalized stress responses for isotropic and deviatoric strain perturbations
                      and strain perturbation perpendicular to both, respectively,
                      to plot response envelopes in the case of complex superposed anisotropy, so soleley the responses \[CapitalDelta]Pstar, \[CapitalDelta]Qstar, \[CapitalDelta]Rstar are plotted.                      
                      The initial stress state cannot be plotted in Pstar-Qstar-Rstar because it is not coaxial with the stress responses for complex superposed anisotropy.
                      Various increments de, each  of identical length = disrurbance (defaut = 0.001), are tried out in the module stressResponse3Dstar. Red point corresponds   \n \
                      to de of isotropic compression.  See also stressResponse3D,  stressResponsePstarQstar and stressResponsePQ. "  ;

xyp2T::usage= "Syntax xyp2T[x_, y_, p_] given a point  {x,y)  on the devatoric plane p=const return  the corresponding diagonal tensor,
                see also inverse function T2xyp[ t33 ]  ";

T2xyp::usage= "Syntax T2xyp[ t33 ] given a tensor t33  returns the corresponding  point $x,y$ on the devatoric plane p=const,
                see also inverse function  xyp2T[x, y, p] ";

deviatoricContourPlot::usage = "Syntax: deviatoricContourPlot[p,  expression, contour, rangefactor  ]
                   plots all states on deviatoric plane p=const that satisfy  expression == contour. Zoom out with rangefactor > 1. Default is  rangefactor = 1.
                   For example, we may define
                   Lade[T_] :=  (-i1[T])^3+ 5^3/3 * i3[T]  ;   or
                   Coulomb[T_] := Module[{Tmax,Tmin,diag },diag=-{T[[1,1]],T[[2,2]],T[[3,3]]}; Tmax=Max[diag ]; Tmin=Min[diag];  Tmax/ Tmin  ];
                   and then  evoke:    deviatoricContourPlot[100, Lade, 0 ] or   deviatoricContourPlot[100, Coulomb , 3 ]" ;

deviatoricRangePlot::usage = "Syntax: deviatoricRangePlot[p, inequality , rangefactor  ]
                   plots all states on deviatoric plane p=const that satisfy the inequality. You zoom out with rangefactor > 1. Default is  rangefactor = 1.
                   For example, we may define
                   Lade[T_] :=  (-i1[T])^3+ 5^3/3 * i3[T]  < 0;   or
                   Coulomb[T_] := Module[{Tmax,Tmin,diag },diag=-{T[[1,1]],T[[2,2]],T[[3,3]]}; Tmax=Max[diag ]; Tmin=Min[diag]; 0< Tmax/ Tmin <3 ];
                   and then  evoke:    deviatoricRangePlot[100, Lade ] or   deviatoricRangePlot[100, Coulomb ]" ;

matrixDiagonal::usage = "Syntax: matrixDiagonal[T] if  called with an argument  t33Q returns a list of diagonal components  (identical to Mma internal Diagonal[] )
                         If matrixDiagonal[T] is  called with an argument t3333Q  then a 3x3 matric of normal components is returned   \ "
                         
pickListPlot::usage = "Syntax: pickListPlot[ alist, {{#[[1]] ,  #[[2]] + #[[3]]  }}, every-> 10 ] from a 2D alist  plots a combination of its columns
                        according to the pattern {x,y}. Usually pickListPlot  plots states = {{e1,e2,s1,s2,....}, {e1,e2,s1,s2, ...}, {}, }  \n \
                        Alternative sytnax is:    pickListPlot[ alist,  {3, 2} ] or  pickListPlot[ alist,  {3, 5, 2} ]   to plot the 2nd column  over 1st column.
                         In the Pattern version
                        you may also add y2 for comparison,  e.g.  pickListPlot[ alist, {{#[[1]] ,  #[[1]] + #[[2]] , #[[3]] - #[[2]] }} ] Options for Graphics
                        can be set via variable  gOptions={.....} , per default: gOptions = {PlotRange \[Rule] All, PlotMarkers \[Rule] Automatic}    " ;
gOptions::usage = "Syntax gOptions = { PlotRange -> {0,2}, AspectRatio -> Automatic, PlotMarkers \[Rule] Automatic ... }  sets options for Graphics
                    to be used  in pickListPlot[ ]  isoTriaxPlot[ ]  per default: gOptions = {PlotRange \[Rule] All, PlotMarkers \[Rule] Automatic}.
                    You may write it new or just modify using AppendTo[gOptions , AxesLabel \[Rule]  {x,y} ]   ";
every::usage = "if a value greater than every -> 1 is used in the pickListPlot then not all points are plotted "

step::usage = "Syntax:  step[ mat,  loading, ninc, OptionsPattern[] ] is a loop calling  ninc times the user's routine 
               increment[mat,  loading, OptionsPattern[] ]. The routine increment uses the last record from the global variable states (must be initialized)
                and returns the updated state. This updated state is appended to states by the routine step. 
                The constitutive routine increment[mat,  loading  OptionsPattern[]]  should start with    {eps, sig, ..} = Last[ states ].
               ARGUMENTS:   mat =  a list of material constants 
                            loading = usually an icrement of deformation (Lb dt or DB dt) applied in each increment 
                            ninc = number of increments calculated with the same mat and the same loading 
               OPTIONS: verbose = comments are printed 
                        ZarembaJaumann = add the Z-J terms to each increment 
                        HughesWinget = rotates stress using the H-W algorithm in each  increment   
              OUTPUT:   states  appended by ninc records           
               Similar functions:  parametricStep[] or cycle[ ] " ;

parametricStep::usage = "Syntax: parametricStep[ mat_,  loading_,  iinc_ , ninc_]  is a loop calling 
            increment[mat,  loading , OptionsPattern[]] and appending
            the updated states (returned by increment[ ] )  to states. 
            It is assumed that the constitutive routine increment[mat_,  loading_ , OptionsPattern[]]
            reads the current state using   {...} = Last[ states ].  
            loading[iinc] is a user's function that describes a load increase in increment iinc.
            Similar functions: step[] and cycle[]." ;

cycle::usage = "Syntax:  cycle[mat_,  loading1_ ,ninc1_,loading2_ ,ninc2_,ncyc_, OptionsPattern[] ]
                 is a loop calling  twice step[ ] per cycle 
                  ARGUMENTS:  mat =  a list of material constants  
                                loading1 = usually an icrement of deformation ({Lb, dt} or {Db, dt}) applied in each increment  
                                 ninc1 = number of increments with loading1
                                loading2 = usually an icrement of deformation (Lb dt or DB dt) applied in each increment  
                                 ninc2 = number of increments with loading2
                                 ncyc = number of cycles with (ninc1+ninc2) increments  
                   OPTIONS:   verbose = comments are printed 
                   OUTPUT:   states will be appended by  ncyc*(ninc1+ninc2) records           
                  it is assumed that the constitutive routine increment[mat_,  loading_, OptionsPattern[] ] 
                    reads the current state using   {...} = Last[ states ]
                   see also step, increment , loading  ";

increment::usage="User's routine  to calculate  an updated state using states and the given strain increment.  
            It is used as  AppendTo[states, increment[mat_, loading_ , OptionsPattern[]] ]. 
            Denining your constitutive model via increment note that  OptionsPattern[] MUST APPEAR ON THE  LIST OF FORMAL ARGUMENTS. 
            The first line should be   {sig, eps, epor ...} = states ;  {dL, dt } = loading;  
             states with the first record  should be initialized before calling increment[]              
             Next a code for the update  of strain, stress and state variables should be provided 
             The last  line  should contain the updated state  {sig, eps, ...}  ]
              ARGUMENTS:    mat = {\"HP\", phi, .. } =  a list of material constants should begin with the material name 
                            loading =  = {dL, dt .. } = velocity gradient and time increment; strain increment loading= Db*dt  is obsolete      
               OPTIONS: verbose = comments are printed
                        ZarembaJaumann = add the Z-J terms to the increment 
                        HughesWinget = rotates stress using the H-W algorithm  
              OUTPUT:   a single record with the updated state (to be appended to states)   "  ;

states::usage = "A global variable containing chronologically stored  records of material state 
                states is needed inside the users' routine increment[ ] incrementEP[ ]  incrementHP[ ] which should begin  with state = Last[states]; 
                 states with the first record  should be initialized before calling increment[]       
                states is elongated after each increment in step[]  or in incrementalDriver[] in the line  AppendTo[states, updatedstate]; 
                The content of states may be used in many plot routines:     
                      pradhanTriaxPlot, pqTriaxPlot, deviatoricPlot, isoTriaxPlot
                     stressResponse3D,   stressResponse3Dstar,  stressResponsePstarQstar, stressResponsePQ 
                 They assume  that each states record is: {stressTensor, strainTensor, voidRatio,...  } , all in mechanical sign convention  
                 The strainTensor is somewhat obsolete and it is being  replaced by the deformation gradient Ftot. 
                 For example, Ftot is used  everywhere in the script models.wl, in particular  
                 in incrementalDriver[] and in all plot.. routines there 
                states\[LeftDoubleBracket]1\[RightDoubleBracket] should be  initialized  depending on the model : 
                Elastoplastic models \"MC\",\"MN\",\"DP\" and hypoplastic models  need  initialization states = {{T0, F0, epor0}} ; 
                but the \"AVHP\" needs initialization states = { {T,Ftot,epor,omega,pB} } ; 
                   
";

mat::usage="a list of material parameters for the routines, increment[], step[] cycle[], etc. 
             It is a good practice to give the name of the material as the first item on the list 
              mat = {matname, Y, nu, phi } can be used for predefined elastoplastic models;  matname is one of {\"MC\", \"MN\",\"DP\", } or   
              mat = {\"HP\",   ,fi, hs,       n,   ed0, ec0,  ei0,   alfa, beta   }   for the predefined hypoplastic  model  or
              mat = {\"AVHP\",    e100, lambda, kappa, Iv,   Dr,   phi, C1, C2, C3   }   for the predefined aniso-visco-hypoplastic model    
             Some sets of material constants may  be defined by name, for example 
              mat = {\"HP\",  \"Ticino\" }   
             see the function knownMat[ ] in models.wl  
";

loading::usage="loading parameters for increment[] step[] or incrementalDriver[] 
                 For predefined EPincrement and HPincrement use loading = {Lb, dt } i.e. velocity gradient and time increment
                 For  incrementalDriver  loading = {Lb, dt, dT, ifdT } may contain also the stress rate and a 3x3 matrix ifdT 
                 ifdT has True as components where dT is prescribed
"  ; 

loading1::usage="first loading  in cycle[], see loading "  ;
loading2::usage="second loading in cycle[], see loading "  ;

ninc::usage="number of increments for step[] cycle[] "  ; 
ninc1::usage="number of increments for  cycle[] "  ; 
ninc2::usage="number of increments for  cycle[] "  ;
ncyc::usage="number of cycles for cycle[] "   ;

\[Nu]::usage=" \[Nu] is the Poisson number as a global variable ";       (* to be changed to Global`\[Nu] in future *)
e::usage=" e is the Young modulus  as a global variable ";
Eh::usage=" Eh is the horizontal Young modulus  as a global variable ";
Ev::usage=" Ev is the vertical  Young modulus  as a global variable ";
nh::usage=" nh is a  transverse isotropic  Poisson number   as a global variable ";
nhv::usage=" nhv is a  transverse isotropic  Poisson number   as a global variable ";
Gv::usage=" Gv is a transverse isotropic  shear modulus  as a global variable ";
E1::usage=" E1 is an orthotropic  Young modulus   as a global variable ";
E2::usage=" E2 is an orthotropic Young modulus  as a global variable ";
E3::usage=" E3 is an orthotropic  Young modulus  as a global variable ";
n12::usage=" n12 is  an orthotropic     Poisson number   as a global variable ";
n13::usage=" n13 is  an orthotropic     Poisson number   as a global variable ";
n23::usage=" n23 is  an orthotropic     Poisson number   as a global variable ";
G12::usage=" G12   an orthotropic     shear modulus  as a global variable ";
G13::usage=" G12   an orthotropic     shear modulus  as a global variable ";
G23::usage=" G12   an orthotropic     shear modulus  as a global variable " ;

voigtEps::usage="voigtEps[ e_?t33Q ] converts a strain tensor to a Voigt strain vector 1:6 with doubled shear components   ";
voigtEpsi::usage="voigtEpsi[{e1_,e2_,e3_,g12_,g13_,g23_}]  converts a  Voigt strain vector 1:6 with doubled shear components to a strain tensor 3:3 ";
voigtSig::usage=" voigtSig[ s_?t33Q ] converts a stress tensor to Voigt stress vector 1:6  ";
voigtSigi::usage="voigtSigi[{s1_,s2_,s3_,t12_,t13_,t23_}]  converts a Voigt stress vector 1:6  to  a stress tensor 3:3 ";
voigtE::usage="voigtE[ e_?t3333Q ] converts a stiffness tensor e 3:3:3:3 to Voigt stiffness matrix  6:6  ";
voigtEi::usage="voigtEi[ e_?t66Q ] converts Voigt stiffness matrix  6:6  to a stiffness tensor e 3:3:3:3   ";
voigtC::usage="voigtC[ c_?t3333Q ] converts a compliance tensor c 3:3:3:3 to Voigt compliance matrix  6:6  ";
voigtCi::usage="voigtC[ c_?t66Q ] converts a  Voigt compliance matrix  6:6 to a compliance tensor c 3:3:3:3    ";

convert::usage = "Syntax: \[Alpha] =  convertCart2Spher[t,p] or convertSpher2Cart[t,p] or convertCart2Cyl or convertCyl2Cart 
returns the transformation matrix 33 for converting components of vectors and tensors in 
Cartesian (x1,x2,x3) and spherical-polar (R,t,p) or Cylindrical bases for a given point with R=the distance of the point from the origin of x1,x2,x3-System.
t [radians]=the angle between x3 and the location vector of the point (t=ArcCos[x3/R] \[Element] <0,180\[Degree]>), p [radians]=the angle between x1 and the projection of the location vector onto the plane x1-x2  (p=ArcTan[x2/x1] \[Element] <0,360\[Degree]>). 
Matrix \[Alpha] is orthogonal and can be applied to any tensor / vector  using: \[Alpha] = convert...[];  T1 = rotateTensor[T, \[Alpha]];   
 See  also  rotateTensor[]";
 

convertCart2Spher::usage = "Syntax:  \[Alpha] = convertCart2Spher[t,p]; returns the transformation matrix 33  from
cartesian (x1,x2,x3) into spherical-polar (R,t,p) base at a given point.  
 R[m] = the distance of the point from the origin of x1,x2,x3,
 t[radians]=the angle between x3 and the location vector of the point (t=ArcCos[x3/R] \[Element] <0,180\[Degree]>), 
 p[radians]=the angle between x1 and the projection of the location vector onto the plane x1-x2 (p=ArcTan[x2/x1] \[Element] <0,360\[Degree]>).   
See  also  convertSpher2Cart[].  Usually  \[Alpha] = convertCart2Spher[t,p];  T1 = rotateTensor[T, \[Alpha]];   " ;

convertSpher2Cart::usage = "Syntax:  convertSpher2Cart[t,p] returns the transformation matrix 33 for converting vectors and tensors from
spherical-polar (R,t,p) into cartesian (x1,x2,x3) base for a given point with 
R=the distance of the point from the origin of x1,x2,x3,
t[radians]=the angle between x3 and the location vector of the point (t=ArcCos[x3/R] \[Element] <0,180\[Degree]>), 
p[radians]=the angle between x1 and the projection of the location vector onto the plane x1-x2 (p=ArcTan[x2/x1] \[Element] <0,360\[Degree]>)
See  also  convertCart2Spher[].   Usually  \[Alpha] = convertSpher2Cart[t,p];  T1 = rotateTensor[T, \[Alpha]];   ";

convertCart2Cyl::usage = "Syntax:  convertCart2Cyl[t] returns the transformation matrix 33 for converting vectors and tensors from
cartesian (x1,x2,x3) into cylindrical-polar (r,t,x3) base for a given point with 
r=the distance of the point from the axis of the cylinder,
t[radians]=the angle between x1 and the location vector of the point on the plane x1-x2 (t=ArcTan[x2/x1] \[Element] <0,360\[Degree]>)
z=x3.
See  also  convertCyl2Cart[]. Usually  \[Alpha] = convertSpher2Cart[t,p];  T1 = rotateTensor[T, \[Alpha]];  
";

convertCyl2Cart::usage = "Syntax:  convertCyl2Cart[t,p] returns the transformation matrix 33 for converting vectors and tensors from
cylindrical-polar (r,t,x3) into cartesian (x1,x2,x3) base for a given point with 
r=the distance of the point from the axis of the cylinder,
t [radians]=the angle between x1 and the location vector of the point on the plane x1-x2 (t=ArcTan[x2/x1] \[Element] <0,360\[Degree]>),
z=x3
See  also  convertCart2Cyl[].  Usually \[Alpha] = convertSpher2Cart[t,p];  T1 = rotateTensor[T, \[Alpha]];  
";

 getMohrParamsT::usage=" Syntax : {m,R} =  getMohrParamsT[ Tb ] 
ARGUMENT   = Tb = 2x2 stress  field in x1,x2 plane (mech. convention with tension positive)
 output:   m =  position of the center of the Mohr circle along x-axis = sigma  
           R = radius of the Mohr circle  ";

 getMohrParamsL::usage=" Syntax : {m,R,w} =  getMohrParamsL[ Lb ] 
ARGUMENT : = L = 2x2 spatial gradient of velocity field in x1,x2 plane
 output:   m =  position of the center of the Mohr circle along x-axis = dot epsilon 
           w = position of the center of the Mohr circle along y-axis = - dot gamma/2 
           R = radius of the Mohr circle  ";

plotCircleT::usage=" Syntax:   {gA, gB} = plotCircleT[Tb , alpha  ] 
ARGUMENTS:   Tb = 2x2 stress in x1,x2 plane (tension positive and x1 is a horizontal axis pointing to the right)  
            alpha = inclination to x1 of the  cross-section  for which the components sigma, tau are marked on the circle
 returns    gA = plot of the physical coordinate system and the axes hb and nb parallel and normal to the cross-section alpha
             gB = graphics with the Mohr circle its Pol and marked position wich components of stress vector
                   on the cross-section alpha.
             See also plotCircleL[ ]    "; 
                  
plotCircleL::usage=" Syntax:   {gA, gB} = plotCircleL[Lb , alpha  ] 
ARGUMENTS:   L = 2x2 spatial gradient of velocity field in x1,x2 plane (tension positive x1 is a horizontal axis pointing to the right)
            alpha = inclination to x1 of a line for which the velocity gradient is plotted on the 
 returns    gA = vector plot of the deformation 
            gB = graphics with the Mohr circle its Pol and marks the 
                 point with velocity gradient along a line inclined to x1 by alpha.
             See also plotCircleT[ ]  "; 
                
 getStrain::usage=" Syntax 1 :
              eps33 = getStrain[  {ur[r,t,f],ut[r,t,f],uf[r,t,f]}, {r,t,f}, \"Spherical\"  ]; 
              or Syntax 2
              eps33 = getStrain[  {ur[r,t,f],ut[r,t,f],uf[r,t,f]},  {r,t,f}, \"Spherical\" , rules ]; 
              or Syntax 3
              eps33 = getStrain[ \"Spherical\"  ]; 

              calculates small strain Matrix eps33 from 
               displacement components {u1,u2,u3} with respect to coordinates {x1,x2,x3}. 
              In the spherical case  the displacements can be  {ur[],ut[],uf[]} general or particular 
              functions of  the coordinates which are usually {r,\[Theta],\[Phi]}.
               The first syntax functions may contain any functions or numbers. 
              The constraints (for example a symmetry) can  be defined as rules see syntax 2. 
  
              Both deformations and coordinates are assumed to be given in the same reference system:
              Spherical, Cylindrical or Cartesian (per Default). 
               spherical coords in the order:  r= radius, \[Theta] = polar angle \[Phi] = azimuthal angle 
               cylindrical coords in the order r= radius, \[Theta] = azimuthal angle, z= height. 
              The calculation is based on the internal Mma function Grad[ ]
              Rules (if any) are applied twice: before differentiation and after differentiation. 
" ;               
                 
 getStressDiv::usage=" Syntax 
              div3 = getStressDiv[  {{srr[r,t,f],srt[r,t,f],srf[r,t,f]},
                                     {str[r,t,f],stt[r,t,f],stf[r,t,f]},
                                     {sfr[r,t,f],sft[r,t,f],sff[r,t,f]} }, {r,t,f}, \"Spherical\"  ]; 
                or Syntax 2
               div3 = getStressDiv[  {{srr[r,t,f],srt[r,t,f],srf[r,t,f]},
                                     {str[r,t,f],stt[r,t,f],stf[r,t,f]},
                                     {sfr[r,t,f],sft[r,t,f],sff[r,t,f]} }, {r,t,f}, \"Spherical\" ,rules ]; 
               or Syntax 3
              div3 = getStressDiv[  \"Spherical\"  ]; 
             Returns three divergencies  sigma_{ij,j}  from  the stress components
             for example {{srr, srt, srf},{str,stt,stf},{sfr,sft,sff} } , 
               with respect to the coordinates    for example {r,\[Theta],\[Phi]}.
               Stress components should be general or particulat functions, for example of {r,\[Theta],\[Phi]}.
               In The first syntax functions may contain any functions or numbers. 
              The constraints (for example a symmetry) can  be defined as rules see syntax 2. 
              Both stress components  and coordinates are assumed to be given in the same reference system:
              Spherical, Cylindrical or Cartesian (per Default). 
               spherical coords should be in the order:    r= radius, \[Theta] = polar angle \[Phi] = azimuthal angle 
               cylindrical coords should be in the order:  r= radius, \[Theta] = azimuthal angle, z= height. 
              The calculation is based on the internal Mma function Div[ ]
              Rules (if any) are applied twice: before differentiation and after differentiation. 
" ;   

containsComplexQ::usage=" syntax If[containsComplexQ[A] , Print[\"error, A=\",A ]  ] can be used for debugging: 
                             detects complex numerical number(s) in A = a scalar or a list  and returns True if any" ;  
                 
                                                   


Begin["`Private`"]

containsComplexQ[a_ ] := Module[{b},  
b = Flatten[ { a }];
br=  Select[ b,  Element[#,Reals]& ] ; 
Length[br] != Length[b]
];

where[cond_, inT_?t33Q,  inF_?t33Q] := Module [ { output, i,j ,vars,rule,test,oV},  
   oV = False;  
 output =Array[0&, {3,3}];
If[Dimensions[cond]=={3,3},
      Do[ If[cond[[i,j]] , output[[i,j]] = inT[[i,j]] , output[[i,j]] = inF[[i,j]] ];
         ,{i,1,3},{j,1,3}]     ] ;
If[Dimensions[cond] != {3,3},
    If[oV, Print[cond]] ; 
    list = makeList[cond ]; 
    If[oV, Print["list= ", list]] ;  
    vars = symbolVariables[ cond ]; 
     If[oV, Print["vars= ", vars]] ; 
    If[ Length[vars] > 2 , Print["where:error condition ", cond, "  contains more than 2 symbolic variables: ", vars ]; Abort[]; ] ; 
    If[ Length[vars] < 2 , Print["where:error condition ", cond, "  contains less than 2 symbolic variables: ", vars ]; Abort[]; ] ; 
    rule  = MapThread[ Rule, {vars, {i,j} } ];  (*  global i, j take the lokal values *)
     If[oV, Print["rule= ", rule]] ; 
    test = cond; 
    If[ StringQ[test], test = ToExpression[test]   ] ; 
    Do[ If[test //. rule , output[[i,j]] = inT[[i,j]] , output[[i,j]] = inF[[i,j]] ];
        ,{i,1,3},{j,1,3}]      ] ;
  output
] ;

where[cond_, inT_?t3Q,  inF_?t3Q] := Module [ { output, i,j ,vars,rule,test,oV},  
   oV = False;  
 output =Array[0&, {3}];
If[Dimensions[cond]=={3},
      Do[ If[cond[[i,j]] , output[[i,j]] = inT[[i,j]] , output[[i,j]] = inF[[i,j]] ];
         ,{i,1,3}]     ] ;
If[Dimensions[cond] != {3},
    If[oV, Print[cond]] ; 
    list = makeList[cond ]; 
    If[oV, Print["list= ", list]] ;  
    vars = symbolVariables[ cond ]; 
     If[oV, Print["vars= ", vars]] ; 
    If[ Length[vars] > 1 , Print["where:error condition ", cond, "  contains more than 1 symbolic variable : ", vars ]; Abort[]; ] ; 
    If[ Length[vars] < 1 , Print["where:error condition ", cond, "  contains less than 1 symbolic variables : ", vars ]; Abort[]; ] ; 
     rule =  Rule[ vars[[1]] , i]  (*  global i  takes the lokal value *) ; 
     If[oV, Print["rule= ", rule]] ; 
    test = cond; 
    If[ StringQ[test], test = ToExpression[test]   ] ; 
    Do[ If[test //. rule , output[[i]] = inT[[i]] , output[[i]] = inF[[i]] ];
        ,{i,1,3}]  ] ;
  output
] ;

componentwise[pure_, a_, b_] := Module[ {da, db}, 
da = Dimensions[a];  db = Dimensions[b];  
If[da != db , Print["componentenwise:error incompatible dimensions of a= ",a, " and b=",b];Abort[];];
ArrayReshape[   MapThread[ pure, {Flatten[ a] ,Flatten[b] }], da] 
];

makeList[term_?StringQ]:=ToExpression/@StringSplit[term, {"+","-","*","/",">",  "!="  , "<",   "==" , " " , "(", ")"}];  
                                    
makeList[term_]:=ToExpression/@StringSplit[ToString[term,InputForm],
                                    {"+","-","*","/",">",  "!= ",  "<",   "==" ,   " " , "(", ")"}]; 
symbolVariables[ term_ ] := DeleteCases[ Select[  makeList[ term ], \[Not] NumberQ[#]&  ] ,Null]// DeleteDuplicates // Sort ; 





getStrain[  uuu_, xxx_,  system_:"Cartesian"  ] := Module[ {u1, u2, u3, x1,x2,x3,gu,eps},
 {u1, u2, u3} = uuu;   {x1,x2,x3}= xxx; 
  gu  = Grad[{u1 , u2 , u3 }, xxx , system];  
eps = ( gu + Transpose[gu] )/2; 
eps  // Simplify 
];

getStrain[  uuu_, xxx_,  system_:"Cartesian", rules_  ] := Module[ {u1, u2, u3, x1,x2,x3,gu,eps},
 {u1, u2, u3} = uuu //. rules ;   
 {x1,x2,x3}= xxx //. rules ;    
  gu  = Grad[{u1 , u2 , u3 }, xxx , system] //. rules ;   
eps = ( gu + Transpose[gu] )/2 //. rules ; 
eps // Simplify 
];

getStrain[  system_:"Cartesian"  ] := Module[  {u1, u2, u3, x1,x2,x3,gu,eps, uuu, xxx },
   uuu =  {Global`ux, Global`uy, Global`uz} ;  xxx = {Global`x,Global`y,Global`z} ; 
  If[system =="Spherical", uuu = {Global`ur, Global`ut, Global`uf} ; xxx = {Global`r,Global`\[Theta],Global`\[Phi]} ]; 
  If[system =="Cylindrical", uuu = {Global`ur, Global`ut, Global`uz} ; xxx = {Global`r,Global`\[Theta],Global`z} ]; 
  If[ anyNumberQ[(uuu ~Join~xxx) ], Print["getStrain error: Some global variables in uuu=", uuu, " or in xxx=", xxx, " are numeric "] ;  Abort[] ]; 
  {u1, u2, u3} = uuu;   {x1,x2,x3}= xxx; 
  gu  = Grad[{u1[x1,x2,x3], u2[x1,x2,x3], u2[x1,x2,x3]}, xxx , system];  
eps = ( gu + Transpose[gu] )/2; 
eps
];

getStressDiv[  system_:"Cartesian"] := Module[{s1,s2,s3,xxx,sss},
 sss =  Partition[{Global`Txx,Global`Txy,Global`Txz,Global`Txy,Global`Tyy,Global`Tyz,Global`Txy, Global`Tyz, Global`Tzz} ,3];
 xxx =  {Global`x,Global`y,Global`z }  ; 
  If[system =="Spherical", 
        sss =  Partition[{Global`Trr,Global`Trt,Global`Trf,Global`Trt,Global`Ttt,Global`Ttf,Global`Trf, Global`Ttf, Global`Tff} ,3];
        xxx = {Global`r,Global`\[Theta],Global`\[Phi]} 
     ]; 
 If[system =="Cylindrical",  
         sss =  Partition[{Global`Trr,Global`Trt,Global`Trz,Global`Trt,Global`Ttt,Global`Ttz,Global`Trz, Global`Ttz, Global`Tzz} ,3];
         xxx = {Global`r,Global`\[Theta],Global`z} 
     ]; 
  If[anyNumberQ[(sss~Join~xxx) ]  , Print["getStressDiv error: Some global variables in stress ", sss, " or in xxx = ", xxx, " are numeric "] ;  Abort[] ];      
{x1,x2,x3 } = xxx; 
s1 = #[x1,x2,x3]& /@ sss[[1]]; 
s2 = #[x1,x2,x3]& /@ sss[[2]]; 
s3 = #[x1,x2,x3]& /@ sss[[3]]; 
div  = Div[{s1,s2,s3}, xxx, system ]; 
div
] ;


getStressDiv[ sss_ , xxx_ , system_:"Cartesian"] := Module[{s1,s2,s3,d1,d2,d3},
 If[anyNumberQ[ xxx ]  , Print["getStressDiv error: Some global variables in xxx = ",  xxx, " are numeric "] ;  Abort[] ]; 
div  = Div[sss, xxx, system ]; 
div // Simplify 
] ;

getStressDiv[ sss_ , xxx_ , system_:"Cartesian",  rules_] := Module[{sss1 ,xxx1, div },
 If[anyNumberQ[ xxx ]  , Print["getStressDiv error: Some global variables in xxx = ",  xxx, " are numeric "] ;  Abort[] ]; 
sss1 = sss //. rules;  
xxx1 = xxx //. rules;  
div  = Div[sss1, xxx1, system ] //. rules; 
div // Simplify 
] ;


states = {{}};  (* a prototype of a global variable with the  list of states of a material  *)
convertCart2Spher[t_,p_]:={{Sin[t]*Cos[p],Sin[t]*Sin[p],Cos[t]},{Cos[t]*Cos[p],Cos[t]*Sin[p],-Sin[t]},{-Sin[p],Cos[p],0}};
convertSpher2Cart[t_,p_]:={{Sin[t]*Cos[p],Cos[t]*Cos[p],-Sin[p]},{Sin[t]*Sin[p],Cos[t]*Sin[p],Cos[p]},{Cos[t],-Sin[t],0}};
convertCyl2Cart[t_]:={{Cos[t],-Sin[t],0},{Sin[t],Cos[t],0},{0,0,1}};
convertCart2Cyl[t_]:={{Cos[t],Sin[t],0},{-Sin[t],Cos[t],0},{0,0,1}};


voigtEps[ e_?t33Q ] := {e[[1,1]] ,     e[[2,2]] , e[[3,3]] , e[[1,2]] +  e[[2,1]] ,    e[[1,3]] + e[[3,1]] ,     e[[2,3]]  +e[[3,2]]   };
voigtEps[ e_?t9Q ] := {e[[1]], e[[2]] , e[[3]] , e[[4]] +  e[[5]] ,    e[[6]] + e[[7]] ,     e[[8]]  +e[[9]]   };
voigtEpsi[{e1_,e2_,e3_,g12_,g13_,g23_}] := {{e1, g12/2, g13/2},{g12/2,e2,g23/2},{g13/2, g23/2, e3}};
voigtSig[ s_?t33Q ] := {s[[1,1]] ,    s[[2,2]] , s[[3,3]] , s[[1,2]], s[[1,3]], s[[2,3]]};
voigtSig[ e_?t9Q ] := {e[[1]], e[[2]], e[[3]], e[[4]],  e[[6]],  e[[8]]};
voigtSigi[{s1_,s2_,s3_,t12_,t13_,t23_}] := {{s1, t12 , t13 },{t12 ,s2,t23 },{t13 , t23 , s3}};

voigtE[ e_?t3333Q ] :=   Module[ {a,aux,aux1,aux2,aux3,output},
a = transfer99[e];
aux1 = (a[[All, 4]] + a[[All, 5]] )/2;
aux2 = (a[[All, 6]] + a[[All, 7]] )/2;
aux3 = (a[[All, 8]] + a[[All, 9]] )/2;
aux = Transpose[{aux1,aux2,aux3}];
output = Array[0 & ,{6,6}] ;
output[[1;;4,1;;3]] = a[[1;;4,1;;3]];
output[[1;;4,4;;6]] = aux[[1;;4,1;;3]];
output[[5, 1;;3 ]] = a[[6,1;;3 ]];
output[[5, 4;;6 ]] = aux[[6,1;;3 ]];
output[[6, 1;;3 ]] = a[[8,1;;3 ]];
output[[6, 4;;6 ]] = aux[[8,1;;3 ]];
output
];

voigtEi[ ee_?t66Q ] :=   Module[ {c1,c2,c3, c4,c5,c6,r1,r2,r3, r4,r5,r6, aux,aux1,aux2,aux3,output},
{c1,c2,c3, c4,c5,c6}= Transpose[ee] ;  (* makes the columns 4,5,6 double *)
{r1,r2,r3, r4,r5,r6} = Transpose[ {c1,c2,c3,c4,c4,c5,c5,c6,c6}];
output = {r1,r2,r3, r4,r4,r5,r5,r6,r6}  ; (* makes the rows 4,5,6 double *)
transfer99i[output]
];



voigtC[ e_?t3333Q ] :=   Module[ {a,aux,aux1,aux2,aux3,output},
a = transfer99[e];
aux1 = (a[[All, 4]] + a[[All, 5]] ) ;
aux2 = (a[[All, 6]] + a[[All, 7]] ) ;
aux3 = (a[[All, 8]] + a[[All, 9]] ) ;
aux = Transpose[{aux1,aux2,aux3}];
output = Array[0 & ,{6,6}] ;
output[[1;;3,1;;3]] = a[[1;;3,1;;3]];
output[[1;;3,4;;6]] = aux[[1;;3,1;;3]];
output[[4,1;;3]] = a[[4,1;;3]] +  a[[5,1;;3]] ;
output[[4,4;;6]] = aux[[4,1;;3]] +  aux[[5,1;;3]] ;
output[[5, 1;;3 ]] = a[[6,1;;3 ]] +  a[[7,1;;3 ]]  ;
output[[5, 4;;6 ]] = aux[[6,1;;3 ]] + aux[[7,1;;3 ]] ;
output[[6, 1;;3 ]] = a[[8,1;;3 ]]  +  a[[9,1;;3 ]] ;
output[[6, 4;;6 ]] = aux[[8,1;;3 ]] + aux[[9,1;;3 ]];
output
];

voigtCi[ ee_?t66Q ] :=   Module[ {c1,c2,c3, c4,c5,c6,r1,r2,r3, r4,r5,r6, aux,aux1,aux2,aux3,output},
{c1,c2,c3, c4,c5,c6}= Transpose[ee] ;  (* makes the columns 4,5,6 double *)
{r1,r2,r3, r4,r5,r6} = Transpose[ {c1,c2,c3,c4,c4,c5,c5,c6,c6}];
output = {r1,r2,r3, r4/2,r4/2,r5/2,r5/2,r6/2,r6/2}  ; (* makes the rows 4,5,6 double *)
transfer99i[output]
];


approx[a_, b_] :=  Abs[a - b] < 10^-12;

approx[a_?ListQ, b_?ListQ] :=  Total[ Abs[a - b] ] < 10^-12;

approx[a_?t33Q, b_?t33Q] :=  Total[ Abs[Flatten[a] - Flatten[b]] ] < 10^-12;  

approx[a_?t3333Q, b_?t3333Q] :=  Total[ Abs[Flatten[a] - Flatten[b]] ] < 10^-12;

approx[a_?t99Q, b_?399Q] :=  Total[ Abs[Flatten[a] - Flatten[b]] ] < 10^-12;

numericQ[ expr_ ] := Module[ {a},  a = Flatten [{expr}];  FreeQ[ NumericQ[#]& /@ a, False]   ] ;



Options[iE33] = {withLambda -> False};  
iE33[e_,n_, OptionsPattern[]] :=  Module[ {a,b,EE}, 
oL = OptionValue[withLambda ]; 
If[oL, \[Lambda] = e ; 
 EE =  {{\[Lambda] (1-n)/n ,\[Lambda],\[Lambda]},{\[Lambda],\[Lambda] (1-n)/n ,\[Lambda]},{\[Lambda],\[Lambda],\[Lambda] (1-n)/n }}, 
 a=e*(1-n)/((1+n)*(1-2*n));  b = e* n/((1+n)*(1-2*n)); 
 EE =  {{a,b,b},{b,a,b},{b,b,a}}  //Simplify ];  
 EE
  ];
  
iE33[ ] :=  Module[ {a,b},  
              If[anyNumberQ[{e,\[Nu]}],  Message[bnova::"Globals", "{e,\[Nu]}=", {e,\[Nu]} ]   ]; 
             a=e*(1-\[Nu])/((1+\[Nu])*(1-2*\[Nu])); b = e* \[Nu]/((1+\[Nu])*(1-2*\[Nu]));  {{a,b,b},{b,a,b},{b,b,a}}  //Simplify 
             ];
             
iC33[e_, n_] := {{1,-n,-n},{-n,1,-n},{-n,-n,1}} /e;
iC33[ ] := Module[{vars} , 
               If[anyNumberQ[{e,\[Nu]}],  Message[bnova::"Globals", "{e,\[Nu]}=", {e,\[Nu]} ]  ]; 
               {{1,-\[Nu],-\[Nu]},{-\[Nu],1,-\[Nu]},{-\[Nu],-\[Nu],1}} / e 
                 ];
iE[e_,n_]:=Module[{G,K}, 
            G=e/(2*(1+n)); K=e /(3*(1-2*n));    3K*(onev ~out~ onev)   + 2G*  deviatorer4sym    //Simplify 
              ] ;
iC[e_,n_]:=Module[{G,K}, 
            G=e/(2*(1+n)); K=e /(3*(1-2*n)) ;   1/(3K)*(onev ~out~ onev)   + 1/(2G)* deviatorer4sym   //Simplify  
             ];

iE[ ]:=Module[{G,K},
       If[anyNumberQ[{e,\[Nu]}],  Message[bnova::"Globals", "{e,\[Nu]}=", {e,\[Nu]} ]   ];   
       G=e/(2*(1+\[Nu])); K=e /(3*(1-2*\[Nu]));    3K*(onev ~out~ onev)   + 2G*  deviatorer4sym    //Simplify  
        ];
iC[ ]:=Module[{G,K}, 
        If[anyNumberQ[{e,\[Nu]}],  Message[bnova::"Globals", "{e,\[Nu]}=", {e,\[Nu]} ]   ]; 
        G=e/(2*(1+\[Nu])); K=e /(3*(1-2*\[Nu])) ;   1/(3K)*(onev ~out~ onev)   + 1/(2G)* deviatorer4sym   //Simplify 
         ];


orthoE[] :=   Module[{g,o11,o12,o13,o21,o22,o23,o31,o32,o33,o44,o66,o88,ee99,ee,n32,n31,n21,a},
 If[anyNumberQ[{E1,E2,E3,n12,n13,n23,G12,G13,G23} ], 
 Message[bnova::"Globals", "{E1,E2,E3,n12,n13,n23,G12,G13,G23}=", {E1,E2,E3,n12,n13,n23,G12,G13,G23} ] ];
 n32  = E3  n23 / E2;
 n31  = E3  n13 / E1;
 n21  = E2  n12 / E1;
g =1/(1-n12 n21 -n13 n31 - n12 n23 n31 - n13 n21 n32 - n23 n32);
o11 = g E1 (1 - n23 n32);
o12 = g E1 (n21 + n31 n23);
o13 = g E1 (n31 + n21 n32);
o22 = g E2 (1 - n13 n31);
o23 = g E2 (n32 + n12 n31);
o33 = g E3 (1- n12 n21 );
o44 = G12; o66= G13; o88 = G23;
o21 = o12 ; o31 = o13;  o32 = o23;
ee99 = {{o11,o12,o13,0,0,0,0,0,0},
 {o21,o22,o23,0,0,0,0,0,0},
  {o31,o32,o33,0,0,0,0,0,0},
  {0,0,0,o44,o44,0,0,0,0},
  {0,0,0,o44,o44,0,0,0,0},
  {0,0,0,0,0,o66,o66,0,0},
  {0,0,0,0,0,o66,o66,0,0},
  {0,0,0,0,0,0,0,o88,o88},
  {0,0,0,0,0,0,0,o88,o88} };
  ee = transfer99i[ee99]
  (* cross-anisotropy can be obtained as a special case via
   xiRules  =  {E1 ->  Eh,E2 -> Eh , E3 ->  Ev,   G13 -> Gv ,G23->  Gv, G12 ->  Eh/(2 + 2 nh) ,
                 n32 -> nvh, n32 -> nvh,  n13 -> nhv  , n23 -> nhv, n12->  nh, h21-> nh}
 *)
 ];
 
 orthoC[] :=   Module[{g,o11,o12,o13,o21,o22,o23,o31,o32,o33,o44,o66,o88,ee99,ee,n32,n31,n21,a},
 If[anyNumberQ[{E1,E2,E3,n12,n13,n23,G12,G13,G23} ], 
  Message[bnova::"Globals", "{E1,E2,E3,n12,n13,n23,G12,G13,G23}=", {E1,E2,E3,n12,n13,n23,G12,G13,G23} ] ];
 n32  = E3  n23 / E2;
 n31  = E3  n13 / E1;
 n21  = E2  n12 / E1;
g =1/(1-n12 n21 -n13 n31 - n12 n23 n31 - n13 n21 n32 - n23 n32);
o11 = 1/ E1  ;
o12 = -n21/E2;
o13 = -n31/E3;
o22 = 1/E2;
o23 = -n32/E3 ;
o33 =  1/E3;
o44 =  1/(4G12); o66 =1/(4G13); o88=1/(4G23);
o21 = o12 ; o31 = o13;  o32 = o23;
ee99 = {{o11,o12,o13,0,0,0,0,0,0},
 {o21,o22,o23,0,0,0,0,0,0},
  {o31,o32,o33,0,0,0,0,0,0},
  {0,0,0,o44,o44,0,0,0,0},
  {0,0,0,o44,o44,0,0,0,0},
  {0,0,0,0,0,o66,o66,0,0},
  {0,0,0,0,0,o66,o66,0,0},
  {0,0,0,0,0,0,0,o88,o88},
  {0,0,0,0,0,0,0,o88,o88} };
  ee = transfer99i[ee99]
  (* cross-anisotropy can be obtained as a special case via
   xiRules  =  {E1 ->  Eh,E2 -> Eh , E3 ->  Ev,   G13 -> Gv ,G23->  Gv, G12 ->  Eh/(2 + 2 nh) ,
                 n32 -> nvh, n32 -> nvh,  n13 -> nhv  , n23 -> nhv, n12->  nh, h21-> nh}
 *)
 ];
  

orthoE[ mm1_?t3Q, mm2_?t3Q] :=  Module[{ee,n32,n31,n21,a},
If[anyNumberQ[{E1,E2,E3,n12,n13,n23,G12,G13,G23} ], 
  Message[bnova::"Globals", "{E1,E2,E3,n12,n13,n23,G12,G13,G23}=",{E1,E2,E3,n12,n13,n23,G12,G13,G23}] ];
Quiet[ ee = orthoE[] ];
a = rotationTensor[{1,0,0}, mm1];   ee = rotateTensor[ee,a] ;
a = rotationTensor[{0,1,0}, mm2];   ee = rotateTensor[ee,a] ;
ee
 ];
 
orthoC[ mm1_?t3Q, mm2_?t3Q] :=  Module[{ee,n32,n31,n21,a},
 Message[bnova::"Globals", "{E1,E2,E3,n12,n13,n23,G12,G13,G23}=",{E1,E2,E3,n12,n13,n23,G12,G13,G23}] ;
Quiet[ ee = orthoC[] ];
a = rotationTensor[{1,0,0}, mm1];   ee = rotateTensor[ee,a] ;
a = rotationTensor[{0,1,0}, mm2];   ee = rotateTensor[ee,a] ;
ee
 ]; 
 
 


xiC[] :=   Module[{o11,o12,o13,o22,o23,o33,o44,o66,o88,cc99,cc,nvh,Gh},
If[anyNumberQ[ {Eh,Ev,nh,nhv,Gv}  ],   Message[bnova::"Globals", "{Eh,Ev,nh,nhv,Gv}=", {Eh,Ev,nh,nhv,Gv} ] ];
 Gh = Eh/(2+2 nh) ;
 nvh = nhv Ev / Eh ;
o11 =   1/Eh ;
o12 = -nh/Eh;
o13 = -nvh/Ev;
o22 = 1/Eh;
o23 = -nvh/Ev;
o33 =  1/Ev;
o44 = 1/(4*Gh);
o66 = 1/(4Gv);
o88 = 1/(4Gv);
cc99 = {{o11,o12,o13,0,0,0,0,0,0},
 {o12,o22,o23,0,0,0,0,0,0},
  {o13,o23,o33,0,0,0,0,0,0},
  {0,0,0,o44,o44,0,0,0,0},
  {0,0,0,o44,o44,0,0,0,0},
  {0,0,0,0,0,o66,o66,0,0},
  {0,0,0,0,0,o66,o66,0,0},
  {0,0,0,0,0,0,0,o88,o88},
  {0,0,0,0,0,0,0,o88,o88} };
  cc = transfer99i[cc99]
 ];

xiC[ mm_?t3Q ] :=  Module[{cc,a},
cc = xiC[] ;
a = rotationTensor[{0,0,1}, mm ];
cc = rotateTensor[cc,a] ;
cc
 ];
 
 epE[  iE_ , nb_, mb_, K_] := Module[ {p,q,Kplast }, 
 If[ Dimensions[ iE   ] == {3,3,3,3}, Null, Print[ "Dimensions elastic stiffness are not {3,3,3,3} "]; Abort[]];
 If[ Dimensions[ nb ] == {3,3}, Null, Print[ "Dimensions of loading direction are not {3,3} "]; Abort[]]; 
  If[ Dimensions[ mb ] == {3,3}, Null, Print[ "Dimensions of flow direction are not {3,3} "]; Abort[]]; 
Kplast= K + (nb ~colon~  iE) ~colon~ mb;
p = iE ~colon~ mb; 
q = nb ~colon~ iE; 
iE - (p ~out~ q)/Kplast 
] ;
 
xiC[Eh_,Ev_,nh_,nhv_,Gv_, mm_?t3Q ] :=   Module[{o11,o12,o13,o22,o23,o33,o44,o66,o88,cc99,cc,nvh,Gh,a},
Message[bnova::"Untested", "unless mm=", {0,0,1}] ;
Gh = Eh/(2+2 nh) ;
nvh = nhv Ev / Eh ;
o11 =   1/Eh ;
o12 = -nh/Eh;
o13 = -nvh/Ev;
o22 = 1/Eh;
o23 = -nvh/Ev;
o33 =  1/Ev;
o44 = 1/(4*Gh);
o66 = 1/(4Gv);
o88 = 1/(4Gv);
cc99 = {{o11,o12,o13,0,0,0,0,0,0},
 {o12,o22,o23,0,0,0,0,0,0},
  {o13,o23,o33,0,0,0,0,0,0},
  {0,0,0,o44,o44,0,0,0,0},
  {0,0,0,o44,o44,0,0,0,0},
  {0,0,0,0,0,o66,o66,0,0},
  {0,0,0,0,0,o66,o66,0,0},
  {0,0,0,0,0,0,0,o88,o88},
  {0,0,0,0,0,0,0,o88,o88} };
  cc = transfer99i[cc99] ;
 a = rotationTensor[{0,0,1}, mm ];
 cc = rotateTensor[cc,a] ;
 cc
 ];

xiE[]:=Module[{c1,c2,c3,c4,c4n,c5,c6,g , Gh, nvh,  mm = {0,0,1}, mm2},    (* global (Eh, Ev nh nhv Gv) assumed as el. parameters  and direction mm = {0,0,1} *)
If[anyNumberQ[ {Eh,Ev,nh,nhv,Gv} ],  Message[bnova::"Globals", "{Eh,Ev,nh,nhv,Gv}=", {Eh,Ev,nh,nhv,Gv} ] ];
        Gh = Eh/(2+2 nh) ;
        nvh = nhv Ev / Eh ;
				g = 1/(1-nh^2 - 2 nhv nvh - 2 nh nhv nvh);
				c1 = Eh g  (nh + nhv nvh) ;
				c2 = Eh g  (-nh + nvh + nh nvh -   nvh nhv);
				c4 =  Ev g + 2 Gh - 4 Gv  + Eh g nh - Ev g nh^2 - 2 Eh g nvh - 2  Eh g nh nvh  +  2  Eh g nhv nvh ;
				c5 = Gh;
				c6 = Gv - Gh;
                c4n =   -Eh g+Ev g+2 Eh g nh-Ev g nh^2-2 Eh g nvh-2 Eh g nh nvh+3 Eh g nhv nvh    - 4 c6;  (* repaired 25.10.2014 *)
				mm2 = mm ~out~ mm;
				c1*(delta ~out~ delta)+ c2 ((delta ~out~ mm2)+ (mm2 ~out~ delta )) +  c4n (mm2 ~out~ mm2) + c5*2 identity4sym +
				   c6*(tpose23[ (mm2 ~out~ delta)]+ tpose24[(mm2 ~out~ delta)] +tpose23[(delta ~out~mm2)] + tpose24[(delta ~out~ mm2)]   ) //Simplify
				 ];
				 
xiE[Eh_,Ev_,nh_,nhv_,Gv_, mm_?t3Q ]:=Module[{c1,c2,c3,c4,c4n,c5,c6,mm2,g, Gh, nvh,mmm},   (*  given el. parameters  and direction mm *)
        mmm = normalized[mm];  (* added 14.8.2015*)
        Gh = Eh/(2+2 nh) ;
        nvh = nhv Ev / Eh ;
				g = 1/(1-nh^2 - 2 nhv nvh - 2 nh nhv nvh);
				c1 = Eh g  (nh + nhv nvh) ;
				c2 = Eh g  (-nh + nvh + nh nvh -   nvh nhv);
				c4 =  Ev g + 2 Gh - 4 Gv  + Eh g nh - Ev g nh^2 - 2 Eh g nvh - 2  Eh g nh nvh  +  2  Eh g nhv nvh ;
				c5 = Gh;
				c6 = Gv - Gh;
                c4n =   -Eh g+Ev g+2 Eh g nh-Ev g nh^2-2 Eh g nvh-2 Eh g nh nvh+3 Eh g nhv nvh    - 4 c6;  (* repaired 25.10.2014 *)
				mm2 = mmm ~out~ mmm;
				c1*(delta ~out~ delta)+ c2 ((delta ~out~ mm2)+ (mm2 ~out~ delta )) +  c4n (mm2 ~out~ mm2) + c5*2 identity4sym +
				   c6*(tpose23[ (mm2 ~out~ delta)]+ tpose24[(mm2 ~out~ delta)] +tpose23[(delta ~out~mm2)] + tpose24[(delta ~out~ mm2)]   ) // Simplify
				 ]	;
				 
xiEr[ Ev_,Eh_,nh_,nhv_,Gv_, mm_?t3Q  ]:=Module[{o11,o12,o13,o22,o23,o33,o44,o66,o88,  Gh, nvh, g,ee99,ee,a },      (* global (Eh, Ev nh nhv Gv) assumed as el. parameters, given direction mm *)
        Gh = Eh/(2+2 nh) ;
        nvh = nhv Ev / Eh ;
		g = 1/(1-nh nh - 2 nhv nvh - 2 nh nhv nvh);
        o11 = g Eh (1 - nhv nvh);
        o12 = g Eh (nh + nhv nvh);
        o13 = g Eh (nvh + nh nvh);
        o22 = g  Eh (1 - nhv nvh);
        o23 = g Eh (nvh + nh nvh);
 	   o33 = g Ev (1 - nh nh);
        o44 = Gh;
        o66 = Gv;
        o88 = Gv;
	    ee99 = {{o11,o12,o13,0,0,0,0,0,0},
               {o12,o22,o23,0,0,0,0,0,0},
               {o13,o23,o33,0,0,0,0,0,0},
               {0,0,0,o44,o44,0,0,0,0},
               {0,0,0,o44,o44,0,0,0,0},
               {0,0,0,0,0,o66,o66,0,0},
               {0,0,0,0,0,o66,o66,0,0},
               {0,0,0,0,0,0,0,o88,o88},
               {0,0,0,0,0,0,0,o88,o88}} ;
       ee = transfer99i[ee99]  ;
       a = rotationTensor[{0,0,1}, mm ];
       ee = rotateTensor[ee,a] ;
       ee
	     ]	;					 

xiE[ mm_?t3Q  ]:=Module[{c1,c2,c3,c4,c4n,c5,c6,mm2,  Gh, nvh, g, mmm  },      (* global (Eh, Ev nh nhv Gv) assumed as el. parameters, given direction mm *)
       If[anyNumberQ[ {Ev,Eh,nh,nhv,Gv} ],  Message[bnova::"Globals", "{Ev,Eh,nh,nhv,Gv}=", {Ev,Eh,nh,nhv,Gv} ] ] ;
        mmm = normalized[mm];  (* added 14.8.2015*)
        Gh = Eh/(2+2 nh) ;
        nvh = nhv Ev / Eh ;
				g = 1/(1-nh^2 - 2 nhv nvh - 2 nh nhv nvh);
				c1 = Eh g  (nh + nhv nvh) ;
				c2 = Eh g  (-nh + nvh + nh nvh -   nvh nhv);
				c4 = Ev g + 2 Gh - 4 Gv  + Eh g nh - Ev g nh^2 - 2 Eh g nvh - 2  Eh g nh nvh  +  2  Eh g nhv nvh ;
				c5 = Gh;
				c6 = Gv - Gh;
                c4n =   -Eh g+Ev g+2 Eh g nh-Ev g nh^2-2 Eh g nvh-2 Eh g nh nvh+3 Eh g nhv nvh    - 4 c6;  (* repaired 25.10.2014 *)
				mm2 = mmm ~out~ mmm;
				c1*(delta ~out~ delta)+ c2 ((delta ~out~ mm2)+ (mm2 ~out~ delta )) +  c4n (mm2 ~out~ mm2) + c5* 2 identity4sym +
				   c6*(tpose23[ (mm2 ~out~ delta)]+ tpose24[(mm2 ~out~ delta)] +tpose23[(delta ~out~mm2)] + tpose24[(delta ~out~ mm2)]   ) // Simplify
				 ]	;
				 
xiEr[ mm_?t3Q  ]:=Module[{o11,o12,o13,o22,o23,o33,o44,o66,o88,  Gh, nvh, g,ee99,ee,a },      (* global (Eh, Ev nh nhv Gv) assumed as el. parameters, given direction mm *)
        If[anyNumberQ[  {Ev,Eh,nh,nhv,Gv}  ], Message[bnova::"Globals", "{Ev,Eh,nh,nhv,Gv}=", {Ev,Eh,nh,nhv,Gv} ] ];
        Gh = Eh/(2+2 nh) ;
        nvh = nhv Ev / Eh ;
		g = 1/(1-nh nh - 2 nhv nvh - 2 nh nhv nvh);
        o11 = g Eh (1 - nhv nvh);
        o12 = g Eh (nh + nhv nvh);
        o13 = g Eh (nvh + nh nvh);
        o22 = g  Eh (1 - nhv nvh);
        o23 = g Eh (nvh + nh nvh);
 	   o33 = g Ev (1 - nh nh);
        o44 = Gh;
        o66 = Gv;
        o88 = Gv;
	    ee99 = {{o11,o12,o13,0,0,0,0,0,0},
               {o12,o22,o23,0,0,0,0,0,0},
               {o13,o23,o33,0,0,0,0,0,0},
               {0,0,0,o44,o44,0,0,0,0},
               {0,0,0,o44,o44,0,0,0,0},
               {0,0,0,0,0,o66,o66,0,0},
               {0,0,0,0,0,o66,o66,0,0},
               {0,0,0,0,0,0,0,o88,o88},
               {0,0,0,0,0,0,0,o88,o88}} ;
       ee = transfer99i[ee99]  ;
       a = rotationTensor[{0,0,1}, mm ];
       ee = rotateTensor[ee,a] ;
       ee
	     ]	;
	     				 				 

bnova::"Globals" = "Syntax warning: possibly  unintended usage of globals  this function is using global variable(s):  `1`   `2` ." ;
bnova::"Untested" = "This function has not been tested yet    `1`   `2` ." ;
	
xiCr[ mm_?t3Q  ]:=Module[{o11,o12,o13,o22,o23,o33,o44,o66,o88,  Gh, nvh, g,ee99,ee,a },      (* global (Eh, Ev nh nhv Gv) assumed as el. parameters, given direction mm *)
        Message[bnova::"Globals", "{Ev,Eh,nh,nhv,Gv}=", {Ev,Eh,nh,nhv,Gv} ] ;
        Gh = Eh/(2+2 nh) ;
        nvh = nhv Ev / Eh ;
        o11 = 1/ Eh  ;
        o12 =  -nh /Eh ; 
        o13 =  -nvh / Ev; 
        o22 = 1/Eh ;
        o23 = -nvh /Ev;
 	   o33 = 1/ Ev ;
        o44 = 1/(4 Gh);
        o66 = 1/(4 Gv);
        o88 = 1/(4 Gv);
	    ee99 = {{o11,o12,o13,0,0,0,0,0,0},
               {o12,o22,o23,0,0,0,0,0,0},
               {o13,o23,o33,0,0,0,0,0,0},
               {0,0,0,o44,o44,0,0,0,0},
               {0,0,0,o44,o44,0,0,0,0},
               {0,0,0,0,0,o66,o66,0,0},
               {0,0,0,0,0,o66,o66,0,0},
               {0,0,0,0,0,0,0,o88,o88},
               {0,0,0,0,0,0,0,o88,o88}} ;
       ee = transfer99i[ee99]  ;
       a = rotationTensor[{0,0,1}, mm ];
       ee = rotateTensor[ee,a] ;
       ee
	     ]	;
	     
	    
	    xiCr[ Ev_,Eh_,nh_,nhv_,Gv_,mm_?t3Q  ]:=Module[{o11,o12,o13,o22,o23,o33,o44,o66,o88,  Gh, nvh, g,ee99,ee,a },      
        Gh = Eh/(2+2 nh) ;
        nvh = nhv Ev / Eh ;
        o11 = 1/ Eh  ;
        o12 =  -nh /Eh ; 
        o13 =  -nvh / Ev; 
        o22 = 1/Eh ;
        o23 = -nvh /Ev;
 	   o33 = 1/ Ev ;
        o44 = 1/(4 Gh);
        o66 = 1/(4 Gv);
        o88 = 1/(4 Gv);
	    ee99 = {{o11,o12,o13,0,0,0,0,0,0},
               {o12,o22,o23,0,0,0,0,0,0},
               {o13,o23,o33,0,0,0,0,0,0},
               {0,0,0,o44,o44,0,0,0,0},
               {0,0,0,o44,o44,0,0,0,0},
               {0,0,0,0,0,o66,o66,0,0},
               {0,0,0,0,0,o66,o66,0,0},
               {0,0,0,0,0,0,0,o88,o88},
               {0,0,0,0,0,0,0,o88,o88}} ;
       ee = transfer99i[ee99]  ;
       a = rotationTensor[{0,0,1}, mm ];
       ee = rotateTensor[ee,a] ;
       ee
	     ]	;	     
	     
	     
	          
xiEgeot[ Ev_, nh_, a_, mm_?t3Q  ]:= Module[{c1,c2,c3,c4,c4n,c5,c6,mm2 , Eh, Gv, Gh, nvh, nhv, g, mmm}, (* simplified (Ev nh a) el. parameters  & given dir. mm  *)
         mmm = normalized[mm];  (* added 14.8.2015*)
         Eh = Ev*a^2;
         Gh = Eh/(2+2 nh) ;
         Gv = Gh / a;
         nvh = nh / a ;
         nhv =  nh * a ;
				g = 1/(1-nh^2 - 2 nhv nvh - 2 nh nhv nvh);
				c1 = Eh g  (nh + nhv nvh) ;
				c2 = Eh g  (-nh + nvh + nh nvh -   nvh nhv);
				c4 = Ev g + 2 Gh - 4 Gv  + Eh g nh - Ev g nh^2 - 2 Eh g nvh - 2  Eh g nh nvh  +  2  Eh g nhv nvh ;
				c5 = Gh;
				c6 = Gv - Gh;
                c4n =   -Eh g+Ev g+2 Eh g nh-Ev g nh^2-2 Eh g nvh-2 Eh g nh nvh+3 Eh g nhv nvh    - 4 c6;  (* repaired 25.10.2014 *)
				mm2 = mmm ~out~ mmm;
				c1*(delta ~out~ delta)+ c2 ((delta ~out~ mm2)+ (mm2 ~out~ delta )) + c4n (mm2 ~out~ mm2) + c5* 2 identity4sym +
	            c6*(tpose23[ (mm2 ~out~ delta)]+ tpose24[(mm2 ~out~ delta)] +tpose23[(delta ~out~mm2)] + tpose24[(delta ~out~ mm2)]   ) // Simplify
				 ];

		 
				 				 				 
xiEgeotShort[ Ev_, nh_, a_, mm_?t3Q  ]:= Module[{c1,c2,c3,c4,c4n,c5,c6,mm2 , Eh, Gv, Gh, nvh, nhv, g, mmm}, (* simplified (Ev nh a) el. parameters  & given dir. mm  *)
         mmm = normalized[mm];  (* added 14.8.2015*)
         Eh = Ev*a^2;
         Gh = Eh/(2+2 nh) ;
         Gv = Gh / a;
         nhv =  nh * a ;
         xiEr[ Ev,Eh,nh,nhv,Gv, mmm  ] 
				 ];				 
				 
xiEgeotShort[ Ev_, nh_, a_, n_, mm_?t3Q  ]:= Module[{c1,c2,c3,c4,c4n,c5,c6,mm2 , Eh, Gv, Gh, nvh, nhv, g, mmm}, 
     (* simplified  cross anisotropic stiffness after Niemunis+Staszewska 2021 
          a = alpha after Graham+Houlsby 
          n=beta = exponent after Niemunis+Staszewska 2021 
           mm = direction of sedimentation   
           *)
         mmm = normalized[mm];  
         Eh = Ev*a^(2/n);
         Gh = Eh/(2+2 nh) ;
         Gv = Gh / a;
         nhv =  nh * a^(1/n) ;
		 xiEr[ Ev,Eh,nh,nhv,Gv, mmm  ] 	
				 ];	
				 
			 			 			 

xiCgeotShort[ Ev_, nh_, a_, mm_?t3Q  ]:= Module[{c1,c2,c3,c4,c4n,c5,c6,mm2 , Eh, Gv, Gh, nvh, nhv, g, mmm}, (* simplified (Ev nh a) el. parameters  & given dir. mm  *)
         mmm = normalized[mm];  (* added 14.8.2015*)
         Eh = Ev*a^2;
         Gh = Eh/(2+2 nh) ;
         Gv = Gh / a;
         nhv =  nh * a ;
         xiCr[ Ev,Eh,nh,nhv,Gv, mmm  ] 
				 ];				 
				 
xiCgeotShort[ Ev_, nh_, a_, n_, mm_?t3Q  ]:= Module[{c1,c2,c3,c4,c4n,c5,c6,mm2 , Eh, Gv, Gh, nvh, nhv, g, mmm}, (* simplified (Ev nh a, n) el. parameters  & given dir. mm  *)
         mmm = normalized[mm];  
         Eh = Ev*a^(2/n);
         Gh = Eh/(2+2 nh) ;
         Gv = Gh / a;
         nhv =  nh * a^(1/n) ;
		 xiCr[ Ev,Eh,nh,nhv,Gv, mmm  ] 	
				 ];	
				 				 
				 				 				 
				 
				 
xiEgeot[ Ev_, nh_, a_, n_, mm_?t3Q  ]:= Module[{c1,c2,c3,c4,c4n,c5,c6,mm2 , Eh, Gv, Gh, nvh, nhv, g, mmm}, (* simplified (Ev nh a, n) el. parameters  & given dir. mm  *)
         mmm = normalized[mm];  
         Eh = Ev*a^(2/n);
         Gh = Eh/(2+2 nh) ;
         Gv = Gh / a;
         nvh = nh / a^(1/n) ;
         nhv =  nh * a^(1/n) ;
				g = 1/(1-nh^2 - 2 nhv nvh - 2 nh nhv nvh);
				c1 = Eh g  (nh + nhv nvh) ;
				c2 = Eh g  (-nh + nvh + nh nvh -   nvh nhv);
				c4 = Ev g + 2 Gh - 4 Gv  + Eh g nh - Ev g nh^2 - 2 Eh g nvh - 2  Eh g nh nvh  +  2  Eh g nhv nvh ;
				c5 = Gh;
				c6 = Gv - Gh;
                c4n =   -Eh g+Ev g+2 Eh g nh-Ev g nh^2-2 Eh g nvh-2 Eh g nh nvh+3 Eh g nhv nvh    - 4 c6;  (* repaired 25.10.2014 *)
				mm2 = mmm ~out~ mmm;
				c1*(delta ~out~ delta)+ c2 ((delta ~out~ mm2)+ (mm2 ~out~ delta )) +  Chop[ c4n (mm2 ~out~ mm2)] + c5* 2 identity4sym +
				   c6*(tpose23[ (mm2 ~out~ delta)]+ tpose24[(mm2 ~out~ delta)] +tpose23[(delta ~out~mm2)] + tpose24[(delta ~out~ mm2)]   ) // Simplify
				 ];
				 


		
	 	 

getXAniso[a_,m_?t3Q]:= Module[{mm,mu,Q}, (* returns pure anisotropic Q-matrix from paper Niemunis+Grandas+Wichtmann  2016 
                                              the arguments are the Houlsby constant  a  and the given direction  mm  of settlement *)
    mm=m/Norm[m];
    mu = Sqrt[a] delta + (1-Sqrt[a])( mm~out~mm );
    Q =tpose23[mu~out~ mu ]  //Simplify
];

getXAniso[a_,n_,m_?t3Q]:= Module[{mm,mu,Q,d,aa,b,h}, (*  returns pure anisotropic Q-matrix from paper Niemunis + Staszewska 2021   
                                                            the arguments are:  a=alpha  m=1/beta and  diretion  mm  of settlement, repaired 2022 *)
    mm=m/Norm[m];
    h = 1/n; 
    aa = -(Sqrt[a^(2*h)*((-1 + Sqrt[a])^2 + 2*a^(-1/2 + h) + (-3 + a)*a^h)]/Sqrt[a + (-4 + a)*a^(2*h) + 2*a^(1 + h)]);
    b = (Sqrt[a^(2*h)*((-1 + Sqrt[a])^2 + 2*a^(-1/2 + h) + (-3 + a)*a^h)]*(Sqrt[a] + a - 2*a^h - a^(1/2 + h) + a^(1 + h)))/((-1 + a)*a^h*Sqrt[a + (-4 + a)*a^(2*h) + 2*a^(1 + h)]);
    d = (a^(-1/2 + h)*(a - a^h)*(Sqrt[a] + 2*a^h + a^(1/2 + h)))/(a + (-4 + a)*a^(2*h) + 2*a^(1 + h));
    mu = aa delta + b (mm~out~mm);
    Q =tpose23[mu~out~ mu ]  +d  identity4 //Simplify
];


iCVermeer[T_,props_:{7500, 200, 0.25 }  ]:=Module[{G,K,Gref,pref,\[Beta]},  (*s. 181 - BM II*)
{Gref,pref,\[Beta]} = props;
G=Gref*(Sqrt[(T~colon~T)/3  ]  / pref )^(1-\[Beta]);
1/(2G)*(identity4sym-(1-\[Beta]) (T~out~T) /(T~colon~T) )  //Simplify
];

iEVermeer[ T_?t2Q, props_:{7500, 200, 0.25 }] :=   Module[{P,Q, p0 ,G  , \[Beta]  ,R ,a},
{G, p0, \[Beta]} = props;
{P,Q}  = T;
R = Sqrt[ P^2 + Q^2 ]  ;
a = ( 2 3^(-(1/2)+\[Beta]/2) G (R/p0)^-\[Beta]  ) / (p0 R \[Beta]) ;
a *{{P^2+Q^2 \[Beta],-P Q (-1+\[Beta])},{-P Q (-1+\[Beta]),Q^2+P^2 \[Beta]}}
 ];
 
 iEVermeer[T_?t33Q, props_:{7500, 200, 0.25 }]:=Module[{G,K,Gref,pref,\[Beta]},
{Gref,pref,\[Beta]} = props;
G=Gref*(Sqrt[(T~colon~T)/3]/pref)^(1-\[Beta]);
 2*G*(identity4sym-(\[Beta]-1)/\[Beta]  * (T~out~T) / ( T~colon~T ) )  //Simplify
];


iCNiemunis[T_?t33Q,props_:{1.517*10^-4,0.1,0.6}  ]:=Module[{c,\[Alpha],n,A,B,C,D,P,R}, 
{c,\[Alpha],n} = props;  P = -tr[T]/Sqrt[3]; R = Sqrt[norm2[T]];
A = 1/3 c \[Alpha] (\[Alpha]-1) P^(\[Alpha]-2) R^(2-\[Alpha]-n);
B = 1/Sqrt[3] c \[Alpha] (\[Alpha]+n-2) P^(\[Alpha]-1) R^(-\[Alpha]-n);
C = c (\[Alpha]+n-2) (\[Alpha]+n) P^\[Alpha] R^(-2-\[Alpha]-n);
D = c (2-\[Alpha]-n) P^\[Alpha] R^(-\[Alpha]-n);
A *(delta~out~delta) + B *(delta~out~T ) + B*(T~out~delta) + C ( T~out~T ) + D identity4sym //Simplify
];

iCGehring[T_?t33Q, props_:{0.02097,0.55855,1,0.0096279}  ]:=Module[{c,\[Alpha],n,cL,A,B,C,D,E,P,R}, 
{c,\[Alpha],n,cL} = props;  P = -tr[T]/Sqrt[3]; R = Sqrt[norm2[T]];
A = 1/3 c \[Alpha] (\[Alpha]-1) P^(\[Alpha]-2) R^(2-\[Alpha]-n);
B = 1/Sqrt[3] c \[Alpha] (\[Alpha]+n-2) P^(\[Alpha]-1) R^(-\[Alpha]-n);
C = c (\[Alpha]+n-2) (\[Alpha]+n) P^\[Alpha] R^(-2-\[Alpha]-n);
D = c (2-\[Alpha]-n) P^\[Alpha] R^(-\[Alpha]-n);
E = cL 1/(3P);
A delta~out~delta + B*(delta~out~T) + B*(T~out~delta) + C *( T~out~T )+ D identity4sym + E *(delta~out~delta)//Simplify
];

 iELiu[ eps_?t33Q, props_:{100,1.666}] := Module[{ ev,ev2,ev15, e, x, B},
{B, x }= props;   (* Jiang + Liu 2003  granular elasticity version cubic , max friction 17\[Degree] = convexity limit  :( *)
If[ev<  0,  Print["Error: iELiu called with negative vol. strain "]; Abort[] ] ;
ev= -tr[eps];ev2  = ev*ev;  ev15 = ev*Sqrt[ev];
 e = dev[eps];
1/( 4* x* ev15 ) * B* (   -4  ev (delta ~out~eps) -4  ev  (eps ~out~ delta)+
                          (ev2 (-5+6* x)-norm2[eps])  (delta  ~out~delta) +8*ev2* identity4sym   )   //Simplify
];

iEHoulsby[ T_?t33Q, props_:{ 0.6, 10, 0.25 ,100 }] := Module[{sig, s,n,k,p0,pa, g, p,q,nu},
{n, k, nu, pa} = props;   (* Houlsby Amorosi Rojas 2005, no homogeneity  :(  *)
sig = -T; s = deviator[sig];
g = (k/2)*(3 - 6 nu)/(1+nu) ;
p = tr[sig];  q =( s ~colon~ s )* Sqrt[1.5];
p0 =Sqrt[   p^2  +  q^2 *k*(1-n)/(3*g) ];
pa*(p0/pa)^n  * (     n*k  (sig ~out~ sig) /p0^2         + k *(1-n) *(delta ~out~ delta)        + 2*g* deviatorer4      )
];


aRot12[ t_ ] :=  {{Cos[t],-Sin[t],0},{Sin[t],Cos[t],0},{0,0,1}}  	;
aRot13[ t_ ] :=   {{Cos[t],0,-Sin[t] },{0,1,0},{Sin[t],0,Cos[t]}}   ;
aRot23[ t_ ] :=   {{1,0,0},{0,Cos[t],-Sin[t] },{0,Sin[t],Cos[t]}}  	;
pRot12[ t_ ]  :=   {{Cos[t],Sin[t],0},{-Sin[t],Cos[t],0},{0,0,1}}  	;
pRot13[ t_ ]  :=   {{Cos[t],0,Sin[t] },{0,1,0},{-Sin[t],0,Cos[t]}}  ;
pRot23[ t_ ]  :=   {{1,0,0},{0,Cos[t], Sin[t] },{0,-Sin[t],Cos[t]}}  ;

rotateTensor[T_?t3Q, a_?t33Q ] := contract[T ~out~ a , 1, 3]  // FullSimplify;
rotateTensor[T_?t33Q, a_?t33Q ] :=  contract[contract[T ~out~ a , 1, 4] ~out~ a , 1, 4] // FullSimplify;
rotateTensor[T_?t333Q, a_?t33Q ] := contract[contract[contract[T ~out~ a , 1,5] ~out~ a , 1,5] ~out~    a, 1, 5] // FullSimplify;
rotateTensor[T_?t3333Q, a_?t33Q ] := contract[contract[contract[contract[T~out~a, 1,6] ~out~a,1,6]~out~ a, 1,6]~out~a,1,6] // FullSimplify   ;

hausholderMatrix[from_?vectorQ, to_?vectorQ] := Module[ {fromN ,toN, ubv,nt,nf}, 
fromN = Norm[from]; toN = Norm[to] ; 
nf =  Dimensions[from];  nt =  Dimensions[to]; 
If[nf!= nt || Length[nf] > 1,
 Print["Error in housholderMatrixin: Dimension[from]=", nf, " Dimension[to]="  ,nt ] ; Abort[] ];
ubv =  (fromN*normalized[to] - from )//normalized ; 
If[  Not[(toN/fromN) ~approx~1],  Print["bnova::Warning in housholderMatrixin: arguments from and to have different norms"] ]; 
(toN/fromN)(IdentityMatrix[nf[[1]]]  - 2*(ubv ~out~ ubv) ) 
];

givensRotate[aIn_?numberQ ] := Module[{a, p, q, c, s, t, theta, signtheta, app, apq, aqp, aqq , auxp, auxq},
a = aIn; a = (a - DiagonalMatrix[ Diagonal[a] ]) // Abs ;
{p, q} = Position[ a , Max[a] ] [[1]] // Sort ;
{app, apq , aqp, aqq } = { aIn[[p, p]], aIn[[p, q]], aIn[[q, p]] , aIn[[q, q]]};
If[Abs[apq - aqp] > 10^-15 , Print["Unsymmetric input matrix"]];
If[Abs[apq] < 10^-15, Print["Nothing to do: the input Matrix is already diagonal"]];
theta = (aqq - app) / (2*apq); (* NR 11.1 **********  *)
signtheta = Sign[theta]; If[signtheta  == 0, signtheta = 1]; 
t = signtheta /(Abs[theta] + Sqrt[theta*theta + 1 ]);
c = 1 / Sqrt[t*t + 1]; s = t*c;  
(* Jacobi rotation *)
auxp = c*aIn[[All, p ]] - s* aIn[[ All, q ]]; (* new row / column p *)
auxq = c*aIn[[All, q ]] + s* aIn[[ All, p ]]; (* new row / column q *)
a = aIn;
a[[p, All]] = auxp ; a[[All, p]] = auxp ;
a[[q, All]] = auxq; a[[All, q]] = auxq;
a[[p, q]] = 0; a[[q, p]] = 0; (* special cases *)
a[[p, p]] = c*c *app + s*s *aqq - 2* s*c *apq ;
a[[q, q]] = s*s *app + c*c *aqq + 2* s*c *apq ; 
a
];

givensRotate[aIn_?symmMQ, p_?NumberQ, q_?NumberQ ] := Module[{a, c, s, t, theta, app, signtheta, apq, aqp, aqq , auxp, auxq},
{app, apq , aqp, aqq } = { aIn[[p, p]], aIn[[p, q]], aIn[[q, p]] , aIn[[q, q]]};
If[Abs[apq - aqp] > 10^-15 , Print["Unsymmetric input matrix"]];
If[Abs[apq] < 10^-15, Print["done"]];
theta = (aqq - app) / (2*apq); (* NR 11.1 *)
signtheta = Sign[theta]; If[signtheta  == 0, signtheta = 1]; 
t = signtheta /(Abs[theta] + Sqrt[theta*theta + 1 ]);
c = 1 / Sqrt[t*t + 1]; s = t*c;
auxp = c*aIn[[All, p ]] - s* aIn[[ All, q ]]; (* new row / column p *)
auxq = c*aIn[[All, q ]] + s* aIn[[ All, p ]]; (* new row / column q *)
a = aIn;
a[[p, All]] = auxp ; a[[All, p]] = auxp ;
a[[q, All]] = auxq; a[[All, q]] = auxq;
a[[p, q]] = 0; a[[q, p]] = 0; (* special cases *)
a[[p, p]] = c*c *app + s*s *aqq - 2* s*c *apq ;
a[[q, q]] = s*s *app + c*c *aqq + 2* s*c *apq ;
 a
]; 






rotationTensor[f_?t3Q, t_?t3Q ] := Module[{fn,tn,w,c,s}, (* Euler-Rodriguez rotation matrix from  *)
fn =  normalized[f] ;
tn= normalized[t] ;
s = Norm[Cross[fn,tn]];
w = normalized[ Cross[ fn, tn ] ]; (* = a in R.Brannon's script , p. 20*)
c =  fn . tn; (* cos \[Alpha] *)
c*  ( delta -  (w~out~w) )   + (w~out~w)   + s (-ricci . w)
];

rotationTensor[f_?t33Q, t_?t33Q ] := Module[{fn,tn,w1,w2,c}, (* R3333 rotation matrix from to  *)
fn =  normalized[f] ;
tn= normalized[t] ;
c =  fn  ~colon~ tn;
w1 = normalized[ fn + tn];
w2 = normalized[tn - fn];
identity4 +  (c-1)  ( (w1~out~w1)   + (w2 ~out~w2 ) ) -  Sqrt[1-c^2]   ( (w1~out~w2)   -  (w2 ~out~w1 ) )
] ;

rotationTensor[f_?t3Q, t_?t3Q , beta_ ] := Module[{fn,tn,w,c,s}, (* Euler-Rodriguez rotation matrix from to by angle*)
fn =  normalized[f] ;
tn= normalized[t] ;
w = normalized[ Cross[ fn, tn ]];
c = Cos[beta];
s = Sin[beta];
c*delta + (1-c) (w~out~w)  +  s (-ricci . w)
] ;

rotationTensor[f_?t33Q, t_?t33Q, beta_  ] := Module[{fn,tn,w1,w2,c,s},  (* R3333 rotation matrix from to by angle *)
fn =  normalized[f] ;
tn= normalized[t] ;
c=Cos[beta];
s = Sin[beta];
w1 = normalized[ fn + tn];
w2 = normalized[tn - fn];
identity4 +  (c-1)  ( (w1~out~w1)   + (w2 ~out~w2 ) ) -  s   ( (w1~out~w2)   -  (w2 ~out~w1 ) )
] ;

rotationTensor[ {alpha_, a_?t3Q}] := Module[ {c,s}, 
c = Cos[alpha]; s = Sin[alpha] ; 
  c *delta + (1-c) (a ~out~a)  - s* ricci . a // Simplify
];

rotationTensorInverse[R_] := Module[ {c,s, aa,aaaa,koniec,alpha,a1,a2,a3},
 c = (tr[R] - 1 )/2; 
If[c==1, alpha = 0; aa = {1,0,0}; Goto[koniec]]; 
If[c==-1, alpha = Pi;   
      aa= {0,0,0};
      aaaa = (R + delta)/2;   
      {a1,a2,a3} = Diagonal[aaaa]; 
      If[a1> 0 , aa = aaaa[[1,All]] / Sqrt[a1] ];   
      If[a2> 0 , aa = aaaa[[2,All]] /  Sqrt[a2] ]; 
      If[a3> 0 , aa = aaaa[[3,All]] /  Sqrt[a3] ]; 
     Goto[koniec];
]; 
aa = -Normalize[ ricci ~colon~ R];
alpha = ArcCos[c];
Label[koniec] ; 
{alpha, aa }
];

gOptions = {PlotRange -> All, PlotMarkers -> Automatic } ;


Options[pickListPlot] = {every -> 1};

pickListPlot[inlist_,{ix_,iy_}, OptionsPattern[] ] :=  Module[{everyV,list},
everyV= OptionValue[every]; list=inlist[[1;;Length[inlist];;everyV]] ;
ListLinePlot[  { Transpose[list] [[ ix ]]  ,  Transpose[list] [[ iy]]    } //Transpose,   Evaluate[gOptions] ]
];

pickListPlot[inlist_,{ix_,iy_ ,iz_},  OptionsPattern[]   ] := Module[{everyV,list, g1,g2},
everyV= OptionValue[every]; list=inlist[[1;;Length[inlist];;everyV]] ;
g1 =  ListLinePlot[  { Transpose[list] [[ ix ]]  ,  Transpose[list] [[ iy]]    } //Transpose,   Evaluate[gOptions] ];
g2 =   ListLinePlot[  { Transpose[list] [[ ix ]]  ,  Transpose[list] [[ iz]]    } //Transpose,  Evaluate[gOptions] , PlotStyle -> Red ] ;
Show[g1,g2]
]

pickListPlot[inlist_,{ix_,iy_ ,iz_, ia_},  OptionsPattern[] ] := Module[{everyV,list,g1,g2,g3},
everyV= OptionValue[every]; list=inlist[[1;;Length[inlist];;everyV]] ;
g1 =  ListLinePlot[  { Transpose[list] [[ ix ]]  ,  Transpose[list] [[ iy]]    } //Transpose,   Evaluate[gOptions] ];
g2 =   ListLinePlot[  { Transpose[list] [[ ix ]]  ,  Transpose[list] [[ iz]]    } //Transpose,  Evaluate[gOptions] , PlotStyle -> Red ] ;
g3 =   ListLinePlot[  { Transpose[list] [[ ix ]]  ,  Transpose[list] [[ ia]]    } //Transpose,  Evaluate[gOptions] , PlotStyle -> Blue ] ;
Show[g1,g2,g3]
];

SetAttributes[ pickListPlot,HoldAll];

pickListPlot[inlist_  , {pickPattern_} , OptionsPattern[] ] := Module[{everyV,list, xyp, xzp, g1,g2,g3},
 everyV= OptionValue[every]; list=inlist[[1;;Length[inlist];;everyV]] ;
 xyp = (pickPattern&  /@ list );  (* creates combinations. First is x then y1,y2,y3 are possible *)
 n = Dimensions[xyp][[2]];
 If[n >= 2,  g1 =   ListLinePlot[  xyp[[All, 1;;2]],  Evaluate[gOptions]  ]  ];
 If[ n >= 3,   g2 = ListLinePlot[  { Transpose[xyp] [[ 1 ]]  ,  Transpose[xyp] [[3]]    } //Transpose, Evaluate[gOptions] , PlotStyle -> Red  ] ];
 If[ n >= 4,   g3 = ListLinePlot[  { Transpose[xyp] [[ 1 ]]  ,  Transpose[xyp] [[4]]    } //Transpose, Evaluate[gOptions] , PlotStyle -> Blue  ] ];
 Which[ n==2 , Show[g1], n==3 , Show[g1,g2],  n==4 , Show[g1,g2,g3]  ]
];

xyp2T[x_, y_, p_]:=Module[{c=Cos[Pi/6],s=Sin[Pi/6],aa},  (* tension > 0 *) aa={{0,1},{c,-s},{-c,-s}}; DiagonalMatrix[Simplify[-p-aa . {x,y}]] ];

T2xyp[ T_ ]:=Module[{ c=Cos[Pi/6],s= Sin[Pi/6] ,diag, aa, x,y,p},
diag = {T[[1,1]], T[[2,2]],T[[3,3]] };
If[Norm[ T - DiagonalMatrix[diag]] > 10^-20, Print["Warning: T2xyp obtains a non diagonal argument T=" , T ] ];
aa={{0,1},{c,-s},{-c,-s}} // Transpose  ;
{x,y} =- aa . dev[diag];
 {x,y,  -tr[T]/3.0 }
  ];

deviatoricContourPlot[ p_, function_ ,contour_ , rangefactor_:1   ] := Module[ {T, x,y , cos=Cos[Pi/6],sin= Sin[Pi/6], T1,T2,T3, g1,g2  },
    g1 = ContourPlot[ function[xyp2T[x ,y,  p]] ==contour  , {x,-rangefactor* p,rangefactor*p},{y,-rangefactor*p,rangefactor*p} ];
    g2 = Graphics[ Line[ {{0,0}, {0,rangefactor*p}, {0,0}, rangefactor*p*{cos,-sin}  ,{0,0}, rangefactor*p*{-cos,-sin},{0,0}  }]] ;
    Show[ {g1,g2} ]
   ];

deviatoricRangePlot[ p_, function_  , rangefactor_:1   ] := Module[ {T, x,y , cos=Cos[Pi/6],sin= Sin[Pi/6], T1,T2,T3, g1,g2  },
    g1 =   RegionPlot[   function[ xyp2T[x ,y,  p]     ] , {x,-rangefactor* p,rangefactor*p},{y,-rangefactor*p,rangefactor*p} ];
    g2 = Graphics[ Line[ {{0,0}, {0,rangefactor*p}, {0,0}, rangefactor*p*{cos,-sin}  ,{0,0}, rangefactor*p*{-cos,-sin},{0,0}  }]] ;
    Show[ {g1,g2} ]
   ];



Options[step] = {ZarembaJaumann -> False ,verbose  -> False , HughesWinget -> False} ; 
step[ mat_,  loading_ , ninc_ , OptionsPattern[] ] := Module[{oZJ, oV, oHW, iinc},  
  oZJ = OptionValue[ZarembaJaumann]; oV = OptionValue[verbose];  oHW =  OptionValue[HughesWinget];
  Do[  AppendTo[ states, increment[mat,  loading , ZarembaJaumann -> oZJ ,verbose  -> oV , HughesWinget -> oHW ] ];  
   If[oV, Print["iinc = ", iinc]] ;  
   ,{iinc ,1,ninc}    ];
];

parametricStep[ mat_,  loading_, iinc_ , ninc_] := Do[  AppendTo[ states, increment[mat,  Evaluate[ loading[iinc]  ]  ]      ],   {iinc ,1, ninc}    ];


Options[cycle] = {ZarembaJaumann -> False ,verbose  -> False , HughesWinget -> False} ; 
cycle[mat_,  loading1_ ,ninc1_, loading2_, ninc2_, ncyc_]  :=  Module[{oZJ, oV, oHW, icyc}, 
  oZJ = OptionValue[ZarembaJaumann]; oV = OptionValue[verbose];  oHW =  OptionValue[HughesWinget];
 Do[ step[mat, loading1 ,ninc1, ZarembaJaumann -> oZJ ,verbose  -> oV , HughesWinget -> oHW] ;   
     step[mat, loading2, ninc2, ZarembaJaumann -> oZJ ,verbose  -> oV , HughesWinget -> oHW ] ; 
      If[oV, Print["icyc = ", icyc]] ; 
     ,{icyc,1,ncyc}];       
       ];



isoTriaxPlot[path_, sfi_:0 ] := Module[ {pathT, pathEps,P,Q,EpsP,EpsQ , Pmin, Pmax,CSL, PP},
{pathT, pathEps} = Transpose[path ][[1;;2]];
{P,Q} = (  {-onev~colon~#,onevstar~colon~#}&/@pathT) //Transpose  ;
{Pmin, Pmax} = {Min[P], Max[P]};
CSL = Plot[ {(Sqrt[2]/3 )*  6*sfi/(3-sfi) PP ,   -(Sqrt[2]/3 )*  6*sfi/(3+sfi) PP   } , {PP,Pmin,Pmax} ];
{EpsP,EpsQ} = (  {-onev~colon~#,onevstar~colon~#}&/@pathEps) //Transpose  ;
If[ sfi > 0 ,  GraphicsRow[{Show[ ListPlot[ ({P,Q}  // Transpose) ,  AxesLabel -> {"P","Q"} ], CSL], ListPlot[   {EpsP,EpsQ} //Transpose ,   AxesLabel -> {"\[Epsilon]P(compr)", "\[Epsilon]Q"} ]}],
               GraphicsRow[{ ListPlot[ ({P,Q}  // Transpose ),  AxesLabel-> {"P", "Q"}  ],ListPlot[  ( {EpsP,EpsQ} //Transpose) ,  AxesLabel-> {"\[Epsilon]P(compr)"," \[Epsilon]Q"}  ]} ]          ]
];


isoPlot[path_, sfi_:0 ] := Module[ {pathT, pathEps,P,Q,EpsP,EpsQ , Pmin, Pmax, sq3 = Sqrt[3] //N, g1, g2, g0, output,nitem } ,
 nitem = Dimensions[path][[2]];
 If[nitem == 2, {pathT, pathEps} = Transpose[path ][[1;;2]] ];
 If[nitem == 1,  pathT  =  path[[All, 1]] ];
P =-tr[#] /sq3 & /@pathT  ; 
Q = Sqrt[  norm2[deviator[#]] ]& /@ pathT;
{Pmin, Pmax} = MinMax[P];
g0 = {};
If[ sfi > 0, g0 = Plot[ {(Sqrt[2]/3 )*  6*sfi/(3-sfi)* x ,   (Sqrt[2]/3 )*  6*sfi/(3+sfi) x  } , {x,Pmin-0.1,Pmax+0.1} , PlotLegends->{"Mc","Me"}] ];
g1 = Show[ ListPlot[ ({P,Q}  // Transpose) ,  AxesLabel -> {"P","Q"} ], g0 , PlotRange -> All ];
If[nitem >1, 
 EpsP  = -tr[#] /sq3 &/@ pathEps  ;
 EpsP  = Sqrt[  norm2[deviator[#]] ]  &/@ pathEps  ; 
 g2 = ListPlot[  ( {EpsP,EpsQ} //Transpose) ,  AxesLabel-> {"\[Epsilon]P(compr)"," \[Epsilon]Q"}  ] ; 
 output = {g1,g2}, output = g1   
 ]; 
   output     
];

Options[deviatoricPlot] = {verbose -> False , criterion -> "MN", principal -> False, every -> 1}; 
deviatoricPlot[ path_, sfi_ , pMN_ , OptionsPattern[] ] := Module[ 
{pathT,   devIxy , xyIdev, pathxy , rmax, gaxes, gminusAxes, glabels,x,y,tt, gSurf, gnoTens, gpath, aux,p0,scale, decorations, M2, 
  oCrit, oPrinc, oV, oE,full, off , redPoints},
oV = OptionValue[verbose]; 
oCrit = OptionValue[criterion]; 
oPrinc = OptionValue[principal]; (* input is not diagonal and principal stresses must be determined *)
 oE =  OptionValue[every];

xyIdev =  {{1, 2, 0}/Sqrt[3], {1, 0, 0}};           (* xy = xyIdev . dev      mapping *)
devIxy =  {{0,2},{Sqrt[3],-1},{-Sqrt[3],-1}}/2 ;   (* dev =  devIxy . xy     mapping  *)

gpath = {}; rmax = pMN;  
If[ Length[path] < 1, Goto[decorations]]; (*no path so plot just the yield surface and exit *)
pathT   =  path[[All,1]];     (* stress plot with M-N criterion at pMN =100 kPa *)

If[ Not[oPrinc], 
     full =  norm2[ # ]& /@ pathT;  
     off = norm2[ # - DiagonalMatrix[Diagonal[#]] ]& /@ pathT; 
     If[Total[off] / Total[full] > 0.05, Print["deviatoricPlot warning:  non-zero off-diagonal components! Use option: principal -> True" ] ]
         ]; 

If[oPrinc, pathT = DiagonalMatrix[Sort[ Eigenvalues[#] ] ]& /@ pathT ]; 

If[oV, Print["deviatoricPlot: pathT\[LeftDoubleBracket]1\[RightDoubleBracket]=", pathT[[1]]]]; 


pathxy = (-xyIdev . Diagonal[ deviator[ #] ])& /@ pathT  ;   (*geot. sign convention *)

redPoints = pathxy[[1;;-1;;oE,All]]; 
 gpath= Show[ ListLinePlot[pathxy, AspectRatio -> Automatic] ,  Graphics[ {Red, PointSize[0.01], Point[redPoints]} ]    ];
 
rmax  = Max[1.1* Norm[#] & /@  pathxy];

Label[decorations]; 
gaxes  =  {Thick, Line[ 1.07*rmax*{{0,0}, devIxy[[1]] , {0,0}, devIxy[[2]] , {0,0},devIxy[[3]] }]};
glabels = {Text[ "-T1", 1.2*rmax  *devIxy[[1]]],  Text[ "-T2", 1.2*rmax  *devIxy[[2]]],Text[ "-T3", 1.2*rmax  *devIxy[[3]]]} ;
gminusAxes  =  {Dashed,{  Line[  -0.7*rmax*{{0,0}, devIxy[[1]] }],  Line[  -0.7*rmax*{{0,0}, devIxy[[2]] }],  Line[  -0.7*rmax*{{0,0}, devIxy[[3]] }]}};




If[pMN < 1, p0 = -tr[ path[[-1,1 ]]] /3 , p0 = pMN ];  
If[oV, Print["point 1, p0=", p0 ]]; 

x=.;y=.;
tt = { -y , -(1/2) (Sqrt[3] x-y) , 1/2 ( Sqrt[3] x+y)  } -p0 ;    (* from xy to sig1,sig2,sig3 *)
If[oV, Print["point 4, tt=", tt ]]; 
gSurf = {}; 
scale = 1.1; 
If[ oCrit == "DP", 
     Print["criterion -> \"DP\"  is interpreted as \"DPextension\" , other options are DPcompression and DPsmall "];
     oCrit = "DPextension"
 ];
If[ oCrit == "DPsmall",  M2 = (9 sfi^2)/(3 + sfi^2); 
gSurf = RegionPlot[1.5*norm2[ deviator[tt]] < ( tr[tt]/3)^2  * M2  && x^2 + y^2 < p0^2, {x,-scale*p0, scale*p0 },{y, -scale*p0,  scale*p0 }]
 ];
If[ oCrit == "DPextension",   M2 = (6 sfi)^2/(3 + sfi)^2; 
gSurf = RegionPlot[1.5*norm2[ deviator[tt]] < ( tr[tt]/3)^2  * M2  && x^2 + y^2 < p0^2, {x, - scale*p0,  scale*p0 },{y, - scale*p0,  scale*p0 }]
 ];
If[ oCrit == "DPcompression",   M2 = (6 sfi)^2/(3 - sfi)^2; 
gSurf = RegionPlot[1.5*norm2[ deviator[tt]] < ( tr[tt]/3)^2  * M2  && x^2 + y^2 < p0^2, {x, - scale*p0,  scale*p0 },{y, - scale*p0,  scale*p0 }]
 ];
If[ oCrit == "MN", 
gSurf = RegionPlot[ tr[tt]*tr[1/tt]  <   (9-sfi^2)/(1-sfi^2)   && x^2 + y^2 < p0^2, {x, - scale*p0,  scale*p0 },  {y, - scale*p0,  scale*p0 }] ];
If[ oCrit == "MC", 
gSurf = RegionPlot[    Min[-tt]  >   (1-sfi)/(1+sfi) Max[-tt]   && x^2 + y^2 < p0^2, {x, - scale*p0,  scale*p0 },  {y, - scale*p0,  scale*p0 }] ];
If[oV, Print["point 5"]]; 
gnoTens = RegionPlot[ tt[[1]] < 0 && tt[[2]] < 0 && tt[[3]] < 0, {x, -3.2*p0, 3.2*p0 },  {y, -3.2*p0, 3.2*p0 }, PlotStyle->None ];


 Show[gSurf, gpath, gnoTens,   Graphics[ gaxes ] , Graphics[gminusAxes]  , Graphics[glabels]]  
];


 pqTriaxPlot[path_, sfi_:0] := Module[ { pathT, pathEps,p,q,EpsVol,Epsq,CSL, pmin, pmax, PP },
{pathT, pathEps} = Transpose[path][[1;;2]];
{p,q} = (     {-(delta~colon~# ) /3,(onevstar~colon~#)*Sqrt[1.5]}&/@pathT    ) //Transpose  ;
{pmin, pmax} = {Min[p], Max[p]};
{EpsVol,Epsq} = (  {-delta~colon~#,(onevstar~colon~#) / Sqrt[1.5]}& /@  pathEps ) //Transpose  ;
CSL = Plot[ {  6*sfi/(3-sfi) PP ,   -  6*sfi/(3+sfi) PP   } , {PP,pmin*0.999  ,pmax*1.001} ];
If[ sfi > 0 ,  GraphicsRow[{Show[ ListPlot[({p,q}  // Transpose),  AxesLabel->{"p","q"} ], CSL],  ListPlot[   ({EpsVol,Epsq} //Transpose ), AxesLabel->{"\[Epsilon]Vol(compr)", "\[Epsilon]q"} ]}],
                GraphicsRow[{ ListPlot[ {p,q}  // Transpose ,  AxesLabel-> {"p","q"} ],ListPlot[ {EpsVol,Epsq} //Transpose ,  AxesLabel-> {"\[Epsilon]Vol(compr)", "\[Epsilon]q"} ]} ]                               ]
];

pradhanTriaxPlot[path_,  sfi_:0] := Module[ { pathT, pathEps, x, y, xmax, xmin, xx },
{pathT, pathEps} = Transpose[path][[1;;2]];
{p,q} = (     {-(delta~colon~# ) /3,(onevstar~colon~#)*Sqrt[1.5]}&/@pathT    ) //Transpose  ;
{EpsVol,Epsq} = (  {-delta~colon~#,(onevstar~colon~#) /    Sqrt[1.5]}&/@pathEps) //Transpose  ;
dEpsVol = Drop[EpsVol,1 ] -  Drop[EpsVol,-1 ];
dEpsq = Drop[Epsq,1 ] -  Drop[Epsq,-1 ];
x = dEpsVol/dEpsq; y = Drop[q,1]/Drop[p,1];
{xmin, xmax} = {Min[x], Max[x]};
CSL = Plot[ {  6*sfi/(3-sfi) ,   -  6*sfi/(3+sfi)    } , {xx,xmin-0.01,xmax+0.01} ];
If[ sfi > 0 , Show[ ListPlot[  {-x,y} //Transpose ,  AxesLabel-> {"d\[Epsilon]Vol/d\[Epsilon]q ", "q/p"}  ], CSL],    ListPlot[  {-x,y} //Transpose,  AxesLabel-> {"d\[Epsilon]Vol/d\[Epsilon]q ", "q/p"}]       ]
];



stressResponsePQ[ constitutiveUpdate_ , state_,  params_ , disturbance_:10^-3   ] := Module[ {de,a, g1,g2, dePure,TPure,PQPure,PQmiddle},
de = (- onev*Cos[a] + onevstar* Sin[a]) * disturbance ;
g1 = ParametricPlot[( {(-onev ~colon~  #), (onevstar ~colon~ #) }&  @   
                      constitutiveUpdate[  state, de,  params ][[1]] )  ,  {a,0,2Pi} , 
                     AspectRatio -> Automatic, AxesLabel->{"P","Q"},PlotRange->All  ];
dePure = { de /. a-> 0 ,   de /. a-> Pi/2 , de /. a-> Pi , de /. a-> 3/2 Pi} ;
TPure =  constitutiveUpdate[  state, #,  params ][[1]]&  /@  dePure;
If[  axisymm23Q[ state[[1]] ], Null,    Print[" warning stressResponsePQ: Initial stress is not axisymmetric"  ] ];
If[  coaxialQ[ state[[1]],TPure[[1]]] && coaxialQ[ state[[1]], TPure[[2]] ], Null ,
                     Print[" warning stressResponsePQ: Initial stress not coaxial with the stress increment, try stressResponsePstarQstar[] instead"] ];
PQmiddle =   {(-onev ~colon~  # ), (onevstar ~colon~ #) }&   @   state[[1]];
PQPure =    {(-onev ~colon~  # ), (onevstar ~colon~ #) }&  /@TPure;
g2 = Graphics[ { PointSize[Large], Green, Point[ PQmiddle]  , Red, Point[PQPure[[1]]] ,   Blue, Point[PQPure[[2;;4]] ]  }   ];
Show[ g1, g2]
];
 

stressResponsePstarQstar[ constitutiveUpdate_ , state_,  params_ , disturbance_:10^-3   ] := Module[ 
{de,a,g1,g2,dePure,dTPure,PQPure,PQmiddle, dsPUnit,dsQ,dsQUnit,g3,g4},
de = (- onev*Cos[a] + onevstar* Sin[a]) * disturbance ;
dePure = { de /. a-> 0 ,   de /. a-> Pi/2 , de /. a-> Pi , de /. a-> 3/2 Pi} ;
dTPure =  (constitutiveUpdate[  state, #,  params ][[1]] - state[[1]] )&  /@  dePure;
dsPUnit=dTPure[[1]]// normalized;  (* basisPstar unit response to isotropic strain perturbance *)
dsQUnit=restprojOn[dTPure[[2]],dsPUnit] // normalized ;   (* basisQstar   unit perpendicular to basisPstar *)
g1 = ParametricPlot[ {  #~colon~dsPUnit    ,    #~colon~dsQUnit   }&  @   ( constitutiveUpdate[  state, de,  params ][[1]] - state[[1]] ) 
     ,{a,0,2Pi} , 
     AspectRatio ->Automatic , 
     AxesLabel->{ "\!\(\*SuperscriptBox[\(\[CapitalDelta]P\), \(\[FivePointedStar]\)]\)","\!\(\*SuperscriptBox[\(\[CapitalDelta]Q\), \(\[FivePointedStar]\)]\)" },
     PlotRange->All ];
     
PQmiddle =   {  0,0  };
PQPure =    {  #~colon~dsPUnit    ,    #~colon~dsQUnit   }&  /@dTPure;
 
g2 = Graphics[ { PointSize[Large], Black, Point[ PQmiddle]  , Red, Point[PQPure[[1]]], Blue, Point[PQPure[[2;;4]] ]  }   ];
 
g3=ParametricPlot[( {(-onev ~colon~  # ), (onevstar ~colon~ #) }&  @   de ) 
                  ,{a,0,2Pi} 
                  , AspectRatio ->Automatic 
                  , AxesLabel->{"\!\(\*SubscriptBox[\(\[CapitalDelta]\[CurlyEpsilon]\), \(P\)]\)","\!\(\*SubscriptBox[\(\[CapitalDelta]\[CurlyEpsilon]\), \(Q\)]\)"} 
                  ,PlotRange->All
                  ];
g4 = Graphics[ { PointSize[Large], Black, Point[ {0,0}]  ,
            Red, Point[   {(-onev ~colon~  # ), (onevstar ~colon~ #) }&  @   dePure[[1]] ] , 
            Blue, Point[    {(-onev ~colon~  # ), (onevstar ~colon~ #) }&/@   dePure[[2;;4]] ]}  
             ];
Print["Basis vectors are:\n\!\(\*SubscriptBox[SuperscriptBox[\(e\), \(\[FivePointedStar]\)], \(Q\)]\)=",dsQUnit//Chop//MatrixForm];
Print["\!\(\*SubscriptBox[SuperscriptBox[\(e\), \(\[FivePointedStar]\)], \(P\)]\)=",dsPUnit//Chop//MatrixForm];
GraphicsRow[{Show[g3,g4],Show[g1,g2]}]
];

 
stressResponse3D[ constitutiveUpdate_ , state_,  params_ , disturbance_:10^-3   ] := Module[ {dd,de,a,s,t,dePure, TPure,  g1,g2 },
If[ diagonalQ[state[[1]]] , Null ,Print["error in stressResponse3D: The initial stress is not diagonal"]; Abort[] ];
dd=  DiagonalMatrix[{Cos[s]*Cos[t],Cos[s]*Sin[t],Sin[s]}]* disturbance ;
g1 = ParametricPlot3D[( matrixDiagonal[#]&  @   constitutiveUpdate[  state, dd,  params ][[1]]  )  ,{t,0,2Pi},{s,-Pi/2,Pi/2}   , AspectRatio-> 1 ,
 AxesLabel->{"\!\(\*SubscriptBox[\(\[Sigma]\), \(3\)]\)","\!\(\*SubscriptBox[\(\[Sigma]\), \(1\)]\)","\!\(\*SubscriptBox[\(\[Sigma]\), \(2\)]\)"} ];
de = (- onev*Cos[a] + onevstar* Sin[a]) * disturbance ;
dePure = { de /. a-> 0 ,   de /. a-> Pi/2 , de /. a-> Pi , de /. a-> 3/2 Pi  ,  disturbance* DiagonalMatrix[ {0,1,-1} ]/Sqrt[2.0] } ;
TPure =  constitutiveUpdate[  state, #,  params ][[1]]&  /@  dePure;
If[ coaxialQ[ state[[1]] ,TPure[[1]]  ] &&  coaxialQ[ state[[1]] ,TPure[[2]]  ] && coaxialQ[ state[[1]] ,TPure[[5]]  ] , Null ,
     Print["warning from stressResponse3D: noncoaxial initial stress and stress increment, try stressResponse3Dstar[] instead"] ];
TPure =Diagonal[#] & /@ TPure//Chop;
g2 = Graphics3D[ {  PointSize[Large],Red, Point[TPure[[1]]] ,   Blue, Point[TPure[[2;;4]] ] , Green, Point[TPure[[5]] ]  }   ];
Show[ g1,g2] 
];

 

Options[stressResponse3Dstar]={"aspectRatio"-> "BoxRatios\[Rule]{1,1,1}","viewPoint"-> {1,1,1}}
stressResponse3Dstar[ constitutiveUpdate_ , state_,  params_ , disturbance_:10^-3 ,OptionsPattern[]  ] := Module[ 
{dd,de,a,s,t,dePure, dTPure,  g1,g2,g3,deR, dsPUnit,dsQ,dsQUnit,dsRUnit,PQRPure,PQRR,g4,g5,g6 },
dd=  DiagonalMatrix[{Cos[s]*Cos[t],Cos[s]*Sin[t],Sin[s]}]* disturbance ;
de = (- onev*Cos[a] + onevstar* Sin[a]) * disturbance ;
deR=(DiagonalMatrix[{0,1,-1}]//normalized)*disturbance;
dePure = { de /. a-> 0 ,   de /. a-> Pi/2 , de /. a-> Pi , de /. a-> 3/2 Pi, deR} ;
dTPure = ( constitutiveUpdate[  state, #,  params ][[1]] -  state[[1]] ) &  /@  dePure;

 
dsPUnit=dTPure[[1]]// normalized ;   (* basisPstar unit response to isotropic strain perturbance *)
dsQUnit=restprojOn[dTPure[[2]],dsPUnit] // normalized ; (*    basisQstar   unit tensor perpendicular to dsPUnit *)
dsRUnit=restprojOn[dTPure[[5]],dsPUnit,dsQUnit]//normalized; (*  basisRstar  unit tensor perpendicular to dsPUnit and dsQUnit *)

g1 = ParametricPlot3D[  {  #~colon~dsPUnit    ,    #~colon~dsQUnit     ,    #~colon~dsRUnit }&  @  ( constitutiveUpdate[  state, dd,  params ][[1]] - state[[1]])  
                         ,{t,0,2Pi},{s,-Pi/2,Pi/2}
                         ,Evaluate[ToExpression[OptionValue["aspectRatio"]]]  
                         ,Mesh->None, 
                         AxesLabel->{"\!\(\*SuperscriptBox[\(\[CapitalDelta]P\), \(\[FivePointedStar]\)]\)","\!\(\*SuperscriptBox[\(\[CapitalDelta]Q\), \(\[FivePointedStar]\)]\)","\!\(\*SuperscriptBox[\(\[CapitalDelta]R\), \(\[FivePointedStar]\)]\)"} 
                         ];
PQRPure =    {  #~colon~dsPUnit    ,    #~colon~dsQUnit  ,    #~colon~dsRUnit }&  /@ dTPure;

g2 = Graphics3D[ {  PointSize[Large],Red, Point[PQRPure[[1]]] ,   Blue, Point[PQRPure[[2;;4]] ]  ,  Green, Point[PQRPure[[5]] ]}   ];
g3=ParametricPlot3D[ {  #~colon~dsPUnit    ,    #~colon~dsQUnit     ,    #~colon~dsRUnit }&  @ ( constitutiveUpdate[  state, de,  params ][[1]] - state[[1]] )  
                      ,{a,0,2Pi}  ,
                      Evaluate[ToExpression[OptionValue["aspectRatio"]]],
                      PlotStyle->Blue ];
g4= ParametricPlot3D[( matrixDiagonal[#]&  @   dd )  ,{t,0,2Pi},{s,-Pi/2,Pi/2} 
                       ,Evaluate[ToExpression[OptionValue["aspectRatio"]]]
                       ,Mesh->None 
                       ,AxesLabel->{"\!\(\*SubscriptBox[\(\[CapitalDelta]\[CurlyEpsilon]\), \(P\)]\)","\!\(\*SubscriptBox[\(\[CapitalDelta]\[CurlyEpsilon]\), \(Q\)]\)","\!\(\*SubscriptBox[\(\[CapitalDelta]\[CurlyEpsilon]\), \(R\)]\)"}
                        ];
g5= Graphics3D[ { PointSize[Large], Black, Point[ {0,0,0}]  ,
Red, Point[   -matrixDiagonal[#]&  @   dePure[[1]] ] , 
Blue, Point[    -matrixDiagonal[#]&/@   dePure[[2;;4]] ],
Green, Point[    matrixDiagonal[#]&  @   deR  ]} ];
g6=ParametricPlot3D[( matrixDiagonal[#]&  @   de )  ,{a,0,2Pi}   ,Evaluate[ToExpression[OptionValue["aspectRatio"]]] ,PlotStyle->Blue ];

Print["Basis vectors are:\n\!\(\*SubscriptBox[SuperscriptBox[\(e\), \(\[FivePointedStar]\)], \(Q\)]\)=",dsQUnit//Chop//MatrixForm];
Print["\!\(\*SubscriptBox[SuperscriptBox[\(e\), \(\[FivePointedStar]\)], \(P\)]\)=",dsPUnit//Chop//MatrixForm];
Print["\!\(\*SubscriptBox[SuperscriptBox[\(e\), \(\[FivePointedStar]\)], \(R\)]\)=",dsRUnit//Chop//MatrixForm];
GraphicsRow[{Show[g4,g5,g6,ViewPoint->OptionValue["viewPoint"]],Show[g1,g2,g3,ViewPoint->OptionValue["viewPoint"]]}]
];


isoPQ[X_?t3Q]:= If[ X[[3]] == X[[2]],   {(-DiagonalMatrix[X]~colon~onev),(DiagonalMatrix[X]~colon~onevstar)} , 
                                     Print[ "Error in isoPQ: argument  ",X, "  is not of the form {a,b,b}" ], 
                                      Print[ "Error in isoPQ: argument  ",X, "  is not necessarily of the form {a,b,b}" ] 
      ]; 

            
isoPQ[X_?t33Q]:=  Module[{PQ} ,    (*X is a mechanical tensor *)
     If[ DiagonalMatrixQ[X] && X[[3,3]] == X[[2,2]] ,   PQ = {-(X~colon~onev),(X~colon~onevstar)}  ]  ;                         (*Q with sign *)
     If[ DiagonalMatrixQ[X] && X[[1,1]] == X[[2,2]] ,   PQ = {-(X~colon~onev),(X~colon~DiagonalMatrix[{1,1,-2}]/Sqrt[6])}  ]  ;  (*Q with sign *)
     If[ DiagonalMatrixQ[X] && X[[1,1]] == X[[3,3]] ,   PQ = {-(X~colon~onev),(X~colon~DiagonalMatrix[{1,-2,1}]/Sqrt[6])}  ]  ;  (*Q with sign *)
     If[ Not[ DiagonalMatrixQ[X] ]              ,   PQ = {-tr[X]/Sqrt[3], Sqrt[norm2[dev[X]]]}  ]  ;                       (* Q > 0*)
     PQ
  ]; 
                         
isoPQ[X_?t3333Q]:={{onev~colon~(X~colon~onev),(-onev)~colon~(X~colon~onevstar)},{onevstar~colon~(X~colon~(-onev)),onevstar~colon~(X~colon~onevstar)}};

isoPQFull[T_?t33Q]:=   {-tr[T]/Sqrt[3], Sqrt[norm2[dev[T]]]  }  ;                       (* always Q > 0*) 
isoPQFull[T_?t3Q]:=   {-tr[T]/Sqrt[3], Sqrt[norm2[dev[T]]]  }  ;                       (* always Q > 0*) 
  


isoPQgeot[X_?t3Q]:= If[ X[[3]] == X[[2]],   {(DiagonalMatrix[X]~colon~onev),(DiagonalMatrix[X]~colon~(-onevstar))} , Print[ "Error in isoPQgeot: argument  ",X, "  is not of the form {a,b,b}" ], 
  Print[ "Error in isoPQgeot: argument  ",X, "  is not necessarily of the form {a,b,b}" ]  ]; 
  
isoPQgeot[X_?t33Q]:=  If[ DiagonalMatrixQ[X] && X[[3,3]] == X[[2,2]] ,   {(X~colon~onev),(X~colon~(-onevstar))} ,   Print[ "Error in isoPQgeot: argument  ",X, "  is not of the form DiagonalMatrix[{a,b,b}]" ], 
  Print[ "Error in isoPQgeot: argument  ",X, "  is not necessarily of the form DiagonalMatrix[{a,b,b}]" ]
  ]; 
  
isoPQgeot[X_?t3333Q]:={{onev~colon~(X~colon~onev),onev~colon~(X~colon~(-onevstar))},{(-onevstar)~colon~(X~colon~onev),onevstar~colon~(X~colon~onevstar)}};
 



inverseSM[A_?t3333Q , u_?t33Q ,  v_?t33Q ] := Module[{ iA, aux1, aux2},
iA = inverse99[A]  ;
aux1= (iA  ~colon~ u ) ~out~( v ~colon~ iA);
aux2=  1+ ( ( v ~colon~ iA) ~colon~ u );
If[aux2 ~approx~ 0, Print["Sherman-Morisson error aux2==0"]; Abort[];];
iA - aux1/aux2
   ];
     

inversedSM[iA_?t3333Q , u_?t33Q ,  v_?t33Q , u2_?t33Q ,  v2_?t33Q   ] := Module[{ aux1, aux2},
 inversedSM[inversedSM[iA,u,v],u2,v2] 
];    
     
inversedSM[iA_?t3333Q , u_?t33Q ,  v_?t33Q , u2_?t33Q ,  v2_?t33Q , u3_?t33Q ,  v3_?t33Q  ] := Module[{ aux1, aux2},
 inversedSM[inversedSM[inversedSM[iA,u,v],u2,v2],u3,v3] 
];

inversedSM[iA_?t3333Q , u_?t33Q ,  v_?t33Q , u2_?t33Q ,  v2_?t33Q , u3_?t33Q ,  v3_?t33Q , u4_?t33Q ,  v4_?t33Q ] := Module[{ aux1, aux2},
inversedSM[inversedSM[inversedSM[inversedSM[iA,u,v],u2,v2],u3,v3],u4,v4]
];

inversedSM[iA_?t3333Q , u_?t33Q ,  v_?t33Q ] := Module[{ aux1, aux2},
aux1= (iA  ~colon~ u ) ~out~( v ~colon~ iA);
aux2=  1+ ( ( v ~colon~ iA) ~colon~ u );
If[aux2 ~approx~ 0, Print["Sherman-Morisson error aux2==0"]; Abort[];];
iA - aux1/aux2
     ];




t2Q[x_] := Dimensions[x] == {2} ;
t22Q[x_] := Dimensions[x] == {2, 2} ;  (* tests if x is a 2:2 matrix*)
t3Q[x_] := Dimensions[x] == {3} ;
t33Q[x_] := Dimensions[x] == {3, 3} ;  (* tests if x is a 3:3 matrix*)
t333Q[x_] := Dimensions[x] == {3, 3, 3};
t3333Q[x_] := Dimensions[x] == {3,3,3,3} ; (* tests if x is a 3:3:3:3 matrix *)
t9Q[x_] := Dimensions[x] == {9} ;        (* tests if x is a 9:9 matrix *)
t6Q[x_] := Dimensions[x] == {6} ;
t99Q[x_] := Dimensions[x] == {9,9} ;        (* tests if x is a 9:9 matrix *)
t66Q[x_] := Dimensions[x] == {6,6} ;
t33333Q[x_] := Dimensions[x] == {3, 3, 3, 3, 3};
t333333Q[x_] := Dimensions[x] == {3, 3, 3, 3, 3, 3};
t3333333Q[x_] := Dimensions[x] == {3, 3, 3, 3, 3, 3, 3};
t33333333Q[x_] := Dimensions[x] == {3, 3, 3, 3, 3, 3, 3, 3};
atomSymbolQ[a_] := Not[NumberQ[a]] && AtomQ[a] ;
tQ[x_] := Dimensions[x] == {3,3} || Dimensions[x] == {3} ;
vectorQ[x_] :=   ListQ[x] && Length[Dimensions[x]]  == 1  ;
squareMQ[x_] :=  ListQ[x] && Length[Dimensions[x] ] == 2 &&   Dimensions[x][[1]] ==   Dimensions[x][[2]]; 
symmMQ[x_] :=  squareMQ[x] && (norm2[x-Transpose[x]] ~approx ~ 0);  
coaxialQ[a_?t33Q,  b_?t33Q   ] := norm2[a . b - b . a] ~approx~ 0;
coaxialQ[a_?t3333Q,  b_?t3333Q   ] := norm2[(a~colon~b) - (b~colon~a) ] ~approx~ 0;
axisymm23Q[aa_?t33Q ] :=   DiagonalMatrixQ[Chop[ aa] ] && (aa[[2,2]]-aa[[3,3]] ~approx~ 0) ;
axisymm23Q[aa_?t3Q ] :=   aa[[2]]~approx~aa[[3]]   ;


delta = IdentityMatrix[3];
\[Delta] = IdentityMatrix[3]; 
onev =  IdentityMatrix[3]/Sqrt[3];
onevstar = -DiagonalMatrix[{2,-1,-1}]/Sqrt[6];
ricci := Array[Signature[{#1, #2, #3}] & , {3, 3, 3}]   ;
Ricci := Array[Signature[{#1, #2, #3}] & , {3, 3, 3}]   ;



colon[a_?t33Q,Ricci] := Table[   Sum[a[[i,j]]*Ricci[[i,j,k]],{i,1,3},{j,1,3} ],  {k,1,3}];
colon[Ricci,a_?t33Q ]:= Table[   Sum[Ricci[[i,j,k]]*a[[j,k]],{j,1,3},{k,1,3} ],    {i,1,3}];
colon[Ricci,Ricci] := 2 delta ;
colon[a_?t33Q,b_?t33Q] := Sum[a[[i,j]]*b[[i,j]],{i,1,3},{j,1,3}];                                       (* : with rank 2 tensor*)
colon[a_?t333Q,b_?t33Q] := Table[ Sum[ a[[j,k,l]]*b[[k,l]],{k,1,3},{l,1,3}] , {j,1,3}];
colon[a_?t33Q,b_?t333Q] := Table[ Sum[ a[[i,j]]*b[[i,j,k]],{i,1,3},{j,1,3}] , {k,1,3} ];
colon[a_?t3333Q,b_?t33Q] := Table[ Sum[ a[[i,j,k,l]]*b[[k,l]],{k,1,3},{l,1,3}] ,{i,1,3},{j,1,3}];
colon[a_?t33Q,b_?t3333Q] := Table[ Sum[ a[[i,j]]*b[[i,j,k,l]],{i,1,3},{j,1,3}] ,{k,1,3},{l,1,3}];
colon[a_?t333Q,b_?t33Q] := Table[ Sum[a[[ j,k,l]]*b[[k,l]],{k,1,3},{l,1,3}] ,{j,1,3}];
colon[a_?t33Q,b_?t333Q] := Table[ Sum[a[[i,j]]*b[[i,j,k ]],{i,1,3},{j,1,3}] ,{k,1,3} ];
colon[a_?t33333Q,b_?t33Q] := Table[ Sum[ a[[z,i,j,k,l]]*b[[k,l]],{k,1,3},{l,1,3}] ,{z,1,3},{i,1,3},{j,1,3}];
colon[a_?t33Q,b_?t33333Q] := Table[ Sum[ a[[i,j]]*b[[i,j,k,l,z]],{i,1,3},{j,1,3}] ,{k,1,3},{l,1,3},{z,1,3}];
colon[a_?t333333Q,b_?t33Q] := Table[ Sum[ a[[y,z,i,j,k,l]]*b[[k,l]],{k,1,3},{l,1,3}] ,{y,1,3},{z,1,3},{i,1,3},{j,1,3}];
colon[a_?t33Q,b_?t333333Q] := Table[ Sum[ a[[i,j]]*b[[i,j,k,l,z,y]],{i,1,3},{j,1,3}] ,{k,1,3},{l,1,3},{z,1,3},{y,1,3}];
colon[a_?t333Q,b_?t333Q] := Table[ Sum[ a[[i,j,k]]*b[[j,k,l]],{j,1,3},{k,1,3}] ,{i,1,3},{l,1,3}];                               (* :  with rank 3 tensor*)
colon[a_?t3333Q,b_?t333Q] := Table[ Sum[ a[[z,i,j,k]]*b[[j,k,l]],{j,1,3},{k,1,3}] ,{z,1,3},{i,1,3},{l,1,3}];
colon[a_?t333Q,b_?t3333Q] := Table[ Sum[ a[[i,j,k]]*b[[j,k,l,z]],{j,1,3},{k,1,3}] ,{i,1,3},{l,1,3} ,{z,1,3}];
colon[a_?t33333Q,b_?t333Q] := Table[ Sum[ a[[y,z,i,j,k]]*b[[j,k,l]],{j,1,3},{k,1,3}] ,{y,1,3},{z,1,3},{i,1,3},{l,1,3}];
colon[a_?t333Q,b_?t33333Q] := Table[ Sum[ a[[i,j,k]]*b[[j,k,l,z,y]],{j,1,3},{k,1,3}] ,{i,1,3},{l,1,3} ,{z,1,3},{y,1,3}];
colon[a_?t333333Q,b_?t333Q] := Table[ Sum[ a[[x,y,z,i,j,k]]*b[[j,k,l]],{j,1,3},{k,1,3}] ,{x,1,3},{y,1,3},{z,1,3},{i,1,3},{l,1,3}];
colon[a_?t333Q,b_?t333333Q] := Table[ Sum[ a[[i,j,k]]*b[[j,k,l,z,y,x]],{j,1,3},{k,1,3}] ,{i,1,3},{l,1,3} ,{z,1,3},{y,1,3},{x,1,3}];
colon[a_?t3333Q,b_?t3333Q] := Table[ Sum[ a[[i,j,k,l]]*b[[k,l,m,n]],{k,1,3},{l,1,3}] ,{i,1,3},{j,1,3},{m,1,3},{n,1,3}];             (* : with rank 4 tensor*)
colon[a_?t3333Q,b_?t33333Q] := Table[ Sum[ a[[i,j,k,l]]*b[[k,l,m,n,z]],{k,1,3},{l,1,3}] ,{i,1,3},{j,1,3},{m,1,3},{n,1,3},{z,1,3}];
colon[a_?t33333Q,b_?t3333Q] := Table[ Sum[ a[[z,i,j,k,l]]*b[[k,l,m,n]],{k,1,3},{l,1,3}] ,{z,1,3},{i,1,3},{j,1,3},{m,1,3},{n,1,3}];
colon[a_?t3333Q,b_?t333333Q] :=Table[ Sum[ a[[i,j,k,l]]*b[[k,l,m,n,z,y]],{k,1,3},{l,1,3}] ,{i,1,3},{j,1,3},{m,1,3},{n,1,3},{z,1,3},{y,1,3}];
colon[a_?t333333Q,b_?t3333Q] :=Table[ Sum[  a[[y,z,i,j,k,l]]*b[[k,l,m,n]],{k,1,3},{l,1,3}], {y,1,3} ,{z,1,3},{i,1,3},{j,1,3},{m,1,3},{n,1,3}];
colon[a_?t33333Q,b_?t33333Q] := Table[ Sum[ a[[i,j,k,l,m]]*b[[l,m,n,o]],{l,1,3},{m,1,3}] ,{i,1,3},{j,1,3},{k,1,3},{n,1,3},{o,1,3}];     (* : with rank 5 tensor*)
colon[a_?t33333Q,b_?t333333Q] := Table[ Sum[ a[[i,j,k,l,m]]*b[[l,m,n,o,z]],{l,1,3},{m,1,3}] ,{i,1,3},{j,1,3},{k,1,3},{n,1,3},{o,1,3},{z,1,3}];
colon[a_?t333333Q,b_?t33333Q] := Table[ Sum[ a[[z,i,j,k,l,m]]*b[[l,m,n,o,p]],{l,1,3},{m,1,3}] ,{z,1,3},{i,1,3},{j,1,3},{k,1,3},{n,1,3},{o,1,3},{p,1,3}];
colon[a_?t33333Q,b_?t333333Q] := Table[ Sum[ a[[i,j,k,l,m]]*b[[l,m,n,o,p,z]],{l,1,3},{m,1,3}],{i,1,3},{j,1,3},{k,1,3},{n,1,3},{o,1,3},{p,1,3},{z,1,3}];
colon[a_?t333333Q,b_?t333333Q] := Table[ Sum[ a[[u,i,j,k,l,m]]*b[[l,m,n,o,p,z]],{l,1,3},{m,1,3}],{u,1,3},{i,1,3},{j,1,3},{k,1,3},{n,1,3},{o,1,3},{p,1,3},{z,1,3}];  (* : with rank 6 tensor*)
colon3[A_?t333Q,B_?t333Q] :=   Sum[ A[[i,j,k]]*B[[i,j,k]],{i,1,3},{j,1,3},{k,1,3}]   ;   (* with rank 3 tensor *)
colon3[A_?t333Q,B_?t333333Q] := Table[ Sum[ A[[i,j,k]]*B[[i,j,k,a,b,c]],{i,1,3},{j,1,3},{k,1,3}] ,  {a,1,3},{b,1,3},{c,1,3}];  (* with rank 6 tensor *)
colon3[A_?t333333Q,B_?t333Q] := Table[ Sum[ A[[a,b,c,i,j,k]]*B[[i,j,k]],{i,1,3},{j,1,3},{k,1,3}] ,  {a,1,3},{b,1,3},{c,1,3}];
colon3[A_?t333333Q,B_?t333333Q] := Table[ Sum[ A[[a,b,c,i,j,k]]*B[[i,j,k,d,e,f]],{i,1,3},{j,1,3},{k,1,3}] ,{a,1,3},{b,1,3},{c,1,3},{d,1,3},{e,1,3},{f,1,3} ];
colon4[A_?t3333Q,B_?t3333Q] :=   Sum[ A[[i,j,k,l]]*B[[i,j,k,l]],{i,1,3},{j,1,3},{k,1,3},{l,1,3}]   ;  
hatcolon[a_?t333333Q,b_?t33Q] := Table[ Sum[ a[[y,z,k,l,i,j]]*b[[k,l]],{k,1,3},{l,1,3}] ,{y,1,3},{z,1,3},{i,1,3},{j,1,3}];




 
projOn[aa_?t3Q, bb_?t3Q ] := bb (bb . aa)/ (bb . bb) //Simplify ;
restprojOn[aa_?t3Q, bb_?t3Q ] := aa - bb (bb . aa)/ (bb . bb)  // Simplify;
projOn[aa_?t33Q, bb_?t33Q ] := bb (bb~colon~aa)/ (bb~colon~bb) //Simplify ;
restprojOn[aa_?t33Q, bb_?t33Q ] := aa - bb (bb~colon~aa)/ (bb~colon~bb)  // Simplify;
projOn[aa_?t333Q, bb_?t333Q ] := bb (bb~colon~aa)/ (bb~colon~bb) //Simplify ;
restprojOn[aa_?t333Q, bb_?t333Q ] := aa - bb (bb~colon~aa)/ (bb~colon~bb)  // Simplify;
projOn[aa_?t3333Q, bb_?t3333Q ] := bb (bb~colon~aa)/ (bb~colon~bb) //Simplify ;
restprojOn[aa_?t3333Q, bb_?t3333Q ] := aa - bb (bb~colon~aa)/ (bb~colon~bb)  // Simplify;
restprojOn[aa_, bb_, cc_ ] :=   aa -  (aa~projOn~bb) - ( aa~projOn~(cc~restprojOn~bb) )//Simplify  ;  

externalHashProduct[a_?t33Q,b_?t33Q]  := (ricci ~colon~( tpose23( a ~out~ b) ))~colon~ricci;
doubleCrossProduct[a_?t33Q,b_?t33Q]  := ( tr[a]tr[b] -( a~colon~b)) delta +a . b + b . a  - tr[a] b - tr[b]a;



contract[T_?t33Q , a_, b_] := Module[ {indices, c, dx, f1 },
 If[a == b || Max[a, b] > 2 || Min[a, b] < 1,
 Print["contract error: wrong indices "]; Abort[];];
 tr[T]
 ];


contract[T_?t333Q , a_, b_] := Module[ {indices, c, dx, f1 },
 If[a == b || Max[a, b] > 3 || Min[a, b] < 1,
 Print["contract error: wrong indices "]; Abort[];];
 {c} = Complement[{1, 2, 3}, {a, b}];
 indices = ReplacePart[{1, 1, 1} , { a -> dx, b -> dx, c -> f1 }] ;
 Table[ Sum[ Extract[ T, indices ], {dx, 1, 3} ] , {f1, 1, 3} ]
 ];

contract[T_?t3333Q , a_, b_] :=
 Module[ {indices, c, d, dx, f1, f2 },
 If[a == b || Max[a, b] > 4 || Min[a, b] < 1,
 Print["contract error: wrong indices "]; Abort[];];
 {c, d} = Complement[{1, 2, 3, 4}, {a, b}];
 indices = ReplacePart[{1, 1, 1, 1} , { a -> dx, b -> dx, c -> f1, d -> f2}] ;
 Table[ Sum[ Extract[ T, indices ], {dx, 1, 3} ] , {f1, 1, 3}, {f2, 1, 3} ]
 ];

contract[T_?t33333Q , a_, b_] :=
 Module[ {indices, c, d, e, dx, f1, f2 , f3},
 If[a == b || Max[a, b] > 5 || Min[a, b] < 1, Print["contract error: wrong indices "]; Abort[];];
 {c, d, e} = Complement[{1, 2, 3, 4, 5}, {a, b}];
 indices = ReplacePart[{1, 1, 1, 1, 1} , { a -> dx, b -> dx, c -> f1, d -> f2, e -> f3}] ;
 Table[ Sum[ Extract[ T, indices ], {dx, 1, 3} ] , {f1, 1, 3}, {f2, 1, 3}, {f3, 1, 3} ]
 ];

contract[T_?t333333Q , a_, b_] :=
 Module[ {indices, c, d, e, f, dx, f1, f2 , f3, f4},
 If[a == b || Max[a, b] > 6 || Min[a, b] < 1,
 Print["contract error: wrong indices "]; Abort[];];
 {c, d, e, f} = Complement[{1, 2, 3, 4, 5, 6}, {a, b}]; (* positions of free indices *)
 indices = ReplacePart[{1, 1, 1, 1, 1, 1 } , { a -> dx, b -> dx, c -> f1, d -> f2, e -> f3, f -> f4}] ;
 Table[ Sum[ Extract[ T, indices ], {dx, 1, 3} ] , {f1, 1, 3}, {f2, 1, 3}, {f3, 1, 3} , {f4, 1, 3} ]
 ];

contract[T_?t3333333Q , a_, b_] :=
 Module[ {indices, c, d, e, f, g, dx, f1, f2 , f3, f4, f5},
 If[a == b || Max[a, b] > 7 || Min[a, b] < 1,
 Print["contract error: wrong indices "]; Abort[];];
 {c, d, e, f, g} = Complement[{1, 2, 3, 4, 5, 6, 7}, {a, b}]; (* positions of free indices *)
 indices = ReplacePart[{1, 1, 1, 1, 1, 1, 1} , { a -> dx, b -> dx, c -> f1, d -> f2, e -> f3, f -> f4, g -> f5}] ;
 Table[ Sum[ Extract[ T, indices ], {dx, 1, 3} ] , {f1, 1, 3}, {f2, 1, 3}, {f3, 1, 3} , {f4, 1, 3}, {f5, 1, 3}]
 ] ;

contract[T_?t33333333Q , a_, b_] :=
 Module[ {indices, c, d, e, f, g, h, dx, f1, f2 , f3, f4, f5,f6},
 If[a == b || Max[a, b] > 8 || Min[a, b] < 1,
 Print["contract error: wrong indices "]; Abort[];];
 {c, d, e, f, g, h} = Complement[{1, 2, 3, 4, 5, 6, 7, 8}, {a, b}]; (* positions of free indices *)
 indices = ReplacePart[{1, 1, 1, 1, 1, 1, 1, 1} , { a -> dx, b -> dx, c -> f1, d -> f2, e -> f3, f -> f4, g -> f5, h-> f6}] ;
 Table[ Sum[ Extract[ T, indices ], {dx, 1, 3} ] , {f1, 1, 3}, {f2, 1, 3}, {f3, 1, 3} , {f4, 1, 3}, {f5, 1, 3}, {f6, 1, 3}]
 ];


tr[x_?t33Q] := x[[1,1]] + x[[2,2]] + x[[3,3]];
tr[x_?t3Q] := x[[1]] + x[[2]] + x[[3]];
deviator[x_?t33Q] :=  x - (tr[x]/3)* delta;
deviator[x_?t3Q] :=  x -  tr[x]*{1,1,1}/3;
dev[x_?t33Q] :=  x - (tr[x]/3)* delta;
dev[x_?t3Q] :=  x -  tr[x]*{1,1,1}/3;
hated[x_?t33Q] :=  x /tr[x];
hated[x_?t3Q] :=  x/tr[x];
norm2[x_?t33Q] := Simplify[ tr[ Transpose[x] . x ] ];
norm2[x_?t3Q] := Simplify[  x . x   ];
norm2[x_?t3333Q] := Simplify[  x ~colon4~ x   ];  
qubic[x_?t33Q] := Simplify[tr[x . x . x]];
qubic[x_?t3Q] := Simplify[x[[1]]^3 + x[[2]]^3+ x[[3]]^3];
scalar[x_?t33Q, y_?t33Q, z_?t33Q] := Simplify[tr[x . y . z]];
scalar[x_?t3Q, y_?t3Q, z_?t3Q] := Simplify[x[[1]]*y[[1]]*z[[1]] + x[[2]]*y[[2]]*z[[2]]+ x[[3]]*y[[3]]*z[[3]] ];
scalar[x_?t33Q, y_?t33Q] :=Simplify[ tr[ Transpose[x] . y]];
scalar[x_?t3Q, y_?t3Q] :=Simplify[x . y];
normalized[x_?t33Q] := Module[{a,b}, a = norm2[x];    If[numericQ[x]  , If[a == 0, b=x,  b=x/Sqrt[a] ], b=x/Sqrt[a]  ]; b]
normalized[x_?t3Q] := Normalize[x] ;
i1[x_?tQ] := tr[x];
i2[x_?tQ] := (norm2[x] - tr[x]^2 )/2;
i3[x_?t33Q] :=  Det[x];
i3[x_?t3Q] :=  x[[1]] * x[[2]] * x[[3]];
j2[x_?tQ] := norm2[deviator[x]] /2;
j3[x_?t33Q] := Det[deviator[x]];
j3[x_?t3Q] := i3[deviator[x]];
RoscoeP[x_?tQ] := -tr[x]/3;
RoscoeQ[x_?tQ] :=  Sqrt[3*j2[x]];

RoscoeQ[{a_,b_,b_}] := -(a-b);    (* axisymmetric form with sign *)
RoscoeQ[{b_,a_,b_}] := -(a-b);    (*  x = {a, b, b}; y = {c, d, d}; x.y  - RoscoeP[x] RoscoeEpsilonV[y] - RoscoeQ[x] RoscoeEpsilonQ[y] // Simplify *)
RoscoeQ[{b_,b_,a_}] := -(a-b);

RoscoeEpsilonV[x_?t33Q] := -tr[x] ;
RoscoeEpsilonV[x_?t3Q] := -tr[x] ;
RoscoeEpsilonQ[x_?t33Q] := Sqrt[2/3 * norm2[deviator[x]]] ;
RoscoeEpsilonQ[x_?t3Q] := Sqrt[2/3 norm2[deviator[x]]] ;

RoscoeEpsilonQ[{a_,b_,b_}] := -2/3 (a -b);
RoscoeEpsilonQ[{b_,a_,b_ }] := -2/3 (a -b);
RoscoeEpsilonQ[{b_,b_,a_}] := -2/3 (a -b);

isomorphicP[x_?t33Q]  := -tr[x]/Sqrt[3]  ;
isomorphicP[x_?t3Q]   := -tr[x]/Sqrt[3]  ;
isoP[x_?t33Q]  := -tr[x]/Sqrt[3]  ;
isoP[x_?t3Q]   := -tr[x]/Sqrt[3]  ;

isomorphicQ[x_?t33Q]  := Sqrt[norm2[deviator[x]]]  ;
isomorphicQ[x_?t3Q]  := Sqrt[norm2[deviator[x]]]  ;
isomorphicQ[{a_,b_,b_}] := -Sqrt[2/3](a-b);    (* axisymmetric form with sign *)
isomorphicQ[{b_,a_,b_}] := -Sqrt[2/3](a-b);   
isomorphicQ[{b_,b_,a_}] := -Sqrt[2/3](a-b);

isoQ[x_?t33Q ]  := Sqrt[norm2[deviator[x]]]  ;
isoQ[x_?t3Q]  := Sqrt[norm2[deviator[x]]]  ;
isoQ[{a_,b_,b_}] := -Sqrt[2/3](a-b);    (* axisymmetric form with sign *)
isoQ[{b_,a_,b_}] := -Sqrt[2/3](a-b);   (*  x = {a, b, b}; y = {c, d, d}; x.y  - isoP[x] isoP[y] - isoQ[x] isoQ[y] // Simplify *)
isoQ[{b_,b_,a_}] := -Sqrt[2/3](a-b);


LodeTheta[x_?tQ]:=(1/3)*ArcCos[ -3*Sqrt[3]*j3[x]/(2* (j2[x])^(3/2)  )] //Re  ;



st33[ a_?atomSymbolQ ]   := {{a[1, 1], a[1, 2], a[1, 3]}, {a[1, 2], a[2, 2], a[2, 3]},  {a[1, 3], a[2, 3], a[3, 3]}} ;
st33[ a_?NumberQ ]   := symm12[ Array[RandomReal[{-Abs[a],Abs[a]}]&,{3,3}] ];
st33[ a_?t3Q ]   := DiagonalMatrix[a];
st33[] := Module[{a} , 
             a = Global`T;  If[ NumberQ[a] , Message[bnova::"Globals", "{T}=", {Global`T} ] ] ; 
             st33[a] ];  

 
ast33[ a_?atomSymbolQ ]   := {{0, a[1, 2], a[1, 3]}, {-a[1, 2], 0 , a[2, 3]},  {-a[1, 3], -a[2, 3], 0}} ;
ast33[ a_?NumberQ ]   := Module[{T} , 
                       T =   Array[RandomReal[{-Abs[a],Abs[a]}]&,{3,3}]  ;  
                       T-symm12[T]       ];
                       
ast33[ a_?t3Q ]   :=  {{0, a[[1]], a[[2]]}, {-a[[1]], 0 , a[[3]]},  {-a[[2]], -a[[3]], 0}} ;
 
ast33[] := Module[{a} , 
  a = Global`T;   If[ NumberQ[a] , Message[bnova::"Globals", "{T}=", {Global`T} ] ] ; 
   ast33[a] ]; 




Options[st3333]  = {symmMajor -> True, verbose -> False};
st3333[ a_?atomSymbolQ , OptionsPattern[] ]:= Module[{EE,uniq, uniqSymb,aa ,srules,n}, 

                             EE = Array[a,{9,9}]  // transfer99i     //symm12 //symm34  ; 
                             If[OptionValue[symmMajor],  EE = EE //  symm13i24];  
                             EE = EE // transfer99   //Simplify; 
                             uniq = EE // Flatten // DeleteDuplicates   ;  
                             uniqSymb = Select[ uniq , Not[NumberQ[#]]& ] ; 
                             n = Length[uniqSymb]; aa = Array[a, {n}]; 
                             srules = MapThread[ Rule, {uniqSymb,  aa}];  
                             If[OptionValue[verbose], Print[ "symmetrized from initial a[9,9] matrix" , srules] ]; 
                             (EE //. srules ) // transfer99i // Simplify 
                                ] ; 
                                
st3333[ a_?NumberQ , OptionsPattern[] ]:= Module[{EE,   aa ,srules,n}, 
                             EE = Array[ RandomReal[{-Abs[a]; Abs[a]}]&  ,{9,9}]  // transfer99i     //symm12 //symm34  ; 
                             If[OptionValue[symmMajor],  EE = EE //  symm13i24];  
                              EE //N      
                              ] ; 
                              

   

    


Options[tpose]  = {fromOrder -> True};
tpose[A_?t3333Q , order_,  OptionsPattern[]] := Module[{i,j,k,l,o={0,0,0,0},B},
If[Dimensions[order] != {4} || !DuplicateFreeQ[order], Print["order=", order, " has wrong dimension or contains duplicates" ]; Abort[]];
B=Array[0&,{3,3,3,3}];o=order/.{1->i,2->j,3->k,4->l};
If[ OptionValue[fromOrder],
Do[B[[i,j,k,l]]=A[[ o[[1]], o[[2]], o[[3]], o[[4]] ]], {i,1,3}, {j,1,3}, {k,1,3}, {l,1,3}],
Do[B[[ o[[1]], o[[2]], o[[3]], o[[4]] ]]=A[[i,j,k,l]], {i,1,3}, {j,1,3}, {k,1,3}, {l,1,3}] ] ; B ];

tpose[A_?t333Q, order_, OptionsPattern[]] := Module[{i,j,k,o={0,0,0},B},
If[Dimensions[order] != {3} || !DuplicateFreeQ[order], Print["order=", order," has wrong dimension or contains duplicates" ]; Abort[]];
B=Array[0&,{3,3,3}];o=order/.{1->i,2->j,3->k};
If[ OptionValue[fromOrder],
Do[B[[i,j,k]]=A[[o[[1]],o[[2]],o[[3]]]],{i,1,3},{j,1,3},{k,1,3}],
Do[B[[o[[1]],o[[2]],o[[3]]]]=A[[i,j,k]],{i,1,3},{j,1,3},{k,1,3}] ];  B] ;

tpose[A_?t333333Q, order_, OptionsPattern[]] := Module[{i,j,k,l,m,n,o={0,0,0,0},B},
If[Dimensions[order] != {6} || !DuplicateFreeQ[order],Print["order=", order, " has wrong dimension or contains duplicates" ]; Abort[] ];
B=Array[0&,{3,3,3,3,3,3}];
o=order/.{1->i,2->j,3->k,4->l,5->m,6->n};
If[ OptionValue[fromOrder],
Do[B[[i,j,k,l]]=A[[o[[1]], o[[2]], o[[3]], o[[4]], o[[5]], o[[6]]]], {i,1,3},{j,1,3},{k,1,3},{l,1,3},{m,1,3},{n,1,3}],
Do[B[[o[[1]], o[[2]], o[[3]], o[[4]], o[[5]], o[[6]]]]=A[[i,j,k,l]], {i,1,3},{j,1,3},{k,1,3},{l,1,3},{m,1,3},{n,1,3}] ] ;  B] ;
tpose12[a_?t333Q]:=Module[{b=Array[0 &,{3,3,3}],i,j,k}, Do[b[[i,j,k]]=a[[j,i,k]],{i,1,3},{j,1,3},{k,1,3}];b];     (* transpositions of 3rd  rank tensors *)
tpose13[a_?t333Q]:=Module[{b=Array[0 &,{3,3,3}],i,j,k}, Do[b[[i,j,k]]=a[[k,j,i]],{i,1,3},{j,1,3},{k,1,3}];b];
tpose23[a_?t333Q]:=Module[{b=Array[0 &,{3,3,3}],i,j,k}, Do[b[[i,j,k]]=a[[i,k,j]],{i,1,3},{j,1,3},{k,1,3}];b];
tpose12[a_?t3333Q]:=Module[{b=Array[0 &,{3,3,3,3}],i,j,k,l},Do[b[[i,j,k,l]]=a[[j,i,k,l]],{i,1,3},{j,1,3},{k,1,3},{l,1,3}];b];   (* transpositions of 4th rank tensors *)
tpose13[a_?t3333Q]:=Module[{b=Array[0 &,{3,3,3,3}],i,j,k,l},Do[b[[i,j,k,l]]=a[[k,j,i,l]],{i,1,3},{j,1,3},{k,1,3},{l,1,3}];b];
tpose14[a_?t3333Q]:=Module[{b=Array[0 &,{3,3,3,3}],i,j,k,l},Do[b[[i,j,k,l]]=a[[l,j,k,i]],{i,1,3},{j,1,3},{k,1,3},{l,1,3}];b];
tpose23[a_?t3333Q]:=Module[{b=Array[0 &,{3,3,3,3}],i,j,k,l},Do[b[[i,j,k,l]]=a[[i,k,j,l]],{i,1,3},{j,1,3},{k,1,3},{l,1,3}];b];
tpose24[a_?t3333Q]:=Module[{b=Array[0 &,{3,3,3,3}],i,j,k,l},Do[b[[i,j,k,l]]=a[[i,l,k,j]],{i,1,3},{j,1,3},{k,1,3},{l,1,3}];b];
tpose34[a_?t3333Q]:=Module[{b=Array[0 &,{3,3,3,3}],i,j,k,l},Do[b[[i,j,k,l]]=a[[i,j,l,k]],{i,1,3},{j,1,3},{k,1,3},{l,1,3}];b];
tpose13i24[a_?t3333Q]:=Module[{b=Array[0 &,{3,3,3,3}],i,j,k,l},Do[b[[i,j,k,l]]=a[[k,l,i,j]],{i,1,3},{j,1,3},{k,1,3},{l,1,3}];b];
tpose12[a_?t333333Q]:=Module[{b=Array[0 &,{3,3,3,3,3,3}],i,j,k,l,m,n},Do[b[[i,j,k,l,m,n]]=a[[j,i,k,l,m,n]],{i,1,3},{j,1,3},{k,1,3},{l,1,3},{m,1,3},{n,1,3} ];b];  (* transpositions of 6th rank tensors *)
tpose13[a_?t333333Q]:=Module[{b=Array[0 &,{3,3,3,3,3,3}],i,j,k,l,m,n},Do[b[[i,j,k,l,m,n]]=a[[k,j,i,l,m,n]],{i,1,3},{j,1,3},{k,1,3},{l,1,3,{m,1,3},{n,1,3}}];b];
tpose14[a_?t333333Q]:=Module[{b=Array[0 &,{3,3,3,3,3,3}],i,j,k,l,m,n},Do[b[[i,j,k,l,m,n]]=a[[l,j,k,i,m,n]],{i,1,3},{j,1,3},{k,1,3},{l,1,3},{m,1,3},{n,1,3}];b];
tpose15[a_?t333333Q]:=Module[{b=Array[0 &,{3,3,3,3,3,3}],i,j,k,l,m,n},Do[b[[i,j,k,l,m,n]]=a[[m,j,k,l,i,n]],{i,1,3},{j,1,3},{k,1,3},{l,1,3},{m,1,3},{n,1,3}];b];
tpose16[a_?t333333Q]:=Module[{b=Array[0 &,{3,3,3,3,3,3}],i,j,k,l,m,n},Do[b[[i,j,k,l,m,n]]=a[[n,j,k,l,m,i]],{i,1,3},{j,1,3},{k,1,3},{l,1,3},{m,1,3},{n,1,3}];b];
tpose23[a_?t333333Q]:=Module[{b=Array[0 &,{3,3,3,3,3,3}],i,j,k,l,m,n},Do[b[[i,j,k,l,m,n]]=a[[i,k,j,l,m,n]],{i,1,3},{j,1,3},{k,1,3},{l,1,3},{m,1,3},{n,1,3}];b];
tpose24[a_?t333333Q]:=Module[{b=Array[0 &,{3,3,3,3,3,3}],i,j,k,l,m,n},Do[b[[i,j,k,l,m,n]]=a[[i,l,k,j,m,n]],{i,1,3},{j,1,3},{k,1,3},{l,1,3},{m,1,3},{n,1,3}];b];
tpose25[a_?t333333Q]:=Module[{b=Array[0 &,{3,3,3,3,3,3}],i,j,k,l,m,n},Do[b[[i,j,k,l,m,n]]=a[[i,m,k,l,j,n]],{i,1,3},{j,1,3},{k,1,3},{l,1,3},{m,1,3},{n,1,3}];b];
tpose26[a_?t333333Q]:=Module[{b=Array[0 &,{3,3,3,3,3,3}],i,j,k,l,m,n},Do[b[[i,j,k,l,m,n]]=a[[i,n,k,l,m,j]],{i,1,3},{j,1,3},{k,1,3},{l,1,3},{m,1,3},{n,1,3}];b];
tpose34[a_?t333333Q]:=Module[{b=Array[0 &,{3,3,3,3,3,3}],i,j,k,l,m,n},Do[b[[i,j,k,l,m,n]]=a[[i,j,l,k,m,n]],{i,1,3},{j,1,3},{k,1,3},{l,1,3},{m,1,3},{n,1,3}];b];
tpose35[a_?t333333Q]:=Module[{b=Array[0 &,{3,3,3,3,3,3}],i,j,k,l,m,n},Do[b[[i,j,k,l,m,n]]=a[[i,j,m,l,k,n]],{i,1,3},{j,1,3},{k,1,3},{l,1,3},{m,1,3},{n,1,3}];b];
tpose36[a_?t333333Q]:=Module[{b=Array[0 &,{3,3,3,3,3,3}],i,j,k,l,m,n},Do[b[[i,j,k,l,m,n]]=a[[i,j,n,l,m,k]],{i,1,3},{j,1,3},{k,1,3},{l,1,3},{m,1,3},{n,1,3}];b];
tpose45[a_?t333333Q]:=Module[{b=Array[0 &,{3,3,3,3,3,3}],i,j,k,l,m,n},Do[b[[i,j,k,l,m,n]]=a[[i,j,k,m,l,n]],{i,1,3},{j,1,3},{k,1,3},{l,1,3},{m,1,3},{n,1,3}];b];
tpose46[a_?t333333Q]:=Module[{b=Array[0 &,{3,3,3,3,3,3}],i,j,k,l,m,n},Do[b[[i,j,k,l,m,n]]=a[[i,j,k,n,m,l]],{i,1,3},{j,1,3},{k,1,3},{l,1,3},{m,1,3},{n,1,3}];b];
tpose56[a_?t333333Q]:=Module[{b=Array[0 &,{3,3,3,3,3,3}],i,j,k,l,m,n},Do[b[[i,j,k,l,m,n]]=a[[i,j,k,l,n,m]],{i,1,3},{j,1,3},{k,1,3},{l,1,3},{m,1,3},{n,1,3}];b];


symm12[a_?t3333Q]    :=    (a  +   tpose12[a]  )/2 ;
symm34[a_?t3333Q]    :=    (a  +   tpose34[a]  )/2 ;
symm23[a_?t3333Q]    :=    (a  +   tpose23[a]  )/2 ;
symm14[a_?t3333Q]    :=    (a  +   tpose14[a]  )/2 ;
symm24[a_?t3333Q]    :=    (a  +   tpose24[a]  )/2 ;
symm13[a_?t3333Q]    :=    (a  +   tpose13[a]  )/2 ;
symm12[a_?t333Q]     :=    (a  +   tpose12[a]  )/2 ;
symm13[a_?t333Q]     :=    (a  +   tpose13[a]  )/2 ;
symm23[a_?t333Q]     :=    (a  +   tpose23[a]  )/2 ;
symm13i24[a_?t3333Q] :=    (a  +tpose13i24[a]  )/2 ;
symm12[a_?t33Q]      :=    (a  + Transpose[a]  )/2 ;
symm[a_?t33Q]        :=    (a  + Transpose[a]  )/2 ;
symmEl[a_?t3333Q]    :=   Module[ {b}, b= (2* a + tpose12[a] +  tpose34[a] )/4 ; (b + symm13i24[b])/2  ] ;


colon[a_?t33Q,b_?t33Q]:= Module[{c,k,l}, c =Sum[a[[k,l]]*b[[k,l]],{k,1,3},{l,1,3}]; c];
colon[a_?t3333Q,b_?t33Q]:= Module[{c = Array[0 &, {3,3}],i,j,k,l},  Do[ c[[i,j]] =
                                   Sum[a[[i,j,k,l]]*b[[k,l]],{k,1,3},{l,1,3}],{i,1,3},{j,1,3}]; c];
colon[a_?t33Q,b_?t3333Q]:= Module[{c = Array[0 &, {3,3}],i,j,k,l},  Do[ c[[k,l]] =
                                    Sum[a[[i,j]]*b[[i,j,k,l]],{i,1,3},{j,1,3}],{k,1,3},{l,1,3}]; c];
colon[a_?t3333Q,b_?t3333Q]:= Module[{c = Array[0 &, {3,3,3,3}],i,j,k,l,m,n}, Do[c[[i,j,m,n]]=
                                     Sum[a[[i,j,k,l]]*b[[k,l,m,n]],{k,1,3},{l,1,3}],{i,1,3},{j,1,3},{m,1,3},{n,1,3}]; c];

out[a_, b_] := Outer[Times, a, b];
zout[a_, b_] := tpose23[  a ~out~ b ];
zoutSym[a_, b_] :=  tpose[(a ~out~ b),{1,3,4,2} ]   ;


z3  = Array[0&, {3  }]; 
one3[ a_  ] :=  Module[{i }, Table[  If[ i==a , 1,0,0] , {i,1,3}] ] ;
z33  = Array[0&, {3,3  }]; 
one33[ a_,b_ ] :=  Module[{i,j}, Table[  If[ i==a &&  j== b, 1,0,0] , {i,1,3}, {j,1,3}] ];
z333  = Array[0&, {3,3,3 }]; 
one333[ a_,b_,c_ ] :=  Module[{i,j,k}, Table[  If[ i==a &&  j== b && k== c , 1,0,0] , {i,1,3}, {j,1,3}, {k,1,3}] ];
z3333 = Array[0&, {3,3,3,3}]; 
one3333[ a_,b_,c_,d_ ] :=  Module[{i,j,k,l}, Table[  If[ i==a &&  j== b && k== c && l==d , 1,0,0] , {i,1,3}, {j,1,3}, {k,1,3}, {l,1,3}] ]; 


identity4 = tpose23[ Outer[Times,delta,delta]]  ;
identity4sym = ( tpose23[ Outer[Times,delta,delta]]  +  tpose24[ Outer[Times,delta,delta]]  )/2  ;
antimetry4 = (  tpose23[ Outer[Times,delta,delta]]  -  tpose24[ Outer[Times,delta,delta]]  )/2  ;
symmetry4 = (  tpose23[ Outer[Times,delta,delta]]  +  tpose24[ Outer[Times,delta,delta]]  )/2  ;
transposer4 = tpose24[ Outer[Times,delta,delta]];   (* transposer4_ijkl =   delta_il delta_jk *)

deviatorer = identity4 -  Outer[Times,delta,delta] /3;
deviatorer4 = identity4 -  Outer[Times,delta,delta] /3;
deviatorer4sym = identity4sym -  Outer[Times,delta,delta] /3;
deviatorer33 =  {{2, -1, -1}, {-1, 2, -1}, {-1, -1, 2}}/3 ;

matrixDiagonal[T_?t33Q] := { T[[1,1]],    T[[2,2]], T[[3,3]]     };
matrixDiagonal[m_?t3333Q] := Module[ {a},    a=transfer99[m];   {{a[[1,1]],a[[1,2]],a[[1,3]]}, {a[[2,1]],a[[2,2]],a[[2,3]]},  {a[[3,1]], a[[3,2]],a[[3,3]]}}   ];
matrixForm[mm_?t3333Q]:= Module[ {i,j, i9={1,2,3,1,2,1,3,2,3}, j9={1,2,3,2,1,3,1,3,2}, aa=Array[0&, {9,9}]  },
                           Do[ aa[[i,j]] = mm[[ i9[[i]], j9[[i]] ,   i9[[j]],  j9[[j]] ]] , {i,1,9},{j,1,9} ]; aa // MatrixForm  ]  ;

 transfer99[mm_?t3333Q]:= Module[ {i,j, i9={1,2,3,1,2,1,3,2,3}, j9={1,2,3,2,1,3,1,3,2}, aa=Array[0&, {9,9}]  },
                             Do[ aa[[i,j]] = mm[[ i9[[i]], j9[[i]] ,   i9[[j]],  j9[[j]] ]] , {i,1,9},{j,1,9} ]; aa  ]  ;

 transfer99[mm_?t33Q]:= Module[ {i, i9={1,2,3,1,2,1,3,2,3} , j9={1,2,3,2,1,3,1,3,2},  aa=Array[0&,9 ]  },
 Do[ aa[[i]] = mm[[   i9[[i]],  j9[[i]]    ]] , {i,1,9}  ]; aa  ]  ;

 transfer99i[mm_?t99Q]:= Module[ {i,j, i9={1,2,3,1,2,1,3,2,3}, j9={1,2,3,2,1,3,1,3,2}, aa=Array[0&, {3,3,3,3}]  },
                          Do[ aa[[ i9[[i]], j9[[i]], i9[[j]],  j9[[j]] ]] = mm[[i,j]]  , {i,1,9},{j,1,9} ]; aa  ]  ;

 transfer99i[mm_?t9Q]:= Module[ {i, i9={1,2,3,1,2,1,3,2,3} , j9={1,2,3,2,1,3,1,3,2},  aa=Array[0&, {3,3} ]  },
                          Do[aa[[   i9[[i]],  j9[[i]]    ]] = mm[[i]], {i,1,9}  ]; aa  ]  ;
matrixForm[mm_?t33Q]:= Module[{}, mm // MatrixForm ]  ;





tensorial[f_ , a_] := Module[{L =Array[0 &,3],vv=Array[0 &,{3,3}],vvn=Array[0 &,{3,3}], ndim , ff, nReal },
                                  Print["tensorial[f, aa] is obsolete, use MatrixFunction[f,aa] with identical arguments "];  
                                  ndim = Dimensions[a][[1]];
                                 {L,vv}=Eigensystem[N[a]];vvn=Orthogonalize[vv];
                                  ff = f[ L ] //Quiet ;
                                  nReal =  Length[ Select[  ff,  (# \[Element] Reals)&  ]]  ;
                                  If[  nReal  < ndim , Print["Error: ", f, " on Eigenvalues of ", a , " is not Real" ]; Return[0] ];
                                  Transpose[vvn] . DiagonalMatrix[ f[L]  ] . vvn //Simplify 
                                  ];
                                  
tensorial[ Sqrt, mm_?t33Q  ] :=  MatrixPower[mm, 1/2]   ;
tensorial[ Exp, mm_?t33Q  ] :=  MatrixExp[mm ]   ;
tensorial[ Log, mm_?t33Q  ] :=  MatrixLog[mm ]   ;

tensorial[ f_, { { a_, 0, 0}, { 0, b_, 0}, {0, 0, c_}}   ] :=  Module[{R},
    R =  {{f[a],0,0},{0,f[b],0},{0,0,f[c]} } ;
  R  ] ;

tensorial[ f_, { { a_, b_, 0}, { b_, c_, 0}, {0, 0, d_}}   ] :=  Module[{L1,L2,R,rules},
Print[ "a special case of tensorial for a symm. 2-2-1 matrix " ] ; 
 Print["tensorial[f, aa] is obsolete, use MatrixFunction[f,aa] with identical arguments "];  
R =  Array[0 &, {3, 3}];
R[[1 ;; 2, 1 ;; 2]] = {{((c - L1)^2*f[L1])/(b^2 + (c - L1)^2) + ((c - L2)^2*f[L2])/(b^2 + (c - L2)^2),
  (b*(-c + L1)*f[L1])/(b^2 + (c - L1)^2) + (b*(-c + L2)*f[L2])/(b^2 + (c - L2)^2)},
 {(b*(-c + L1)*f[L1])/(b^2 + (c - L1)^2) + (b*(-c + L2)*f[L2])/(b^2 + (c - L2)^2),
  b^2*(f[L1]/(b^2 + (c - L1)^2) + f[L2]/(b^2 + (c - L2)^2))}};
 R[[3,3]] = f[d] ;
rules = { L1 ->  1/2 (a + c - Sqrt[a^2 + 4 b^2 - 2 a c + c^2]), L2 ->  1/2 (a + c + Sqrt[a^2 + 4 b^2 - 2 a c + c^2])   };
 R //. rules
];

tensorial[f_, {{a_, 0, b_}, {0, d_, 0}, {b_, 0, c_}}   ] :=  Module[ {L1,L2,R,rules,a11,a12,a21,a22},
Print[ "a special case of tensorial for a symm. 2-1-2 matrix " ] ; 
 Print["tensorial[f, aa] is obsolete, use MatrixFunction[f,aa] with identical arguments "];  
R =  Array[0 &, {3, 3}];
 {{ R[[1,1]] ,   R[[1,3]] } ,{R[[3,1]],R[[3,3]]}} =
 {{((c - L1)^2*f[L1])/(b^2 + (c - L1)^2) + ((c - L2)^2*f[L2])/(b^2 + (c - L2)^2),
  (b*(-c + L1)*f[L1])/(b^2 + (c - L1)^2) + (b*(-c + L2)*f[L2])/(b^2 + (c - L2)^2)},
 {(b*(-c + L1)*f[L1])/(b^2 + (c - L1)^2) + (b*(-c + L2)*f[L2])/(b^2 + (c - L2)^2),
  b^2*(f[L1]/(b^2 + (c - L1)^2) + f[L2]/(b^2 + (c - L2)^2))}};
  R[[2,2]] = f[d] ;
rules = { L1 ->  1/2 (a + c - Sqrt[a^2 + 4 b^2 - 2 a c + c^2]), L2 ->  1/2 (a + c + Sqrt[a^2 + 4 b^2 - 2 a c + c^2])   };
 R //. rules
]  ;

tensorial[f_, {{d_, 0, 0}, {0, a_, b_}, {0, b_, c_}}   ] :=  Module[ {L1,L2,R,rules},
Print[ "a special case of tensorial for a symm. 1-2-2 matrix " ] ; 
 Print["tensorial[f, aa] is obsolete, use MatrixFunction[f,aa] with identical arguments "];  
R =  Array[0 &, {3, 3}];
R[[2 ;; 3, 2 ;; 3]] ={{((c - L1)^2*f[L1])/(b^2 + (c - L1)^2) + ((c - L2)^2*f[L2])/(b^2 + (c - L2)^2),
  (b*(-c + L1)*f[L1])/(b^2 + (c - L1)^2) + (b*(-c + L2)*f[L2])/(b^2 + (c - L2)^2)},
 {(b*(-c + L1)*f[L1])/(b^2 + (c - L1)^2) + (b*(-c + L2)*f[L2])/(b^2 + (c - L2)^2),
  b^2*(f[L1]/(b^2 + (c - L1)^2) + f[L2]/(b^2 + (c - L2)^2))}};
 R[[1,1]] = f[d] ;
rules = { L1 ->  1/2 (a + c - Sqrt[a^2 + 4 b^2 - 2 a c + c^2]), L2 ->  1/2 (a + c + Sqrt[a^2 + 4 b^2 - 2 a c + c^2])   };
 R //. rules
]  ;


tensorial3[func_, mat_, a_] := 
    Module[{L, Lvs, vvv, vvn, vvvs, ff, Ls },  
       {L,vvv}=Eigensystem[N[a]];    vvn=Orthogonalize[vvv];     (* Mma sorts eigenvalues from largest to smallest abs val*)
         Lvs =   Sort[  MapThread[ Prepend[ #2, #1]&,   {L, vvn}]   ]  ; (* sorted lines of 4 components from smallest to largest eigv *)
         Ls = Lvs[[All,1]] ; 
          vvvs = Lvs[[All,2;;]];             
           ff =  func[ Ls, mat ]//Evaluate ;
           Transpose[vvvs] . DiagonalMatrix[ ff  ] . vvvs //Simplify 
      ];





tensorialfD[ f_ ,a_ ]  := Module[ {L =Array[0 &,3] ,vv,P,PP, x, i,j ,fp, ndim, mul , ff=Array[0 &,3], nReal   },
If[ Dimensions[a] != {3,3}, Print["error: input tensor a (2nd argument) must be of dimensions 3 x 3 "]; Return[0] ];
If[ numericQ[a], ndim = 3,  Print["error: input tensor a (2nd argument) numerical and real "]; Return[0] ];
fp = D[ Evaluate[ f[x]],x];
{L, vv}  = Eigensystem[ N[ a ] ] //Chop;
ff = f[ L ] //Quiet ;
nReal =  Length[ Select[  ff,  (# \[Element] Reals)&  ]   ]  ;
If[   nReal < ndim , Print["Error: ", f, " on eigenvalues of ",a," is not Real" ]; Return[0] ];
(* vv = Orthogonalize[vv];  *)
 P = Table[  vv[[i]]  ~out~  vv[[i]]    , {i,1,ndim} ];
PP = Table[    zoutSym [  P[[  i ]], P[[  j  ]]  ]   ,{i,1,ndim},{j,1,ndim}  ];
mul = Table[ If[ L[[i]] ~approx~ L[[j]]  ,  (fp/.  x-> L[[i]] ) ,   (ff[[i]]- ff[[j]] )/(L[[i]]-L[[j]])] ,{i,1,ndim},{j,1,ndim}] ;
 Sum[ mul[[i,j]]* PP[[i,j]] ,{i,1,3},{j,1,3}]
 ];

decomposeVRU[f_] := Module[{v=Array[0 &, 3],r=Array[0 &, {3,3}],u=Array[0 &, {3,3}]},
                                 v = f . Transpose[f];  v= MatrixPower[v, 1/2]  ; (*v = tensorial[Sqrt,v];  *)
                                 u = Transpose[f] . f;  u= MatrixPower[u, 1/2]  ; (* u = tensorial[Sqrt,u]; *)  
                                 r= f . Inverse[u]; 
                                 {v,r,u}];

 inverse99[a_] := Module[{w=Array[0&, {9,9}] ,  at=Array[0&, {9,9}] , w3333 =  Array[0&, {3,3,3,3}],
        row = Array[0 &,9], col= Array[0 &,9], wi,i,j,samecols=False, samerows=False, samecross  = Array[False &,9],
        error=False, i9={1,2,3,1,2,1,3,2,3}, j9={1,2,3,2,1,3,1,3,2}, original3333=False,wt,mm,u,v },
        error = !Dimensions[a] == {9,9} && !Dimensions[a] == {3,3,3,3}  ;
        If[error, GoTo[10]];
        original3333 =  Dimensions[a] == {3,3,3,3};      (* convert 3333 to 99 if necessary *)
       If[original3333, Do[ w[[i,j]] = a[[ i9[[i]], j9[[i]] ,   i9[[j]],  j9[[j]] ]] , {i,1,9},{j,1,9} ], w=a  ] ;
        wt = Transpose[w] ; (* check identities of rows and columns *)
        Do[{ row = Abs[w[[ii]] - w[[ii+1]]]; col =  Abs[wt[[ii]] - wt[[ii+1]]] ;
             samerows = Sum[row[[i]],{i,1,9}]<10^(-6); samecols = Sum[col[[i]],{i,1,9}]< 10^(-6)  ;
             samecross[[ii]]  = samerows && samecols ;
             error = error || (!samerows && samecols)   || (samerows && !samecols) ;
                 } , {ii,4,8,2}     ];
        w = If[samecross[[8]], Delete[w,8],w ]; w = If[samecross[[6]], Delete[w,6],w ];  (* remove columns  and rows *)
        w = If[samecross[[4]], Delete[w,4],w ]; w=Transpose[w] ;
        w = If[samecross[[8]], Delete[w,8],w ]; w = If[samecross[[6]], Delete[w,6],w ];
        w = If[samecross[[4]], Delete[w,4],w ]; w=Transpose[w] ;
        mm = Dimensions[w][[1]]; wi= Array[0 &,{mm,mm}];   u = wi; v = wi;
        {u,w,v} = SingularValueDecomposition[N[w]];
         Do[If[Abs[w[[ii,ii]]]<10^(-6),error = error || True, wi[[ii,ii]]= 1/w[[ii,ii]] ],{ ii,1,mm}];
        If[error, GoTo[10]];
         w = v . wi . Transpose[u]  ; (* inverse reduced *)
          If[samecross[[4]], w=Insert[w,w[[4]]/2,4] ; w=ReplacePart[w,w[[4]],5 ]; ]; (* add rows and halve them *)
          If[samecross[[6]], w=Insert[w,w[[6]]/2,6] ; w=ReplacePart[w,w[[6]],7 ];];
          If[samecross[[8]], w=Insert[w,w[[8]]/2,8] ; w=ReplacePart[w,w[[8]],9 ];]; w= Transpose[w];
          If[samecross[[4]], w=Insert[w,w[[4]]/2,4] ; w= ReplacePart[w,w[[4]],5 ]; ];(* add columns and halve them *)
          If[samecross[[6]], w=Insert[w,w[[6]]/2,6] ; w= ReplacePart[w,w[[6]],7 ];];
          If[samecross[[8]], w=Insert[w,w[[8]]/2,8] ; w= ReplacePart[w,w[[8]],9 ];]; w =    Transpose[w];
        (* convert back 99 to 3333  if necessary *)
         Label[10]; If[error, Print["Unremovable singularity encountered"]; Abort[]; ];
         If[ !error, If[original3333, Do[ w3333[[ i9[[i]],j9[[i]],i9[[j]],j9[[j]] ]]= w[[i,j]], {i,1,9},{j,1,9} ]; w3333 , w ]]
         ];
 


   
  Options[solveLinear99] = { verbose  -> False } ;     
 solveLinear99[ K_?t3333Q ,u_?t33Q, rhs_?t33Q , ifu_ , OptionsPattern[] ] := Module[
 {oV, K99, u9, rhs9, ifu9,x9,samecross,samecrossi,samerows,samecols,nc,x, unknowns, solu, u9solu, rhs9solu , i,j} , 
 oV =  OptionValue[verbose];   
{K99, u9, rhs9, ifu9} = transfer99[#]& /@  {K ,u, rhs , ifu }; 
x9 = Array[x,9]; (* unknowns *)
If[ ifu9[[#]], rhs9[[#]]= x9[[#]], u9[[#]]= x9[[#]]  ]& /@ Range[9]; 
samecross = {}; 
Do[
  samerows = ( K99[[i,All]] ~approx~  K99[[i+1,All]] ) ;
  samecols = ( K99[[All,i]] ~approx~  K99[[All,i+1]] ); 
  If[ samerows &&  samecols  , AppendTo[samecross, i] ];  
  If[(samerows && Not[samecols] ) || (Not[ samerows] && samecols ) , Print["K99 has identical rows", i," and  ", i+1 ,"  but not identical colums or vice versa"];  Abort[] ];
, {i,4,8,2}]; 
  nc=Length[samecross]; 
  If[oV, Print["solveLinear99: number of crosses = (line and column pairs) eliminated to avoid sincularity nc =", nc]];
  If[ nc > 0, 
       samecrossi = Reverse[samecross]; (* od konca zeby nie popsuc numeracji *)
       Do[j=samecrossi[[i]]; 
            K99 = Drop[K99, {j},{j} ]; 
            {u9, rhs9, ifu9} =  Drop[#, {j}]& /@   {u9, rhs9, ifu9} 
       ,{i,1,nc}]; 
  ];
  unknowns = Select[  rhs9 ~Join~ u9 , Not[NumberQ[#]]& ]; 
  solu = Solve[ K99 . u9 == rhs9, unknowns ][[1]]; 
   {u9solu , rhs9solu }   =   {u9 , rhs9 } /. solu ; 
    Do[ j=samecross[[i]]; 
     u9solu =  Insert[u9solu, u9solu[[j]] , j+1] ;  
     rhs9solu= Insert[rhs9solu, rhs9solu[[j]] , j+1] 
   ,{i,1,nc} ];
   {transfer99i[u9solu], transfer99i[rhs9solu] }
     ]; 
     
          


symbolQ[t_]:=\[Not]NumberQ[t];

symbolQ[t_?ListQ]:=MemberQ[(\[Not]NumberQ[#]&/@ Flatten[ t ] ), True] ; 

anySymbolQ[t_?ListQ]:=MemberQ[(\[Not]NumberQ[#]&/@ Flatten[ t ] ), True] ; 

allSymbolQ[t_?ListQ]:=\[Not]MemberQ[(NumberQ[#]&/@ Flatten[ t ] ), True] ; 

numberQ[ x_] := Module[{n, q, xflat},   (* identical as allNumberQ *)
                xflat = x; 
                If[Length[xflat] > 0 , xflat =  Flatten[xflat]; ];
                n= Length[xflat];
               If[ n==0, q = NumberQ[xflat] ];
               If[ n>0,  q = (n ==Length[ Select[xflat,NumberQ]] )];
               q   ] ; 
               
anyNumberQ[ t_?ListQ] := MemberQ[(NumberQ[#]&/@ Flatten[ t ] ), True] ; 
               
allNumberQ[ t_?ListQ] :=  \[Not]MemberQ[(\[Not]NumberQ[#]&/@ Flatten[ t ] ), True] ;                
                                       
                                                                                                                             

realQ[ x_] := Module[{n, q, xflat},
               If[ Not[ numberQ[x] ], q= False ; Goto[exitealQ] ]   ;
                xflat = x; If[Length[xflat] > 0 , xflat =  Flatten[xflat]; ];
                n= Length[xflat];
               If[ n==0, q = Element[xflat, Reals ]];
               If[ n>0,  q =  And @@( Element[#,Reals]&  /@  xflat )    ];
               Label[exitealQ];
               q   ] ;
               


               
theReal[ a_?AtomQ ] :=   Module[{}, $Assumptions =  $Assumptions  &&  a  \[Element] Reals ;   Print[  $Assumptions];   ];

theReal[ a_?ListQ ] :=   Module[{}, $Assumptions =  $Assumptions  && ( And @@ (# \[Element] Reals & /@ a ) );  Print[  $Assumptions];   ];

theReal[] := Module[{} ,$Assumptions= And @@ (# \[Element] Reals & /@ (Select[ToExpression[Names["Tensor`bnova`*"]], AtomQ[#]&]));   Print[  $Assumptions  ] ;   ];

thePositiveReal[ a_?ListQ ] :=   Module[{}, $Assumptions =  $Assumptions  && ( And @@ (# \[Element] Reals & /@ a ) )   &&   ( And @@ (# > 0 & /@ a ) )   ;  Print[  $Assumptions];   ];

thePositiveReal[ a_?AtomQ ] :=   Module[{}, $Assumptions =  $Assumptions  &&  a  \[Element] Reals  && a > 0;   Print[  $Assumptions];   ];

thePositiveReal[] := Module[{} ,$Assumptions = And @@ ((# \[Element] Reals && # > 0)& /@ (Select[ToExpression[Names["Tensor`bnova`*"]], AtomQ[#]&]));
                    Print[  $Assumptions  ] ;
                      ];


(* graphics *)

getMohrParamsT[ Tb_ ] := Module[{  m, R },
   m = (Tb[[1,1]] + Tb[[2,2]] )/2;  R=Sqrt[(Tb[[1,1]]- Tb[[2,2]] )^2 /4+ Tb[[1,2]]^2];
   {m, R}    ];

 
Options[plotCircleT] = {withCoulomb -> {0,0}, plotRange -> {0,0}, verbose -> False };  
plotCircleT[Tb_, a_ , OptionsPattern[] ] :=  Module[{nb, hb, stressPoint, polPoint, m, R,phi,coh,range,sigP,tauP,s, oV,aLabel },
   (*   Tb={{T11,T12},{T12,T22}},  -->  x1 and 90\[Degree] CCW x2;  mechanical signs*)
   {phi, coh} = OptionValue[withCoulomb]; 
   range = OptionValue[plotRange]; 
   oV = OptionValue[verbose]; 
   {m, R } = getMohrParamsT[ Tb ]  ;
   g1 = Graphics[{ Circle[ {m,0}, R]}, Axes -> True,
                  AxesLabel -> {"\[Sigma] M", "\[Tau] M"},  AxesOrigin -> {0, 0}];
   hb = {Cos[a], Sin[a]};
   nb = {- Sin[a], Cos[a] };
   g01 =  Graphics[{Arrow[  {{0, 0},  8 * hb }],
                Text [Style["h",Bold,Larger], 9*hb], Arrow[  {{0, 0},  4 * nb }],
                 Text [Style["n",Bold,Larger], 5*nb]},Axes->True, AxesLabel->{"x1","x2"}
                 ];
   stressPoint = {nb . Tb . nb, hb . Tb . nb} ;
   nb = {0,1}; hb = {1,0};   tauP =  hb . Tb . nb; (* from section along x1 *)
   nb = {-1,0}; hb = {0,1};   sigP  =  nb . Tb . nb;(* from section along x2 *)
   polPoint =        {sigP , tauP };
   g2 = Graphics[{PointSize[Large], Point[ stressPoint], Red , Point[polPoint] ,
                  Text [Style[ "Pol", Larger], polPoint]  } ] ; 
    aLabel  = {"\[Sigma] tension > 0", "\[Tau] clockwise > 0 "};               
   If[ range == {0,0}, 
       If[oV, Print["using the automatically calculated prescribed = ", {-1.2 R, 1.2 R}]];         
        g3 = Plot[ {coh + Tan[phi]*(-s), -coh  - Tan[phi]*(-s) },  {s, m-R, m+R } ,
                      PlotRange -> 1.2*R*{-1,1} , AspectRatio->Automatic, AxesLabel ->   aLabel  ]     
        ];  

         If[ Dimensions[range]=={2,2}  ,    
              If[oV, Print["using the prescribed = ",range]];         
              g3 = Plot[{coh + Tan[phi]*(-s), -coh  - Tan[phi]*(-s) } , {s,  range[[1,1]], range[[1,2]]  } , 
                         PlotRange -> range , AspectRatio->Automatic,  AxesLabel ->   aLabel   ] ;
           ]; 
        If[ Dimensions[range]=={2} && range != {0,0} ,   
             If[oV, Print["using the prescribed range = ",range]];               
             g3 = Plot[ {coh + Tan[phi]*(-s), -coh  - Tan[phi]*(-s) } , {s,  m-R,  m+R  } , 
                          PlotRange -> range , AspectRatio->Automatic , AxesLabel ->   aLabel  ] ;
          ];     
               
   {g01,  Show[  {g3, g1, g2}  ] }
      ];
  


 getMohrParamsL[ Lb_ ] := Module[{Db,Wb,w,m,R },
Db =(Lb + Transpose[Lb] )/2;  Wb =(Lb - Transpose[Lb] )/2;
m = (Db[[1,1]] + Db[[2,2]] )/2;
R  =   Sqrt[  (Db[[1,1]] - Db[[2,2]] )^2 /4 + Db[[1,2]]^2   ];  w = Wb[[1,2]];
{m,R ,w}
  ];

plotCircleL[Lb_, a_ ] :=  Module[{pb,qb,strainPoint, polPoint, e, mg , mgP, eP},
{m,R ,w} = getMohrParamsL[ Lb ]  ;
 g00 = VectorPlot[   Lb    . {x,y},{x,-10,10},{y,-10,10} , VectorScaling->Automatic,
  Axes -> True, AxesLabel -> {"x1", "x2"}  ] ;
g1 = Graphics[{ Circle[ {m,w}, R] }   , Axes -> True,
      AxesLabel -> {"\[Epsilon]", "-\[Gamma]/2"} , AxesOrigin->{0,0},
      AspectRatio -> Automatic ];
pb = {Cos[a], Sin[a]};
qb = {- Sin[a],Cos[a] };
g01 = Graphics[{Arrow[  {{0,0},  8 * pb }], Text [Style[ "p",Bold,Larger], 9 * pb],
                Arrow[  {{0,0},  4 * qb }], Text [Style[ "q",Bold,Larger], 5 * qb]
}];
strainPoint = {pb . Lb . pb, -qb . Lb . pb} ;
pb = {1,0}; qb = {0,1};       (* for p--line along x1 *)
e = pb . Lb . pb; mg =  - qb . Lb . pb;   (* mg = minus dot gamma/2*)
mgP =mg;
pb = {0,1}; qb = {-1,0};   (* for p--line along x2 *)
e = pb . Lb . pb; mg =   -qb . Lb . pb;
eP  = e;
polPoint =        {eP ,mgP };
g2 = Graphics[ {PointSize[Large], Point[ strainPoint], Red ,
                 PointSize[Medium],  Point[polPoint],
                 Text [Style[ "Pol",Larger], polPoint]}, Axes -> True ] ;
{ Show[{g00,g01}],  Show[{g1,g2}, PlotRange -> All]}
];


findBiggest[source_] := 
   (If[Length[#1] > 0, First[First[#1]]] & )[Sort[Select[Split[Sort[source]], 
      Length[#1] > 1 & ], LeafCount[Drop[#1, 1]] > LeafCount[Drop[#2, 1]] & ]]; 

 
replaceSubexpr[{expr_, {}}, 0, leaf_Integer] := expr;  (* if there are no rules so do nothing *)
replaceSubexpr[{expr_, rules_}, 0, leaf_Integer] := {expr, rules }; 

replaceSubexpr[{expr_, rules1_}, n_Integer, leaf_Integer] :=    Module[{rules, biggest, rules2, nNew, exprOut, source = {}}, 
      Scan[If[LeafCount[#1] >= leaf, AppendTo[source, #1]] & , {expr, rules1}, {2, Infinity}]; 
       biggest = findBiggest[source]; 
rules = If[LeafCount[biggest] >= Max[leaf, 2], {biggest -> Unique["z"]}, {}];
exprOut = expr //.  rules ;
rules2 = Join[rules1 //. rules, Reverse /@ rules]; 
 If[biggest === Null,  nNew = 0,  nNew = n - 1];
replaceSubexpr[{exprOut, rules2  }, nNew, leaf]
]; 




(*Messages*)
  bnova::"Globals" = "Syntax warning: possibly  unintended usage of globals.  This function is using global variable(s):  `1`   `2` ." ;

End[]
EndPackage[ ];

$Context = "Tensor`bnova`"   ;

Protect[ antimetry4, approx,aRot,aRot12,aRot13,aRot23,atomSymbolQ,axissymQ,axisymm23Q,coaxialQ,colon,colon3,colon4,componentwise ,
contract,convertCart2Cyl, convertCart2Spher,convertCyl2Cart,convertSpher2Cart,cycle,
decomposeVRU,delta,dev,deviator,deviatorer,deviatorer4,deviatorer4sym,deviatoricContourPlot,deviatoricPlot,deviatoricRangePlot,doubleCrossProduct,
epE, externalHashProduct,getXAniso,givensRotate,
hatcolon,hated,hausholderMatrix,
i1,i2,i3,iC,iC33,iCGehring,iCNiemunis,iCVermeer,identity4,identity4sym,iE,iE33,iEHoulsby,iELiu,iEVermeer,inverse99,inversedSM,inverseSM,
isomorphicP,isomorphicQ, isoP,isoQ, isoPQ,isoTriaxPlot,
j2,j3,LodeTheta,matrixDiagonal,matrixForm,norm2,normalized, numberQ,numericQ,onev,
onevstar,orthoC,orthoE, out, one3,one33,one333,one3333,
pickListPlot, plotCircleL,plotCircleT, pqTriaxPlot,pradhanTriaxPlot,projOn,pRot,pRot12,pRot13,pRot23,qubic,
realQ,restprojOn,Ricci,RoscoeEpsilonQ,RoscoeEpsilonV,RoscoeP,RoscoeQ,rotateTensor,rotationTensor, rotationTensorInverse, ReplaceSubs,
scalar,squareMQ,st33,step,stressResponse3D,stressResponse3Dstar,stressResponsePQ,stressResponsePstarQstar, symbolQ,  symbolVariables, 
symm23,symmEl,symmMQ, symmetry4,
t2Q,T2xyp,t33333333Q,t33Q,t3Q,tensorial,tensorialfD,thePositiveReal,theReal,tpose,tpose12,tpose13,tpose13i24,tpose14,tpose23,tpose24,
tpose34,tQ,tr,transfer99,transfer99i, transposer4, 
vectorQ,voigtC,voigtCi,voigtE,voigtEi,voigtEps,voigtEpsi,voigtSig,voigtSigi,
 where,
xiC,xiCgeotShort,xiCr,xiE,xiEgeot,xiEgeotShort,xiEr,xyp2T,zout,zoutSym,z3,z33,z333,z3333  
 ];
             


SetOptions[$FrontEndSession,{"PageWidth"->1000,"ExportTypesetOptions"->{"PageWidth"->1000}}];

Print[ " You  are in the context bnova. It provides:
  SMALL OBJECTS :   st33 ast33 z3 z33 z333 Ricci  delta  onev  onevstar aRot pRot rotationTensor rotationTensorInverse
  BASIC OPERATIONS: ~colon~  ~colon3~  ~colon4~   ~out~  deviator=dev  tr  norm2 qubic scalar normalized  hated  rotateTensor contract 
                      projOn  restprojOn  externalHashProduct  doubleCrossProduct   hausholderMatrix  givensRotate 
  INVARIANTS :      i1  i2  i3  j2  j3 RoscoeP RoscoeEpsilonV RoscoeQ RoscoeEpsilonQ  LodeTheta isoP  isoQ
  TRANSPOSITIONS:   tpose, tpose12  tpose34  tpose23 tpose14  tpose24  tpose13  tpose13i24
  4-TH ORDER TENSORS:  ISOTROPIC:    iE33 iC33 iE iC identity4 identity4sym   deviatorer deviatorer4sym  antimetry4 z3333 symmetry4 transposer4
                       CROSS-ANISO:   xiE  xiC   xiEr  xiCr  xiEgeot xiCgeotShort xiEgeotShort  
                       ORTHOTROPIC:   orthoE orthoC  iEVermeer iCVermeer   
                                      iCNiemunis  iCGehring  getXAniso  iEHoulsby iELiu   
                       ELASTOPLASTIC: epE[ iE, n,m,K]                          
  TENS. MANIPULATIONS:  isoPQ tensorial tensorial3 tensorialfD decomposeVRU inverse99 inverseSM  inversedSM
                        where  componentwise makeList symbolVariables replaceSubexpr                            
  REPRESENTATION:      matrixForm  transfer99 transfer99i voigtEps voigtEpsi voigtSig voigtSigi voigtE voigtEi voigtC voigtCi 
  CYLINDRICAL, SPHERICAL : getStrain getStressDiv  
                          convertCart2Spher convertSpher2Cart convertCart2Cyl convertCyl2Cart                       
  ELEMENT TESTS   :  step  cycle parametricStep 
  PLOTS:             pradhanTriaxPlot pqTriaxPlot deviatoricPlot isoTriaxPlot stressResponsePQ  
                      stressResponsePstarQstar stressResponse3D  stressResponse3Dstar
                      pickListPlot,  deviatoricContourPlot  deviatoricRangePlot T2xyp xyp2T plotCircleL plotCircleT
  AUXILIARIES:        approx zout zoutSym ~zout~ ~zoutSym~ decomposeVRU ~hatcolon~   symm23 symmEl  matrixDiagonal
  QUERIES:            realQ numberQ symbolQ tQ t2Q t3Q t33Q ...  t33333333Q   numericQ  atomSymbolQ coaxialQ axissymQ 
                      vectorQ squareMQ  symmMQ   
  ASSUMPTIONS     :   theReal thePositiveReal   
  25.10.2022
 "   ]

$PrePrint = If[MatrixQ[#], MatrixForm[#], #] &;      (* Applies automatic MatrixForm if results are displayed. Such output can be marked and copy-pasted to Input cells *)
