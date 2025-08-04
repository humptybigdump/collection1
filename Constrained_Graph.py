from  CSP_solver import *

#The set of variables of the CSP with domains
variables = [
    Variable("A", domain= [1,2,3,4]),
    Variable("B", domain= [1,2,3,4]),
    Variable("C", domain= [1,2,3,4]),
    Variable("D", domain= [1,2,3,4]),
    Variable("E", domain= [1,2,3,4]),
    Variable("F", domain= [1,2,3,4])
]

#Here are the constraints:
constraints = [
    Constraint("B + 1 == C"),
    Constraint("B < A"),
    Constraint("A != C"),
    Constraint("C < E"),
    Constraint("E != D"),
    Constraint("E + 1 == F"),
    Constraint("B < D"),
    Constraint("D * 2 == F"),
]

#construct a csp with the variables and constraints
csp = CSP(variables, constraints, init_node = False, init_arc= False, keep_node= False, keep_arc= False)

#Solve the csp and use verbose = True in order to print the search tree
csp.solve(verbose=False)