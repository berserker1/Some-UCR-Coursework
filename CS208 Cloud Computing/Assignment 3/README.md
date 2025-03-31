# Initialization Steps
- Logged into Cloudlab.
- Started an experiment with profile name `OpenStack`.
- Default parameters.
  - ![Final Image](image.png)
  - 16 hours experiment
- Gave Floating IP.
  - ![Floating IP Image](image-1.png)
  - As one can see the external IP of the 3 machines is a whole subnet of its own.
  - ![Network Topology Description](image-2.png)
- Have created the SSH keypair file.

# Logging in using SSH
- Using the SSH private key stored in my personal machine, I logged in.
  - ![Logged in terminal](image-3.png)

# Topology
- Running Instances as shown from the node which hosts all VMs.
  - ![Display of 3 virtual nodes](image-6.png)
- Current network topology
  - ![Network Toplogy](image-4.png)
  - After logging in I can ping the other 2 as well.
    - ![Ping Check](image-5.png)
- To calculate average rtt I used 20 ping packets for using machine A to both B and C.
  - Results
  - Machine A
    - ![RTT of machine A](image-7.png)
  - Machine B
    - ![RTT of machine B](image-8.png)

# Virtual Nodes and Physical Nodes
- Virtual Nodes are different VMs on the same physical machine.
- Physical Node are the actual machines.

# DNAT different from SNAT
- DNAT alters IP packets and changes destination such that it reaches a private IP inside the network.
- SNAT alters outgoing IP so that an internal node inside a network needs to communicate with an external node.