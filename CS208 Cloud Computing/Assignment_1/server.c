#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>

int main(int argc, char const *argv[])
{
    int byte_count = 0 ;
    int listenfd = 0;
    int connfd = 0;
    struct sockaddr_in serv_addr;
    char send_buff[1025];
    int numrv;

    if(argc != 3)
    {
        fprintf(stderr, "%s", "incorrect number of inputs, exact is 3\n");    
        exit(1);
    }

    //converting arguments to their types
    int PORT = strtol(argv[1], NULL, 10);
    char *filename = strdup(argv[2]);
    printf("Will Transfer %s to incoming connections\n",filename);


    listenfd = socket(AF_INET, SOCK_STREAM, 0);

    // printf("Got a socket\n");

    memset(&serv_addr, '0', sizeof(serv_addr));
    memset(send_buff, '0', sizeof(send_buff));

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    serv_addr.sin_port = htons(PORT);

    if (bind(listenfd, (struct sockaddr*)&serv_addr,sizeof(serv_addr))== -1)
    {
        fprintf(stderr, "%s", "Bind Error\n");    
        exit(2);
    }
    else
    {
        printf("Bind Success to %s\n", argv[1]);
    }

    if(listen(listenfd, 10) == -1)
    {
        printf("Listen failed\n");
        return -1;
    }
    else
    {
        printf("Listen Succesfully on %s\n", argv[1]);
    }

    // Listening for incoming connections
    while(1)
    {
        int count = 0;
        connfd = accept(listenfd, (struct sockaddr*)NULL ,NULL);
        // Open the file that we want to transfer
        FILE *fp = fopen(filename,"rb");
        if(fp==NULL)
        {
            //checking if there is some problem with file or file present or not??
            fprintf(stderr, "%s", "File open error\n");
            exit(3); 
        }

        //Read data from file in chunks of 256 bytes and send it
        while(1)
        {
            // First read
            unsigned char buff[256]={0};
            int nread = fread(buff,1,256,fp);
            byte_count +=nread;
            printf("Bytes read %d \n", nread);        

            // send data on succesful read
            if(nread > 0)
            {
                // printf("Sending \n");
                write(connfd, buff, nread);
                count++;
            }
            if((nread < 256) && (count != 0))
            {
                printf("Total Transfer Done: %d bytes\n" ,byte_count);
                if(feof(fp))
                {
                    printf("End of file, closing this connection now\n");
                }

                if(ferror(fp))
                {
                    printf("Error reading\n");
                }
                break;
            }
        }

        // Closing connection
        fclose(fp);
        close(connfd);
    }
    close(listenfd);
    return 0;
}