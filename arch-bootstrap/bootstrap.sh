#!/bin/bash
# Arch Install Bootstrap

# WARNING: this script will destroy data on the selected disk.
# This script can be run by executing the following:
#   curl -sL https://git.io/JLHZM | bash
# Based heavily on https://disconnected.systems/blog/archlinux-installer/#the-complete-installer-script

# DEFAULT VALUES HERE -- IF SET YOU WILL NOT GET PROPMTED
# These are all the possible settings...
#-- hostname=arch-test
#-- disk=/dev/sda
#-- part_root=/dev/sda3
#-- part_swap=/dev/sda2
#-- fstype=f2fs
#-- wire_net=enp1s0f0
#-- wire_net=enp0s3
#-- configure_wifi=false
#-- wifi_net=wlp2s0
#-- wifi_ssid=wifi
#-- wifi_psk="psk"
#-- system_packages <-- include a space after each item!
#-- rootpass=super
#-- user=arch
#-- password=password

# VirtualBox with UEFI, SSD, wired-only, wipe and use entire drive
# hostname=arch-test
# disk=/dev/sda
# fstype=f2fs
# wire_net=enp0s3
# configure_wifi=false
# rootpass=super
# user=arch
# password=password

# VirtualBox with BOIS, HDD, use esisting /dev/sda2(swap) and /def/sda3(root)
# hostname=arch-test
# disk=/dev/sda
# part_swap=/dev/sda2
# part_root=/dev/sda3
# fstype=ext4
# wire_net=enp0s3
# configure_wifi=true
# wifi_net=enp0s8
# wifi_ssid="wifi"
# wifi_psk="wpa-pre-shared-key"
# rootpass=super
# user=arch
# password=password

# MacMini, UEFI, SSD, wired and wireless, wipe and use entire drive
# broadcom-wl-dkms 	-- Mac mini wireless driver
# hostname=mini-mame
# disk=/dev/sda
# fstype=f2fs
# wire_net=enp1s0f0
# configure_wifi=true
# wifi_net=wlp2s0
# wifi_ssid="houser"
# wifi_psk="wpa-pre-shared-key"
# system_packages="broadcom-wl-dkms "
# # rootpass=super
# user=houser
# # password=mame

# KidsMAME-1, BIOS, HDD, wired and wireless, use existing partitions
# hostname=kids-mame-1
# disk=/dev/sda
# part_swap=/dev/sda2
# part_root=/dev/sda3
# fstype=ext4
# wire_net=enp02s5
# configure_wifi=true
# wifi_net=wlan0
# wifi_ssid="houser"
# wifi_psk="wpa-pre-shared-key"
# rootpass=super
# user=mame
# password=mame

# Base Packages to install
# linux linux-firmware 	-- the kernel
# linux-headers 		-- allows building and dynamic build kernel modules
# intel-ucide 			-- indel microcode updates
# base base-devel 		-- base GNU/Linux and development tools
# e2fsprogs				-- ext based file systems
# exfatprogs			-- MS-DOS FAT based file systems
# dosfstools			-- MS-DOS FAT based file systems
# f2fs-tools			-- F2FS Flash-based file systems
# ntfs-3g				-- NTFS-based file systems
# openssh				-- SSH client and server
# man-db man-pages		-- The manual
# pkgfile 				-- allows finding which package provides a program
# zsh grml-zsh-confit	-- zsh and pre-configured zsh scripts
# sudo					-- sudo command 
# vim					-- the editor
# screen				-- terminal multiplexer
# git					-- source code control
# libnewt 				-- whiptail for text-mode prompts

# jack					-- sound routing
base_packages="
	linux linux-firmware linux-headers intel-ucode
	base base-devel
	openssh
	e2fsprogs exfatprogs f2fs-tools dosfstools ntfs-3g
	pkgfile libnewt
	man-db man-pages
	zsh grml-zsh-config
	sudo vim git screen rsync
"

set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

### Get infomation from user ###
if [ -z ${hostname+x} ]; then
	hostname=$(whiptail --inputbox "Enter hostname" 10 50 3>&1 1>&2 2>&3) || exit 1
	: ${hostname:?"hostname cannot be empty"}
fi

