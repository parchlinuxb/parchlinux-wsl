#!/bin/bash

set -euo pipefail

declare -r WORKDIR="$1"
declare -r BUILDDIR="$WORKDIR/build"
declare -r OUTPUTDIR="$WORKDIR/output"
declare -r IMAGE_VERSION="$2"
declare -r PACKAGES="${3:-vim git curl wget fzf man-db man-pages texinfo sudo zsh micro nano}"

mkdir -vp "$BUILDDIR/alpm-hooks/usr/share/libalpm/hooks"
find /usr/share/libalpm/hooks -exec ln -sf /dev/null "$BUILDDIR/alpm-hooks"{} \;

mkdir -vp "$BUILDDIR/var/lib/pacman/" "$OUTPUTDIR"
install -Dm 644 "/usr/share/devtools/pacman.conf.d/extra.conf" "$BUILDDIR/etc/pacman.conf"

sed 's/Include = /&rootfs/g' < "$BUILDDIR/etc/pacman.conf" > "$WORKDIR/pacman.conf"

cp --recursive --preserve=timestamps rootfs/* "$BUILDDIR/"
ln -sf /usr/lib/os-release "$BUILDDIR/etc/os-release"

fakechroot -- fakeroot -- \
    pacman -Sy -r "$BUILDDIR" \
        --noconfirm --dbpath "$BUILDDIR/var/lib/pacman" \
        --config "$WORKDIR/pacman.conf" \
        --noscriptlet \
        --hookdir "$BUILDDIR/alpm-hooks/usr/share/libalpm/hooks/" base $PACKAGES

fakechroot -- fakeroot -- chroot "$BUILDDIR" update-ca-trust
fakechroot -- fakeroot -- chroot "$BUILDDIR" pacman-key --init
fakechroot -- fakeroot -- chroot "$BUILDDIR" pacman-key --populate
fakechroot -- fakeroot -- chroot "$BUILDDIR" /usr/bin/systemd-sysusers --root "/"
fakechroot -- fakeroot -- chroot "$BUILDDIR" /usr/bin/systemctl mask systemd-firstboot

fakeroot -- \
    tar \
        --numeric-owner \
        --xattrs \
        --acls \
        --exclude-from=scripts/exclude \
        -C "$BUILDDIR" \
        -c . \
        -f "$OUTPUTDIR/parchlinux-$IMAGE_VERSION.tar"

cd "$OUTPUTDIR"
xz -T0 -9 "parchlinux-$IMAGE_VERSION.tar"
mv -v "parchlinux-$IMAGE_VERSION.tar.xz" "parchlinux-$IMAGE_VERSION.wsl"
sha256sum "parchlinux-$IMAGE_VERSION.wsl" > "parchlinux-$IMAGE_VERSION.wsl.SHA256"
