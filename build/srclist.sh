# list origin, version, aports commit, repo for every package in the image (+ the kernel), with licence
set -e
cd ~/v86/idx
for r in main community; do curl -sf https://dl-cdn.alpinelinux.org/alpine/v3.24/$r/x86/APKINDEX.tar.gz -o $r.tgz; rm -rf $r; mkdir -p $r; tar xzf $r.tgz -C $r 2>/dev/null; done
{ sed -E 's/^(.*)-([^-]+-r[0-9]+) x86 .*/\1 \2/' ~/v86/out/v1/installed.txt; echo "linux-virt $(sed -E 's/linux-virt-(.*)\.apk/\1/' ~/v86/out/v1/kernel-apk.txt)"; } > want.txt
for r in main community; do awk -v R=$r 'BEGIN{RS="";FS="\n"} {n="";v="";o="";c="";l=""; for(i=1;i<=NF;i++){k=substr($i,1,2); x=substr($i,3); if(k=="P:")n=x; if(k=="V:")v=x; if(k=="o:")o=x; if(k=="c:")c=x; if(k=="L:")l=x} print n, v, o, c, R, l}' $r/APKINDEX; done > all.txt
awk 'NR==FNR{w[$1" "$2]=1; next} ($1" "$2) in w' want.txt all.txt > have.txt
echo "wanted $(wc -l < want.txt), found $(wc -l < have.txt)"
awk 'NR==FNR{h[$1" "$2]=1; next} !(($1" "$2) in h){print "MISSING", $0}' have.txt want.txt
# one line per origin
awk '{l=$6; for(i=7;i<=NF;i++) l=l" "$i; print $3, $2, $4, $5, l}' have.txt | sort -u > origins.txt
cat origins.txt
