void dgemm2(double *C,double *A,double *B,int n)
{
    int i, j, k;
    register size = n;
    for(i=0; i<n; i+=2)
    {
        for(j=0; j<n; j+=2)
        {
            register int l = i*n + j;
            // register int ll = l + n;
            register double c00 = C[l];
            register double c01 = C[l+1];
            register double c10 = C[l+size];
            register double c11 = C[l+size+1];
            for(k=0; k<n; k+=2)
            {
                register int o = i*size + k;
                // register int oo = o + n;
                register int bo = k*size + j;
                // register int boo = bo + n;
                register double a00 = A[o];
                register double b00 = B[bo];
                register double b01 = B[bo+1];
                c00 += a00*b00;
                c01 += a00*b01;
                //put a10 in the register of a00
                a00 = A[o + size];
                c10 += a00*b00;
                c11 += a00*b01;
                a00 = A[o+1]; //a01
                b00 = B[bo+size]; //b10
                b01 = B[bo+size+1]; //b11
                c00 += a00*b00;
                c01 += a00*b01;
                //put a11 in the register of a10
                a00 = A[o+size+1];
                c10 += a00*b00;
                c11 += a00*b01;

            }
            C[l] = c00;
            C[l+1] = c01;
            C[l+size] = c10;
            C[l+size+1] = c11;
        }
    }
}