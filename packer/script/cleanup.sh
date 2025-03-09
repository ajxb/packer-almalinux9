#!/bin/bash -eu
DISK_USAGE_BEFORE_CLEANUP=$(df -h)

# Clean package manager
echo "==> Clean up dnf cache of metadata and packages to save space"
dnf -y --enablerepo='*' clean all
rm -rf /var/cache/dnf/*

# Clean temporary files
echo "==> Removing temporary files used to build box"
rm -rf /tmp/*
rm -rf /var/tmp/*

# Clean logs
echo "==> Cleaning logs"
find /var/log -type f -exec rm -f {} \;
find /var/log -type d -empty -delete

# Create fresh log files for essential services
touch /var/log/wtmp /var/log/btmp /var/log/lastlog
chown root:utmp /var/log/wtmp /var/log/btmp
chmod 664 /var/log/wtmp
chmod 660 /var/log/btmp
chmod 664 /var/log/lastlog

# Clean up other common log locations and history files
rm -rf /var/log/audit/*
rm -rf /var/log/tuned/tuned.log
rm -rf /root/.bash_history
rm -rf /home/*/.bash_history
rm -rf /root/.cache
rm -rf /home/*/.cache

echo '==> Clear out swap and disable until reboot'
set +e
swapuuid=$(/sbin/blkid -o value -l -s UUID -t TYPE=swap)
case "$?" in
	2|0) ;; # 2: no swap found, 0: swap found - both are ok
	*) echo "Error detecting swap partition"; exit 1 ;;
esac
set -e

if [ -n "${swapuuid}" ]; then
	# Whiteout the swap partition to reduce box size
	swappart=$(readlink -f /dev/disk/by-uuid/$swapuuid)
	if [ -e "${swappart}" ]; then
		/sbin/swapoff "${swappart}" || true
		# Zero out the swap partition
		dd if=/dev/zero of="${swappart}" bs=1M status=none || echo "dd exit code $? is suppressed"
		# Recreate the swap partition
		/sbin/mkswap -U "${swapuuid}" "${swappart}"
	fi
fi

echo '==> Zeroing out empty area to save space in the final image'
# Zero out the free space to save space in the final image.
# Contiguous zeroed space compresses down to nothing.
# Note: "No space left on device" is the expected outcome - it means we've
# successfully filled all free space with zeros
dd if=/dev/zero of=/EMPTY bs=1M status=progress || true
rm -f /EMPTY

# Also zero out /boot if it's a separate partition
if mountpoint -q /boot; then
    dd if=/dev/zero of=/boot/EMPTY bs=1M status=progress || true
    rm -f /boot/EMPTY
fi

# Final cleanup
echo "==> Final cleanup"
sync
# Clean up this script
rm -f $0

echo "==> Disk usage before cleanup"
echo "${DISK_USAGE_BEFORE_CLEANUP}"

echo "==> Disk usage after cleanup"
df -h
