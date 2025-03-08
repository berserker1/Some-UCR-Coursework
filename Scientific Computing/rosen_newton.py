import matplotlib.pylab as plt
from matplotlib.pyplot import figure
import numpy as np


def rosenbrock(x, y):
   return 100 * ((y - (x ** 2)) ** 2) + ((1-x) ** 2)


def gradient(x, y):
   return np.array([-400 * x * (y - (x ** 2)) - 2 * (1-x), 200 * (y - (x ** 2))])


def hessian(x, y):
   return np.array([[(-400 * y) + (1200 * (x ** 2)) + 2, -400*x], [-400 * x, 200]])


def plotc(fun, xmin, xmax, ymin, ymax, contour=100, colour=True):
   x = np.linspace(xmin, xmax, 300)
   y = np.linspace(ymin, ymax, 300)
   X, Y = np.meshgrid(x, y)
   Z = fun(X, Y)
   if colour:
       plt.contourf(X, Y, Z, contour)
   else:
       plt.contour(X, Y, Z, contour)
   plt.scatter(1, 1, marker='o', s=100, color='g')


figure(figsize=(15, 8))
plotc(rosenbrock, -30,30, -100, 300, colour=False)
plt.xlabel("x")
plt.ylabel("y")
plt.title("Contours plot rosenback function")
def newton_line(fun, gradient, hessian, init, tol=1e-5, max_iter=10000, alpha=0.01, beta=0.05):
   a = init
   t = 1 #step size
   count = 0
   values = [a]
   f_prev = fun(a[0], a[1])
   f_values = [f_prev]
   while count < max_iter:
       # computer hessian and gradient
       g = gradient(a[0], a[1])
       h = hessian(a[0], a[1])
       dir = -np.linalg.solve(h, g) # # Let numpy handle the complex calculations, negative gradient direction
       val = a + t*dir
       while(fun(val[0], val[1]) > (fun(a[0], a[1]) + alpha * t * np.dot(g.T, dir))): #alpha and beta for backtracking
           val = a + t*dir
           t *= beta
       a += t * dir # Update
       current = fun(a[0], a[1])
       if np.isnan(current):
           break
       values.append(a)
       f_values.append(current)
       if abs(current - f_prev) < tol:
           # under tolerance hence end the algorithm
           break
       f_prev = current
       count = count + 1
   return np.array(values), np.array(f_values)
for elem in [[-1, 1], [0, 1], [2, 1]]:
   x_values, y_values = newton_line(rosenbrock, gradient, hessian, init=elem)
   figure(figsize=(15, 8))
   plt.subplot(1,2,1)
   plotc(rosenbrock, -1,3,0,10)
   plt.xlabel("x")
   plt.ylabel("y")
   title = "Minimize rosenbrock using damped newton for initial point " + str(elem)
   plt.title(title)
   plt.scatter(x_values[0,0],x_values[0,1],marker="*",color="w")
   for i in range(1,len(x_values)):   
           plt.plot((x_values[i-1,0],x_values[i,0]), (x_values[i-1,1],x_values[i,1]) , "w");
   plt.subplot(1,2,2)
   plt.plot(y_values)
   plt.xlabel("iterations")
   plt.ylabel("function value")
plt.show()
