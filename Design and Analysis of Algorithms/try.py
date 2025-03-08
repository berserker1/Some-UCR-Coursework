'''

Welcome to GDB Online.
GDB online is an online compiler and debugger tool for C, C++, Python, Java, PHP, Ruby, Perl,
C#, OCaml, VB, Swift, Pascal, Fortran, Haskell, Objective-C, Assembly, HTML, CSS, JS, SQLite, Prolog.
Code, Compile, Run and Debug online from anywhere in world.

'''
import random
# print ('Hello World')

n = int(input())

edges = []
numbers = random.choices(range(1, n), k = 2*n)
i = 0
while (i < (len(numbers) - 1)):
    edges.append([numbers[i], numbers[i+1]])
    # print(i, i+1)
    i = i+2
# print("DONEEE")
print(n, n)
for elem in edges:
    print(elem[0], elem[1])