if [ -z ${disk+x} ]; then
	SAVE_IFS=${IFS}
	IFS=$'\n'
	blockdevices=()
	for dev in $(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tac); do
		dev_name=$(echo $dev | awk -e '{print $1}')
		dev_size=$(echo $dev | awk -e '{print $2}')
		blockdevices+=("${dev_name}" "    ${dev_size}")
	done
	IFS=${SAVE_IFS}
	disk=$(whiptail --menu "Select installation disk" 10 50 0 "${blockdevices[@]}" 3>&1 1>&2 2>&3) || exit 1
fi

if [ -z ${fstype+x} ]; then
	fstypes=()
	fstypes+=("f2fs" "    Best for SSDs")
	fstypes+=("ext4" "    Best for HDDs")
	fstype=$(whiptail --menu "Select root file system type" 10 50 0 "${fstypes[@]}" 3>&1 1>&2 2>&3) || exit 1
	: ${fstype:?"fstype cannot be empty"}
fi

netdevices=()
for dev in $(ip link show | tac | grep -E "^[0-9]+:" | cut -d: -f2); do
	netdevices+=("$dev" " ")
done

if [ -z ${wire_net+x} ]; then
	wire_net=$(whiptail --menu "Select wired network device" 10 50 0 "${netdevices[@]}" 3>&1 1>&2 2>&3) || exit 1
	: ${wire_net:?"Wired network device cannot be empty"}
fi

if [ -z ${configure_wifi+x} ]; then
	configure_wifi=false
	if whiptail --yesno "Configure WiFi?" 0 0; then
		configure_wifi=true
	fi
fi

if [ "${configure_wifi}" = true ]; then
	if [ -z ${wifi_net+x} ]; then
		wifi_net=$(whiptail --menu "Select wireless network device" 10 50 0 "${netdevices[@]}" 3>&1 1>&2 2>&3) || exit 1
		: ${wifi_net:?"Wireless network device cannot be empty"}
	fi

	if [ -z ${wifi_ssid+x} ]; then
		wifi_ssid=$(whiptail --inputbox "Enter WiFi ssid" 10 50 3>&1 1>&2 2>&3) || exit 1
		: ${wifi_ssid:?"WiFi ssid cannot be empty"}
	fi

	if [ -z ${wifi_psk+x} ]; then
		wifi_psk=$(whiptail --passwordbox "Enter WiFi password" 10 50 3>&1 1>&2 2>&3) || exit 1
		: ${wifi_psk:?"WiFi password cannot be empty"}
	fi
fi

if [ -z ${rootpass+x} ]; then
	rootpass=$(whiptail --passwordbox "Enter root password" 10 50 3>&1 1>&2 2>&3) || exit 1
	: ${rootpass:?"root's password cannot be empty"}
	rootpass2=$(whiptail --passwordbox "Enter root password again" 10 50 3>&1 1>&2 2>&3) || exit 1
	[[ "$rootpass" == "$rootpass2" ]] || ( echo "Passwords did not match"; exit 1; )
fi

if [ -z ${user+x} ]; then
	user=$(whiptail --inputbox "Enter primary user username" 10 50 3>&1 1>&2 2>&3) || exit 1
	: ${user:?"user cannot be empty"}
fi

if [ -z ${password+x} ]; then
	password=$(whiptail --passwordbox "Enter ${user}'s password" 10 50 3>&1 1>&2 2>&3) || exit 1
	: ${password:?"password cannot be empty"}
	password2=$(whiptail --passwordbox "Enter ${user}'s password again" 10 50 3>&1 1>&2 2>&3) || exit 1
	[[ "$password" == "$password2" ]] || ( echo "Passwords did not match"; exit 1; )
fi

[ -d /sys/firmware/efi ] && firmware=UEFI || firmware=BIOS

# Compile extra packages needed based on system
: ${system_packages:=""}
# Firmware packages
if [ "${firmware}" == "UEFI" ]; then
	# efibootmgr		-- for manipulating UEFI boot order systemd-boot
	system_packages+="efibootmgr refind "
else
	# grub				-- The GRUB bootloader
	system_packages+="grub "
fi

