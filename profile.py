import geni.portal as portal
import geni.rspec.pg as pg
import geni.rspec.igext as IG

pc = portal.Context()
request = pc.makeRequestRSpec()

tourDescription = \
"""
This profile provides the template for a compute node with Docker installed on Ubuntu 18.04
"""

#
# Setup the Tour info with the above description and instructions.
#  
tour = IG.Tour()
tour.Description(IG.Tour.TEXT,tourDescription)
request.addTour(tour)

prefixForIP = "192.168.1."
link = request.LAN("lan")

num_nodes = 3
for i in range(num_nodes):
  if i == 0:
    node = request.XenVM("head")
  else:
    node = request.XenVM("worker-" + str(i))
  node.cores = 4
  node.ram = 8192
  node.routable_control_ip = "true" 
  node.disk_image = "urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD"
  iface = node.addInterface("if" + str(i))
  iface.component_id = "eth1"
  iface.addAddress(pg.IPv4Address(prefixForIP + str(i + 1), "255.255.255.0"))
  link.addInterface(iface)
  
  # setup NFS
  if i == 0:
    node.addService(RSpec.Execute("sh", "sudo apt-get update"))
    node.addService(RSpec.Execute("sh", "sudo apt-get install -y nfs-kernel-server"))
    node.addService(RSpec.Execute("sh", "sudo mkdir -p /opt/keys"))
    node.addService(RSpec.Execute("sh", "sudo chown nobody:nogroup /opt/keys"))
    for k in range(1,num_nodes):
      node.addService(RSpec.Execute("sh", "sudo echo '/opt/keys 192.168.1." + str(k+1) + "(rw,sync,no_root_squash,no_subtree_check)' | sudo tee -a /etc/exports"))
    node.addService(RSpec.Execute("sh", "sudo systemctl restart nfs-kernel-server"))
  else:
    node.addService(RSpec.Execute("sh", "sudo apt-get update"))
    node.addService(RSpec.Execute("sh", "sudo apt-get install -y nfs-common"))
    node.addService(RSpec.Execute("sh", "sudo mkdir -p /opt/keys"))
    node.addService(RSpec.Execute("sh", "sleep 3m"))
    node.addService(RSpec.Execute("sh", "sudo mount 192.168.1.1:/opt/keys /opt/keys"))
  
  # setup Docker
  node.addService(pg.Execute(shell="sh", command="sudo bash /local/repository/install_docker.sh"))
  
pc.printRequestRSpec(request)
