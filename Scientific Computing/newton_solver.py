import numpy as np
import matplotlib.pyplot as plt


def ss(a, b):
    return a*b > 0
def bisection(eq, derivatives, x1, x2, threshold=1e-6, max_steps=1000):
    assert not ss(eq(x1), eq(x2))
    for i in range(max_steps):
        mid = (x1 + x2) / 2.0
        if ss(eq(x1), eq(mid)):
            x1 = mid
        else:
            x2 = mid
        if abs(x2 - x1) < threshold:
            break
    return [mid, i]

def f1(x):
    return (x**3) - 3 * (x**2) + 3*x -1


def df1_dx(x):
    return 3*(x**2) - 6 * x + 3


eq = f1
derivatives = df1_dx


start_point = np.array([-1.5])


root = bisection(eq, derivatives, -10, 10)

if root is not None:
    print("Root found:", root[0], " in ", root[1], " steps")
else:
    print("bisection's method did not converge.")
    exit()

# Plot the functions
x_vals = np.linspace(-4, 4, 100)

y = f1(x_vals)
plt.plot(x_vals, y, color='r')
plt.scatter(root[0], 0, color='green', marker='o', label='Root')
plt.xlabel('x')
plt.ylabel('y')
plt.title('Roots of the Equations')
plt.legend()
plt.grid(True)
plt.show()