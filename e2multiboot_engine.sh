cat << 'EOF' > /usr/bin/e2multiboot_engine.sh
#!/bin/bash
# Engine script for AJ Panel Custom Menu - Novaler 4K Pro Multiboot

ACTION=$1
PARAM1=$2
PARAM2=$3

case $ACTION in
    "format_sd")
        # PARAM1 = total slots requested (e.g. 2 for slot 6 and 7)
        SLOTS_COUNT=$PARAM1
        echo "[+] Preparing SD card with GPT for $SLOTS_COUNT external slots..."
        init 4
        umount -f /dev/mmcblk1* 2>/dev/null
        parted -s /dev/mmcblk1 mklabel gpt
        
        for i in $(seq 1 $SLOTS_COUNT); do
            SLOT_NUM=$((5 + i))
            START_SIZE="$(( (i - 1) * 3000 + 1 ))MiB"
            [ "$i" -eq 1 ] && START_SIZE="2048s"
            END_SIZE="$(( i * 3000 ))MiB"
            
            echo "[+] Creating Partition for Slot $SLOT_NUM ($START_SIZE to $END_SIZE)..."
            parted -s /dev/mmcblk1 mkpart primary ext4 ${START_SIZE} ${END_SIZE}
        done
        
        partprobe /dev/mmcblk1
        sleep 2
        
        for i in $(seq 1 $SLOTS_COUNT); do
            SLOT_NUM=$((5 + i))
            DEV_PART="/dev/mmcblk1p${i}"
            echo "[+] Formatting $DEV_PART as linux${SLOT_NUM}..."
            mkfs.ext4 -F -L "linux${SLOT_NUM}" ${DEV_PART}
        done
        echo "SUCCESS: SD Card formatted for $SLOTS_COUNT slots successfully!"
        init 3
        ;;

    "install_image")
        # PARAM1 = Slot Number (6 or 7)
        # PARAM2 = Image ZIP path
        SLOT_NUM=$PARAM1
        ZIP_PATH=$PARAM2
        PART_INDEX=$((SLOT_NUM - 5))
        DEV_PART="/dev/mmcblk1p${PART_INDEX}"
        MOUNT_DIR="/mnt/sdcard${SLOT_NUM}"
        STARTUP_FILE="/boot/STARTUP_LINUX_${SLOT_NUM}"

        if [ ! -f "$ZIP_PATH" ]; then
            echo "ERROR: Image file not found at $ZIP_PATH"
            exit 1
        fi

        echo "[+] Extracting Image to Slot $SLOT_NUM on $DEV_PART..."
        mkdir -p ${MOUNT_DIR}
        mount ${DEV_PART} ${MOUNT_DIR}
        rm -rf ${MOUNT_DIR}/*
        unzip -p "${ZIP_PATH}" */rootfs.tar.bz2 | tar -xvjf - -C ${MOUNT_DIR}/ && sync
        umount ${MOUNT_DIR} && sync

        echo "[+] Creating STARTUP_LINUX_${SLOT_NUM}..."
        echo 'bootcmd=setenv bootargs $(bootargs) $(bootargs_common); mmc read 0 0x1000000 0x3D5000 0x8000; bootm 0x1000000; run bootcmd_fallback' > ${STARTUP_FILE}
        echo "bootargs=root=${DEV_PART} rootfstype=ext4 rw rootwait console=ttyAMA0,115200 kernel=/dev/mmcblk0p22" >> ${STARTUP_FILE}

        echo "SUCCESS: Image installed to Slot $SLOT_NUM successfully!"
        ;;
esac
EOF

chmod +x /usr/bin/e2multiboot_engine.sh
