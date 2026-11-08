# usage: build.sh <name> <packages...>   -> ~/v86/out/<name>/{vmlinuz-virt,initrd.*}
set -e
NAME=$1; shift; PKGS="$*"
V=3.24; R=3.24.4; B=https://dl-cdn.alpinelinux.org/alpine/v$V
DL=~/v86/dl; W=~/v86/work/$NAME; O=~/v86/out/$NAME
APK=$DL/apkstatic/sbin/apk.static
sudo rm -rf $W; mkdir -p $W/root $O
sudo tar xzf $DL/alpine-minirootfs-$R-x86.tar.gz -C $W/root
# verify apk.static with the key shipped in the (checksum-verified) minirootfs
openssl dgst -sha256 -verify $W/root/usr/share/apk/keys/alpine-devel@lists.alpinelinux.org-6165ee59.rsa.pub \
  -signature $DL/apkstatic/sbin/apk.static.SIGN.RSA.sha256.alpine-devel@lists.alpinelinux.org-6165ee59.rsa.pub $APK
printf '%s\n' $B/main $B/community | sudo tee $W/root/etc/apk/repositories >/dev/null
sudo mount --bind /proc $W/root/proc || true
sudo cp /etc/resolv.conf $W/root/etc/resolv.conf
sudo $APK --root $W/root --arch x86 -U add $PKGS 2>&1 | tail -3
sudo umount $W/root/proc || true
# kernel: extract linux-virt apk separately (only the bzImage; no modules needed for initramfs root)
if [ ! -f $DL/kernel/boot/vmlinuz-virt ]; then
  mkdir -p $DL/kernel; KV=$(curl -s $B/main/x86/ | grep -oE 'linux-virt-[0-9][^"<]*\.apk' | sort -uV | tail -1)
  curl -sfo $DL/$KV $B/main/x86/$KV; tar xzf $DL/$KV -C $DL/kernel 2>/dev/null || true
fi
cp $DL/kernel/boot/vmlinuz-virt $O/; (cd $DL; ls linux-virt-*.apk) > $O/kernel-apk.txt
cp $DL/kernel/boot/config-virt $O/ 2>/dev/null || true
# --- customise the guest ---
R0=$W/root
sudo tee $R0/init >/dev/null <<'EOI'
#!/bin/sh
mount -t proc proc /proc; mount -t sysfs sys /sys; mount -t devtmpfs dev /dev 2>/dev/null
mkdir -p /dev/pts /dev/shm; mount -t devpts devpts /dev/pts; mount -t tmpfs tmpfs /dev/shm; mount -t tmpfs -o mode=1777 tmpfs /tmp
chmod 755 /   # the kernel creates the initramfs root as 1777
hostname seoyun-note
exec /sbin/init
EOI
sudo chmod 755 $R0/init
sudo tee $R0/etc/inittab >/dev/null <<'EOI'
ttyS0::respawn:/bin/busybox login -f seoyun
tty1::respawn:/bin/busybox login -f seoyun
::ctrlaltdel:/sbin/reboot
::shutdown:/bin/umount -a -r
EOI
echo seoyun-note | sudo tee $R0/etc/hostname >/dev/null
sudo chroot $R0 /bin/sh -c 'adduser -D -s /bin/bash -g "Seoyun" seoyun; passwd -d root >/dev/null; passwd -d seoyun >/dev/null' || true
if [ -x $R0/usr/bin/sudo ]; then echo 'seoyun ALL=(ALL) NOPASSWD: ALL' | sudo tee $R0/etc/sudoers.d/seoyun >/dev/null; fi
sudo tee $R0/etc/profile.d/v86.sh >/dev/null <<'EOI'
export LANG=C.UTF-8 LC_ALL=C.UTF-8 TERM=xterm-256color PAGER=less EDITOR=nano
EOI
sudo truncate -s 0 $R0/etc/motd
# Ubuntu 24.04's /etc/skel (from the saebyeok-lab distro) so the prompt and aliases (ll, la, l) match the course
sudo cp /etc/skel/.bashrc /etc/skel/.profile /etc/skel/.bash_logout $R0/home/seoyun/
# the handover folder from the story (docs/plans/linux-facts.md section 2), generated deterministically
HERE=$(dirname "$(readlink -f "$0")")
T=$(mktemp -d); bash $HERE/mkhome.sh $T; sudo cp -a $T/saebyeok $R0/home/seoyun/; rm -rf $T
sudo chroot $R0 chown -R seoyun:seoyun /home/seoyun
sudo chroot $R0 apk info -s $PKGS 2>/dev/null | paste - - - | awk '{print $1, $(NF-1), $NF}' > $O/pkgsizes.txt || true
sudo chroot $R0 apk list -I 2>/dev/null > $O/installed.txt || true
sudo cp $O/installed.txt $R0/etc/installed-packages.txt
# trim: no network in the guest, so the package manager and TLS libs are dead weight (unless something else links them)
if [ "$TRIM" = 1 ]; then
  sudo rm -rf $R0/sbin/apk $R0/usr/sbin/apk $R0/lib/apk $R0/usr/lib/apk $R0/lib/libapk* $R0/usr/lib/libapk* $R0/etc/apk $R0/usr/share/apk $R0/bin/ssl_client $R0/usr/bin/ssl_client $R0/etc/ssl* $R0/usr/share/ca-certificates
  USERS=$(sudo chroot $R0 scanelf -nRqF '%F %n' /bin /sbin /usr/bin /usr/sbin /lib /usr/lib /usr/libexec 2>/dev/null | grep -E 'libssl|libcrypto' | grep -vE '/lib(ssl|crypto)\.so' || true)
  if [ -z "$USERS" ]; then sudo rm -f $R0/lib/libcrypto.so* $R0/lib/libssl.so* $R0/usr/lib/libcrypto.so* $R0/usr/lib/libssl.so*; echo "removed openssl libs"
  else echo "kept openssl libs, linked by: $USERS"; fi
  sudo rm -rf $R0/usr/share/vim/vim*/doc $R0/usr/share/vim/vim*/spell $R0/usr/share/vim/vim*/tutor $R0/usr/share/vim/vim*/lang $R0/usr/share/locale $R0/usr/share/bash-completion/completions/[!a-z]* 2>/dev/null || true
