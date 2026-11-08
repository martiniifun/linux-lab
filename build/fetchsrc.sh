# Corresponding source for every GPL/LGPL package in the image: aports dir at the exact commit + distfiles (sha512-checked).
# output: ~/v86/src/out/src-<origin>-<ver>.tar and ~/v86/src/out/SOURCES.txt
set -e
S=~/v86/src; mkdir -p $S/work $S/out; cd $S
{ grep -E 'GPL' ~/v86/idx/origins.txt | awk '{print $1, $2, $3, $4}' | sort -u
  echo "linux-lts 6.18.60-r0 97a4e7b01d88cdec22ef3a5d30247628dc14d8bc main"; } > list.txt
: > out/SOURCES.txt
while read o v c r; do
  d=work/$o; rm -rf $d; mkdir -p $d
  curl -sfL "https://gitlab.alpinelinux.org/alpine/aports/-/archive/$c/aports-$c.tar.gz?path=$r/$o" -o $d/aports.tgz
  tar xzf $d/aports.tgz -C $d; rm $d/aports.tgz
  A=$(echo $d/aports-*/$r/$o); mv $A $d/aports-$r-$o; rm -rf $d/aports-$c*
  # read source= and sha512sums= from the APKBUILD (official aports; evaluated in a subshell, functions are not run)
  ( cd $d/aports-$r-$o; CARCH=x86 CTARGET_ARCH=x86 CBUILD=i586-alpine-linux-musl CHOST=i586-alpine-linux-musl; . ./APKBUILD >/dev/null 2>&1
    for e in $source; do echo "$e"; done > ../srcs.txt; echo "$sha512sums" > ../sums.txt )
  mkdir -p $d/distfiles
  while read e; do
    case "$e" in *://*) ;; *) continue;; esac
    if [ "${e#*::}" != "$e" ]; then fn=${e%%::*}; url=${e#*::}; else url=$e; fn=${url##*/}; fi
    want=$(awk -v f="$fn" '$2==f{print $1}' $d/sums.txt)
    got=""; for u in https://distfiles.alpinelinux.org/distfiles/v3.24/$fn https://distfiles.alpinelinux.org/distfiles/edge/$fn "$url"; do
      if curl -sfL "$u" -o $d/distfiles/$fn && [ "$(sha512sum $d/distfiles/$fn | cut -d' ' -f1)" = "$want" ]; then got=$u; break; fi
    done
    if [ -z "$got" ]; then echo "FAILED $o $fn" | tee -a out/SOURCES.txt; else echo "$o $v $fn sha512=$want from=$got" >> out/SOURCES.txt; fi
  done < $d/srcs.txt
  echo "$o $v aports=$r/$o@$c" >> out/SOURCES.txt
  tar -cf out/src-$o-$v.tar -C $d aports-$r-$o distfiles
  echo "done $o $v $(du -h out/src-$o-$v.tar | cut -f1)"
done < list.txt
