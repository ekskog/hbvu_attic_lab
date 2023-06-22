# Flatcar on Proxmox

Get he latest ISO file for a ProxMox VM from the [Flatcar downloads](https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_iso_image.iso) page. Upload the iso to the NFS shared storage under templates/iso  
  
Create a VM with downloaded image, use the defaults from PXE WebGUI  
  
Install a webserver on your local machine (or whatever machine you use to connect to the proxmox VMs. You need this to get the ignition config files.  
  
Create an ignition file to allow for ssh login with a ssh key with the content brlow and omve this file to wherever your webserver serves files (e.g. /var/www/html):  

```json
{
  "ignition": {
    "version": "3.3.0"
  },
  "passwd": {
    "users": [
      {
        "name": "core",
        "sshAuthorizedKeys": [
          "<THE PUBLIC KEY TO USE>"
        ]
      }
    ]
  }
}
```  
  
Get the ignition config file from the webserver  

 ``` bash
    $ curl -LO http://<YOUR_WEBSERVER ROOT>/<YOUR .ign FILE>
      % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
      100   764  100   764    0     0  29796      0 --:--:-- --:--:-- --:--:-- 30560
```  

Identify the disk attached to the VM. In my case it was /dev/sda.

``` bash
    $ sudo lsblk
      NAME    MAJ:MIN RM SIZE  RO TYPE  MOUNTPOINTS 
      loop0   7:0     0  297M  0  loop  /usr   
      sda     8:0     0  32G   0  disk
      sr0    11:0     1  353M  0  rom

```  

Configure the VM using the ign file. This might take some time, wait patiently.  

```bash
  $ sudo flatcar-install -d <YOUR DISK> -i <YOUR IGN FILE>  
  Downloading the signature for https://stable.release.flatcar-linux.net/amd64-usr
  ...
  ...
  Success!! 
  Flatcar Container Linux stable 3374.2.5 is installed on /dev/sda
```

Reboot, and when ready connect to the VM using ssh  

The newly created VM will have a sudo user called core and the hostname will be localhost. You can fix that by adding further config to the ingintion json, or manually like:  

```bash  
$ sudo useradd another_user
$ sudo passwd another_user
New password:
Retype new password:
passwd: password updated successfully
add user to sudoers by adding the following line to /etc/sudoers.d/another_user  
another_user ALL=(ALL) NOPASSWD:ALL
$ sudo vim /etc/sudoers.d/another_user
$ sudo hostnamectl set-hostname new_flatcar_vm
```

Remember to also edit the /etc/hosts file to rename your host.

Make this VM into a PM template, which will allow for speeding up provisioning of new VMs on the other nodes of the cluster.  
