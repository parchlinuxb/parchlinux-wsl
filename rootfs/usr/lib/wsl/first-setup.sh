#!/bin/bash

cat <<EOF
Welcome to Parch Linux WSL!

This image is maintained at <https://git.parchlinux.com/parchlinux/parchlinux-wsl>.
Please report bugs at <https://git.parchlinux.org/parchlinux/parchlinux-wsl/-/issues>.
Note that WSL 1 is not supported.

For more information about this WSL image and its usage, see the Arch Wiki page at
<https://wiki.parchlinux.com/title/Install_Parch_Linux_on_WSL>.

While images are built regularly, it is strongly recommended running "pacman -Syu" 
right after the first launch due to the rolling release nature of Parch Linux.

Available editors: vim, nano, micro
Available shells: bash (default), zsh
EOF

echo -e "\nGenerating pacman keys..."
pacman-key --init 2>/dev/null
pacman-key --populate 2>/dev/null
echo "Done"

echo -e "\nTo change your shell to zsh, run: chsh -s /bin/zsh"
