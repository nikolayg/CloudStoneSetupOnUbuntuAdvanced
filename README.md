CloudStoneSetupOnUbuntuAdvanced
=======================

A set of scripts and configuration files for setting up CloudSuite's CloudStone (http://parsa.epfl.ch/cloudsuite/web.html) on Ubuntu Virtual Machines (VMs). 

The predecessor of this project named CloudStoneSetupOnUbuntu(https://github.com/nikolayg/CloudStoneSetupOnUbuntu) sets up CloudStone in a standard topology - i.e. in 3 VMs - a client emulator, web/app server and a database server. This project allows for an automatic setup in an extended environment using a load balancer and an NFS server. This enables new approaches for load balancing and autoscaling to be tested. 


Documentation about how to use the scripts can be found in the following article:
http://nikolaygrozev.wordpress.com/2014/06/02/advanced-automated-cloudstone-setup-in-ubuntu-vms-part-2/

These scripts have also been used for the following VMWare evaluation - http://blogs.vmware.com/performance/2015/04/scaling-web-2-0-applications-using-docker-containers-vsphere-6-0.html
