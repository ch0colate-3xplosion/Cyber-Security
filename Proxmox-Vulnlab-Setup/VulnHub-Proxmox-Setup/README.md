# wh0ami Proxmox VulnHub Setup Script

### Tasks Completed by this Script

- [X] Will download all the following Vulnhub file extensions, 7z, zip, tar, ,bz2, gz, rar, tgz, ova.
- [X] Download files on premade directory on Proxmox Server


### Tasks Working On

1. Extract files in their own premade directory (Make this a user selection)
2. Extract the files necessary for conversion to qcow2
3. Convert files whether it be vdi, vmdk, ova, or iso to qcow2
4. Grab necessary information from the VulnHub site to determine the machine OS type, Linux or Windows
5. Create VM based OS Type
   - VM ID, VM Name, CPU Cores, CPU Sockets, RAM, will be user selection
6. Move and rename converted qcow2/raw file to VM storage/images
7. Modify VM configuration to include the storage
8. Check to ensure p7zip is installed and/or other software for extraction and conversion
9. On https://download.vulnhub.com/ ignore .torrent files.
10. Read .txt files and create VM based on .txt files if Windows, Linux versions are mentioned.

### Future Task

1. Have specific VulnHub machine to be user selected
2. Automate preconfigured download links from VulnHub
