from  CSP_solver import *
from utils import all_diff

"""
   P L A Y S 
 +   W E L L 
-------------
 B E T T E R
"""

#The set of variables of the CSP with domains
variables = [
    Variable("P", domain= [x for x in range(10)]),
    Variable("L", domain= [x for x in range(10)]),
    Variable("A", domain= [x for x in range(10)]),
    Variable("Y", domain= [x for x in range(10)]),
    Variable("S", domain= [x for x in range(10)]),
    Variable("W", domain= [x for x in range(10)]),
    Variable("E", domain= [x for x in range(10)]),
    Variable("B", domain= [x for x in range(10)]),
    Variable("T", domain= [x for x in range(10)]),
    Variable("R", domain= [x for x in range(10)]),
    Variable("c1", domain= [0,1]),
    Variable("c2", domain= [0,1]),
    Variable("c3", domain= [0,1]),
    Variable("c4", domain= [0,1]),
    Variable("c5", domain= [0,1]),
]

#Here are the constraints:
constraints = [
    Constraint("B != 0"),
    Constraint("P != 0"),
    Constraint("W != 0"),
    Constraint("S + L == R + c1 * 10"),
    Constraint("Y + L +c1 == E + c2 * 10"),
    Constraint("A + E +c2 == T + c3 *10"),
    Constraint("L + W +c3 == T + c4 *10"),
    Constraint("P +c4 == E + c5 *10"),
    Constraint("c5 == B"),
]

constraints += all_diff(variables[:10])

# Problem will be quite slow without mrv and node consistency
csp = CSP(variables, constraints, init_node = True, init_arc= False, heuristic= "mrv", keep_node= True, keep_arc= False)

#Solve the csp and use verbose = True in order to print the search tree
csp.solve(verbose=False)