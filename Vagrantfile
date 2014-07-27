VAGRANTFILE_API_VERSION = "2"


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "vcenter-55-simulator"

  # VAMI port
  config.vm.network "forwarded_port", guest: 5480, host: 5480
  # The beloved vSphere Web Client UI
  config.vm.network "forwarded_port", guest: 9443, host: 9443
end
