import scipy.optimize as opt
import matplotlib.pyplot as plot
import numpy

def f(x):
    return -x * numpy.cos(x)
    
x1 = opt.minimize_scalar(f, method='golden', bounds=(0, 2.5)).x
print("Das Minimum ist bei: ",x1)
X = numpy.arange(0, 2.5, 0.1)
Z = f(X)

plot.xlabel('x')
plot.ylabel('f(x)')
plot.plot(X, Z)