## Резервное копирование и восстановление GitLab
Для резервного копирования у GitLab предусмотрен штатный функционал, запустить его можно командой:

```
root@host:~$ gitlab-rake gitlab:backup:create
```

По умолчанию, все резервные копии формируются в следующей директории: /var/opt/gitlab/backups в формате *.tar. Однако, во время резервного копирования могут появляться ошибки, если с GitLab в это время идет активная работа и данные изменяются. На этот случай существует такая возможность как «стратегия». Выполнив следующую команду, файлы сначала будут скопированы во временную директорию и уже после этого она будет упакована архиватором tar:

```
root@host:~$ gitlab-rake gitlab:backup:create STRATEGY=copy
```

Все настройки резервного копирования выполняются в главном конфигурационном файле, о котором мы говорили ранее. Рассмотрим некоторые полезные надстройки.

Изменить место хранения резервных копий:

```
gitlab_rails['backup_upload_connection'] = {
:provider => 'Local',
:local_root => '/mnt/gitlab-backups'
}
gitlab_rails['backup_upload_remote_directory'] = 'gitlab_backups'
```

Вариант скрипта gitlab_backup.sh:

```
#!/bin/bash

# Искомая часть имени контейнера
search_term="eterinte_gitlab"

# Ищем контейнеры, содержащие искомую часть имени
container_name=$(docker ps --filter "name=${search_term}" --format "{{.Names}}" | head -n 1)

# Проверяем, найден ли контейнер
if [ -z "$container_name" ]; then
echo "Контейнер с именем, содержащим '${search_term}', не найден."
exit 1
fi

# Выводим полное имя контейнера
echo "Найден контейнер: $container_name"

# Выполняем команду бэкапа в контейнере
echo "Запуск резервного копирования..."
backup_output=$(docker exec -t "$container_name" gitlab-rake gitlab:backup:create 2>&1)

# Проверяем статус выполнения команды бэкапа
if [ $? -eq 0 ]; then
echo "Резервное копирование выполнено успешно."
else
echo "Ошибка при выполнении резервного копирования."
echo "$backup_output"
exit 1
fi

# Выводим завершение скрипта
echo "Good LUCK!"
```

Время хранения резервной копии:

## Limit backup lifetime to 7 days - 604800 seconds

```
gitlab_rails['backup_keep_time'] = 604800
```

Обратите внимание. При резервном копировании Вам кроме каталогов непосредственно с GitLab, так же нужно отдельно копировать файлы расположенные в /etc/gitlab. В частности — главный конфигурационный файл /etc/gitlab/gitlab.rb

Восстановление данных происходит следующим образом. Необходимо установить GitLab версии которая аналогична той, что у нас в архиве *.tar. Восстанавливаете вручную файл /etc/gitlab/gitlab-secrets.json. Архив с резервной копией размещаете по стандартному пути: /var/opt/gitlab/backups. И выполняете восстановление:

```
root@host: gitlab-ctl stop unicorn
root@host: gitlab-ctl stop sidekiq
root@host: gitlab-ctl status
root@host: gitlab-rake gitlab:backup:restore BACKUP=6345346124_2020_01_18_12.6.1-ce
```


Теперь копируем наш главный конфиг /etc/gitlab/gitlab.rb, резервную копию которого мы сделали ранее и перезапустим систему:



```
root@host: gitlab-ctl restart
root@host: gitlab-rake gitlab:check SANITIZE=true
```


Более детально о нюансах резервного копирования рекомендуем почитать в официальной документации.