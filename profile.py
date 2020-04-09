import geni.portal as portal
import geni.rspec.pg as pg
import geni.rspec.igext as IG

pc = portal.Context()
request = pc.makeRequestRSpec()

tourDescription = \
"""
This profile provides the template for multiple compute nodes with Docker installed on Ubuntu 18.04-ARM. 
This profile must be initiated on Utah. 
"""

#
# Setup the Tour info with the above description and instructions.
#  
tour = IG.Tour()
tour.Description(IG.Tour.TEXT,tourDescription)
request.addTour(tour)

prefixForIP = "192.168.1."
link = request.LAN("lan")

for i in range(3):
  if i == 0:
    #node = request.XenVM("head")
    node=request.RawPC("head")
  else:
    #node = request.XenVM("worker-" + str(i))
    node=request.RawPC("worker-" + str(i))
  #node.cores = 2
  #node.ram = 2048
  node.routable_control_ip = "true" 
  node.disk_image = "urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-ARM"
  iface = node.addInterface("if" + str(i))
  iface.component_id = "eth1"
  iface.addAddress(pg.IPv4Address(prefixForIP + str(i + 1), "255.255.255.0"))
  link.addInterface(iface)
  node.addService(pg.Execute(shell="sh", command="sudo bash /local/repository/install_docker.sh"))
  
  if i == 0:
    node.addService(pg.Execute(shell="sh", command="sudo bash /local/repository/nfs/nfsServer.sh"))
  else: 
    node.addService(pg.Execute(shell="sh", command="sudo bash /local/repository/nfs/nfsClient.sh"))
  
pc.printRequestRSpec(request)
