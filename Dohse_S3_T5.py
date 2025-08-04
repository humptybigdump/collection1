import itertools, sys, getopt, subprocess, os

glucoseStr = "../glucose-syrup-4.1/simp/glucose_static"

def line_prepender(filename, line):
    with open(filename, 'r+') as f:
        content = f.read()
        f.seek(0, 0)
        f.write(line.rstrip('\r\n') + '\n' + content)

f = open("Dohse.cnf", "w")
#f.write("p cnf 1000 5000\n")

def onlyOne(vars): #implement to allow only 1 to be true
    for x in itertools.combinations(vars,2):
        f.write("-%s -%s 0\n"%(x[0],x[1]))

def atLeastone(vars):#implement to make at least one true
    for x in vars:
        f.write("%s "%x)                    # one has to be true
    f.write("0\n")

def setterOrCell(setters,cells): #for each setter and each cell: not setter or cell
    for s in setters:
        for c in cells:
            f.write("-%s %s 0\n"%(s,c))

def countVariables(vars):
    if len(vars)>0:

        for x in range(len(vars)-1,0,-1):
            f.write("-%s %s 0\n"%(vars[x],vars[x-1]))
        f.write("%s 0\n"%vars[len(vars)-1])
        

inputString = sys.argv[1]
splitInput0 = inputString.split(":")
splitInput1 = splitInput0[0].split(",")
splitInput2 = splitInput0[1].split(";")
height = int(splitInput1[1])
width = int(splitInput1[0])
total = width*height



cells = [ ]
variables = 1
oneAndTotal = [[],[]]

numbers = []

for i in range(total):
    temp_list = []
    numbers.append(temp_list)



for h in range(height): #get an empty list for each cell first argument height second width
    h_list = []
    for w in range(width):
        h_list.append([])
    cells.append(h_list)

for h in range(height): #create the variables for the different numbers in the cells
    for w in range(width):
        for i in range(total):
            numbers[i].append(variables)
            cells[h][w].append(variables)
            variables += 1 

lineIndex = 0

for line in splitInput2:
    if line != "":
        content = line.split(",")
        
        colIndex = 0
        for x in content:
            elem = int(x)
            if elem > 0:
                f.write("%s 0\n"%cells[lineIndex][colIndex][elem -1])
            colIndex += 1
        lineIndex +=1

for h in range(height): #create the variables for the different numbers in the cells
    for w in range(width):
        oneAndTotal[0].append(cells[h][w][0])
        oneAndTotal[1].append(cells[h][w][total-1])
        for i in range(total -1):
            f.write("-%s "%cells[h][w][i])
            if h > 0 and w > 0 and h < height -1 and w < width -1:
                f.write("%s %s %s %s %s %s %s %s 0\n"%(cells[h-1][w-1][i+1],cells[h-1][w][i+1],cells[h-1][w+1][i+1],
                cells[h][w-1][i+1],cells[h][w+1][i+1],cells[h+1][w-1][i+1],cells[h+1][w][i+1],cells[h+1][w+1][i+1])) 
            elif h == 0:
                if w == 0:
                    f.write("%s %s %s 0\n"%(cells[h][w+1][i+1],cells[h+1][w+1][i+1],cells[h+1][w][i+1])) 
                elif w == width -1:
                    f.write("%s %s %s 0\n"%(cells[h][w-1][i+1],cells[h+1][w][i+1],cells[h+1][w-1][i+1])) 
                else:
                    f.write("%s %s %s %s %s 0\n"%(cells[h][w-1][i+1],cells[h][w+1][i+1],cells[h+1][w-1][i+1],
                    cells[h+1][w][i+1],cells[h+1][w+1][i+1])) 
            elif h == height-1:
                if w == 0:
                    f.write("%s %s %s 0\n"%(cells[h][w+1][i+1],cells[h-1][w+1][i+1],cells[h-1][w][i+1])) 
                elif w == width -1:
                    f.write("%s %s %s 0\n"%(cells[h][w-1][i+1],cells[h-1][w-1][i+1],cells[h-1][w][i+1])) 
                else:
                    f.write("%s %s %s %s %s 0\n"%(cells[h][w-1][i+1],cells[h][w+1][i+1],cells[h-1][w-1][i+1],
                    cells[h-1][w][i+1],cells[h-1][w+1][i+1])) 
            elif w == 0:
                f.write("%s %s %s %s %s 0\n"%(cells[h-1][w][i+1],cells[h+1][w][i+1],cells[h-1][w+1][i+1],
                    cells[h][w+1][i+1],cells[h+1][w+1][i+1]))
            elif w == width -1:
                f.write("%s %s %s %s %s 0\n"%(cells[h-1][w][i+1],cells[h+1][w][i+1],cells[h-1][w-1][i+1],
                    cells[h][w-1][i+1],cells[h+1][w-1][i+1]))
            #above: if the number i in this cell is true, set the surrounding i+1 true
        onlyOne(cells[h][w])
        atLeastone(cells[h][w])
for i in range(total):
    onlyOne(numbers[i])
    atLeastone(numbers[i])
#atLeastone(oneAndTotal[0])
#atLeastone(oneAndTotal[1])
#onlyOne(oneAndTotal[0])
#onlyOne(oneAndTotal[1])
f.close()

count = 0
for line in open("Dohse.cnf").readlines(  ): count += 1

line_prepender("Dohse.cnf","p cnf %s %s\n"%(variables-1,count))

subprocess.call(glucoseStr+" Dohse.cnf -model | grep '^s\|^v' >>resultD.txt",shell=True)

lines = open("resultD.txt", "r").readlines()
if "UNSATISFIABLE" in lines[0]:
    print("sol:UNSAT")
else:
    result = lines[1].split(" ")
    returnString = "sol:"
    index = -1
    newIndex = 0
    for x in result:
        
        if not(index == -1):
            variab = int(x)
            if variab > 0:
                newTotal = total +1
                outp = ((variab-1)%total) +1
                returnString += ("%s"%outp)
                if (newIndex+1) % width == 0:
                    returnString += ";"
                    newIndex = 0
                else: 
                    returnString += ","  
                    newIndex += 1     
        index += 1
    print(returnString)

os.remove("Dohse.cnf")
os.remove("resultD.txt")

#TODO delete files
""" 
def between(file, startVar, numValues):
    for x in itertools.combinations(range(startVar,startVar+numValues),2):
        file.write("-%s -%s 0\n"%(x[0],x[1])) #not two values true
    for x in range(startVar,startVar+numValues):
        file.write("%s "%x)                    # one has to be true
    file.write("0\n")

#tage m
for person in  range(3):
    for day in range(5):
        print("Person %s Day %s starts at %s\n"%(person+1,day+1,variables))
        between(f,variables,8)
        variables = variables +8

for otherday in range(4):
    print("Day %s starts at %s\n"%(otherday+1,variables))
    between(f,variables,5)
    variables = variables +5 """

#print("Variables: %s"%variables)
