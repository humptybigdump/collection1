import scipy.optimize as opt
import matplotlib.pyplot as plot
import numpy

def f(x_arg):
    return x_arg**2 - 10*x_arg

def bar(x_arg):
    return -numpy.log(-x_arg + 1)

def f_extended(x_arg):
    return f(x_arg) + t_current * bar(x_arg)

rho = 0.5
x_arg = 0
t_current = 1

plot.xlabel('x')
plot.ylabel('f(x)')
while t_current > 0.001:
    x_opt = opt.minimize(f_extended, x0 = x_arg, method='Nelder-Mead').x
    x_arg = x_opt
    X = numpy.arange(0, 1, 0.01)
    Z = f_extended(X)
    plot.plot(X, Z)
    print(x_arg)
    t_current = rho * t_current