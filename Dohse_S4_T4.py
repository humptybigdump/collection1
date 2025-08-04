import itertools, sys, getopt, subprocess, os

glucoseStr = "../../glucose/simp/glucose_static"
modelStr = " -model"
def line_prepender(filename, line):
    with open(filename, 'r+') as f:
        content = f.read()
        f.seek(0, 0)
        f.write(line.rstrip('\r\n') + '\n' + content)

f = open("Dohse_SAT.cnf", "w")
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
            equivalent(s,c)

def thisThenNot(setOne,two):
    for x in setOne:
        f.write("-%s -%s 0\n"%(x,two))
        
def orVarsNewVar(vars, newVar): #TODO implement
        retStr = "-%s "%newVar
        for var in vars:
            retStr = retStr + "%s "%var
            f.write("-%s %s 0\n"%(var,newVar))
        retStr = retStr +"0\n"
        f.write(retStr)

def equivalent(varOne,varTwo): #todo implement
    f.write("-%s %s 0\n"%(varOne,varTwo))
    f.write("-%s %s 0\n"%(varTwo,varOne))

inputString = sys.argv[1]
splitCone = inputString.split(":")
#print(splitCone[0].split(","))
height = int(splitCone[0].split(",")[1])
width = int(splitCone[0].split(",")[0])

splitSemicolon = splitCone[1].split(";")

heightBlocks = []
for i in range(height):
    heightBlocks.append([])
    splitComma = splitSemicolon[i].split(",")
    #print(splitComma)
    for j in range(len(splitComma)):
        if not( int(splitComma[j]) == 0):
            if int(splitComma[j]) > width:
                #print("yolo")
                print("sol:UNSAT")
                exit(20)
            heightBlocks[i].append(int(splitComma[j]))

widthBlocks = []
for i in range(height,width+height):
    widthBlocks.append([])
    splitComma = splitSemicolon[i].split(",")
    #print(splitComma)
    for j in range(len(splitComma)):
        if not( int(splitComma[j]) == 0):
            if int(splitComma[j]) > height:
                #print("polo")
                print("sol:UNSAT")
                exit(20)
            widthBlocks[i - height].append(int(splitComma[j]))




#print("heigth %s width %s i %s t %s s %s l %s o %s"%(height,width,iNumBlock,tNumBlock,sNumBlock,lNumBlock,oNumBlock))
cells = [ ]
cellsWidth = []
setCells= []
setters = []
blockedCells = []

variables = 1
for h in range(height): #get an empthy list for each cell first argument height second width
    h_list = []
    blockedList = []
    h2_list = []
    setCellInsert = []
    for w in range(width):
        blockedList.append([])
        h_list.append([])
        h2_list.append([])
        setCellInsert.append(0)
    blockedCells.append(blockedList)
    setCells.append(setCellInsert)
    cells.append(h_list)
    cellsWidth.append(h2_list)



for i in range(height):
        for elem in heightBlocks[i]:
            lineSetters = []
            for j in range(width):
                if j + elem <= width:
                    
                        
                    thissetter= variables
                    lineSetters.append(variables)

                   

                    for k in range(elem):
                        cells[i][j+k].append(variables)
                        variables += 1
                    if elem > 1:
                        
                        setterOrCell([thissetter],range(thissetter+1,thissetter+elem))

                    if j > 0:
                        equivalent(thissetter,variables)
                        blockedCells[i][j-1].append(variables)
                        variables = variables +1
                        
                    if j+elem < width:
                        equivalent(variables,thissetter)
                        blockedCells[i][j+elem].append(variables)
                        variables = variables +1


            setters.append(lineSetters)
                
for j in range(width):
        for elem in widthBlocks[j]:
            lineSetters = []
            for i in range(height):
                if i + elem <= height:
                    thissetter= variables
                    lineSetters.append(variables)
                    for k in range(elem):
                            cellsWidth[i+k][j].append(variables)
                            variables += 1
                    if elem > 1:
                        
                        setterOrCell([thissetter],range(thissetter+1,thissetter+elem))
                    if i > 0:
                        equivalent(thissetter,variables)
                        blockedCells[i-1][j].append(variables)
                        variables = variables +1
                        
                    if i+elem < height:
                        equivalent(variables,thissetter)
                        blockedCells[i+elem][j].append(variables)
                        variables = variables +1
            setters.append(lineSetters)


for vars in setters:
    if len(vars) > 0:
            atLeastone(vars)
            onlyOne(vars)
    

for i in range(height):
    for j in range(width):
        vars = cells[i][j]
        varsWidth = cellsWidth[i][j]
            
        if len(vars) > 0 and len(varsWidth) > 0:
            onlyOne(vars)
            onlyOne(varsWidth)
            orVarsNewVar(vars,variables)
            orVarsNewVar(varsWidth,variables+1)
            equivalent(variables, variables+1)
            setCells[i][j] = variables
            variables +=2
        else:
            for k in vars:
                f.write("-%s 0\n"%(k))
            for k in varsWidth:
                f.write("-%s 0\n"%(k))

for i in range(height):
    for j in range(width):
        if not setCells[i][j] ==0:
            thisThenNot(blockedCells[i][j],setCells[i][j])

#print(cells)
#print(cellsWidth)



# for lists in cells:
#     for vars in lists:
#         if len(vars) > 0:
#             onlyOne(vars)

# for lists in cellsWidth:
#     for vars in lists:
#         if len(vars) > 0:
#             onlyOne(vars)
        






#print(setCells)

f.close()

count = 0
for line in open("Dohse_SAT.cnf").readlines(  ): count += 1

line_prepender("Dohse_SAT.cnf","p cnf %s %s\n"%(variables-1,count))



subprocess.call(glucoseStr+" Dohse_SAT.cnf" + modelStr+ " | grep '^s\|^v' >>resultD.txt",shell=True)

lines = open("resultD.txt", "r").readlines()
if "UNSATISFIABLE" in lines[0]:
    print("sol:UNSAT")
else:
    result = lines[1].split(" ")
    returnString = "sol:"
    for i in range(height):
        for j in range(width):
            if setCells[i][j] == 0 or (("-"+str(setCells[i][j])) in result):
                returnString = returnString + "0"
            else:
                returnString = returnString + "1"
        returnString = returnString + ";"
    returnString = returnString
    print(returnString)






os.remove("Dohse_SAT.cnf")
os.remove("resultD.txt")
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
