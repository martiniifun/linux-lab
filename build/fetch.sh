set -e
V=3.24; R=3.24.4; B=https://dl-cdn.alpinelinux.org/alpine/v$V
mkdir -p ~/v86/dl && cd ~/v86/dl
for f in alpine-minirootfs-$R-x86.tar.gz alpine-minirootfs-$R-x86.tar.gz.sha256; do [ -f $f ] || curl -sfO $B/releases/x86/$f; done
sha256sum -c alpine-minirootfs-$R-x86.tar.gz.sha256
[ -f apk-tools-static-3.0.9-r0.apk ] || curl -sfO $B/main/x86_64/apk-tools-static-3.0.9-r0.apk
mkdir -p apkstatic && tar xzf apk-tools-static-3.0.9-r0.apk -C apkstatic 2>/dev/null || true
ls -la apkstatic/sbin
file apkstatic/sbin/apk.static || true
which cpio zstd xz file || sudo apt-get install -y cpio zstd xz-utils file >/dev/null
grep -i ia32 /proc/config.gz 2>/dev/null || zcat /proc/config.gz 2>/dev/null | grep IA32_EMU || echo noconfig
