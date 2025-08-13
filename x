[0;1;32m●[0m ntpsec.service - Network Time Service
     Loaded: loaded (]8;;file://raspberrypi5/lib/systemd/system/ntpsec.service/lib/systemd/system/ntpsec.service]8;;; [0;1;32menabled[0m; preset: [0;1;32menabled[0m)
     Active: [0;1;32mactive (running)[0m since Wed 2025-08-13 14:43:18 +07; 2s ago
       Docs: ]8;;man:ntpd(8)man:ntpd(8)]8;;
   Main PID: 6614 (ntpd)
      Tasks: 1[0;38;5;245m (limit: 4761)[0m
        CPU: 49ms
     CGroup: /system.slice/ntpsec.service
             └─[0;38;5;245m6614 /usr/sbin/ntpd -p /run/ntpd.pid -c /etc/ntpsec/ntp.conf -g -N -u ntpsec:ntpsec[0m

Thg 8 13 14:43:18 raspberrypi5 ntpd[6614]: NTSc: Using system default root certificates.
Thg 8 13 14:43:18 raspberrypi5 ntpd[6614]: [0;1;31m[0;1;39m[0;1;31mstatistics directory /var/log/ntpsec/ does not exist or is unwriteable, error No such file or directory[0m
Thg 8 13 14:43:19 raspberrypi5 ntpd[6614]: DNS: dns_probe: 0.debian.pool.ntp.org, cast_flags:8, flags:101
Thg 8 13 14:43:19 raspberrypi5 ntpd[6614]: DNS: dns_check: processing 0.debian.pool.ntp.org, 8, 101
Thg 8 13 14:43:19 raspberrypi5 ntpd[6614]: DNS: Pool taking: 115.165.161.155
Thg 8 13 14:43:19 raspberrypi5 ntpd[6614]: DNS: dns_take_status: 0.debian.pool.ntp.org=>good, 8
Thg 8 13 14:43:20 raspberrypi5 ntpd[6614]: DNS: dns_probe: 1.debian.pool.ntp.org, cast_flags:8, flags:101
Thg 8 13 14:43:20 raspberrypi5 ntpd[6614]: DNS: dns_check: processing 1.debian.pool.ntp.org, 8, 101
Thg 8 13 14:43:20 raspberrypi5 ntpd[6614]: DNS: Pool skipping: 115.165.161.155
Thg 8 13 14:43:20 raspberrypi5 ntpd[6614]: DNS: dns_take_status: 1.debian.pool.ntp.org=>good, 8