# WiFi Packages (if enabled)
if [ "${configure_wifi}" = true ]; then
	# wpa_supplicant	-- WPA WiFi authentication
	system_packages+="wpa_supplicant "
fi

# Review
cat >> /tmp/settings.$$ <<- EOF
		hostname=${hostname}
		rootpass=${rootpass}
		user=${user}
		password=${password}
		disk=${disk}
		part_root=${part_root:-"auto"}
		part_swap=${part_swap:-"auto"}
		fstype=${fstype}
		firmware=${firmware}
		system_packages=${system_packages}
		wire_net=${wire_net}
		configure_wifi=${configure_wifi}
		wifi_net=${wifi_net:-"--unset--"}
		wifi_ssid=${wifi_ssid:-"--unset--"}
		wifi_psk=${wifi_psk:-"--unset--"}
	EOF

whiptail --title "Review settings" \
		--yesno "$(cat /tmp/settings.$$)" 0 0 \
		--yes-button Install \
		--no-button Cancel \
		--defaultno || exit 1

### Set up logging ###
exec 1> >(tee "stdout.log")
exec 2> >(tee "stderr.log")

timedatectl set-ntp true

### Setup the disk and partitions ###
# if part_root defined, then use it and don't re-partition
if [ -z ${part_root+x} ]; then
	echo ""
	echo "Partitioning..."
	swap_size=$(free --mebi | awk '/Mem:/ {print $2}')
	swap_end=$(( $swap_size + 129 + 1 ))MiB

	[ "${firmware}" == "UEFI" ] && boot_fstype=ESP || boot_fstype=primary
	[ "${firmware}" == "UEFI" ] && label_type=gpt || label_type=msdos

	parted --script "${disk}" -- mklabel ${label_type} \
		mkpart ${boot_fstype} fat32 1Mib 129MiB \
		set 1 boot on \
		mkpart primary linux-swap 129MiB ${swap_end} \
		mkpart primary ext4 ${swap_end} 100%

	# Simple globbing was not enough as on one disk I needed to match /dev/mmcblk0p1
	# but not /dev/mmcblk0boot1 while being able to match /dev/sda1 on other disks.
	part_boot="$(ls ${disk}* | grep -E "^${disk}p?1$")"
	part_swap="$(ls ${disk}* | grep -E "^${disk}p?2$")"
	part_root="$(ls ${disk}* | grep -E "^${disk}p?3$")"
fi

echo ""
echo "Creating and activating file systems..."
if [ ! -z ${part_swap+x} ]; then
	wipefs -a "${part_swap}"
	mkswap "${part_swap}"
	swapon "${part_swap}"
fi

wipefs -a "${part_root}"
mkfs -t ${fstype} "${part_root}"
mount "${part_root}" /mnt

if [ ! -z ${part_boot+x} ]; then
	wipefs -a "${part_boot}"
	mkfs.vfat -F32 "${part_boot}"
	mkdir /mnt/boot
	mount "${part_boot}" /mnt/boot
fi

echo ""
echo "Botstrapping the root volume..."

while ! systemctl show pacman-init.service | grep SubState=exited; do
	echo "Waiting for pacman keyring init to be done..."
    systemctl --no-pager status -n0 pacman-init.service || true
    sleep 1
done

pacstrap /mnt ${base_packages} ${system_packages}

genfstab -t PARTUUID /mnt >> /mnt/etc/fstab

echo ""
echo "Setting up timezone and locale..."
arch-chroot /mnt ln -sf /usr/share/zoneinfo/US/Eastern /etc/localtime
arch-chroot /mnt hwclock --systohc
arch-chroot /mnt systemctl enable systemd-timesyncd

echo en_US.UTF-8 UTF-8 >> /mnt/etc/locale.gen
echo LANG=en_US.UTF-8 >> /mnt/etc/locale.conf
arch-chroot /mnt locale-gen

echo ""
echo "Setting up hostname and hosts..."
echo $hostname >> /mnt/etc/hostname
cat >> /mnt/etc/hosts <<- EOF	
	127.0.0.1 localhost
	::1 localhost
	127.0.0.1 ${hostname}.localdomain ${hostname}
EOF

