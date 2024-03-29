resource "null_resource" "check-bastion-resources" {
  
        depends_on = [ ibm_is_security_group_rule.inbound-sg-sch-ssh-rule ]

        connection {
            type = "ssh"
            user = "root"
            host = var.BASTION_FLOATING_IP
            private_key = var.PRIVATE_SSH_KEY
            timeout = "1m"
         }

         provisioner "file" {
           source      = "modules/precheck-ssh-exec/check_file.sh"
           destination = "/tmp/check_file-${var.HOSTNAME}.sh"
         }

         provisioner "remote-exec" {
           inline = [
             "chmod +x /tmp/check_file-${var.HOSTNAME}.sh",
             "dos2unix /tmp/check_file-${var.HOSTNAME}.sh",
           ]
         }


         provisioner "file" {
           source      = "modules/precheck-ssh-exec/error.sh"
           destination = "/tmp/${var.HOSTNAME}.error.sh"
         }

         provisioner "remote-exec" {
           inline = [
             "chmod +x /tmp/${var.HOSTNAME}.error.sh",
             "dos2unix /tmp/${var.HOSTNAME}.error.sh",
           ]
         }
    }


  resource "null_resource" "check-path-errors" {

         depends_on	= [ null_resource.check-bastion-resources ]

         provisioner "local-exec" {
             command = "export ID_RSA_FILE_PATH=${var.ID_RSA_FILE_PATH}; ssh -o 'StrictHostKeyChecking no' -i $ID_RSA_FILE_PATH root@${var.BASTION_FLOATING_IP} 'export HOSTNAME=${var.HOSTNAME}; timeout 5s /tmp/${var.HOSTNAME}.error.sh'"
             on_failure = fail
         }

     }
