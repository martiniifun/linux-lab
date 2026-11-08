# fill LICENSES/ and NOTICE.md in the repo
set -e
R=$1; L=$R/LICENSES
rm -rf $L; mkdir -p $L/packages $L/texts
cp -r ~/v86/notices/by-origin/. $L/packages/
find $L/packages -type d -empty -delete
for t in GPL-2 GPL-3 LGPL-2.1 LGPL-3 Apache-2.0; do cp /usr/share/common-licenses/$t $L/texts/$t.txt; done
mkdir -p $L/packages/seabios; tar xzf ~/v86/src/seabios/seabios_1.16.3.orig.tar.gz -C /tmp; cp /tmp/seabios-1.16.3/COPYING /tmp/seabios-1.16.3/COPYING.LESSER $L/packages/seabios/ 2>/dev/null || ls /tmp/seabios-1.16.3 | head
NPM=/mnt/c/Users/user/AppData/Local/Temp/claude/c--Users-user-ReflexProjects-reflexkr/a2b0f334-abf0-4f46-837e-b598184cd653/scratchpad/v86
mkdir -p $L/web; cp $NPM/npm/pkg/package/LICENSE $L/web/v86-LICENSE.txt; cp $NPM/xterm/package/LICENSE $L/web/xterm.js-LICENSE.txt
cat > $L/MIT-this-repo.txt <<'T'
MIT License

Copyright (c) 2026 BlueGrass Studio (ReflexKR)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
T
{
echo "# NOTICE"
echo
echo "\`v1/state.bin.zst\` is a memory snapshot of a running Linux system, so it contains (object code of) the software below."
echo "Licence and copyright files of each package are in \`LICENSES/packages/<origin>/\`; full licence texts in \`LICENSES/texts/\`."
echo "Corresponding source for every GPL/LGPL item is attached to release [v1](https://github.com/martiniifun/linux-lab/releases/tag/v1) as \`src-<origin>-<version>.tar\` (index: \`SOURCES.txt\`)."
echo "Some packages were installed only as dependencies and parts of them were removed from the image (apk-tools, ca-certificates, bash-completion); they are listed for completeness."
echo
echo "## Firmware"
echo
echo "| Component | Version | Licence | Source |"
echo "| --- | --- | --- | --- |"
echo "| SeaBIOS (\`v1/seabios.bin\`), SeaVGABIOS (\`v1/vgabios.bin\`) | Ubuntu \`seabios\` 1.16.3-2 | LGPL-3.0 | release asset \`src-seabios-1.16.3-2-ubuntu.tar\` |"
echo
echo "## Alpine Linux 3.24 packages (x86)"
echo
echo "| Origin | Version | Licence (as declared by Alpine) | aports commit | Source in release v1 |"
echo "| --- | --- | --- | --- | --- |"
awk '{o=$1; v=$2; c=$3; l=$5; for(i=6;i<=NF;i++) l=l" "$i; if(!(o in L)) {L[o]=l; V[o]=v; C[o]=c} else if (index(L[o], l)==0) L[o]=L[o]" ; "l} END{for(o in L) print o"|"V[o]"|"L[o]"|"C[o]}' ~/v86/idx/origins.txt > /tmp/o.txt
echo "zlib|1.3.2-r1|Zlib|0afa2da0e8c8051c6f8f64a7a388e5a259904245" >> /tmp/o.txt
echo "linux-lts (kernel linux-virt)|6.18.60-r0|GPL-2.0-only|97a4e7b01d88cdec22ef3a5d30247628dc14d8bc" >> /tmp/o.txt
sort /tmp/o.txt | while IFS='|' read o v l c; do
  b=${o%% *}; f="-"; [ -f ~/v86/src/out/src-$b-$v.tar ] && f="\`src-$b-$v.tar\`"
  echo "| $o | $v | $l | \`${c:0:12}\` | $f |"
done
echo
echo "## Used by the web page (not in this repository)"
echo
echo "- v86 0.5.472 (BSD-2-Clause; includes zstd decoder, BSD) — \`LICENSES/web/v86-LICENSE.txt\`"
echo "- xterm.js 5.5.0 (MIT) — \`LICENSES/web/xterm.js-LICENSE.txt\`"
echo
echo "## Files added by this project"
echo
echo "- \`/home/seoyun/.bashrc\`, \`.profile\`, \`.bash_logout\`: copied from Ubuntu 24.04 \`/etc/skel\` (bash package examples, GPL-3.0-or-later)."
echo "- \`/home/seoyun/saebyeok/handover/\`, \`/init\`, \`/etc/inittab\`: written for this course (MIT, see \`LICENSES/MIT-this-repo.txt\`)."
} > $R/NOTICE.md
cp ~/v86/src/out/SOURCES.txt $R/build/SOURCES.txt
find $L -type f | wc -l; du -sh $L
