#!/bin/bash

set -ex


# Add vagrant user & vagrant ssh keys
/usr/sbin/groupadd vagrant
/usr/sbin/useradd vagrant -g vagrant -G wheel -s /bin/bash
echo "vagrant"|passwd --stdin vagrant
echo "vagrant        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

mkdir -pm 700 /home/vagrant/.ssh
wget --no-check-certificate \
    'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' \
    -O /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant


# VMware configures sshd MaxSessions at 1 where the default is 10. this
# breaks Vagrant. Remove the VMware configuration and set back to default
# configuration. See: https://github.com/mitchellh/vagrant/issues/4044
sed -i '/MaxSessions.*$/d' /etc/ssh/sshd_config


# Install VMware HGFS driver for shared folders or else Vagrant will complain
zypper addrepo --refresh --no-gpgcheck \
    http://packages.vmware.com/tools/esx/5.5u1/sles11.2/x86_64/ vmware-tools
zypper install -y vmware-tools-esx-nox vmware-tools-hgfs


# Remove traces of mac address from network configuration
rm -rfv /etc/udev/rules.d/70-persistent-net.rules \
        /lib/udev/rules.d/75-persistent-net-generator.rules


# Perform the initial vCenter configuration that normally needs to be done
# via ths VAMI WWW UI.
# @see: http://www.virtuallyghetto.com/2012/02/automating-vcenter-server-appliance.html
echo "Performing initial vCenter configuration"
echo "This will take several minutes ..."
/usr/sbin/vpxd_servicecfg eula accept
/usr/sbin/vpxd_servicecfg timesync write tools
echo "Configuring DB ..."
/usr/sbin/vpxd_servicecfg db write embedded
echo "Configuring SSO ..."
/usr/sbin/vpxd_servicecfg sso write embedded
echo "Starting VPXD ..."
/usr/sbin/vpxd_servicecfg service start


# Needed otherwise vagrant's changing of the VM's hostname will
# break SSL certs.
# @see: http://www.virtuallyghetto.com/2013/04/automating-ssl-certificate-regeneration.html
echo only-once > /etc/vmware-vpx/ssl/allow_regeneration


# Setup vCenter Simulator config files.
# @see: http://eng-wiki.vi.local/display/ENG/VMware%27s+VCSIM+simulator

cat > /etc/vmware-vpx/vcsim/model/vcsim-vagrant.cfg <<EOF
  <simulator>
    <enabled>true</enabled>
    <cleardb>true</cleardb>
    <initInventory>vcsim/model/initInventory-vagrant.cfg</initInventory>
    <enableHistStats>true</enableHistStats>
    <perfCounterInfo>vcsim/model/PerfCounterInfo.xml</perfCounterInfo>
    <metricMetadata>vcsim/model/metricMetadata.cfg</metricMetadata>
  </simulator>
EOF

cat > ./insert_metricMd.txt <<EOF
    <StatsModel id="Default">
        <Type>Triangle</Type>
        <Values>0,200,50,300,0</Values>
        <Periods>600,300,600,900</Periods>
    </StatsModel>
EOF

sed -i '/<GeneralStatsModels>/r insert_metricMd.txt' \
    /etc/vmware-vpx/vcsim/model/metricMetadata.cfg
rm -v ./insert_metricMd.txt

cat > /etc/vmware-vpx/vcsim/model/initInventory-vagrant.cfg <<EOF
<config>
  <inventory>
    <dc>1</dc>
    <host-per-dc>0</host-per-dc>
    <vm-per-host>0</vm-per-host>
    <poweron-vm-per-host>0</poweron-vm-per-host>
    <cluster-per-dc>2</cluster-per-dc>
    <host-per-cluster>8</host-per-cluster>
    <rp-per-cluster>8</rp-per-cluster>
    <vm-per-rp>8</vm-per-rp>
    <poweron-vm-per-rp>6</poweron-vm-per-rp>
    <dv-portgroups>0</dv-portgroups>
  </inventory>

  <worker-threads>2</worker-threads>
  <synchronous>true</synchronous>
</config>
EOF

vmware-vcsim-start /etc/vmware-vpx/vcsim/model/vcsim-vagrant.cfg


# setup the MOTD to tell people how to reconfigure vcsim
cat > /etc/motd <<EOF

################################################################################
#                            vagrant-vcenter-simulator                         #
################################################################################
#                                                                              #
#  To reconfigure the inventory of vCenter Simulator:                          #
#                                                                              #
#    * Edit: /etc/vmware-vpx/vcsim/model/initInventory-vagrant.cfg             #
#    * Run: vmware-vcsim-start /etc/vmware-vpx/vcsim/model/vcsim-vagrant.cfg   #
#                                                                              #
################################################################################

EOF


echo "Done"
