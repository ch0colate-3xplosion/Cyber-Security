#!/bin/bash

# Define the directory where you want to store the downloaded and extracted files
BASE_DIR="/mnt/pve/chocolatestream_storage/vulnhub_downloads"

# Read the list of download links from a text file (one link per line)
while read -r LINK; do
    # Extract the file extension from the link
    EXTENSION="${LINK##*.}"

    # Determine the directory name based on the file extension
    case "${EXTENSION}" in
        "tar")
            DIR_NAME="vuln_tar"
            ;;
        "zip")
            DIR_NAME="vuln_zip"
            ;;
        "ova")
            DIR_NAME="vuln_ova"
            ;;
        "vmdk")
            DIR_NAME="vuln_vmdk"
            ;;
        "vdi")
            DIR_NAME="vuln_vdi"
            ;;
        "vmx")
            DIR_NAME="vuln_vmx"
            ;;
        "bz2")
            DIR_NAME="vuln_bz2"
            ;;
        "gz")
            DIR_NAME="vuln_gz"
            ;;
        "rar")
            DIR_NAME="vuln_rar"
            ;;
        "tgz" | "tar.gz")
            DIR_NAME="vuln_tgz"
            ;;
        "7z")
            DIR_NAME="vuln_7z"
            ;;
        *)
            # If the file extension is not recognized, skip the download
            echo "Skipping unrecognized file extension: ${EXTENSION}"
            continue
            ;;
    esac

    # Create the destination directory
    DEST_DIR="${BASE_DIR}/${DIR_NAME}"
    mkdir -p "${DEST_DIR}"

    # Download the file
    wget -P "${DEST_DIR}" "${LINK}"

    # Check if the file needs to be extracted (e.g., tar, unzip, 7z, etc.)
    case "${EXTENSION}" in
        "tar")
            tar -xvf "${DEST_DIR}/*.tar" -C "${DEST_DIR}"
            ;;
        "zip")
            unzip -d "${DEST_DIR}" "${DEST_DIR}/*.zip"
            ;;
        "7z")
            7z x "${DEST_DIR}/*.7z" -o"${DEST_DIR}"
            ;;
        "bz2")
            bunzip2 -k "${DEST_DIR}/*.bz2"
            ;;
        "gz")
            gunzip -k "${DEST_DIR}/*.gz"
            ;;
        "rar")
            unrar x "${DEST_DIR}/*.rar" "${DEST_DIR}"
            ;;
        "tgz" | "tar.gz")
            tar -xzvf "${DEST_DIR}/*.tgz" -C "${DEST_DIR}"
            ;;
    esac

    # Remove the downloaded archive (optional)
    rm -f "${DEST_DIR}/*.${EXTENSION}"

    # Check the content of the extracted directory
    CONTENT=$(ls "${DEST_DIR}")

    # Iterate through each file in the extracted directory
    for FILE in ${CONTENT}; do
        # Check if the content includes a virtual machine image, ISO, OVA, VDI, or VMDK
        if [[ "${FILE}" == *".iso"* || "${FILE}" == *".img"* || "${FILE}" == *".qcow2"* ]]; then
            # Convert the image/ISO to a Proxmox VM (example for qcow2 format)
            qemu-img convert -f qcow2 -O raw "${DEST_DIR}/${FILE}" "${DEST_DIR}/${FILE}.raw"
        elif [[ "${FILE}" == *".ova"* ]]; then
            # Convert the OVA to a Proxmox VM (example for ova format)
            qm importovf <vmid> "${DEST_DIR}/${FILE}" [--format ova]
            # Replace <vmid> with your specific VM ID and specify the appropriate format
        elif [[ "${FILE}" == *".vdi"* ]]; then
            # Convert the VDI to a Proxmox VM (example for qcow2 format)
            qemu-img convert -f vdi -O qcow2 "${DEST_DIR}/${FILE}" "${DEST_DIR}/${FILE}.qcow2"
        elif [[ "${FILE}" == *".vmdk"* ]]; then
            # Convert the VMDK to a Proxmox VM (example for qcow2 format)
            qemu-img convert -f vmdk -O qcow2 "${DEST_DIR}/${FILE}" "${DEST_DIR}/${FILE}.qcow2"
        fi
    done
done < download_links.txt
