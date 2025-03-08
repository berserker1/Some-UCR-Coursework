#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
// #include "kernel/Defs.h"
// #include <stdlib.h>
// #include <stdio.h>
struct Pinfo {
int ppid;
int syscall_count;
int page_usage;
};
int main(int argc, char *argv[]){
    printf("\n ********** BEGIN *********\n");
    struct Pinfo param ;
    // = malloc(sizeof(Pinfo));
    param.ppid =123123;
    param.syscall_count=192;
    param.page_usage=12343;

    int n_proc;

    // mem = atoi(argv[2]);
    n_proc = atoi(argv[1]);
    printf(" i am main()....");
    printf("\n");

    printf("\n SYSINFO returns value is  %d \n", info(n_proc));

    printf("\nMaking PROCINFO call\n");
    int res = procinfo(&param);
    printf("\nparam page_usage is %d", param.page_usage);
    printf("\nparam ppid is %d", param.ppid);
    printf("\nparam syscall_count is %d", param.syscall_count);
    printf("\nres is %d", res);
    printf("\nend of main()...\n");
    printf("\n ********* END **********\n");
    exit(0);
    // return 1;
}