#include <stdio.h>
#include <ctype.h>
#include <vector>
#include <cmath>
#include <cstdlib>
#include <algorithm> 
#include <time.h> 
#include <iostream>
#include <cstring>
#include <fstream>

using namespace std;

// Data structure for representing a clause
// Feel free to modify it
struct Clause {
    // Number of literals in the clause
    int numLits;
    // An array containing the literals
    int* lits;
};

/* struct Literal
{
    int numApp = 0;
    vector<int> pos_appearances;
    vector<int> neg_appearances;
}; */

// Number of variables
int numVariables;
// Number of clauses
int numClauses;
// An array containing all the clauses
Clause* clauses;
Clause* sortedClauses;


bool* setClauses;
bool* setSortedClaues;
bool* setVariables;
//Literal* literals;

// Print a clause (for Debugging purposes)
void printClause(const Clause& cls) {
    for (int li = 0; li < cls.numLits; li++) {
        printf("%d ", cls.lits[li]);
    }
    printf("0 \n");
}

// Used for parsing input CNF
int readNextNumber(FILE* f, int c) {
    while (!isdigit(c)) {
        c = fgetc(f);
    }
    int num = 0;
    while (isdigit(c)) {
        num = num*10 + (c-'0');
        c = fgetc(f);
    }
    return num;
}

// Used for parsing input CNF
void readLine(FILE* f) {
    int c = fgetc(f);
    while(c != '\n') {
        c = fgetc(f);
    }
}

// Used for parsing input CNF
bool loadSatProblem(const char* filename) {
    FILE* f = fopen(filename, "r");
    if (f == NULL) {
        return false;
    }
    int c = 0;
    bool neg = false;
    int clauseInd = 0;
    vector<int> tmpClause;
    while (c != EOF) {
        c = fgetc(f);

        // comment line
        if (c == 'c') {
            readLine(f);
            continue;
        }
        // problem lines
        if (c == 'p') {
            numVariables = readNextNumber(f, 0);
            numClauses = readNextNumber(f, c);
            clauses = new Clause[numClauses];
            continue;
        }
        // whitespace
        if (isspace(c)) {
            continue;
        }
        // negative
        if (c == '-') {
            neg = true;
            continue;
        }

        // number
        if (isdigit(c)) {
            int num = readNextNumber(f, c);
            if (neg) {
                num *= -1;
            }
            neg = false;
            if (num == 0) {
                clauses[clauseInd].numLits = tmpClause.size();
                clauses[clauseInd].lits = new int[tmpClause.size()];
                for (size_t i = 0; i < tmpClause.size(); i++)
                    clauses[clauseInd].lits[i] = tmpClause[i];
                tmpClause.clear();
                clauseInd++;
            } else {
                tmpClause.push_back(num);
            }
        }
    }
    fclose(f);
    return true;
}

int firstUnsat(bool* tempSetClauses) {
    for (size_t i = 0; i < numClauses; i++)
    {
        if (!tempSetClauses[i])
        {
            return i;
        }
        
    }
    return -1;
    
}



void setClausesTrue(Clause* temoClauses,bool* tempSetClauses) {
    for (size_t i = 0; i < numClauses; i++)
    {   tempSetClauses[i] = false;
        for (size_t j = 0; j < temoClauses[i].numLits; j++)
        {
            int lit = temoClauses[i].lits[j];
            if( lit < 0){
                lit = abs(lit);
                if (!setVariables[lit-1])
                {
                    tempSetClauses[i] = true;
                    
                } 
                
            } else
            {
                if (setVariables[lit-1])
                {
                    tempSetClauses[i] = true;
                    
                } 
            }
            if(tempSetClauses[i]) break;
            
        }
        
        
    }
    
}


int sortByNumLiterals(const Clause &lhs, const Clause &rhs) 
{ 
    return lhs.numLits < rhs.numLits;
}

void search(unsigned int seed) {

        srand(seed);




    // literals = new literals[numVariables];
    sortedClauses = new Clause[numClauses];
    memcpy(sortedClauses,clauses,numClauses*sizeof(Clause));
    std::sort(sortedClauses, sortedClauses + numClauses,sortByNumLiterals);

    setClauses = new bool[numClauses];
    setSortedClaues = new bool[numClauses];
    setVariables = new bool[numVariables];

    for (size_t i = 0; i < numClauses; i++)
    {
        setClauses[i] = false;
        setSortedClaues[i] = false;
    }
    for (size_t i = 0; i < numVariables; i++)
    {
        setVariables[i] = false;
    }
    
    
    setClausesTrue(clauses,setClauses);
    setClausesTrue(sortedClauses,setSortedClaues);
    int firstClause = firstUnsat(setClauses);
    int firstSortedClause = firstUnsat(setSortedClaues);
    while (firstClause != -1 && firstSortedClause != -1)
    {
      
       int randVal = rand();
       int varToChange;
       if(randVal%2) {
        varToChange = randVal%clauses[firstClause].numLits;
       
        
        setVariables[abs( clauses[firstClause].lits[varToChange])-1] = 
                !setVariables[abs( clauses[firstClause].lits[varToChange])-1];

        setClausesTrue(clauses,setClauses);
        firstClause = firstUnsat(setClauses);
       } else
       {
           varToChange = randVal%sortedClauses[firstSortedClause].numLits;
           setVariables[abs( sortedClauses[firstSortedClause].lits[varToChange])-1] = 
                !setVariables[abs( sortedClauses[firstSortedClause].lits[varToChange])-1];

        setClausesTrue(sortedClauses,setSortedClaues);
        firstSortedClause = firstUnsat(setSortedClaues);
       }
       
    }

    //std::cout << setVariables[9] << setVariables[3] << setVariables[1] << varToChange << "   " << clauses[firstClause].lits[varToChange] << "\n";
    

     
    
    
    
    
   


    


    
    // search for satisfiable solution until found or forever
    // print the solution if found
}


int main(int argc, char** argv) {
    printf("c This is Dohse's local search satisfiability solver\n");
    printf("c USAGE: ./Dohse <cnf-formula-in-dimacs-format>\n");
    if (!loadSatProblem(argv[1])) {
        printf("ERROR: problem not loaded\n");
        return 1;
    }
    unsigned int seed;
    if(argv[2] == 0) {
        seed =   (unsigned) time(0);
    } else{
        seed = (unsigned long)argv[2];
    }

    search(seed);
    // if your program gets to this line, it solved the problem.
    printf("s SATISFIABLE\nv ");

    //ofstream myfile;
    //myfile.open (argv[1], std::ios_base::app);
    for (int i = 0; i < numVariables; i++)
    {

        //myfile << "Writing this to a file.\n";


        if (setVariables[i])
        {
           cout << i+1 << " "  ;
            //myfile << i+1 << " 0\n";
        } else
        {
           cout << -(i+1) << " ";
            //myfile << -(i+1) << " 0\n";
        }

        
        
    }
    //myfile.close();
    cout << "\n";
    delete(clauses);
    delete(sortedClauses);
    delete(setVariables);
    delete(setClauses);
    delete(setSortedClaues);
    
    exit(10);
}
