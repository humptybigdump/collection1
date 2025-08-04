import scipy.optimize as opt
import matplotlib.pyplot as plot
import numpy

def f(x):
    #return (x+1)*(x-3)*(x-5)
    return -x * numpy.cos(x) #Aufgabe "Liniensuche"
    #return -x**3 - 2*x + 2*x**2 + 0.25*x**4 #Aufgabe "Liniensuche"
    
x1 = opt.minimize_scalar(f, method='golden', bounds=(0, 2.5)).x #golden, brent, bounded; Dichotomous nicht enthalten
print("Das Minimum ist bei: ",x1)
X = numpy.arange(0, 2.5, 0.1)
Z = f(X)

plot.xlabel('x')
plot.ylabel('f(x)')
plot.plot(X, Z)