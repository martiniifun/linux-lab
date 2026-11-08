# usage: mkhome.sh <dir>  -> writes <dir>/saebyeok/handover (deterministic; same bytes every run)
set -e
H=$1/saebyeok/handover
rm -rf "$1/saebyeok"; mkdir -p $H/notes $H/logs $H/photos/2024 $H/photos/2025 $H/attendance $H/bin
cat > $H/README.txt <<'T'
새벽 인수인계

먼저 네 컴퓨터에서 익숙해져. 진짜 서버는 그다음에. — 이안

여기 든 것:
  notes/       내 노트. start.txt부터 읽어.
  logs/        서버 로그 복사본.
  photos/      동아리 사진. 해마다 폴더 하나.
  attendance/  출석부.
  bin/         내가 쓰던 스크립트.

천천히 해. 급할 거 없어.
T
cat > $H/notes/start.txt <<'T'
처음 할 일
1. 터미널 열고 pwd, ls부터 쳐 봐.
2. 모르는 명령은 --help 또는 man.
3. 지우기 전에 한 번 더 봐. rm에는 휴지통이 없어.
T
cat > $H/notes/server.txt <<'T'
새벽 (동아리방 307호 책장 위 미니 PC)
- 우분투 서버 24.04
- nginx: 동아리 홈페이지
- 출석부 봇: 파이썬
- 사진첩: /srv/photos
T
cat > $H/notes/backup.txt <<'T'
백업
- bin/backup.sh 가 홈페이지와 사진을 묶어서 /backup 에 둬.
- 일주일에 한 번은 백업 파일이 진짜 풀리는지 확인해.
T
# access.log: 200 lines, nginx combined, fixed pseudo-random sequence (LCG), 2025-12-28 .. 2026-01-03 KST
awk 'BEGIN{
  s=20260103; split("203.0.113.7 203.0.113.42 198.51.100.23 198.51.100.88 192.0.2.15 192.0.2.201 203.0.113.99",ip," ");
  split("/ /about /photos/ /photos/2025/ /attendance /favicon.ico /robots.txt /notice /join /wp-login.php /.env",pa," ");
  split("200 200 200 200 200 200 200 200 200 404 404",st," ");
  split("4521 1830 7342 6120 2210 1150 67 3305 2876 162 162",sz," ");
  ua[1]="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36";
  ua[2]="Mozilla/5.0 (iPhone; CPU iPhone OS 18_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1 Mobile/15E148 Safari/604.1";
  ua[3]="Mozilla/5.0 (Linux; Android 14; SM-S921N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36";
  ua[4]="Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)";
  ua[5]="python-requests/2.32.3";
  split("28/Dec/2025 29/Dec/2025 30/Dec/2025 31/Dec/2025 01/Jan/2026 02/Jan/2026 03/Jan/2026",dy," ");
  t=0;
  for(i=1;i<=200;i++){
    s=(s*1103515245+12345)%2147483648; r=int(s/65536);
    t+=int(r%5000)+60; if(t>=86400*7)t=86400*7-1;
    d=int(t/86400)+1; x=t%86400;
    k=r%11+1; u=(k>=10)?5:(r%4+1); if(k==7)u=4;
    printf "%s - - [%s:%02d:%02d:%02d +0900] \"GET %s HTTP/1.1\" %s %s \"-\" \"%s\"\n", ip[r%7+1], dy[d], int(x/3600), int(x%3600/60), x%60, pa[k], st[k], sz[k], ua[u];
  }}' > $H/logs/access.log
cat > $H/logs/error.log <<'T'
2025/12/30 03:12:44 [error] 812#812: *1043 open() "/var/www/saebyeok/wp-login.php" failed (2: No such file or directory), client: 203.0.113.99, server: _, request: "GET /wp-login.php HTTP/1.1", host: "saebyeok"
2026/01/02 04:01:09 [error] 812#812: *2210 open() "/var/www/saebyeok/.env" failed (2: No such file or directory), client: 203.0.113.99, server: _, request: "GET /.env HTTP/1.1", host: "saebyeok"
T
cat > $H/logs/bot.log <<'T'
2026-01-02 19:00:01 INFO 출석부 봇 시작
2026-01-02 19:30:12 INFO 출석 체크: 6명
2026-01-02 21:00:00 INFO 출석부 저장: attendance/members.csv
T
J='\377\330\377\340\000\020JFIF\000\001\001\000\000\001\000\001\000\000\377\331'
for f in 2024/first-meeting.jpg 2024/hackathon.jpg 2024/year-end.jpg 2025/first-meeting.jpg 2025/mt-01.jpg 2025/mt-02.jpg 2025/year-end.jpg; do printf "$J" > $H/photos/$f; done
cat > $H/attendance/members.csv <<'T'
이름,학번,입부일
정이안,2015,2015-03-10
박지후,2021,2021-03-09
최유나,2022,2022-03-15
강도윤,2024,2024-03-12
이하준,2024,2024-03-12
윤서아,2025,2025-03-11
김민재,2025,2025-03-18
T
cat > $H/bin/backup.sh <<'T'
#!/bin/bash
# 홈페이지와 사진첩을 날짜 붙은 tar.gz 하나로 묶는다. — 이안
set -e
today=$(date +%F)
mkdir -p /backup
tar czf "/backup/saebyeok-$today.tar.gz" /var/www/saebyeok /srv/photos
echo "백업 끝: /backup/saebyeok-$today.tar.gz"
T
chmod 755 $H/bin/backup.sh
find "$1/saebyeok" -exec touch -h -d '2026-01-03 21:40:00 +0900' {} +
