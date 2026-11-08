# licence/notice files for every package in the image, from Alpine's -doc packages (usr/share/licenses/<pkg>/)
set -e
L=~/v86/notices; rm -rf $L; mkdir -p $L/apk $L/licenses
cd ~/v86/idx
awk '{print $1}' origins.txt | sort -u > /tmp/origins
# candidate doc package for each origin: <origin>-doc at the same version (index lines: name ver origin commit repo lic)
while read o; do
  awk -v O="$o" '$3==O && $1 ~ /-doc$/ {print $1, $2, $5}' all.txt | sort -u
done < /tmp/origins > $L/docpkgs.txt
while read n v r; do
  f=$n-$v.apk; curl -sf https://dl-cdn.alpinelinux.org/alpine/v3.24/$r/x86/$f -o $L/apk/$f || { echo "nodl $f"; continue; }
  tar xzf $L/apk/$f -C $L/licenses --wildcards 'usr/share/licenses/*' 2>/dev/null || true
done < $L/docpkgs.txt
ls $L/licenses/usr/share/licenses/ 2>/dev/null | tr '\n' ' '; echo
echo "origins without licence files:"; for o in $(cat /tmp/origins); do ls -d $L/licenses/usr/share/licenses/$o* >/dev/null 2>&1 || echo -n "$o "; done; echo
