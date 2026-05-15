#!/bin/sh
# =================================================================
# Target: Novaler Multibox 4K SE - Slot 5 (E2TV)
# Description: Creates a recovery ZIP with the required SubDir 
#              structure and hardware-matched filesystem specs.
# =================================================================

SOURCE_TAR="/media/hdd/rootfs.tar.bz2"
OUTPUT_ZIP="/media/hdd/novaler_recovery_slot5.zip"
BASE_DIR="/media/hdd/recovery_build"
IMAGE_DIR="$BASE_DIR/multiboxse"
MNT_DIR="/media/hdd/mnt_ext4"
EXTRACT_DIR="/media/hdd/extracted_files"

echo "--- Starting Final Slot 5 Build ---"

# 1. Cleanup
rm -rf $BASE_DIR $MNT_DIR $EXTRACT_DIR $OUTPUT_ZIP
mkdir -p $IMAGE_DIR $MNT_DIR $EXTRACT_DIR

# 2. Extract
echo "Step 1: Extracting files to HDD..."
tar -xjf $SOURCE_TAR -C $EXTRACT_DIR

# 3. Create Hardware-Matched Image (306MB / 1024 Block Size)
echo "Step 2: Creating hardware-matched e2tv.ext4..."
dd if=/dev/zero of=$IMAGE_DIR/e2tv.ext4 bs=1024 count=313344
mkfs.ext4 -F -L "e2tv" -b 1024 -I 128 -U "fc44476a-7864-49dd-a826-ee66a2e27f67" $IMAGE_DIR/e2tv.ext4

# 4. Populate with linuxrootfs5 Sub-Directory
echo "Step 3: Populating Sub-Directory (linuxrootfs5)..."
mount -o loop $IMAGE_DIR/e2tv.ext4 $MNT_DIR
mkdir -p $MNT_DIR/linuxrootfs5
cp -aP $EXTRACT_DIR/. $MNT_DIR/linuxrootfs5/

# 5. Kernel & Version
if [ -f "$MNT_DIR/linuxrootfs5/boot/uImage" ]; then
    cp $MNT_DIR/linuxrootfs5/boot/uImage $IMAGE_DIR/kernel.bin
fi
echo "9.1-OK" > $IMAGE_DIR/imageversion

sync
umount $MNT_DIR

# 6. Create Final ZIP
echo "Step 4: Zipping for Recovery Menu..."
cd $BASE_DIR
zip -r $OUTPUT_ZIP multiboxse

# Cleanup working folders
rm -rf $BASE_DIR $MNT_DIR $EXTRACT_DIR

echo "------------------------------------------------"
echo "DONE! Your recovery file is at:"
echo "$OUTPUT_ZIP"
echo "------------------------------------------------"

