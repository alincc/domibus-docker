## Setup Network File Shares (On Host machine)

Setup the network file shares to be used by Domibus FS Plugin.

### Samba Share

* Make sure you have Samba installed on your Host (adapt the command and package name to your OS):
```
apt-get install samba
```
* Set a password for the domibus user in Samba credentials store:
```
smbpasswd -a domibus
```
* Create the following directories for each eDelivery corner, under domibus user home dir as we use this user to manage all the domibus instances:
```   
mkdir -p /home/domibus/domibus-files-wlc_c2/smb_plugin_data/OUT
mkdir -p /home/domibus/domibus-files-wlc_c3/smb_plugin_data/OUT
```
* Copy the correspondent metadata.xml file, available on this project "conf" directory:
```
cp conf/metadata_samples/smb_c2_metadata.xml ~/domibus-files-wlc_c2/smb_plugin_data/OUT/metadata.xml
cp conf/metadata_samples/smb_c3_metadata.xml ~/domibus-files-wlc_c3/smb_plugin_data/OUT/metadata.xml
```
* Add the following to the end of the file "/etc/samba/smb.conf":
```
[wlc_smb_plugin_data_c2]
  path = /home/domibus/domibus-files-wlc_c2/smb_plugin_data
  valid users = domibus
  read only = no
[wlc_smb_plugin_data_c3]
  path = /home/domibus/domibus-files-wlc_c3/smb_plugin_data
  valid users = domibus
  read only = no
```
* Restart Samba service:
```
service smbd restart
```

### SFTP Share

* If you already have an SSH server configured on the Host, as is typical, add a password to the domibus user so that he can connect through SSH:
```
passwd domibus
```
* Create the following directories for each eDelivery corner, under domibus user home dir as we use this user to manage all the domibus instances:
```
mkdir -p /home/domibus/domibus-files-wlc_c2/sftp_plugin_data/OUT
mkdir -p /home/domibus/domibus-files-wlc_c3/sftp_plugin_data/OUT
```
* Copy the correspondent metadata.xml file, available on this project "conf" directory:
   $> cp conf/metadata_samples/sftp_c2_metadata.xml ~/domibus-files-wlc_c2/sftp_plugin_data/OUT/metadata.xml
   $> cp conf/metadata_samples/sftp_c3_metadata.xml ~/domibus-files-wlc_c3/sftp_plugin_data/OUT/metadata.xml

### FTP Share

* Make sure you have FTP installed on your Host (adapt the command and package name to your OS):
```
apt-get install vsftpd
```
* Change the following configurations on "/etc/vsftpd.conf":
```
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES
```
* Restart FTP service:
```
service vsftpd restart
```
* Create the following directories for each eDelivery corner, under domibus user home dir as we use this user to manage all the domibus instances:
```
mkdir -p /home/domibus/domibus-files-wlc_c2/ftp_plugin_data/OUT
mkdir -p /home/domibus/domibus-files-wlc_c3/ftp_plugin_data/OUT
```
* Copy the correspondent metadata.xml file, available on this project "conf" directory:
```
cp conf/metadata_samples/ftp_c2_metadata.xml ~/domibus-files-wlc_c2/ftp_plugin_data/OUT/metadata.xml
cp conf/metadata_samples/ftp_c3_metadata.xml ~/domibus-files-wlc_c3/ftp_plugin_data/OUT/metadata.xml
```
