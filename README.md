Packer template & setup script to create a Vagrant box of VMware
vCenter Server Appliance running in simulator mode.

The resulting Vagrant box will have a simulated inventory of
several Hosts, Clusters, VMs, etc with metrics also being simulated.


Requirements
============

* [ovftool](https://my.vmware.com/web/vmware/details?productId=352&downloadGroup=OVFTOOL350)
* [packer](http://www.packer.io)

Example
=======

```
$ ./build.sh -u VMware-vCenter-Server-Appliance-5.5.0.5100-1312297_OVF10.ova
The manifest validates
Source is signed and the certificate validates
Opening VMX target: output/vcsa-55.vmx
Writing VMX file: output/vcsa-55.vmx
Transfer Completed                    
Completed successfully
+ packer build vcenter-55-simulator.json
vmware-vmx output will be in this color.

==> vmware-vmx: Cloning source VM...
==> vmware-vmx: Starting virtual machine...

... < snip > ...

    vmware-vmx (vagrant): Compressing: vcsa-55-disk1-cl1.vmdk
    vmware-vmx (vagrant): Compressing: vcsa-55-disk2-cl1.vmdk
Build 'vmware-vmx' finished.

==> Builds finished. The artifacts of successful builds are:
--> vmware-vmx: 'vmware' provider box: output/vcenter-55-simulator.box
```

Screen Shots
============

All of the entities & performance metrics below are generated automatically by the simulator:

![vSphere Web Client Dashboard](https://github.com/tehranian/vagrant-vcenter-simulator/raw/master/screenshots/dashboard.png)

![Showing off VM metrics](https://github.com/tehranian/vagrant-vcenter-simulator/raw/master/screenshots/metrics.png)
