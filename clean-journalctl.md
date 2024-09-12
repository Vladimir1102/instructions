настройка журнала! 



```
sudo systemctl stop systemd-journald
sudo nano /etc/systemd/journald.conf
```



```
[Journal]
#Storage=auto
#Compress=yes
#Seal=yes
#SplitMode=uid
#SyncIntervalSec=5m
#RateLimitIntervalSec=30s
#RateLimitBurst=10000
#SystemMaxUse=
#SystemKeepFree=
SystemMaxFileSize=4M
SystemMaxFiles=10
#RuntimeMaxUse=
#RuntimeKeepFree=
RuntimeMaxFileSize=4M
RuntimeMaxFiles=10
MaxRetentionSec=1day
#MaxFileSec=1month
#ForwardToSyslog=yes
#ForwardToKMsg=no
#ForwardToConsole=no
#ForwardToWall=yes
#TTYPath=/dev/console
#MaxLevelStore=debug
#MaxLevelSyslog=debug
#MaxLevelKMsg=notice
#MaxLevelConsole=info
#MaxLevelWall=emerg
#LineMax=48K
#ReadKMsg=yes
#Audit=no

```

полная очистка: 

```
sudo journalctl --disk-usage
sudo journalctl --rotate
sudo journalctl --vacuum-time=1s
```


