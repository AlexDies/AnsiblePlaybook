## Домашнее задание к занятию "08.03 Использование Yandex Cloud"
___
**Подготовка к выполнению**

1. Создайте свой собственный (или используйте старый) публичный репозиторий на github с произвольным именем.
2. Скачайте playbook из репозитория с домашним заданием и перенесите его в свой репозиторий.

___
**Основная часть**

1. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает `kibana`.
2. При создании tasks рекомендую использовать модули: `get_url`, `template`, `yum`, `apt`.
3. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, сгенерировать конфигурацию с параметрами.
4. Приготовьте свой собственный inventory файл `prod.yml`.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
9. Проделайте шаги с 1 до 8 для создания ещё одного play, который устанавливает и настраивает `filebeat`.
10. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
11. Готовый playbook выложите в свой репозиторий, в ответ предоставьте ссылку на него.

___
**Выполнение ДЗ:**

**1,2,3. Подготовка playbook, добавление дополнительного play для установки и настройки `kibana`:**

В `site.yml` добавлено следующее:

    - name: Install Kibana
      hosts: kibana
      handlers:
        - name: restart Kibana
          become: true
          systemd:
            name: kibana
            state: restarted
            enabled: true
      tasks:
        - name: "Download Kibana rpm"
          get_url:
            url: "https://artifacts.elastic.co/downloads/kibana/kibana-{{ kibana_version }}-x86_64.rpm"
            dest: "/tmp/kibana-{{ kibana_version }}-x86_64.rpm"
          register: download_kibana
          until: download_kibana is succeeded
        - name: Install Kibana
          become: true
          yum:
            name: "/tmp/kibana-{{ kibana_version }}-x86_64.rpm"
            state: present
          notify: restart Kibana
        - name: Configure Kibana
          become: true
          template:
            src: kibana.yml.j2
            dest: /etc/kibana/kibana.yml
            mode: 0644
          notify: restart Kibana

Конечный вид:

    - name: Install Elasticsearch
      hosts: elasticsearch
      handlers:
        - name: restart Elasticsearch
          become: true
          systemd:
            name: elasticsearch
            state: restarted
            enabled: true
      tasks:
        - name: "Download Elasticsearch's rpm"
          get_url:
            url: "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-{{ elk_stack_version }}-x86_64.rpm"
            dest: "/tmp/elasticsearch-{{ elk_stack_version }}-x86_64.rpm"
          register: download_elastic
          until: download_elastic is succeeded
        - name: Install Elasticsearch
          become: true
          yum:
            name: "/tmp/elasticsearch-{{ elk_stack_version }}-x86_64.rpm"
            state: present
          notify: restart Elasticsearch
        - name: Configure Elasticsearch
          become: true
          template:
            src: elasticsearch.yml.j2
            dest: /etc/elasticsearch/elasticsearch.yml
            mode: 0644
          notify: restart Elasticsearch

    - name: Install Kibana
      hosts: kibana
      handlers:
        - name: restart Kibana
          become: true
          systemd:
            name: kibana
            state: restarted
            enabled: true
      tasks:
        - name: "Download Kibana rpm"
          get_url:
            url: "https://artifacts.elastic.co/downloads/kibana/kibana-{{ kibana_version }}-x86_64.rpm"
            dest: "/tmp/kibana-{{ kibana_version }}-x86_64.rpm"
          register: download_kibana
          until: download_kibana is succeeded
        - name: Install Kibana
          become: true
          yum:
            name: "/tmp/kibana-{{ kibana_version }}-x86_64.rpm"
            state: present
          notify: restart Kibana
        - name: Configure Kibana
          become: true
          template:
            src: kibana.yml.j2
            dest: /etc/kibana/kibana.yml
            mode: 0644
          notify: restart Kibana

**4. Подготовка `inventory` файла:**

В файл `host.yml` добавлен адрес хоста с `kibana`:

    kibana:
    hosts:
        k-instance:
        ansible_host: 130.193.59.128

