#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <arpa/inet.h>

int main(int argc, char const *argv[])
{
    int byte_count=0;
    int sockfd = 0;
    int bytes_recv = 0;
    int c;
    // We will receive data in chunks of 256 bytes
    char recv_buff[256];
    memset(recv_buff, '0', sizeof(recv_buff));
    struct sockaddr_in serv_addr;

    if(argc != 3)
    {
        fprintf(stderr, "%s", "incorrect number of inputs, exact is 3\n");
        exit(1);
    }

    char *primary_argument = strdup(argv[1]);
    char *filename = strdup(argv[2]);

    // Parse for destination ip and port
    for(int i=0; primary_argument[i]!='\0'; i++)
    {
        if(primary_argument[i]==':')
        {
            c=i;
        }
    }

    char *ip = (char*) malloc(c+1);
    char *tto = (char*) malloc(c+1);
    strncpy(ip, primary_argument, c);
    strncpy(tto, primary_argument+c+1, c);

    int port = atoi(tto);

    printf("After parsing IP, PORT and filename are %s, %d, %s\n",ip,port,filename);

    //Socket creation
    if((sockfd = socket(AF_INET, SOCK_STREAM, 0))< 0)
    {
        printf("\n Error : Could not create socket \n");
        return 1;
    }

    //Initialize sockaddr_in structure
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(port); // port
    serv_addr.sin_addr.s_addr = inet_addr(ip); // ip

    //Connection

    if(connect(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr))<0)
    {
        printf("%s connection failed, error no, %d\n", strerror(errno), errno);
        exit(1);
    }
    else
    {
        printf("connected to %s\n", argv[1]);
    }

    // Open file to write
    FILE *fp;
    fp = fopen(filename, "wb"); 
    if(NULL == fp)
    {
        fprintf(stderr, "%s", "Error in opening file\n");    
        exit(3);
    }

    // Receive data in chunks of 256 bytes
    while((bytes_recv = read(sockfd, recv_buff, 256)) > 0)
    {
        printf("Bytes received %d\n",bytes_recv);    
        // recv_buff[n] = 0;
        fwrite(recv_buff, 1,bytes_recv,fp);
        // printf("%s \n", recv_buff);
        byte_count +=bytes_recv;
    }

    if(bytes_recv < 0)
    {
        printf("\n read function made an error \n");
    }

    printf("Output file size is %d bytes\n", byte_count);   
    return 0;
}