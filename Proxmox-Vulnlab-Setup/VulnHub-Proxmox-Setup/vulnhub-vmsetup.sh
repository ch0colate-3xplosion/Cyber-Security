#!/bin/bash
#Script isn't finished!

BASE_DIR="your directory for Proxmox"
dir_index=401

echo "You will need to install p7zip into Proxmox"

while IFS= read -r LINK; do
    EXTENSION="${LINK##*.}"

    case "${EXTENSION}" in
        "tar" | "zip" | "ova" | "vmdk" | "vdi" | "vmx" | "bz2" | "gz" | "rar" | "tgz" | "tar.gz" | "7z")
            DIR_NAME="vuln_${EXTENSION}"
            ;;
        *)
            echo "Skipping unrecognized file extension: ${EXTENSION}"
            continue
            ;;
    esac

    DEST_DIR="${BASE_DIR}/${DIR_NAME}"
    mkdir -p "${DEST_DIR}"
    wget -P "${DEST_DIR}" "${LINK}"

    FILE_PATH="${DEST_DIR}/${LINK##*/}"
    case "${EXTENSION}" in
        "tar")
            tar -xvf "${FILE_PATH}" -C "${DEST_DIR}"
            ;;
        "zip")
            unzip -d "${DEST_DIR}" "${FILE_PATH}"
            ;;
        "7z")
            7z x "${FILE_PATH}" -o"${DEST_DIR}"
            ;;
        "bz2")
            bunzip2 -k "${FILE_PATH}"
            ;;
        "gz")
            gunzip -k "${FILE_PATH}"
            ;;
        "rar")
            unrar x "${FILE_PATH}" "${DEST_DIR}"
            ;;
        "tgz" | "tar.gz")
            tar -xzvf "${FILE_PATH}" -C "${DEST_DIR}"
            ;;
        "ova")
            OVA_DIR="${DEST_DIR}/extracted_ova_${dir_index}"
            mkdir -p "${OVA_DIR}"
            tar -xvf "${FILE_PATH}" -C "${OVA_DIR}"
            OVA_VMDK=$(find "${OVA_DIR}" -name "*.vmdk")
            if [ -n "$OVA_VMDK" ]; then
                qcow2_file_name="vm-${dir_index}-disk.qcow2"
                qemu-img convert -f vmdk -O qcow2 "$OVA_VMDK" "${OVA_DIR}/${qcow2_file_name}"
                ((dir_index++))
            fi
            ;;
    esac

    rm -f "${FILE_PATH}"
    CONTENT=$(ls "${DEST_DIR}")

    for FILE in ${CONTENT}; do
        qcow2_file_name="vm-${dir_index}-disk.qcow2"

        case "${FILE}" in
            *".iso"* | *".img"* | *".qcow2"*)
                qemu-img convert -f qcow2 -O raw "${DEST_DIR}/${FILE}" "${DEST_DIR}/${FILE}.raw"
                ;;
            *".vdi"*)
                qemu-img convert -f vdi -O qcow2 "${DEST_DIR}/${FILE}" "${DEST_DIR}/${qcow2_file_name}"
                ((dir_index++))
                ;;
            *".vmdk"*)
                if [[ "${EXTENSION}" != "ova" ]]; then
                    qemu-img convert -f vmdk -O qcow2 "${DEST_DIR}/${FILE}" "${DEST_DIR}/${qcow2_file_name}"
                    ((dir_index++))
                fi
                ;;
        esac
    done
done < download_links.txt
