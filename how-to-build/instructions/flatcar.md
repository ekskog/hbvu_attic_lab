# Flatcar on Proxmox
  
## Preparations  

1. Install a webserver on your local machine (or whatever machine you use to connect to the proxmox VMs). You need this to get the ignition config files.  
  
2. Create an ignition file to allow for ssh login with a ssh key (get the key from your dev machine) with the content below and omve this file to wherever your webserver serves files (e.g. /var/www/html):  

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
          "<THE PUBLIC KEY TO USE> usually this is under the .ssh folder on a file called id_rsa.pub"
        ]
      }
    ]
  }
}
```    

3. Get he latest ISO file for a ProxMox VM from the [Flatcar downloads](https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_iso_image.iso) page. Upload the iso to the NFS shared storage under templates/iso  

## ON PVE  
  
1. Create a VM with downloaded image, use the defaults from PXE WebGUI (maybe use 2 cores on the cpu). This shouldn't take more than a few minutes. When created, start the VM, take note of the assigned IP Address on the console.
  
2. Get the ignition config file from the webserver  

 ``` bash
    $ curl -LO http://<YOUR_WEBSERVER ROOT>/<YOUR .ign FILE>
      % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
      100   764  100   764    0     0  29796      0 --:--:-- --:--:-- --:--:-- 30560
```  

3. Identify the disk attached to the VM. In my case it was /dev/sda.

``` bash
    $ sudo lsblk
      NAME    MAJ:MIN RM SIZE  RO TYPE  MOUNTPOINTS 
      loop0   7:0     0  297M  0  loop  /usr   
      sda     8:0     0  32G   0  disk
      sr0    11:0     1  353M  0  rom

```  

4. Configure the VM using the ign file. This might take some time, wait patiently.  

```bash
  $ sudo flatcar-install -d <YOUR DISK> -i <YOUR IGN FILE>  
  Downloading the signature for https://stable.release.flatcar-linux.net/amd64-usr
  ...
  ...
  Success!! 
  Flatcar Container Linux stable 3374.2.5 is installed on /dev/sda
```

5. Reboot, and when done connect to the VM using ssh from the dev machine from which You used the public key on the ign file.  

## Configure for usability  
  
The newly created VM will have a sudo user called core and the hostname will be localhost. You can fix that by adding further config to the ignition json, or manually as below:  
  
1. Create a new user:  

```bash  
sudo useradd another_user
sudo passwd another_user
```  
2. Add user to sudoers by adding the following line to /etc/sudoers.d/another_user  
another_user ALL=(ALL) NOPASSWD:ALL  
```bash
sudo vim /etc/sudoers.d/another_user
```
3. Set the hostname  and edit /etc/hosts
```bash
sudo hostnamectl set-hostname new_flatcar_vm
sudo vim /etc/hosts
```  
Set a static IP Address by creating a file and adding the following: 
```   
[Match]  
Name=<your interface name>   
[Network]  
Address=192.168.1.XXX/24  
Gateway=192.168.1.1  
DNS=192.168.1.1    
```  

```bash
sudo vim  /etc/systemd/network/10-static.network 
```