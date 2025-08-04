import scipy.optimize as opt
import matplotlib.pyplot as plot
import numpy

def f(x_arg):
    return 0.25*x_arg[0]**2 - 6*x_arg[0] + x_arg[1]**2 - 10*x_arg[1]

def bar(x_arg):
    return -numpy.log(8 - x_arg[0]) -numpy.log(7 - x_arg[1]) -numpy.log(x_arg[0]) -numpy.log(x_arg[1]) 

def f_extended(x_arg):
    return f(x_arg) + t_current * bar(x_arg)

rho = 0.5
x_arg = [0, 0]
t_current = 1

ax = plot.axes(projection='3d')
ax.set_xlabel('x')
ax.set_ylabel('y')
ax.set_zlabel('f(x, y)')
while t_current > 0.001:
    x_opt = opt.minimize(f_extended, x0 = x_arg, method='Nelder-Mead').x
    x_arg = x_opt
    x = numpy.linspace(0, 2, 30)
    y = numpy.linspace(0, 2, 30)
    X, Y = numpy.meshgrid(x, y)
    Z = f_extended([X, Y])
    ax.contour3D(X, Y, Z, 50, cmap='rainbow')
    print(x_arg)
    t_current = rho * t_current