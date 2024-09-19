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
# Папка с бэкапами на сервере (volume)
backup_volume_path="/home/compose/gitlab/backups"
# Папка назначения для бэкапов
backup_dest="/home/ubuntu/gitlab_backups"
# Папка, которую нужно архивировать
source_path="/home/compose/gitlab"

# Определяем текущее время для имени архива
timestamp=$(date +%Y%m%d%H%M)
backup_filename="${backup_dest}/${timestamp}_gitlab-bu.tar.gz"

# Определяем текущее время до начала создания бэкапа
current_time=$(date +%s)

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
echo "Запуск резервного копирования GitLab..."
docker exec -t "$container_name" gitlab-rake gitlab:backup:create

# Проверяем статус выполнения команды бэкапа
if [ $? -ne 0 ]; then
  echo "Ошибка при создании бэкапа. Скрипт завершен."
  exit 1
fi

# Находим самый свежий файл, созданный после начала бэкапа
backup_file=$(find "$backup_volume_path" -type f -newermt @$current_time -name '*.tar' | head -n 1)

# Проверяем, что файл бэкапа был найден
if [ -z "$backup_file" ]; then
  echo "Не удалось найти свежий файл бэкапа."
  exit 1
fi

# Выводим имя файла бэкапа
backup_file_name=$(basename "$backup_file")
echo "Имя созданного файла бэкапа: $backup_file_name"

# Копируем файл бэкапа в папку назначения
echo "Копирование файла бэкапа в папку назначения..."
cp "$backup_file" "$backup_dest/$backup_file_name"

# Проверяем статус выполнения команды копирования
if [ $? -eq 0 ]; then
  echo "Файл бэкапа успешно скопирован в $backup_dest."
else
  echo "Ошибка при копировании файла бэкапа."
  exit 1
fi

# Меняем владельца файла на ubuntu:ubuntu
echo "Изменение владельца файла на ubuntu:ubuntu..."
chown -R ubuntu:ubuntu "$backup_dest/$backup_file_name"

# Проверяем статус выполнения команды chown
if [ $? -eq 0 ]; then
  echo "Владелец файла успешно изменен."
else
  echo "Ошибка при изменении владельца файла."
  exit 1
fi

# Удаляем файл бэкапа из volume
echo "Удаление файла бэкапа из папки volume..."
rm -f "$backup_file"

# Проверяем статус выполнения команды удаления
if [ $? -eq 0 ]; then
  echo "Файл бэкапа успешно удален из volume."
else
  echo "Ошибка при удалении файла бэкапа из volume."
  exit 1
fi

# Создаем архив, исключая ненужные файлы и директории
echo "Создание архива с исключениями..."
tar --exclude='*.bak' --exclude='logs' --exclude='data' --exclude='backups' --exclude='html' -czf "$backup_filename" -C "$source_path" .

# Проверяем статус выполнения архивации
if [ $? -eq 0 ]; then
  echo "Архив успешно создан: $backup_filename"
else
  echo "Ошибка при создании архива."
  exit 1
fi

# Меняем владельца архива на ubuntu:ubuntu
chown -R ubuntu:ubuntu "$backup_filename"

# Проверяем статус выполнения команды chown для архива
if [ $? -eq 0 ]; then
  echo "Владелец архива успешно изменен."
else
  echo "Ошибка при изменении владельца архива."
  exit 1
fi

# Удаляем старые файлы из папки назначения, старше 1 недели
echo "Удаление файлов старше 1 недели из папки назначения..."
find "$backup_dest" -type f -mtime +7 -exec rm -f {} \;

# Проверяем статус выполнения команды удаления старых файлов
if [ $? -eq 0 ]; then
  echo "Старые файлы успешно удалены."
else
  echo "Ошибка при удалении старых файлов."
  exit 1
fi

# Выводим завершение скрипта
echo "Скрипт завершен."
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