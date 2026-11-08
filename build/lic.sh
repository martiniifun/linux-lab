# collect licence/copyright files for every origin in the image into ~/v86/notices/by-origin/<origin>/
set -e
S=~/v86/src; L=~/v86/notices/by-origin; rm -rf $L; mkdir -p $L $S/perm
awk '{print $1, $2, $3, $4}' ~/v86/idx/origins.txt | sort -u > /tmp/all-origins
echo "zlib 1.3.2-r1 0afa2da0e8c8051c6f8f64a7a388e5a259904245 main" >> /tmp/all-origins
echo "linux-lts 6.18.60-r0 97a4e7b01d88cdec22ef3a5d30247628dc14d8bc main" >> /tmp/all-origins
while read o v c r; do
  d=$S/work/$o
  if [ ! -d $d/distfiles ]; then  # permissive package: fetch the same way, only to read its licence
    d=$S/perm/$o; rm -rf $d; mkdir -p $d/distfiles
    curl -sfL "https://gitlab.alpinelinux.org/alpine/aports/-/archive/$c/aports-$c.tar.gz?path=$r/$o" -o $d/a.tgz; tar xzf $d/a.tgz -C $d; rm $d/a.tgz
    A=$(echo $d/aports-$c*/$r/$o); mv $A $d/aports-$r-$o; rm -rf $d/aports-$c*
    ( cd $d/aports-$r-$o; CARCH=x86; . ./APKBUILD >/dev/null 2>&1; for e in $source; do echo "$e"; done > ../srcs.txt; echo "$sha512sums" > ../sums.txt )
    while read e; do case "$e" in *://*) ;; *) continue;; esac
      if [ "${e#*::}" != "$e" ]; then fn=${e%%::*}; url=${e#*::}; else url=$e; fn=${url##*/}; fi
      case "$fn" in *.tar*|*.tgz|*.zip) ;; *) continue;; esac
      want=$(awk -v f="$fn" '$2==f{print $1}' $d/sums.txt)
      for u in https://distfiles.alpinelinux.org/distfiles/v3.24/$fn https://distfiles.alpinelinux.org/distfiles/edge/$fn "$url"; do
        curl -sfL "$u" -o $d/distfiles/$fn && [ "$(sha512sum $d/distfiles/$fn | cut -d' ' -f1)" = "$want" ] && break; rm -f $d/distfiles/$fn
      done; break
    done < $d/srcs.txt
  fi
  mkdir -p $L/$o
  t=$(ls $d/distfiles/*.tar* $d/distfiles/*.tgz 2>/dev/null | grep -v -E 'patch|\.sig$|\.asc$' | head -1 || true)
  if [ -n "$t" ]; then
    if [ "$o" = linux-lts ]; then pat='*/COPYING */LICENSES/preferred/GPL-2.0 */LICENSES/exceptions/Linux-syscall-note'; else pat='*COPYING* *LICENSE* *LICENCE* *COPYRIGHT* *NOTICE* *Copyright*'; fi
    tar -tf $t 2>/dev/null | awk -F/ 'NF<=3' | grep -E '/(COPYING|LICEN[CS]E|COPYRIGHT|NOTICE|Copyright)[^/]*$|LICENSES/preferred/GPL-2.0$|Linux-syscall-note$' | grep -v -E '/(po|tests?)/' > /tmp/lf || true
    [ -s /tmp/lf ] && tar -xf $t -C $L/$o -T /tmp/lf 2>/dev/null || true
  fi
  # licence files kept in aports itself (e.g. alpine-keys, alpine-baselayout, sudo)
  for f in $d/aports-$r-$o/LICENSE* $d/aports-$r-$o/COPYING*; do [ -f "$f" ] && cp "$f" $L/$o/; done
  n=$(find $L/$o -type f | wc -l); echo "$o $v files=$n src=$(basename "${t:-none}")"
done < /tmp/all-origins
