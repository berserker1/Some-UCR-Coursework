from math import sqrt, fma

def sign(x):
    if(x < 0):
        return -1
    elif(x == 0):
        return 0
    elif(x == 1):
        return 1
    else:
        exit(1)

a = (10 ** (-155))
b = 5 * (10 ** 154)
c = -4 * (10 ** 154)
v1 = 4 * a * c
v2 = fma(-(4*a), c, v1)
v3 = fma(b, b, -v1)
corrected_D = sqrt(v3 + v2)
r1 = None
r2 = None
if(corrected_D >= 0):
    r1 = (-b - sign(b)*corrected_D) / (2*a)
    r2 = c / (r1 * a)
if(r1 == None):
    print("roots are not real")
else:
    print(r1, r2)
