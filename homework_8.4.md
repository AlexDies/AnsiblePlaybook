## Домашнее задание к занятию "8.4 Работа с Roles"
___
**Подготовка к выполнению**
1. Создайте два пустых публичных репозитория в любом своём проекте: `kibana-role` и `filebeat-role`.
2. Добавьте публичную часть своего ключа к своему профилю в github.
___
**Основная часть**

Наша основная цель - разбить наш playbook на отдельные roles. Задача: сделать `roles` для `elastic`, `kibana`, `filebeat` и написать playbook для использования этих ролей. 

Ожидаемый результат: существуют два ваших репозитория с `roles` и один репозиторий с playbook.

1. Создать в старой версии playbook файл `requirements.yml` и заполнить его следующим содержимым:

  ---
    - src: git@github.com:netology-code/mnt-homeworks-ansible.git
      scm: git
      version: "2.0.0"
      name: elastic 

2. При помощи `ansible-galaxy` скачать себе эту роль.
3. Создать новый каталог с ролью при помощи `ansible-galaxy role init kibana-role`.
4. На основе tasks из старого playbook заполните новую `role`. Разнесите переменные между `vars` и `default`.
5. Перенести нужные шаблоны конфигов в `templates`.
6. Создать новый каталог с ролью при помощи `ansible-galaxy role init filebeat-role`.
7. На основе tasks из старого playbook заполните новую `role`. Разнесите переменные между `vars` и` default`.
8. Перенести нужные шаблоны конфигов в `templates`.
9. Описать в README.md обе роли и их параметры.
10. Выложите все roles в репозитории. Проставьте тэги, используя семантическую нумерацию.
11. Добавьте `roles` в `requirements.yml` в playbook.
12. Переработайте playbook на использование `roles`.
13. Выложите playbook в репозиторий.
14. В ответ приведите ссылки на оба репозитория с `roles` и одну ссылку на репозиторий с playbook.
Необязательная часть
___
**Необязательная часть**

1. Проделайте схожие манипуляции для создания роли `logstash`.
2. Создайте дополнительный набор tasks, который позволяет обновлять стек ELK.
3. Убедитесь в работоспособности своего стека: установите `logstash` на свой хост с `elasticsearch`, настройте конфиги `logstash` и `filebeat` так, чтобы они взаимодействовали друг с другом и `elasticsearch` корректно.
4. Выложите `logstash-role` в репозиторий. В ответ приведите ссылку.
___
**Выполнение ДЗ:**

**1,2. Создание файла `requirements.yml`:**

Добавлено 3 роли:

    ---
      - src: git@github.com:netology-code/mnt-homeworks-ansible.git
        scm: git
        version: "2.0.0"
        name: elastic
      - src: git@github.com:AlexDies/kibana-role.git
        scm: git
        version: "1.1.1"
        name: kibana
      - src: git@github.com:AlexDies/filebeat-role.git
        scm: git
        version: "1.0.1"
        name: filebeat

**3,4,5. Создана роль `Kibana` в репозитории:**

https://github.com/AlexDies/kibana-role

**6,7,8. Создана роль `Filebeat` в репозитории:**

https://github.com/AlexDies/filebeat-role

**9 . Добавлено описание в README.md к каждой роли.**

**10 . Добавление ролей в playbook:**

    root@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/playbook# ansible-galaxy install -r requirements.yml -p roles 
    - extracting elastic to /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/playbook/roles/elastic
    - elastic (2.0.0) was installed successfully
    - extracting kibana to /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/playbook/roles/kibana
    - kibana (1.1.1) was installed successfully
    - extracting filebeat to /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/playbook/roles/filebeat
    - filebeat (1.0.1) was installed successfully

**11,12 Переработа playbook с использованием ролей:**

    ---
    - name: Install Elasticsearch
      hosts: elasticsearch
      roles:
        - elastic
    - name: Install kibana
      hosts: kibana
      roles:
        - kibana
    - name: Install Filebeat
      hosts: app
      roles:
        - filebeat

**Запуск playbook:**

    PLAY RECAP ************************************************************************************
    application-instance       : ok=10   changed=5    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
    el-instance                : ok=8    changed=4    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
    k-instance                 : ok=8    changed=4    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

**Проверка на идемпотентность:**

    PLAY RECAP ************************************************************************************************************************************application-instance       : ok=9    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
    el-instance                : ok=7    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
    k-instance                 : ok=7    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

**Плейбук идемпотентен**