#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
    Author: Lukas Kinder
    Created: 03.2022
    email: lukas.kinder@kit.edu

    Code originally developed in the University of Groninge (RUG).
"""

class Constraint(object): pass
class Variable(object): pass

def add_to_dict(di , key , val):
    if di.get(key) is None:
        di[key] = [val]
    else:
        di[key].append(val)

class Constraint:
    def __init__(self, equation):
        # The equation as string
        self.equation = equation 

        # The variables of the constraint (Will be assigned later)
        self.variables = [] 

        # The csp class (Will be assigned later)
        self.csp = None     

    def n_variables(self) -> int:
        return len(self.variables)

    def unassigned_variables(self) -> list[Variable]:
        return [v for v in self.variables if v.value is None]
    
    def n_unassigned_variables(self) -> int:
        return len(self.unassigned_variables())

    def evaluate(self) -> bool:
        self.csp.n_constraints_evaluated +=1
        values = dict()
        for variable in self.variables:
            values[variable.name] = variable.value
        return eval(self.equation, {}, values)

class Variable:

    def __init__(self, name, domain):
        # variable name as string
        self.name = name

        # variables domain as list
        self.domain = domain 

        # the variables values, as assigned by the solver
        self.value = None 

        # The constraints the variable is involved in (Will be assigned later)
        self.constraints = [] 

    # checks if after assigning value d there exist a legal value for the 
    # other variable w.r.t the  binary-constraint
    def exists_legal(self, d , other, binary_constraint) -> bool:

        is_legal = False
        self.value = d
        for d_other in other.domain:
            other.value = d_other
            if binary_constraint.evaluate():
                is_legal = True
                break
        
        #reverse value changes
        other.value = None
        self.value = None
        return is_legal

    #returns all constraints the variable is involved in with a given number of unassigned variables
    def constraints_with_degree(self, n_unassigned) -> list[Constraint]:
        return [c for c in self.constraints if c.n_unassigned_variables() == n_unassigned]
    
    #checks if the variable is involved in a fully assigned constraint that evaluated to False. 
    def is_conflicting(self) -> Constraint:
        fully_assigned_constraints =  self.constraints_with_degree(n_unassigned = 0)
        for constraint in fully_assigned_constraints:
            if not constraint.evaluate():
                return constraint
        return None

from utils import connect_variables_and_constraints


class CSP:

    def __init__(self, variables, constraints, init_node = False, init_arc = False,heuristic = None,keep_node = False, keep_arc = False, ):

        #the variable of the csp
        self.variables = variables
        #the constraints of the csp
        self.constraints = constraints 

        #The propagation techniques and the heuristics that should be used
        self.init_node = init_node
        self.init_arc = init_arc
        self.heuristic = heuristic
        if heuristic is not None and heuristic != "mrv" and heuristic != "deg":
            print(f"Unknown heuristic '{heuristic}'. Poosible arguments are: None, 'mrv', 'deg'.")
            exit(1)
        self.keep_node = keep_node
        self.keep_arc = keep_arc

        #some statistical variables
        self.n_assigned_variables = 0
        self.n_solutions_found = 0
        self.n_states = 0
        self.n_constraints_evaluated = 0

        for c in self.constraints:
            c.csp = self

        #connect variables and constraints
        connect_variables_and_constraints(self)

    def print_statistic(self):
        print("Number Solutions: {0}; Number States visited {1}; Number constraints evaluated {2}"
            .format(self.n_solutions_found,self.n_states,self.n_constraints_evaluated))

    def is_solved(self) -> bool:
        return len(self.variables) == self.n_assigned_variables

    def print_solution(self):
        for variable in self.variables:
            print(f"{variable.name} = {variable.value}; ",end = "")
        print("")

    # Checks node consistency for a list of unary constraints. 
    def node_consistency(self, unary_constraints) -> tuple[bool, dict]:
        domain_changes = dict()

        for constraint in unary_constraints:

            v = constraint.unassigned_variables()[0]
            
            #remove value from the domain that violate the constraint
            for d in list(v.domain):
                v.value = d
                if not constraint.evaluate():
                    v.domain.remove(d)
                    add_to_dict(domain_changes,v,d)
            #reverse to unassigned
            v.value = None

            #check for empty domain
            if len(v.domain) == 0:
                return True, domain_changes
                    
        return False, domain_changes

    # Checks arc-consistency for a list of binary constraints as well as for a list of variables. 
    def arc_consistency(self, binary_constraints, variables_to_check = None) -> tuple[bool, dict]:

        # a queue of variables and constraints to check for arc-consistency
        queue = []
        for constraint in binary_constraints:
            [v1,v2] = constraint.unassigned_variables()
            queue.append( (v1,v2, constraint) )
            queue.append( (v2,v1, constraint) )

        if variables_to_check is not None:
            for var in variables_to_check:
                for constraint in var.constraints_with_degree(n_unassigned = 2):
                    [v1,v2] = constraint.unassigned_variables()
                    if v1 == var:
                        other = v2
                    else:
                        other = v1
                    if (other,var, constraint) not in queue:
                        queue.append( (other,var, constraint) )


        domain_changes = dict()
        while len(queue) != 0:
            # check if v1 is arc consistent with respect to v2 considering the constraint
            v1, v2, constraint = queue.pop()

            domain_change_v1 = False
            for d in list(v1.domain):
                if not v1.exists_legal(d,v2, constraint):

                    v1.domain.remove(d)
                    domain_change_v1 = True
                    add_to_dict(domain_changes,v1,d)

                    if len(v1.domain) == 0:
                        # found a conflict
                        return True, domain_changes
            
            if domain_change_v1:
                # update queue
                for c in v1.constraints_with_degree(n_unassigned = 2):
                    u1,u2 = c.unassigned_variables()
                    if u1  == v1:
                        other = u2
                    else:
                        other = u1

                    if ( other, v1, c) not in queue:
                        queue.append( (other, v1, c) )

        return False , domain_changes

    def reverse_domain_reductions(self, domain_changes):
        for x in domain_changes.keys():
            x.domain = x.domain + domain_changes[x]
    
    def print_with_indent(self , text):
        print('\t' * (self.n_assigned_variables - 1) + text)

    def unassigned_var(self) -> list[Variable]:
        return [v for v in self.variables if v.value is None]
    
    def mrv_heuristic(self) -> Variable:
        # You have to implement this as an exercise
        exit("Not implemented")

    def degree_heuristic(self) -> Variable:
        # You have to implement this as an exercise
        exit("Not implemented")
    
    def choose_next_variable(self) -> Variable:
        return self.variables[self.n_assigned_variables]

    def solve_rec(self,verbose):

        self.n_states +=1

        if self.is_solved():
            if verbose:
                self.print_with_indent("Solution found: ")
            self.print_solution()
            self.n_solutions_found +=1
            return


        if self.heuristic == "deg": 
            variable = self.degree_heuristic()
        elif self.heuristic == "mrv":
            variable = self.mrv_heuristic()
        else:
            variable = self.choose_next_variable() 
        self.n_assigned_variables +=1

        if verbose:
            self.print_with_indent(f"Choosing variable {variable.name} with domain {variable.domain}")

        for d in variable.domain:
            variable.value = d

            if verbose:
                self.print_with_indent(f"Assigning {d} to {variable.name}:")

            if variable.is_conflicting():
                if verbose:
                    self.print_with_indent(f"conflict with constraint: "  + variable.is_conflicting().equation)
                continue
            
            conflict = False
            node_domain_reductions = {}
            arc_domain_reductions = {}

            if self.keep_node:
                new_unary_constraints = variable.constraints_with_degree(n_unassigned = 1)
                conflict , node_domain_reductions = self.node_consistency(new_unary_constraints)
                if verbose:
                    for x in node_domain_reductions.keys(): 
                        self.print_with_indent(f"node_consistency: remove {node_domain_reductions[x]} from the domain of {x.name}")
                    if conflict:
                        self.print_with_indent("empty domain found while making problem node-consistent!")

            if self.keep_arc and not conflict:
                new_binary_constraints = variable.constraints_with_degree(n_unassigned = 2)
                conflict , arc_domain_reductions =  self.arc_consistency(new_binary_constraints, list(node_domain_reductions.keys()))

                if verbose:
                    for x in arc_domain_reductions.keys(): 
                        self.print_with_indent(f"arc: remove {arc_domain_reductions[x]} from the domain of {x.name}")
                    if conflict:
                        self.print_with_indent("empty domain found during arc!")

            
            if not conflict:
                self.solve_rec(verbose)

            self.reverse_domain_reductions(node_domain_reductions)
            self.reverse_domain_reductions(arc_domain_reductions)
        
        variable.value = None
        self.n_assigned_variables -= 1

    def solve(self,verbose = False):

        if self.init_node:
            unary_constraints = [c for c in self.constraints if c.n_variables() == 1 ]
            conflict , node_domain_reductions = self.node_consistency(unary_constraints)

            if verbose:
                for x in node_domain_reductions.keys(): 
                    self.print_with_indent(f"init_node: remove {node_domain_reductions[x]} from the domain of {x.name}")
            if conflict:
                if verbose:
                    print("empty domain found while making problem initially node consistent!")
                return

        if self.init_arc:
            binary_constraints = [c for c in self.constraints if c.n_variables() == 2 ]
            conflict , arc_domain_reductions = self.arc_consistency(binary_constraints)

            if verbose:
                for x in arc_domain_reductions.keys(): 
                    self.print_with_indent(f"init_arc: remove {arc_domain_reductions[x]} from the domain of {x.name}")

            if conflict:
                if verbose:
                    print("empty domain found while making the problem initially arc consistent!")
                return

        self.solve_rec(verbose)
        self.print_statistic()



