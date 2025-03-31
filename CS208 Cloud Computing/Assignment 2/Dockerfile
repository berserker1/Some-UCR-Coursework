# Using a lightweight linux distro with all the preriquisites of gcc installed
FROM gcc:latest

# Set the working directory
WORKDIR /usr/src/assignment2_server

# Copy server code inside the container
COPY server.c .

# INSTALL BASH
# RUN apt-get update && apt-get install -y bash gcc
# SHELL
SHELL ["/bin/bash", "-c"]

# Compile the file
RUN gcc -o server server.c

# PORT set as env variable PORT_VAR, default value is 9000
ENV PORT_VAR="9000"

# Create mountpoint in WORKDIR
RUN mkdir -p server_storage

# Command to run the executable
ENTRYPOINT ["./server"]
# CMD "./server ${PORT_VAR} server_storage/mydata.txt"
# CMD "/bin/bash"
# ENTRYPOINT ["/bin/bash", "-c", "./server"]
# CMD ["/bin/bash" "./server", "${PORT_VAR}", "server_storage/mydata.txt"]