echo ""
echo "Setting up network..."
cat >> /mnt/etc/systemd/network/10-${wire_net}.network <<- EOF
	[Match]
	Name=${wire_net}

	[Network]
	DHCP=yes
EOF

if [ "${configure_wifi}" = true ]; then
	cat >> /mnt/etc/systemd/network/20-${wifi_net}.network <<- EOF
		[Match]
		Name=${wifi_net}

		[Network]
		DHCP=yes
	EOF

	cat >> /mnt/etc/wpa_supplicant/wpa_supplicant-${wifi_net}.conf <<- EOF
		# allow frontend (e.g., wpa_cli) to be used by all users in 'wheel' group
		ctrl_interface=/var/run/wpa_supplicant 
		ctrl_interface_group=wheel
		network={
			ssid="${wifi_ssid}"
			psk="${wifi_psk}"
		}
	EOF

	# Check that wifi device exists before enabling the service
	if [[ " ${netdevices[*]} " =~ " ${wifi_net} " ]]; then
		#arch-chroot /mnt systemctl enable wpa_supplicant.service
		arch-chroot /mnt systemctl enable wpa_supplicant@${wifi_net}
	else
		echo
		echo "WARNING: WiFi device ${wifi_net} does not exist!"
		echo "WARNING: Configuring but not enabling WiFi"
		echo
	fi
fi

# enable network services...
arch-chroot /mnt systemctl enable systemd-networkd
# Don't wait for the network to boot
arch-chroot /mnt systemctl disable systemd-networkd-wait-online
arch-chroot /mnt systemctl enable systemd-resolved

arch-chroot /mnt systemctl enable sshd

echo ""
echo "Setting up accounts..."
# change sudoers file so wheel group can run admin programs
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/# %wheel ALL=(ALL:ALL) ALL/' /mnt/etc/sudoers

# Root password
echo "root:$rootpass" | arch-chroot /mnt chpasswd

# Add user account
arch-chroot /mnt useradd -mU -s /usr/bin/zsh -G  wheel,uucp,video,audio,storage,games,input ${user}
arch-chroot /mnt chsh -s /usr/bin/zsh
echo "${user}:$password" | arch-chroot /mnt chpasswd

echo ""
echo "Setting up packages..."
arch-chroot /mnt pkgfile -u

# Set up systemd-boot (EFI direct boot)
echo ""
echo "Setting up boot manager and initial ramdisk..."
arch-chroot /mnt mkinitcpio -P

if [ "${firmware}" == "UEFI" ]; then
	arch-chroot /mnt bootctl --path=/boot install
	cat >> /mnt/boot/loader/entries/arch.conf <<- EOF
		title   Arch Linux
		linux   /vmlinuz-linux
		initrd  /intel-ucode.img
		initrd  /initramfs-linux.img
		options root=${part_root} rw
	EOF
	arch-chroot /mnt refind-install

	# TODO: Don't scan for Linux kernels, only use the one I installed.
	echo scan_all_linux_kernels false >> /mnt/boot/EFI/refind/refind.conf

	arch-chroot /mnt refind-install

	# start after power loss
	echo ""
	echo "Setting up power on after power loss..."
	setpci -s 0:1f.0 0xa4.b=0

	cat >> /mnt/etc/systemd/system/reboot-on-power.service <<- EOF
		[Unit]
		Description=Reboot after power failure

		[Service]
		Type=oneshot
		# reboot register for Mac Mini with nVidia ISA bridge
		# ExecStart=setpci -s 00:03.0 0x7b.b=0x19

		# reboot register for Mac Mini with Intel ISA bridge
		ExecStart=sudo setpci -s 0:1f.0 0xa4.b=0:1

		# reboot register for PPC Mac Mini (not tested myself):
		# ExecStart=echo server_mode=1 > /proc/pmu/options


		[Install]
		WantedBy=sysinit.target	
	EOF
	arch-chroot /mnt systemctl enable reboot-on-power
else
	arch-chroot /mnt grub-install ${disk}
	arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
fi

# Link vi to vim
arch-chroot /mnt ln -s /usr/bin/vim /usr/bin/vi

# echo ""
# echo "Unmounting..."
# umount ${part_boot}
# umount ${part_root}

echo ""
echo "done!"
