# Playwright driver for the v86 pilot page.
# usage: drive.py <query> [--throttle N] [--save NAME] [--bench] [--shot PATH] [--cmds]
import argparse, json, sys, time
from playwright.sync_api import sync_playwright

ap = argparse.ArgumentParser()
ap.add_argument("query")
ap.add_argument("--throttle", type=float, default=1)
ap.add_argument("--save")
ap.add_argument("--bench", action="store_true")
ap.add_argument("--shot")
ap.add_argument("--cmds", action="store_true")
ap.add_argument("--timeout", type=int, default=300)
ap.add_argument("--wait", default="prompt")
ap.add_argument("--reset", action="store_true")
a = ap.parse_args()

BENCH = [
    ("echo", "echo hi; echo __D\"\"__", "__D__\r\n"),
    ("ls_usr_bin", "ls -la /usr/bin | wc -l; echo __D\"\"__", "__D__\r\n"),
    ("grep_log", "grep -c ERROR ~/인수인계/app.log; echo __D\"\"__", "__D__\r\n"),
    ("seq_awk_100k", "seq 1 100000 | awk '{s+=$1} END{print s}'; echo __D\"\"__", "__D__\r\n"),
    ("find_sed_sort", "find /usr -type f | sed 's#.*/##' | sort | uniq | wc -l; echo __D\"\"__", "__D__\r\n"),
    ("bash_loop_10k", "time (i=0; while [ $i -lt 10000 ]; do i=$((i+1)); done); echo __D\"\"__", "__D__\r\n"),
]
CMDS = [
    "ls -ld / /backup /tmp /home /root /etc; stat -c %U:%a /",
    "id; hostname; echo $LANG; pwd; type ll; ls",
    "cd ~/saebyeok/handover && ls -la && cat README.txt && wc -l logs/access.log && cut -d' ' -f9 logs/access.log | sort | uniq -c",
    "ls -l photos/2025; file photos/2025/mt-01.jpg; column -s, -t attendance/members.csv; bin/backup.sh; echo rc=$?",
    "su -c id root < /dev/null; sudo id; which ls; dmesg | tail -1; mount | head -2; ls /mnt; cd ~",
]

with sync_playwright() as p:
    b = p.chromium.launch(channel="chrome")
    pg = b.new_page(viewport={"width": 1000, "height": 700})
    logs = []
    pg.on("console", lambda m: logs.append(m.text))
    pg.on("pageerror", lambda e: logs.append("PAGEERROR " + str(e)))
    cdp = pg.context.new_cdp_session(pg)
    if a.throttle != 1:
        cdp.send("Emulation.setCPUThrottlingRate", {"rate": a.throttle})
    t = time.time()
    pg.goto("http://127.0.0.1:8138/index.html?" + a.query)
    res = {"query": a.query, "throttle": a.throttle}
    try:
        pg.wait_for_function(f"window.T && window.T.{a.wait} !== undefined", timeout=a.timeout * 1000, polling=50)
    except Exception as e:
        res["error"] = "no prompt: " + str(e)[:200]
        res["tail"] = pg.evaluate("window.out ? window.out.slice(-1500) : ''")
    res["T"] = pg.evaluate("window.T")
    res["transfer"] = pg.evaluate("""performance.getEntriesByType('resource').map(r => [r.name.split('/').slice(-2).join('/'), r.transferSize, Math.round(r.duration)])""")
    if "error" not in res:
        pg.wait_for_timeout(300)
        if a.cmds:
            res["cmds"] = []
            for c in CMDS:
                r = pg.evaluate("([c]) => window.sendAndWait(c + '; echo __D\"\"__', '__D__\\r\\n')", [c])
                res["cmds"].append(r["out"])
        if a.bench:
            res["bench"] = {}
            for name, c, m in BENCH:
                r = pg.evaluate("([c, m]) => window.sendAndWait(c, m)", [c, m])
                res["bench"][name] = r["ms"]
                if name in ("bash_loop_10k", "seq_awk_100k", "find_sed_sort"):
                    res["bench"][name + "_out"] = r["out"].strip().splitlines()[-3:]
        if a.reset:
            res["reset_ms"] = [pg.evaluate("""async () => { const s = await emulator.save_state(); const t = performance.now(); await emulator.restore_state(s); const ms = performance.now() - t; await window.sendAndWait('echo ok$((1+1))', 'ok2'); return [Math.round(ms), Math.round(performance.now() - t)]; }""") for _ in range(3)]
        if a.save:
            # settle: drop caches & clear screen so the restored state starts clean
            pg.evaluate("() => window.sendAndWait(\"cd ~; history -c; sync; sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches' 2>/dev/null; clear; echo __D''__\", '__D__\\r\\n')")
            pg.evaluate("() => window.sendAndWait('clear', '$ ')")
            pg.wait_for_timeout(500)
            res["save"] = pg.evaluate("([n]) => window.saveState(n)", [a.save])
    if a.shot:
        pg.screenshot(path=a.shot)
    res["logs"] = logs[-15:]
    b.close()
print(json.dumps(res, ensure_ascii=False, indent=1))
