Installation

# parted /dev/sda -- mklabel gpt
# parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
# parted /dev/sda -- set 1 esp on
# parted /dev/sda -- mkpart primary linux-swap 512MiB 20Gib
# parted /dev/sda -- mkpart primary linux-swap 512MiB 20Gib
# parted /dev/sda -- mkpart primary 20Gib 100%

# cryptsetup luksFormat /dev/sda3
# cryptsetup open /dev/sda3 cryptroot

# mkfs.ext4 /dev/mapper/cryptroot
# mkfs.fat -F 32 -n boot /dev/sda1
# mkswap -L swap /dev/sda2

# mount /dev/mapper/cryptroot /mnt
# mkdir /mnt/boot
# mount /dev/sda1 /mnt/boot
# swapon /dev/sda2

# nixos-generate-config --root /mnt