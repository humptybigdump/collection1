from  CSP_solver import *
from utils import all_diff

N_QUEENS = 10

# One queen for each row. Domain of a queen is are the different columns it could be positioned within her row. 

variables = []

for num in range(N_QUEENS):
    var = Variable(f"queen_{num}", [x for x in range(N_QUEENS)])
    variables.append(var)

constraints = all_diff(variables)

#add constraints for diagonals
for q1 in range(N_QUEENS):
    for q2 in range(q1+1, N_QUEENS):
        constraint = Constraint(f"{q2 - q1} != abs( queen_{q1} - queen_{q2})")
        constraints.append(constraint)

csp = CSP(variables, constraints, init_node = False, init_arc= False, heuristic= None, keep_node= True, keep_arc= False)
csp.solve()