fi
if [ "$TRIM2" = 1 ]; then  # slimmer: vim keeps only a few syntax files, no bash-completion, vi -> vim
  V=$(ls -d $R0/usr/share/vim/vim9*); sudo find $V/syntax -type f ! -name 'sh.vim' ! -name 'bash.vim' ! -name 'conf.vim' ! -name 'python.vim' ! -name 'syntax.vim' ! -name 'synload.vim' ! -name 'syncolor.vim' ! -name 'nosyntax.vim' ! -name 'manual.vim' ! -name 'vim.vim' ! -name 'c.vim' ! -name 'markdown.vim' ! -name 'html.vim' ! -name 'css.vim' ! -name 'javascript.vim' ! -name 'yaml.vim' ! -name 'json.vim' ! -name 'awk.vim' ! -name 'sed.vim' ! -name 'crontab.vim' ! -name 'sshconfig.vim' ! -name 'gitcommit.vim' ! -name 'diff.vim' -delete
  sudo rm -rf $V/ftplugin $V/indent $V/autoload/dist/vimhelp* $V/pack $V/import $V/compiler $V/keymap $V/print $V/macros $V/colors/tools $R0/usr/share/bash-completion
  sudo ln -sf /usr/bin/vim $R0/usr/bin/vi; sudo ln -sf /usr/bin/vim $R0/bin/vi
fi
# trim: apk cache, docs
sudo rm -rf $R0/var/cache/apk/* $R0/usr/share/man $R0/usr/share/doc $R0/usr/share/info $R0/etc/resolv.conf
sudo du -sh $R0 | tee $O/rootfs-du.txt
cd $R0 && sudo find . -mindepth 1 | sudo cpio -o -H newc --quiet > $O/initrd.cpio
cd $O; gzip -9 -k -f initrd.cpio; zstd -19 -q -f initrd.cpio -o initrd.cpio.zst; xz -9e -k -f --check=crc32 initrd.cpio
ls -la $O
