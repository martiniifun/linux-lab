# NOTICE

`v1/state.bin.zst` is a memory snapshot of a running Linux system, so it contains (object code of) the software below.
Licence and copyright files of each package are in `LICENSES/packages/<origin>/`; full licence texts in `LICENSES/texts/`.
Corresponding source for every GPL/LGPL item is attached to release [v1](https://github.com/martiniifun/linux-lab/releases/tag/v1) as `src-<origin>-<version>.tar` (index: `SOURCES.txt`).
Some packages were installed only as dependencies and parts of them were removed from the image (apk-tools, ca-certificates, bash-completion); they are listed for completeness.

## Firmware

| Component | Version | Licence | Source |
| --- | --- | --- | --- |
| SeaBIOS (`v1/seabios.bin`), SeaVGABIOS (`v1/vgabios.bin`) | Ubuntu `seabios` 1.16.3-2 | LGPL-3.0 | release asset `src-seabios-1.16.3-2-ubuntu.tar` |

## Alpine Linux 3.24 packages (x86)

| Origin | Version | Licence (as declared by Alpine) | aports commit | Source in release v1 |
| --- | --- | --- | --- | --- |
| acl | 2.3.2-r1 | LGPL-2.1-or-later AND GPL-2.0-or-later | `8bac74716d06` | `src-acl-2.3.2-r1.tar` |
| alpine-baselayout | 3.7.2-r1 | GPL-2.0-only | `60a7585bbab2` | `src-alpine-baselayout-3.7.2-r1.tar` |
| alpine-base | 3.24.4-r0 | MIT | `105b835acd99` | - |
| alpine-keys | 2.6-r0 | MIT | `b9f23becced4` | - |
| apk-tools | 3.0.9-r0 | GPL-2.0-only | `13685e8f2cf1` | `src-apk-tools-3.0.9-r0.tar` |
| attr | 2.5.2-r2 | LGPL-2.1-or-later | `40760f1909b6` | `src-attr-2.5.2-r2.tar` |
| bash-completion | 2.17.0-r1 | GPL-2.0-or-later | `5fc8418c6904` | `src-bash-completion-2.17.0-r1.tar` |
| bash | 5.3.9-r1 | GPL-3.0-or-later | `1522c3193610` | `src-bash-5.3.9-r1.tar` |
| bc | 1.08.2-r1 | GPL-3.0-or-later | `a9e2a2dc46f3` | `src-bc-1.08.2-r1.tar` |
| busybox | 1.37.0-r31 | GPL-2.0-only | `c3ef5d10e6ef` | `src-busybox-1.37.0-r31.tar` |
| ca-certificates | 20261020-r0 | MPL-2.0 AND MIT | `e78f5987166c` | - |
| coreutils | 9.11-r0 | GPL-3.0-or-later | `8e261cdab4fd` | `src-coreutils-9.11-r0.tar` |
| diffutils | 3.12-r0 | GPL-3.0-or-later | `75d3777e6a0e` | `src-diffutils-3.12-r0.tar` |
| file | 5.47-r2 | BSD-2-Clause | `a05d36fa8641` | - |
| findutils | 4.10.0-r1 | GPL-3.0-or-later | `1a4e2ce63095` | `src-findutils-4.10.0-r1.tar` |
| gawk | 5.3.2-r2 | GPL-3.0-or-later | `730f2f5bdc97` | `src-gawk-5.3.2-r2.tar` |
| gettext | 1.0-r0 | LGPL-2.1-or-later | `a0b12dbf67fb` | `src-gettext-1.0-r0.tar` |
| grep | 3.12-r0 | GPL-3.0-or-later | `4cbb86a7e576` | `src-grep-3.12-r0.tar` |
| gzip | 1.15-r0 | GPL-3.0-or-later | `83633a158291` | `src-gzip-1.15-r0.tar` |
| jq | 1.8.2-r0 | MIT | `2437351bfa2a` | - |
| less | 702-r0 | GPL-3.0-or-later OR BSD-2-Clause | `58c8a1ed3dcf` | `src-less-702-r0.tar` |
| libbsd | 0.12.2-r0 | BSD-3-Clause | `02365e78d654` | - |
| libeconf | 0.8.3-r0 | MIT | `62db33049768` | - |
| libmd | 1.2.0-r0 | BSD-3-Clause AND BSD-2-Clause AND ISC AND Beerware AND Public Domain | `87b78bc68906` | - |
| linux-lts (kernel linux-virt) | 6.18.60-r0 | GPL-2.0-only | `97a4e7b01d88` | `src-linux-lts-6.18.60-r0.tar` |
| linux-pam | 1.7.1-r2 | BSD-3-Clause | `b30bac94ff81` | - |
| musl | 1.2.6-r3 | MIT ; MIT AND BSD-2-Clause AND GPL-2.0-or-later | `8f79d39391b4` | `src-musl-1.2.6-r3.tar` |
| nano | 9.3-r0 | GPL-3.0-or-later | `8f82aba1fb0e` | `src-nano-9.3-r0.tar` |
| ncurses | 6.6_p20260516-r0 | X11 | `2cee8a7328d0` | - |
| oniguruma | 6.9.10-r0 | BSD-2-Clause | `31082e89063d` | - |
| openssl | 3.5.9-r0 | Apache-2.0 | `29b9ec24b1b5` | - |
| pax-utils | 1.3.9-r1 | GPL-2.0-only | `c61801eeacb3` | `src-pax-utils-1.3.9-r1.tar` |
| pcre2 | 10.49-r0 | BSD-3-Clause | `3d497cbb3217` | - |
| pixman | 0.46.4-r0 | MIT | `9337ac809a43` | - |
| procps-ng | 4.0.6-r0 | GPL-2.0-or-later AND LGPL-2.1-or-later | `99d7511b57e5` | `src-procps-ng-4.0.6-r0.tar` |
| psmisc | 23.7-r0 | GPL-2.0-or-later | `8a69d460b397` | `src-psmisc-23.7-r0.tar` |
| readline | 8.3.3-r1 | GPL-3.0-or-later | `a854c03acdac` | `src-readline-8.3.3-r1.tar` |
| sed | 4.9-r2 | GPL-3.0-or-later | `84a227baf001` | `src-sed-4.9-r2.tar` |
| shadow | 4.18.0-r1 | BSD-3-Clause | `20f03e3dc807` | - |
| skalibs | 2.15.0.0-r0 | ISC | `f148233038fa` | - |
| sqlite | 3.53.4-r0 | blessing | `a9c3ba8b9129` | - |
| sudo | 1.9.17_p2-r2 | custom ISC | `231b3edb78d9` | - |
| tar | 1.35-r5 | GPL-3.0-or-later | `a9e2a2dc46f3` | `src-tar-1.35-r5.tar` |
| tree | 2.3.2-r0 | GPL-2.0-or-later | `429bf8299b27` | `src-tree-2.3.2-r0.tar` |
| util-linux | 2.42.3-r1 | BSD-2-Clause ; BSD-3-Clause ; GPL-2.0-or-later ; GPL-2.0-or-later AND BSD-1-Clause ; GPL-3.0-or-later AND GPL-2.0-or-later AND GPL-2.0-only AND GPL-1.0-only AND LGPL-2.1-or-later AND BSD-1-Clause AND BSD-3-Clause AND BSD-4-Clause-UC AND MIT AND Public-Domain | `d98c55af5905` | `src-util-linux-2.42.3-r1.tar` |
| utmps | 0.1.3.3-r0 | ISC | `900a4ecef77a` | - |
| vim | 9.2.1202-r0 | Vim | `8dda40f62186` | - |
| which | 2.23-r0 | GPL-2.0-or-later | `183087ae9c60` | `src-which-2.23-r0.tar` |
| xz | 5.8.4-r0 | GPL-2.0-or-later AND 0BSD AND Public-Domain AND LGPL-2.1-or-later | `0c088d609f9f` | `src-xz-5.8.4-r0.tar` |
| zlib | 1.3.2-r1 | Zlib | `0afa2da0e8c8` | - |

## Used by the web page (not in this repository)

- v86 0.5.472 (BSD-2-Clause; includes zstd decoder, BSD) — `LICENSES/web/v86-LICENSE.txt`
- xterm.js 5.5.0 (MIT) — `LICENSES/web/xterm.js-LICENSE.txt`

## Files added by this project

- `/home/seoyun/.bashrc`, `.profile`, `.bash_logout`: copied from Ubuntu 24.04 `/etc/skel` (bash package examples, GPL-3.0-or-later).
- `/home/seoyun/saebyeok/handover/`, `/init`, `/etc/inittab`: written for this course (MIT, see `LICENSES/MIT-this-repo.txt`).