Конечный вид:

    all:
    vars:
        ansible_connection: ssh
        ansible_user: alexd
    elasticsearch:
    hosts:
        el-instance:
        ansible_host: 178.154.233.196
    kibana:
    hosts:
        k-instance:
        ansible_host: 130.193.59.128

В `group_vars` добавлен файл `kibana.yml` для указания переменной `kibana_version`:

    ---
    kibana_version: "7.15.0"

В `templates` создан файл `kibana.yml.j2` для конфигурации `kibana`:

    server.host: "0.0.0.0"
    elasticsearch.hosts: ["http://{{ hostvars['el-instance']['ansible_facts']['default_ipv4']['address'] }}:9200"]
    kibana.index: ".kibana"

**5. Запуск `ansible-lint site.yml` и исправление ошибок:**

        alexd@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/playbook$ ansible-lint site.yml
        WARNING  Overriding detected file kind 'yaml' with 'playbook' for given positional argument: site.yml

Ошибки исправлены

**6. Запуске playbook с флагом `--check`:**

        alexd@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/playbook$ ansible-playbook -i inventory/prod/ site.yml --check

        PLAY [Install Elasticsearch] **************************************************************************************
        TASK [Gathering Facts] ********************************************************************************************ok: [el-instance]

        TASK [Download Elasticsearch's rpm] *******************************************************************************ok: [el-instance]

        TASK [Install Elasticsearch] **************************************************************************************ok: [el-instance]

        TASK [Configure Elasticsearch] ************************************************************************************ok: [el-instance]

        PLAY [Install Kibana] *********************************************************************************************
        TASK [Gathering Facts] ********************************************************************************************ok: [k-instance]

        TASK [Download Kibana rpm] ****************************************************************************************changed: [k-instance]

        TASK [Install Kibana] *********************************************************************************************fatal: [k-instance]: FAILED! => {"changed": false, "msg": "No RPM file matching '/tmp/kibana-7.15.0-x86_64.rpm' found on system", "rc": 127, "results": ["No RPM file matching '/tmp/kibana-7.15.0-x86_64.rpm' found on system"]}     

        PLAY RECAP ********************************************************************************************************el-instance                : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 

        k-instance                 : ok=2    changed=1    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0

Так как файл отсутсвует `--check` выдает ошибку.

**7. Запуск playbook с флагом `--diff`:**

        alexd@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/playbook$ ansible-playbook -i inventory/prod/ site.yml --check

        PLAY [Install Elasticsearch] **************************************************************************************
        TASK [Gathering Facts] ********************************************************************************************ok: [el-instance]

        TASK [Download Elasticsearch's rpm] *******************************************************************************ok: [el-instance]

        TASK [Install Elasticsearch] **************************************************************************************ok: [el-instance]

        TASK [Configure Elasticsearch] ************************************************************************************ok: [el-instance]

        PLAY [Install Kibana] *********************************************************************************************
        TASK [Gathering Facts] ********************************************************************************************ok: [k-instance]

        TASK [Download Kibana rpm] ****************************************************************************************changed: [k-instance]

        TASK [Install Kibana] *********************************************************************************************fatal: [k-instance]: FAILED! => {"changed": false, "msg": "No RPM file matching '/tmp/kibana-7.15.0-x86_64.rpm' found on system", "rc": 127, "results": ["No RPM file matching '/tmp/kibana-7.15.0-x86_64.rpm' found on system"]}     

        PLAY RECAP ********************************************************************************************************el-instance                : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 

        k-instance                 : ok=2    changed=1    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0 


        alexd@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/playbook$ ansible-playbook -i inventory/prod/ site.yml --diff

        PLAY [Install Elasticsearch] **************************************************************************************
        TASK [Gathering Facts] ********************************************************************************************ok: [el-instance]

        TASK [Download Elasticsearch's rpm] *******************************************************************************ok: [el-instance]

        TASK [Install Elasticsearch] **************************************************************************************ok: [el-instance]

        TASK [Configure Elasticsearch] ************************************************************************************ok: [el-instance]

        PLAY [Install Kibana] *********************************************************************************************
        TASK [Gathering Facts] ********************************************************************************************ok: [k-instance]

        TASK [Download Kibana rpm] ****************************************************************************************changed: [k-instance]

        TASK [Install Kibana] *********************************************************************************************changed: [k-instance]

        TASK [Configure Kibana] *******************************************************************************************--- before: /etc/kibana/kibana.yml
        +++ after: /home/alexd/.ansible/tmp/ansible-local-45076_vsdqmm/tmp3yvbsuvb/kibana.yml.j2
        @@ -1,115 +1,3 @@
        (Убрал лишний вывод с тем, что будет удалено)
        +server.host: "0.0.0.0"
        +elasticsearch.hosts: ["http://10.130.0.32:9200"]
        +kibana.index: ".kibana"
        \ No newline at end of file

        changed: [k-instance]

        RUNNING HANDLER [restart Kibana] **********************************************************************************changed: [k-instance]

        PLAY RECAP ********************************************************************************************************el-instance                : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 

        k-instance                 : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 

**8. Повторный запуск playbook с флагом `--diff` для проверки идемпотентности:**

        alexd@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/playbook$ ansible-playbook -i inventory/prod/ site.yml --diff

        PLAY [Install Elasticsearch] **************************************************************************************
        TASK [Gathering Facts] ********************************************************************************************ok: [el-instance]

        TASK [Download Elasticsearch's rpm] *******************************************************************************ok: [el-instance]

        TASK [Install Elasticsearch] **************************************************************************************ok: [el-instance]

        TASK [Configure Elasticsearch] ************************************************************************************ok: [el-instance]

        PLAY [Install Kibana] *********************************************************************************************
        TASK [Gathering Facts] ********************************************************************************************ok: [k-instance]

        TASK [Download Kibana rpm] ****************************************************************************************ok: [k-instance]

        TASK [Install Kibana] *********************************************************************************************ok: [k-instance]

        TASK [Configure Kibana] *******************************************************************************************ok: [k-instance]

        PLAY RECAP ********************************************************************************************************el-instance                : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 

        k-instance                 : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 

**Вывод: изменения идемпотентны**

**9. Выполнить аналогичные действия для создания `play` по установке и настройке `filebeat`:**

В `site.yml` добавлен play для `filebeat`:

      - name: Install filebeat
        hosts: app
        handlers:
          - name: restart filebeat
            become: true
            systemd:
              name: filebeat
              state: restarted
              enabled: true
        tasks:
          - name: "Download filebeat"
            get_url:
              url: "https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-{{ filebeat_version }}-x86_64.rpm"
              dest: "/tmp/filebeat-{{ filebeat_version }}-x86_64.rpm"
            register: download_filebeat
            until: download_filebeat is succeeded
          - name: "Install filebeat"
            become: true
            yum:
              name: "/tmp/filebeat-{{ filebeat_version }}-x86_64.rpm"
              state: present
            notify: restart filebeat
          - name: "Configure filebeat"
            become: true
            template:
              src: filebeat.yml.j2
              dest: /etc/filebeat/filebeat.yml
              mode: 0644
            notify: restart filebeat
          - name: "Set filebeat systemwork"
            become: true
            command:
              cmd: filebeat modules enable system
              chdir: /usr/share/filebeat/bin
            register: filebeat_modules
            changed_when: filebeat_modules.stdout !='Module system is already enabled'
          - name: "Load kibana dashboard"
            become: true
            command:
              cmd: filebeat setup
              chdir: /usr/share/filebeat/bin
            register: filebeat_setup
            changed_when: false
            until: filebeat_setup is succeeded

В `hosts.yml` в `inventory` добавлено следующее:

    app:
    hosts:
        application-instance: 
        ansible_host: 130.193.58.232

В `group_vars` добавлен файл `app.yml` для указания переменной `filebeat_version`:

    ---
    filebeat_version: "7.15.0"

В `templates` создан файл `filebeat.yml.j2` для конфигурации `filebeat`:

    setup.kibana:
    host: "http://{{ hostvars['k-instance']['ansible_facts']['default_ipv4']['address'] }}:5601"
    output.elasticsearch:
    hosts: "http://{{ hostvars['el-instance']['ansible_facts']['default_ipv4']['address'] }}:9200"
    filebeat.config.modules.path: ${path.config}/modules.d/*.yml

Запуск `ansible-lint site.yml` и исправление ошибок:

    alexd@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/playbook$ ansible-lint site.yml
    WARNING  Overriding detected file kind 'yaml' with 'playbook' for given positional argument: site.yml

Ошибки исправлены

Запуске playbook с флагом `--check`:

    alexd@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/playbook$ ansible-playbook -i inventory/prod/ site.yml --check

    PLAY [Install Elasticsearch] *****************************************************************************************************************************************************************************************************************************************
    TASK [Gathering Facts] ***********************************************************************************************************************************************************************************************************************************************ok: [el-instance]

    TASK [Download Elasticsearch's rpm] **********************************************************************************************************************************************************************************************************************************ok: [el-instance]

    TASK [Install Elasticsearch] *****************************************************************************************************************************************************************************************************************************************ok: [el-instance]

    TASK [Configure Elasticsearch] ***************************************************************************************************************************************************************************************************************************************ok: [el-instance]

    PLAY [Install Kibana] ************************************************************************************************************************************************************************************************************************************************
    TASK [Gathering Facts] ***********************************************************************************************************************************************************************************************************************************************ok: [k-instance]

    TASK [Download Kibana rpm] *******************************************************************************************************************************************************************************************************************************************ok: [k-instance]

    TASK [Install Kibana] ************************************************************************************************************************************************************************************************************************************************ok: [k-instance]

    TASK [Configure Kibana] **********************************************************************************************************************************************************************************************************************************************ok: [k-instance]

    PLAY [Install filebeat] **********************************************************************************************************************************************************************************************************************************************
    TASK [Gathering Facts] ***********************************************************************************************************************************************************************************************************************************************ok: [application-instance]

    TASK [Download filebeat] *********************************************************************************************************************************************************************************************************************************************changed: [application-instance]

    TASK [Install filebeat] **********************************************************************************************************************************************************************************************************************************************fatal: [application-instance]: FAILED! => {"changed": false, "msg": "No RPM file matching '/tmp/filebeat-7.15.0-x86_64.rpm' found on system", "rc": 127, "results": ["No RPM file matching '/tmp/filebeat-7.15.0-x86_64.rpm' found on system"]}

    PLAY RECAP ***********************************************************************************************************************************************************************************************************************************************************application-instance       : ok=2    changed=1    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0
    el-instance                : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    k-instance                 : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

Так как файл отсутсвует `--check` выдает ошибку.

Запуск playbook с флагом `--diff`:

    alexd@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/playbook$ ansible-playbook -i inventory/prod/ site.yml --diff

    PLAY [Install Elasticsearch] *****************************************************************************************************************************************************************************************************************************************
    TASK [Gathering Facts] ***********************************************************************************************************************************************************************************************************************************************ok: [el-instance]

    TASK [Download Elasticsearch's rpm] **********************************************************************************************************************************************************************************************************************************FAILED - RETRYING: Download Elasticsearch's rpm (3 retries left).
    ok: [el-instance]

    TASK [Install Elasticsearch] *****************************************************************************************************************************************************************************************************************************************ok: [el-instance]

    TASK [Configure Elasticsearch] ***************************************************************************************************************************************************************************************************************************************ok: [el-instance]

    PLAY [Install Kibana] ************************************************************************************************************************************************************************************************************************************************
    TASK [Gathering Facts] ***********************************************************************************************************************************************************************************************************************************************ok: [k-instance]

    TASK [Download Kibana rpm] *******************************************************************************************************************************************************************************************************************************************ok: [k-instance]

    TASK [Install Kibana] ************************************************************************************************************************************************************************************************************************************************ok: [k-instance]

    TASK [Configure Kibana] **********************************************************************************************************************************************************************************************************************************************ok: [k-instance]

    PLAY [Install filebeat] **********************************************************************************************************************************************************************************************************************************************
    TASK [Gathering Facts] ***********************************************************************************************************************************************************************************************************************************************ok: [application-instance]

    TASK [Download filebeat] *********************************************************************************************************************************************************************************************************************************************changed: [application-instance]

    TASK [Install filebeat] **********************************************************************************************************************************************************************************************************************************************changed: [application-instance]

    TASK [Configure filebeat] ********************************************************************************************************************************************************************************************************************************************--- before: /etc/filebeat/filebeat.yml
    +++ after: /home/alexd/.ansible/tmp/ansible-local-4876jq26jfwv/tmpkb891gio/filebeat.yml.j2
    @@ -1,270 +1,5 @@
    -###################### Filebeat Configuration Example #########################

    +  host: "http://10.130.0.25:5601"

    +  hosts: "http://10.130.0.32:9200"
    +filebeat.config.modules.path: ${path.config}/modules.d/*.yml
    \ No newline at end of file

    changed: [application-instance]

    TASK [Set filebeat systemwork] ***************************************************************************************************************************************************************************************************************************************changed: [application-instance]

    TASK [Load kibana dashboard] *****************************************************************************************************************************************************************************************************************************************ok: [application-instance]

    RUNNING HANDLER [restart filebeat] ***********************************************************************************************************************************************************************************************************************************changed: [application-instance]

    PLAY RECAP ***********************************************************************************************************************************************************************************************************************************************************application-instance       : ok=7    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    el-instance                : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    k-instance                 : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

Запустим playbook с `--diff` повторно:

    alexd@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/playbook$ ansible-playbook -i inventory/prod/ site.yml --diff

    PLAY [Install Elasticsearch] *****************************************************************************************************************************************************************************************************************************************
    TASK [Gathering Facts] ***********************************************************************************************************************************************************************************************************************************************ok: [el-instance]

    TASK [Download Elasticsearch's rpm] **********************************************************************************************************************************************************************************************************************************ok: [el-instance]

    TASK [Install Elasticsearch] *****************************************************************************************************************************************************************************************************************************************ok: [el-instance]

    TASK [Configure Elasticsearch] ***************************************************************************************************************************************************************************************************************************************ok: [el-instance]

    PLAY [Install Kibana] ************************************************************************************************************************************************************************************************************************************************
    TASK [Gathering Facts] ***********************************************************************************************************************************************************************************************************************************************ok: [k-instance]

    TASK [Download Kibana rpm] *******************************************************************************************************************************************************************************************************************************************ok: [k-instance]

    TASK [Install Kibana] ************************************************************************************************************************************************************************************************************************************************ok: [k-instance]

    TASK [Configure Kibana] **********************************************************************************************************************************************************************************************************************************************ok: [k-instance]

    PLAY [Install filebeat] **********************************************************************************************************************************************************************************************************************************************
    TASK [Gathering Facts] ***********************************************************************************************************************************************************************************************************************************************ok: [application-instance]

    TASK [Download filebeat] *********************************************************************************************************************************************************************************************************************************************ok: [application-instance]

    TASK [Install filebeat] **********************************************************************************************************************************************************************************************************************************************ok: [application-instance]

    TASK [Configure filebeat] ********************************************************************************************************************************************************************************************************************************************ok: [application-instance]

    TASK [Set filebeat systemwork] ***************************************************************************************************************************************************************************************************************************************ok: [application-instance]

    TASK [Load kibana dashboard] *****************************************************************************************************************************************************************************************************************************************ok: [application-instance]

    PLAY RECAP ***********************************************************************************************************************************************************************************************************************************************************application-instance       : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
    el-instance                : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    k-instance                 : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

**Изменений нет, соответственно, плейбук идемпотентен.**

