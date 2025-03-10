import os

N_list=[1, 2, 3, 4, 5]
ver_list=[0, 1, 2, 3]
n=10000000000
# n = 100

os.system("module load mpich-3.2.1")
os.system("make")
if os.path.exists("main"):
    os.system("mkdir sh")
    for N in N_list:
        for ver in ver_list:
            f=open("sh/sieve"+str(ver)+"_"+str(N)+".sh","w")
            f.write("#!/bin/bash\n")
            f.write("#SBATCH -o sieve"+str(ver)+"_"+str(N)+".o\n")
            f.write("#SBATCH -e sieve"+str(ver)+"_"+str(N)+".err\n")
            f.write("#SBATCH -J sieve"+str(ver)+"_"+str(N)+"\n")
            f.write("#SBATCH -N "+str(N)+"\n")
            f.write("#SBATCH -t 00:10:00\n")
            f.write("\n")
            f.write("module load mpich-3.2.1\n")
            f.write("mpirun -np "+str(N*32)+" ../main sieve"+str(ver)+" "+str(n))
            f.close()
    os.chdir("sh")
    for N in N_list:
        for ver in ver_list:
            os.system("sbatch sieve"+str(ver)+"_"+str(N)+".sh")