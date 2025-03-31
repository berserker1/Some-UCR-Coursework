# Your State is Not Mine: A Closer Look at Evading Stateful
Internet Censorship


## Problem Statement:


This paper discusses a measurement study done on TCP evasive attacks against large scale firewalls such as the Great Firewall of China. The paper also proposes their own evasive techniques which are more effective than the current ones. The paper claims this to be a novel study (a fact which I haven not personally verified).



Various Network Intrusion Detection Systems have a TCB Control block attribute (data structure) inside them to monitor a particular TCP connection, but several evasive techinques which consists of altering certain TCP packets which are picked up by the NIDS can result in bypassing / altering the TCP Control Block. As the paper writes, a study which is remotely comparable to the present paper was done in 2011.


## Pros:


This paper is straight up GRADE A!


As we know that the work of paper is novel, before this very few did a measurement analysis of various TCP evasive techniques in context of large scale firewalls. We only had khattak et al work showing various evasive techniques but the env was very sanitized and contained, something which might not work in actual world. Besides this, we had a West Chamber Project but most evasive attacks of this project (as checked by the authors) is outdated and not effective. This work in itself a big measurement study.


To make a dataset of what websites to test upon they have done a meticulous analysis of filtering out only 70(ish) sites by first choosing 11 vantage points, 9 cities and 3 different ISPs.
They also have manually verified that these websites are indeed accessible from outside. So we can clearly see that for initial steps the authors are focusing lot of time on authentic data collection. The authors go further by also analyzing middlebox behaviour


Creating an improved model of a Great Firewall based upon the extensive analysis above.


The main contribution of the authors after analyzing existing mehthods and modiying the model of GFW is to give novel ways of TCP evasiveness. What I personally like about their methods is that unlike many who model the GFW, the authors have also tried to model the servers between which the communication is taking place, so that they can better analyze as to what will happen to a packet when its send or received to a machine.


The authors then combine their techniques and package in form of a tool whose source code is also open source.


## Cons:



Honestly I have little problems with this, paper, this paper in 2017 (and no, I am not writing this because one of the authors is my professor), the conference where it was published is great, the github repo of their tool has 2,9k stars. They have delivered what anybody would say is a novel research.



However what I do feel is a con personally is I really wanted to see more development of the tool especially when it came to analyziing bridged networks like TOR or VPNs. In that they left it prematurely. I do wnated to see measurement analysis or new evasive techniques on those networks or why actually the tool was working. How to bypass the rate limit. I feel if they would have removed the initial parts of the paper where they talk about evasive attacks as old as 2017 and worked more on bridge networks, it would have been even more influential paper.


I also feel that the section on evading DNS is also underdeveloped, I am not sure why the authors restricted themselves to only 2 DNS servers or why there was no censorship from their vantage points when they used TCP DNS to query the open DNS resolvers.




# Telex: Anticensorship in the Network Infrastructure


## Problem Statement

This paper tries to show a novel anti censorship technique which is designed at an insfrastructure level at network layer. Telex embeds certain signals with normal HTTP / HTTPS traffic through which one can access blocked content hence bypassing certain censorship softwares. This technique is resilient and stealthy (as one cannot pinpoint which user is bypassing censorship but one can identify only the ISP provider involved in it).

## Assumptions

We need to ensure secure key distribution among users while keeping it hidden from other actors in the network.

Reliance on the HTTP protocol.

## Pros

Telex operates at the network layer unlike other application based circumvention tools.

It's a method to make a whole network topology stealthy by instead of individual users using certain circumvention tools.

Leverages existing network topology.


In the end what I like the most is that it encourages whole ISP to adopt certain circumvention standards and one can see how a systemic adoption can be a boon against various large scale censorship tools.

## Cons

Needs Cooperation with the ISP.

It is still susceptible to various traffic analysis techniques and visible to certain specific sensor.

It is also dependent upon high traffic volume as that can cause bottleneck issues.
