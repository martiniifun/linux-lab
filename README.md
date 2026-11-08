# linux-lab

**한국어** · [English](#english)

ReflexKR 강의 「서버 '새벽'의 일 년」의 **자유 연습장**에서 쓰는 리눅스 이미지입니다.
독자가 강의 페이지에서 '진짜 리눅스 켜기'를 누르면, 브라우저 안의 x86 에뮬레이터 [v86](https://github.com/copy/v86)이
이 저장소의 파일을 내려받아 리눅스를 켭니다. 서버에서 돌아가는 것은 없습니다. 무엇을 지워도 독자의 컴퓨터는 멀쩡합니다.

## 들어 있는 것

| 파일 | 크기 | 설명 |
| --- | --- | --- |
| `v1/state.bin.zst` | 18.9MB | 부팅과 로그인을 마친 직후의 v86 저장 상태(zstd). 메모리 256MB. 켜면 0.5–1초 안에 프롬프트가 뜹니다 |
| `v1/seabios.bin` | 128KB | SeaBIOS 1.16.3 (우분투 `seabios` 1.16.3-2 패키지의 `bios.bin`) |
| `v1/vgabios.bin` | 39KB | SeaVGABIOS (같은 패키지의 `vgabios-stdvga.bin`) |
| `v1/SHA256SUMS` | | 위 파일의 SHA-256 |

이미지 안:

- Alpine Linux 3.24 (x86, 32비트), 커널 `linux-virt` 6.18.60. 루트 파일 시스템 전체가 메모리(initramfs)에 있습니다. 네트워크는 없습니다.
- GNU 도구: bash 5.3, coreutils 9.11, grep 3.12, sed 4.9, gawk 5.3, findutils 4.10, diffutils, tar, gzip, xz, less, nano, vim, procps-ng, psmisc, util-linux(su, mount, dmesg 등), which, file, tree, sudo, bc, jq.
  - 정확한 패키지와 버전: [`build/installed.txt`](build/installed.txt).
- 사용자 `seoyun`, 호스트 `seoyun-note`, `LANG=C.UTF-8`. 비밀번호 없이 `sudo`가 됩니다.
  - 홈의 `.bashrc`, `.profile`은 우분투 24.04의 `/etc/skel`과 같습니다.
- `~/saebyeok/handover/`: 이야기 속 인수인계 폴더의 작은 복사본. 노트, nginx 접속 기록 200줄, 사진, 출석부, 스크립트가 들어 있습니다.

우분투와 다른 점:

- C 라이브러리가 musl입니다.
- `apt`가 없습니다.
- `/bin/sh`는 busybox ash입니다.
- 몇몇 명령(hostname, hexdump, strings, crontab 등)은 busybox 판입니다.

## 쓰는 법 (v86 0.5.472)

```js
const emulator = new V86({
  wasm_path: "https://cdn.jsdelivr.net/npm/v86@0.5.472/build/v86.wasm",
  memory_size: 256 * 1024 * 1024,
  bios: { url: "https://martiniifun.github.io/linux-lab/v1/seabios.bin" },
  vga_bios: { url: "https://martiniifun.github.io/linux-lab/v1/vgabios.bin" },
  initial_state: { url: "https://martiniifun.github.io/linux-lab/v1/state.bin.zst" },
  autostart: true,
});
// 직렬 콘솔(ttyS0)에 셸이 있습니다. 한글은 UTF-8 바이트로 보내세요:
emulator.serial_send_bytes(0, new TextEncoder().encode("ls\n"));
emulator.add_listener("serial0-output-byte", (b) => term.write(Uint8Array.of(b)));
```

저장 상태는 v86 버전에 묶여 있습니다. v86을 바꾸면 `v2/`로 새로 만듭니다.

## 만드는 법

[`build/`](build/)의 스크립트를 우분투 24.04(WSL)에서 돌렸습니다.

1. `fetch.sh`: Alpine 미니 루트 파일 시스템(sha256 확인)과 `apk-tools-static`을 받습니다.
2. `TRIM=1 TRIM2=1 build.sh v1 $(cat packages.txt)`: 패키지를 넣고, 사용자·홈(`mkhome.sh`)을 만들고, initramfs(`initrd.cpio.gz`)를 묶습니다.
   - `apk.static`의 서명은 Alpine 키로 확인합니다.
   - 쓰지 않는 것(apk, vim 문서와 대부분의 문법 파일, bash-completion)은 뺍니다.
3. `build/state/`의 시험 페이지로 v86에서 부팅합니다.
   - 커널 명령줄: `console=ttyS0 quiet loglevel=3 init_on_free=1 tsc=reliable mitigations=off random.trust_cpu=on`
   - 그다음 `cd ~; clear` 뒤에 `save_state()`로 상태를 저장하고 `zstd -19`로 압축합니다.

커널(`vmlinuz-virt`)과 initramfs는 릴리스 [v1](https://github.com/martiniifun/linux-lab/releases/tag/v1)에 있습니다.

## 라이선스

이 저장소의 스크립트와 문서는 MIT 라이선스입니다([`LICENSES/MIT-this-repo.txt`](LICENSES/MIT-this-repo.txt)).
이미지 안의 소프트웨어는 각자의 라이선스를 따릅니다.

- **GPL-2.0**: Linux 커널, busybox 등.
- **GPL-3.0**: bash, coreutils, grep, sed, gawk, findutils 등.
- **LGPL**: SeaBIOS(LGPL-3.0), acl, attr 등.
- **MIT, BSD, ISC 등**: musl, ncurses, openssl(Apache-2.0), sudo, vim, …
- 패키지별 목록과 고지문은 [`NOTICE.md`](NOTICE.md)와 [`LICENSES/`](LICENSES/)에 있습니다.

**소스 받기:** GPL·LGPL 소프트웨어의 대응 소스는 릴리스 [v1](https://github.com/martiniifun/linux-lab/releases/tag/v1)의 첨부 파일에 있습니다.

- 패키지마다 정확한 커밋의 Alpine aports 빌드 스크립트와 패치(커널 config 포함), 그리고 원본 소스 묶음(sha512 확인)이 들어 있습니다.
- 우분투 `seabios` 1.16.3-2 소스 패키지도 있습니다.
- 목록과 출처는 `SOURCES.txt`에 있습니다.

---

## English

Linux image for the **free-practice terminal** of the ReflexKR course 「서버 '새벽'의 일 년」 ("A year with the server *Saebyeok*").
When a reader presses "turn on real Linux", the in-browser x86 emulator [v86](https://github.com/copy/v86) downloads the files in this repository and runs Linux entirely in the browser; nothing runs on a server.

**Files:**
- `v1/state.bin.zst` (18.9 MB): a v86 saved state taken right after boot and login, with 256 MB RAM.
- `v1/seabios.bin` and `v1/vgabios.bin`: SeaBIOS/SeaVGABIOS from Ubuntu's `seabios` 1.16.3-2 package.

**Guest:**
- Alpine Linux 3.24 x86 with kernel `linux-virt` 6.18.60, running from an initramfs. There is no network.
- GNU userland: bash, coreutils, grep, sed, gawk, findutils, util-linux, vim, nano, less, …
- User `seoyun` on host `seoyun-note`, with `LANG=C.UTF-8`.
- Ubuntu 24.04 skeleton dotfiles, and a small story folder in `~/saebyeok/handover/`.
- Exact package versions: `build/installed.txt`.

**Build:** see `build/` (Ubuntu 24.04, `fetch.sh`, then `TRIM=1 TRIM2=1 build.sh v1 $(cat packages.txt)`, then boot in v86 and `save_state()` after `cd ~; clear`, then `zstd -19`).

**Licences:**
- Scripts and docs in this repo: MIT.
- Software inside the image: each package's own licence. See `NOTICE.md` and `LICENSES/`.
- Corresponding source for all GPL/LGPL components is attached to release **v1**. It contains:
  - Alpine aports at the exact commits, with patches and the kernel config;
  - the upstream tarballs, sha512-verified;
  - Ubuntu's `seabios` 1.16.3-2 source package;
  - an index in `SOURCES.txt`.
