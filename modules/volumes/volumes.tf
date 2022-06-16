data "ibm_resource_group" "group" {
  name		= var.RESOURCE_GROUP
}

resource "ibm_is_volume" "swap" {
  name		= "${var.HOSTNAME}-swap"
  profile	= "10iops-tier"
  zone		= var.ZONE
  resource_group = data.ibm_resource_group.group.id
  capacity	= var.SWAP
}

resource "ibm_is_volume" "vol1" {
  name		= "${var.HOSTNAME}-vol1"
  profile	= "10iops-tier"
  zone		= var.ZONE
  resource_group = data.ibm_resource_group.group.id
  capacity	= var.VOL1
}

output "volumes_list" {
  value       = [ ibm_is_volume.swap.id , ibm_is_volume.vol1.id ]
}
