## Домашнее задание к занятию "8.5 Тестирование Roles"
___
**Подготовка к выполнению**

1. Установите molecule: `pip3 install "molecule==3.4.0"`
2. Соберите локальный образ на основе Dockerfile

___
**Основная часть**

Наша основная цель - настроить тестирование наших ролей. 

Задача: сделать сценарии тестирования для `kibana`, `filebeat`. Ожидаемый результат: все сценарии успешно проходят тестирование ролей.

Molecule

1. Запустите `molecule test` внутри корневой директории `elasticsearch-role`, посмотрите на вывод команды.
2. Перейдите в каталог с ролью `kibana-role` и создайте сценарий тестирования по умолчаню при помощи `molecule init scenario --driver-name docker`.
3. Добавьте несколько разных дистрибутивов (`centos:8`, `ubuntu:latest`) для инстансов и протестируйте роль, исправьте найденные ошибки, если они есть.
4. Добавьте несколько `assert`'ов в `verify.yml` файл, для проверки работоспособности `kibana-role` (проверка, что web отвечает, проверка логов, etc). Запустите тестирование роли повторно и проверьте, что оно прошло успешно.
5. Повторите шаги 2-4 для `filebeat-role`.
6. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

Tox

1. Запустите `docker run -it -v <path_to_repo>:/opt/elasticsearch-role -w /opt/elasticsearch-role /bin/bash`, где `path_to_repo` - путь до корня репозитория с `elasticsearch-role` на вашей файловой системе.
2. Внутри контейнера выполните команду tox, посмотрите на вывод.
3. Добавьте файл `tox.ini` в корень репозитория каждой своей роли.
4. Создайте облегчённый сценарий для `molecule`. Проверьте его на исполнимость.
5. Пропишите правильную команду в `tox.ini` для того чтобы запускался облегчённый сценарий.
6. Запустите `docker` контейнер так, чтобы внутри оказались обе ваши роли.
7. Зайдти поочерёдно в каждую из них и запустите команду `tox`. Убедитесь, что всё отработало успешно.
8. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

После выполнения у вас должно получится два сценария `molecule` и один `tox.ini` файл в каждом репозитории. Ссылки на репозитории являются ответами на домашнее задание. Не забудьте указать в ответе теги решений `Tox` и `Molecule` заданий.
___
**Необязательная часть**

1. Проделайте схожие манипуляции для создания роли `logstash`.
2. Создайте дополнительный набор `tasks`, который позволяет обновлять стек ELK.
3. В ролях добавьте тестирование в раздел `verify.yml`. Данный раздел должен проверять, что `logstash` через команду `logstash -e 'input { stdin { } } output { stdout {} }'`  отвечате адекватно.
4. Создайте сценарий внутри любой из своих ролей, который умеет поднимать весь стек при помощи всех ролей.
5. Убедитесь в работоспособности своего стека. Создайте отдельный `verify.yml`, который будет проверять работоспособность интеграции всех инструментов между ними.
6. Выложите свои `roles` в репозитории. В ответ приведите ссылки.
___
**Выполнение ДЗ:**
(https://github.com/AlexDies/filebeat-role/tree/2.0.0

https://github.com/AlexDies/kibana-role/tree/2.0.0)

**0. Добавть драйвер docker для Molecule:**

        pip3 install molecule-docker

        Installing collected packages: ansible-compat, molecule-docker
        Successfully installed ansible-compat-0.5.0 molecule-docker-1.0.2

        alexd@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/kibana$ molecule drivers

        ╶──────────────────────────────────────────────────────────────────────────────────────────     
          delegated
          docker

**1 . Запуск `molecule test` для роли `elastic`:**

        alexd@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/elastic$ molecule test
        CRITICAL 'molecule/default/molecule.yml' glob failed.  Exiting.

**Произошла ошибка, так как нет инициализации сценария тестирования.**

**2. Создание сценария тестирования по умолчанию для роли `kibana`:**

`molecule init scenario --driver-name docker`

Созданы файлы для Molecule.

**3. Создание инфраструктуры и тестирование роли:**

В файл `molecule.yml` добавлено следующее:

    platforms:
      - name: centos7
        image: milcom/centos7-systemd
        pre_build_image: true
        privileged: true
      - name: ubuntu
        image: jrei/systemd-ubuntu
        pre_build_image: true
        privileged: true
        volumes:
          - "/sys/fs/cgroup:/sys/fs/cgroup:rw"
        command: "/usr/sbin/init"

Тестирование будет происходит на `centos7` и на `ubuntu` с установленным systemd для запуска `handlers`

При тестировании выявлена ошибка:

      TASK [kibana : Configure Kibana] ***********************************************
      An exception occurred during task execution. To see the full traceback, use -vvv. The error was: kibana.index: ".kibana"
      fatal: [centos7]: FAILED! => {"changed": false, "msg": "AnsibleError: template error while templating string: unexpected '}', expected ')'. String: server.host: \"0.0.0.0\"\nelasticsearch.hosts: [\"http://{{ hostvars['el-instance']['ansible_facts']['default_ipv4']['address'] | default('0.0.0.0'}}:9200\"]\nkibana.index: \".kibana\""}

Необходимо в файле `kibana.yml.j2` внести исправление в факты, так как докер эти факты не выдает:

`elasticsearch.hosts: ["http://{{ hostvars['el-instance']['ansible_facts']['default_ipv4']['address'] | default('0.0.0.0') }}:9200"]`

Повторный запуск `molecule test`: 

      alexd@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/kibana$ molecule test
      INFO     default scenario test matrix: dependency, lint, cleanup, destroy, syntax, create, prepare, converge, idempotence, side_effect, verify, cleanup, destroy
      INFO     Performing prerun...
      INFO     Guessed /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook as project root directory
      WARNING  Computed fully qualified role name of kibana does not follow current galaxy requirements.
      Please edit meta/main.yml and assure we can correctly determine full role name:

      galaxy_info:
      role_name: my_name  # if absent directory name hosting role is used instead
      namespace: my_galaxy_namespace  # if absent, author is used instead

      Namespace: https://galaxy.ansible.com/docs/contributing/namespaces.html#galaxy-namespace-limitations
      Role: https://galaxy.ansible.com/docs/contributing/creating_role.html#role-names

      As an alternative, you can add 'role-name' to either skip_list or warn_list.

      INFO     Using /home/alexd/.cache/ansible-lint/e1b308/roles/kibana symlink to current repository in order to enable Ansible to find the role using its expected full name.        
      INFO     Added ANSIBLE_ROLES_PATH=~/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles:/home/alexd/.cache/ansible-lint/e1b308/roles
      INFO     Running default > dependency
      WARNING  Skipping, missing the requirements file.
      WARNING  Skipping, missing the requirements file.
      INFO     Running default > lint
      INFO     Lint is disabled.
      INFO     Running default > cleanup
      WARNING  Skipping, cleanup playbook not configured.
      INFO     Running default > destroy
      INFO     Sanity checks: 'docker'

      PLAY [Destroy] *****************************************************************

      TASK [Destroy molecule instance(s)] ********************************************
      changed: [localhost] => (item=centos7)
      changed: [localhost] => (item=ubuntu)

      TASK [Wait for instance(s) deletion to complete] *******************************
      ok: [localhost] => (item=centos7)
      ok: [localhost] => (item=ubuntu)

      TASK [Delete docker networks(s)] ***********************************************

      PLAY RECAP *********************************************************************
      localhost                  : ok=2    changed=1    unreachable=0    failed=0    skipped=1 
        rescued=0    ignored=0

      INFO     Running default > syntax

      playbook: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/kibana/molecule/default/converge.yml
      INFO     Running default > create

      PLAY [Create] ******************************************************************

      TASK [Log into a Docker registry] **********************************************
      skipping: [localhost] => (item=None) 
      skipping: [localhost] => (item=None) 
      skipping: [localhost]

      TASK [Check presence of custom Dockerfiles] ************************************
      ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True})
      ok: [localhost] => (item={'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True})

      TASK [Create Dockerfiles from image names] *************************************
      skipping: [localhost] => (item={'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True})
      skipping: [localhost] => (item={'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True})

      TASK [Discover local Docker images] ********************************************
      ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional 
      result was False', 'item': {'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 
      'pre_build_image': True}, 'ansible_loop_var': 'item', 'i': 0, 'ansible_index_var': 'i'}) 
      ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional 
      result was False', 'item': {'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True}, 'ansible_loop_var': 'item', 'i': 1, 'ansible_index_var': 'i'})

      TASK [Build an Ansible compatible image (new)] *********************************
      skipping: [localhost] => (item=molecule_local/docker.io/pycontribs/centos:7) 
      skipping: [localhost] => (item=molecule_local/docker.io/pycontribs/ubuntu:latest) 

      TASK [Create docker network(s)] ************************************************

      TASK [Determine the CMD directives] ********************************************
      ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True})
      ok: [localhost] => (item={'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True})

      TASK [Create molecule instance(s)] *********************************************
      changed: [localhost] => (item=centos7)
      changed: [localhost] => (item=ubuntu)

      TASK [Wait for instance(s) creation to complete] *******************************
      FAILED - RETRYING: Wait for instance(s) creation to complete (300 retries left).
      changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '547443810407.25631', 'results_file': '/home/alexd/.ansible_async/547443810407.25631', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True}, 'ansible_loop_var': 'item'})
      changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '541659037326.25659', 'results_file': '/home/alexd/.ansible_async/541659037326.25659', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True}, 'ansible_loop_var': 'item'})

      PLAY RECAP *********************************************************************
      localhost                  : ok=5    changed=2    unreachable=0    failed=0    skipped=4 
        rescued=0    ignored=0

      INFO     Running default > prepare
      WARNING  Skipping, prepare playbook not configured.
      INFO     Running default > converge

      PLAY [Converge] ****************************************************************

      TASK [Gathering Facts] *********************************************************
      ok: [ubuntu]
      ok: [centos7]

      TASK [Include kibana] **********************************************************

      TASK [kibana : Fail if unsupported system detected] ****************************
      skipping: [centos7]
      skipping: [ubuntu]

      TASK [kibana : include_tasks] **************************************************
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/kibana/tasks/download_yum.yml for centos7
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/kibana/tasks/download_apt.yml for ubuntu

      TASK [kibana : Download Kibana rpm] ********************************************
      ok: [centos7 -> localhost]

      TASK [kibana : Copy kibana to managed node] ************************************
      changed: [centos7]

      TASK [kibana : Download Kibana deb] ********************************************
      ok: [ubuntu -> localhost]

      TASK [kibana : Copy kibana to managed node] ************************************
      changed: [ubuntu]

      TASK [kibana : include_tasks] **************************************************
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/kibana/tasks/install_yum.yml for centos7
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/kibana/tasks/install_apt.yml for ubuntu

      TASK [kibana : Install kibana yum] *********************************************
      changed: [centos7]

      TASK [kibana : Install kibana apt] *********************************************
      changed: [ubuntu]

      TASK [kibana : Configure Kibana] ***********************************************
      changed: [centos7]
      changed: [ubuntu]

      RUNNING HANDLER [kibana : restart kibana] **************************************
      skipping: [centos7]
      skipping: [ubuntu]

      PLAY RECAP *********************************************************************
      centos7                    : ok=7    changed=3    unreachable=0    failed=0    skipped=2 
        rescued=0    ignored=0
      ubuntu                     : ok=7    changed=3    unreachable=0    failed=0    skipped=2 
        rescued=0    ignored=0

      INFO     Running default > idempotence

      PLAY [Converge] ****************************************************************

      TASK [Gathering Facts] *********************************************************
      ok: [ubuntu]
      ok: [centos7]

      TASK [Include kibana] **********************************************************

      TASK [kibana : Fail if unsupported system detected] ****************************
      skipping: [centos7]
      skipping: [ubuntu]

      TASK [kibana : include_tasks] **************************************************
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/kibana/tasks/download_yum.yml for centos7
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/kibana/tasks/download_apt.yml for ubuntu

      TASK [kibana : Download Kibana rpm] ********************************************
      ok: [centos7 -> localhost]

      TASK [kibana : Copy kibana to managed node] ************************************
      ok: [centos7]

      TASK [kibana : Download Kibana deb] ********************************************
      ok: [ubuntu -> localhost]

      TASK [kibana : Copy kibana to managed node] ************************************
      ok: [ubuntu]

      TASK [kibana : include_tasks] **************************************************
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/kibana/tasks/install_yum.yml for centos7
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/kibana/tasks/install_apt.yml for ubuntu

      TASK [kibana : Install kibana yum] *********************************************
      ok: [centos7]

      TASK [kibana : Install kibana apt] *********************************************
      ok: [ubuntu]

      TASK [kibana : Configure Kibana] ***********************************************
      ok: [centos7]
      ok: [ubuntu]

      PLAY RECAP *********************************************************************
      centos7                    : ok=7    changed=0    unreachable=0    failed=0    skipped=1 
        rescued=0    ignored=0
      ubuntu                     : ok=7    changed=0    unreachable=0    failed=0    skipped=1 
        rescued=0    ignored=0

      INFO     Idempotence completed successfully.
      INFO     Running default > side_effect
      WARNING  Skipping, side effect playbook not configured.
      INFO     Running default > verify
      INFO     Running Ansible Verifier

      PLAY [Verify] ******************************************************************

      TASK [Example assertion] *******************************************************
      ok: [centos7] => {
          "changed": false,
          "msg": "All assertions passed"
      }
      ok: [ubuntu] => {
          "changed": false,
          "msg": "All assertions passed"
      }

      PLAY RECAP *********************************************************************
      centos7                    : ok=1    changed=0    unreachable=0    failed=0    skipped=0 
        rescued=0    ignored=0
      ubuntu                     : ok=1    changed=0    unreachable=0    failed=0    skipped=0 
        rescued=0    ignored=0

      INFO     Verifier completed successfully.
      INFO     Running default > cleanup
      WARNING  Skipping, cleanup playbook not configured.
      INFO     Running default > destroy

      PLAY [Destroy] *****************************************************************

      TASK [Destroy molecule instance(s)] ********************************************
      changed: [localhost] => (item=centos7)
      changed: [localhost] => (item=ubuntu)

      TASK [Wait for instance(s) deletion to complete] *******************************
      FAILED - RETRYING: Wait for instance(s) deletion to complete (300 retries left).
      changed: [localhost] => (item=centos7)
      changed: [localhost] => (item=ubuntu)

      TASK [Delete docker networks(s)] ***********************************************

      PLAY RECAP *********************************************************************
      localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=1 
        rescued=0    ignored=0

      INFO     Pruning extra files from scenario ephemeral directory

**В результате всё прошло успешно, идемпотентность также прошла.**

**4. Добавление нескольких assrert в `verify.yml` :**

Assert на проверку установленного пакета `kibana`:

        - name: Kibana install status
          package:
            name: kibana
            state: "present"
          check_mode: true
          register: pkg_status
        - name: Kibana installed
          assert:
            that:
              - not pkg_status.changed
            fail_msg: "Kibana is not install"
            success_msg: "Kibana is install!"

Assert на проверку запущенного процесса `kibana`:

        - name: Gathering facts
          service_facts:
        - name: See service kibana
          debug:
            msg: "{{ ansible_facts.services['kibana.service'].state }}"
        - name: Verify kibana is running
          assert:
            that:
              - "'{{ ansible_facts.services['kibana.service'].state }}' == 'running'"
            fail_msg: "Kibana not running"
            success_msg: "Kibana is running!"

**Повторный запуск теста:**

      alexd@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook$ molecule test
      INFO     default scenario test matrix: dependency, lint, cleanup, destroy, syntax, create, prepare, converge, idempotence, side_effect, verify, cleanup, destroy
      INFO     Performing prerun...
      INFO     Guessed /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/
      INFO     Running default > dependency
      WARNING  Skipping, missing the requirements file.
      WARNING  Skipping, missing the requirements file.
      INFO     Running default > lint
      INFO     Lint is disabled.
      INFO     Running default > cleanup
      WARNING  Skipping, cleanup playbook not configured.
      INFO     Running default > destroy
      INFO     Sanity checks: 'docker'

      PLAY [Destroy] *****************************************************************

      TASK [Destroy molecule instance(s)] ********************************************
      changed: [localhost] => (item=centos7)
      changed: [localhost] => (item=ubuntu)

      TASK [Wait for instance(s) deletion to complete] *******************************
      ok: [localhost] => (item=centos7)
      ok: [localhost] => (item=ubuntu)

      TASK [Delete docker networks(s)] ***********************************************

      PLAY RECAP *********************************************************************
      localhost                  : ok=2    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

      INFO     Running default > syntax

      playbook: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/molecule/default/converge.yml

      INFO     Running default > create

      PLAY [Create] ******************************************************************

      TASK [Log into a Docker registry] **********************************************
      skipping: [localhost] => (item=None) 
      skipping: [localhost] => (item=None) 
      skipping: [localhost]

      TASK [Check presence of custom Dockerfiles] ************************************
      ok: [localhost] => (item={'image': 'milcom/centos7-systemd', 'name': 'centos7', 'pre_build_image': True, 'privileged': True})
      ok: [localhost] => (item={'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']})

      TASK [Create Dockerfiles from image names] *************************************
      skipping: [localhost] => (item={'image': 'milcom/centos7-systemd', 'name': 'centos7', 'pre_build_image': True, 'privileged': True})
      skipping: [localhost] => (item={'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 
      'name': 'ubuntu', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']})

      TASK [Discover local Docker images] ********************************************
      ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'milcom/centos7-systemd', 'name': 'centos7', 'pre_build_image': True, 'privileged': True}, 'ansible_loop_var': 'item', 'i': 0, 'ansible_index_var': 'i'})ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 
      'ubuntu', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']}, 'ansible_loop_var': 'item', 'i': 1, 'ansible_index_var': 'i'})

      TASK [Build an Ansible compatible image (new)] *********************************
      skipping: [localhost] => (item=molecule_local/milcom/centos7-systemd) 
      skipping: [localhost] => (item=molecule_local/jrei/systemd-ubuntu) 

      TASK [Create docker network(s)] ************************************************

      TASK [Determine the CMD directives] ********************************************
      ok: [localhost] => (item={'image': 'milcom/centos7-systemd', 'name': 'centos7', 'pre_build_image': True, 'privileged': True})
      ok: [localhost] => (item={'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']})

      TASK [Create molecule instance(s)] *********************************************
      changed: [localhost] => (item=centos7)
      changed: [localhost] => (item=ubuntu)

      TASK [Wait for instance(s) creation to complete] *******************************
      FAILED - RETRYING: Wait for instance(s) creation to complete (300 retries left).
      changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '450424115127.6989', 'results_file': '/home/alexd/.ansible_async/450424115127.6989', 'changed': True, 'failed': False, 'item': {'image': 'milcom/centos7-systemd', 'name': 'centos7', 'pre_build_image': 
      True, 'privileged': True}, 'ansible_loop_var': 'item'})
      changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '615293618599.7017', 'results_file': '/home/alexd/.ansible_async/615293618599.7017', 'changed': True, 'failed': False, 'item': {'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']}, 'ansible_loop_var': 'item'})

      PLAY RECAP *********************************************************************
      localhost                  : ok=5    changed=2    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0

      INFO     Running default > prepare
      WARNING  Skipping, prepare playbook not configured.
      INFO     Running default > converge

      PLAY [Converge] ****************************************************************

      TASK [Gathering Facts] *********************************************************
      ok: [ubuntu]
      ok: [centos7]

      TASK [Include kibana] **********************************************************

      TASK [kibana : Fail if unsupported system detected] ****************************
      skipping: [centos7]
      skipping: [ubuntu]

      TASK [kibana : include_tasks] **************************************************
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/tasks/download_yum.yml for centos7
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/tasks/download_apt.yml for ubuntu

      TASK [kibana : Download Kibana rpm] ********************************************
      ok: [centos7 -> localhost]

      TASK [kibana : Copy kibana to managed node] ************************************
      changed: [centos7]

      TASK [kibana : Download Kibana deb] ********************************************
      ok: [ubuntu -> localhost]

      TASK [kibana : Copy kibana to managed node] ************************************
      changed: [ubuntu]

      TASK [kibana : include_tasks] **************************************************
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/tasks/install_yum.yml for centos7
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/tasks/install_apt.yml for ubuntu

      TASK [kibana : Install kibana yum] *********************************************
      changed: [centos7]

      TASK [kibana : Install kibana apt] *********************************************
      [WARNING]: Updating cache and auto-installing missing dependency: python3-apt
      changed: [ubuntu]

      TASK [kibana : Configure Kibana] ***********************************************
      changed: [centos7]
      changed: [ubuntu]

      RUNNING HANDLER [kibana : restart kibana] **************************************
      changed: [ubuntu]
      changed: [centos7]

      PLAY RECAP *********************************************************************
      centos7                    : ok=8    changed=4    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
      ubuntu                     : ok=8    changed=4    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

      INFO     Running default > idempotence

      PLAY [Converge] ****************************************************************

      TASK [Gathering Facts] *********************************************************
      ok: [ubuntu]
      ok: [centos7]

      TASK [Include kibana] **********************************************************

      TASK [kibana : Fail if unsupported system detected] ****************************
      skipping: [centos7]
      skipping: [ubuntu]

      TASK [kibana : include_tasks] **************************************************
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/tasks/download_yum.yml for centos7
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/tasks/download_apt.yml for ubuntu

      TASK [kibana : Download Kibana rpm] ********************************************
      ok: [centos7 -> localhost]

      TASK [kibana : Copy kibana to managed node] ************************************
      ok: [centos7]

      TASK [kibana : Download Kibana deb] ********************************************
      ok: [ubuntu -> localhost]

      TASK [kibana : Copy kibana to managed node] ************************************
      ok: [ubuntu]

      TASK [kibana : include_tasks] **************************************************
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/tasks/install_yum.yml for centos7
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/tasks/install_apt.yml for ubuntu

      TASK [kibana : Install kibana yum] *********************************************
      ok: [centos7]

      TASK [kibana : Install kibana apt] *********************************************
      ok: [ubuntu]

      TASK [kibana : Configure Kibana] ***********************************************
      ok: [centos7]
      ok: [ubuntu]

      PLAY RECAP *********************************************************************
      centos7                    : ok=7    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
      ubuntu                     : ok=7    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

      INFO     Idempotence completed successfully.
      INFO     Running default > side_effect
      WARNING  Skipping, side effect playbook not configured.
      INFO     Running default > verify
      INFO     Running Ansible Verifier

      PLAY [Verify] ******************************************************************

      TASK [Example assertion] *******************************************************
      ok: [centos7] => {
          "changed": false,
          "msg": "All assertions passed"
      }
      ok: [ubuntu] => {
          "changed": false,
          "msg": "All assertions passed"
      }

      TASK [Kibana install status] ***************************************************
      ok: [centos7]
      ok: [ubuntu]

      TASK [Kibana installed] ********************************************************
      ok: [centos7] => {
          "changed": false,
          "msg": "Kibana is install!"
      }
      ok: [ubuntu] => {
          "changed": false,
          "msg": "Kibana is install!"
      }

      TASK [Gathering facts] *********************************************************
      ok: [ubuntu]
      ok: [centos7]

      TASK [See service kibana] ******************************************************
      ok: [centos7] => {
          "msg": "running"
      }
      ok: [ubuntu] => {
          "msg": "running"
      }

      TASK [Verify kibana is running] ************************************************
      ok: [centos7] => {
          "changed": false,
          "msg": "Kibana is running!"
      }
      ok: [ubuntu] => {
          "changed": false,
          "msg": "Kibana is running!"
      }

      PLAY RECAP *********************************************************************
      centos7                    : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
      ubuntu                     : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

      INFO     Verifier completed successfully.
      INFO     Running default > cleanup
      WARNING  Skipping, cleanup playbook not configured.
      INFO     Running default > destroy

      PLAY [Destroy] *****************************************************************

      TASK [Destroy molecule instance(s)] ********************************************
      changed: [localhost] => (item=centos7)
      changed: [localhost] => (item=ubuntu)

      TASK [Wait for instance(s) deletion to complete] *******************************
      FAILED - RETRYING: Wait for instance(s) deletion to complete (300 retries left).
      changed: [localhost] => (item=centos7)
      changed: [localhost] => (item=ubuntu)

      TASK [Delete docker networks(s)] ***********************************************

      PLAY RECAP *********************************************************************
      localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

      INFO     Pruning extra files from scenario ephemeral directory

**Проверка пройдена успешно. Verify без ошибок, идемпотентность пройдена.**
___
**5 . Аналогичные действия для проверки роли `filebeat`:**

5.1. Создание сценария тестирования `default` для роли `kibana`:

`molecule init scenario --driver-name docker`

Создание сценария тестирования `test_filebeat` для роли `kibana`:

`molecule init scenario --driver-name docker test_filebeat`

Созданы файлы для Molecule.

**5.2. Создание инфраструктуры и тестирование роли:**

В файл `molecule.yml` добавлено следующее:

    ---
    dependency:
      name: galaxy
    driver:
      name: docker
    platforms:
      - name: centos7
        image: milcom/centos7-systemd
        pre_build_image: true
        privileged: true
      - name: ubuntu
        image: jrei/systemd-ubuntu
        pre_build_image: true
        privileged: true
        volumes:
          - "/sys/fs/cgroup:/sys/fs/cgroup:rw"
        command: "/usr/sbin/init"
    provisioner:
      name: ansible
    verifier:
      name: ansible

Тестирование будет происходит на `centos7` и на `ubuntu` с установленным systemd для запуска `handlers`

В файле `filebeat.yml.j2` внести исправление в факты, так как докер эти факты не выдает:

    setup.kibana:
      host: "http://{{ hostvars['k-instance']['ansible_facts']['default_ipv4']['address'] | default('0.0.0.0') }}:5601"
    output.elasticsearch:
      hosts: "http://{{ hostvars['el-instance']['ansible_facts']['default_ipv4']['address'] | default('0.0.0.0') }}:9200"
    filebeat.config.modules.path: ${path.config}/modules.d/*.yml 

Запуск `molecule converge -s test_filebeat`: 

      alexd@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook$ molecule converge -s test_filebeat
      INFO     test_filebeat scenario test matrix: dependency, create, prepare, converge
      INFO     Performing prerun...
      INFO     Guessed /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/
      INFO     Using /home/alexd/.cache/ansible-lint/e1b308/roles/AnsiblePlaybook symlink to current repository in order to enable Ansible to find the role using its expected full name.       
      INFO     Added ANSIBLE_ROLES_PATH=~/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles:/home/alexd/.cache/ansible-lint/e1b308/roles
      INFO     Running test_filebeat > dependency
      WARNING  Skipping, missing the requirements file.
      WARNING  Skipping, missing the requirements file.
      INFO     Running test_filebeat > create
      WARNING  Skipping, instances already created.
      INFO     Running test_filebeat > prepare
      WARNING  Skipping, prepare playbook not configured.
      INFO     Running test_filebeat > converge
      INFO     Sanity checks: 'docker'

      PLAY [Converge] ****************************************************************

      TASK [Gathering Facts] *********************************************************
      ok: [ubuntu]
      ok: [centos7]

      TASK [Include AnsiblePlaybook] *************************************************

      TASK [AnsiblePlaybook : Fail if unsupported system detected] *******************
      skipping: [centos7]
      skipping: [ubuntu]

      TASK [AnsiblePlaybook : include_tasks] *****************************************
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/tasks/download_yum.yml for centos7
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/tasks/download_apt.yml for ubuntu

      TASK [AnsiblePlaybook : Download filebeat rpm] *********************************
      ok: [centos7 -> localhost]

      TASK [AnsiblePlaybook : Copy filebeat to managed node] *************************
      ok: [centos7]

      TASK [AnsiblePlaybook : Download filebeat deb] *********************************
      ok: [ubuntu -> localhost]

      TASK [AnsiblePlaybook : Copy filebeat to managed node] *************************
      ok: [ubuntu]

      TASK [AnsiblePlaybook : include_tasks] *****************************************
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/tasks/install_yum.yml for centos7
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/tasks/install_apt.yml for ubuntu

      TASK [AnsiblePlaybook : Install filebeat yum] **********************************
      ok: [centos7]

      TASK [AnsiblePlaybook : Install filebeat deb] **********************************
      ok: [ubuntu]

      TASK [AnsiblePlaybook : Configure filebeat] ************************************
      ok: [centos7]
      ok: [ubuntu]

      TASK [AnsiblePlaybook : Set filebeat systemwork] *******************************
      ok: [ubuntu]
      ok: [centos7]

      TASK [AnsiblePlaybook : Load kibana dashboard] *********************************
      fatal: [ubuntu]: FAILED! => {"changed": true, "cmd": ["filebeat", "setup"], "delta": "0:00:00.071748", "end": "2021-09-29 09:59:20.611324", "msg": "non-zero return code", "rc": 1, "start": "2021-09-29 09:59:20.539576", "stderr": "Exiting: couldn't connect to any of the configured Elasticsearch hosts. Errors: [error connecting to Elasticsearch at http://0.0.0.0:9200: Get \"http://0.0.0.0:9200\": dial tcp 0.0.0.0:9200: connect: connection refused]", "stderr_lines": ["Exiting: couldn't connect to any of the configured Elasticsearch hosts. Errors: [error connecting to Elasticsearch at http://0.0.0.0:9200: Get \"http://0.0.0.0:9200\": dial tcp 0.0.0.0:9200: connect: connection refused]"], "stdout": "", "stdout_lines": []}
      fatal: [centos7]: FAILED! => {"changed": true, "cmd": ["filebeat", "setup"], "delta": "0:00:00.136221", "end": "2021-09-29 09:59:20.645509", "msg": "non-zero return code", "rc": 1, "start": "2021-09-29 09:59:20.509288", "stderr": "Exiting: couldn't connect to any of the configured Elasticsearch hosts. Errors: [error connecting to Elasticsearch at http://0.0.0.0:9200: Get \"http://0.0.0.0:9200\": dial tcp 0.0.0.0:9200: connect: connection refused]", "stderr_lines": ["Exiting: couldn't connect to any of the configured Elasticsearch hosts. Errors: [error 
      connecting to Elasticsearch at http://0.0.0.0:9200: Get \"http://0.0.0.0:9200\": dial tcp 0.0.0.0:9200: connect: connection refused]"], "stdout": "", "stdout_lines": []}

      PLAY RECAP *********************************************************************
      centos7                    : ok=8    changed=0    unreachable=0    failed=1    skipped=1    rescued=0    ignored=0
      ubuntu                     : ok=8    changed=0    unreachable=0    failed=1    skipped=1    rescued=0    ignored=0
___
**Возникает ошибка при тестировании таски `dashboard.yml`, так как Filebeat не может соединиться с Elasticsearch по порту 9200.**


В таске `dashboard.yml` добавлен пункт:

`changed_when: false`
`failed_when: "filebeat_setup.rc != 0 and filebeat_setup.rc != 1"`

Это позволит исключить ошибку, когда elasticsearch не установлен на этот сервер (rc=1) и пройти идемпотентность при тесте. При этом, если будет иная ошибка - тест закончится ошибкой.

**P/S. Или есть другой вариант, более правильный для исключения данной ошибки? Как правильно поступить в такой ситуации?**
___
**5.3. Добавление нескольких assrert в `verify.yml` :**

Assert на проверку установленного пакета `Filebeat`:

        - name: Filebeat install status
          package:
            name: filebeat
            state: "present"
          check_mode: true
          register: pkg_status
        - name: Filebeat installed
          assert:
            that:
              - not pkg_status.changed
            fail_msg: "Filebeat is not install"
            success_msg: "Filebeat is install!"

Assert на проверку запущенного процесса `Filebeat`:

        - name: Gathering facts
          service_facts:
        - name: See service Filebeat
          debug:
            msg: "{{ ansible_facts.services['filebeat.service'].state }}"
        - name: Verify Filebeat is running
          assert:
            that:
              - "'{{ ansible_facts.services['filebeat.service'].state }}' == 'running'"
            fail_msg: "Filebeat not running"
            success_msg: "Filebeat is running!" 

**Повторный запуск теста:**

      alexd@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook$ molecule test -s test_filebeat
      INFO     test_filebeat scenario test matrix: dependency, lint, cleanup, destroy, syntax, create, prepare, converge, idempotence, side_effect, verify, cleanup, destroy
      INFO     Performing prerun...
      INFO     Guessed /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/
      INFO     Using /home/alexd/.cache/ansible-lint/e1b308/roles/AnsiblePlaybook symlink to current repository in order to enable Ansible to find the role using its expected full name.       
      INFO     Added ANSIBLE_ROLES_PATH=~/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles:/home/alexd/.cache/ansible-lint/e1b308/roles
      INFO     Running test_filebeat > dependency
      WARNING  Skipping, missing the requirements file.
      WARNING  Skipping, missing the requirements file.
      INFO     Running test_filebeat > lint
      INFO     Lint is disabled.
      INFO     Running test_filebeat > cleanup
      WARNING  Skipping, cleanup playbook not configured.
      INFO     Running test_filebeat > destroy
      INFO     Sanity checks: 'docker'

      PLAY [Destroy] *****************************************************************

      TASK [Destroy molecule instance(s)] ********************************************
      changed: [localhost] => (item=centos7)
      changed: [localhost] => (item=ubuntu)

      TASK [Wait for instance(s) deletion to complete] *******************************
      FAILED - RETRYING: Wait for instance(s) deletion to complete (300 retries left).
      changed: [localhost] => (item=centos7)
      changed: [localhost] => (item=ubuntu)

      TASK [Delete docker networks(s)] ***********************************************

      PLAY RECAP *********************************************************************
      localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

      INFO     Running test_filebeat > syntax

      playbook: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/molecule/test_filebeat/converge.yml
      INFO     Running test_filebeat > create

      PLAY [Create] ******************************************************************

      TASK [Log into a Docker registry] **********************************************
      skipping: [localhost] => (item=None) 
      skipping: [localhost] => (item=None) 
      skipping: [localhost]

      TASK [Check presence of custom Dockerfiles] ************************************
      ok: [localhost] => (item={'image': 'milcom/centos7-systemd', 'name': 'centos7', 'pre_build_image': True, 'privileged': True})
      ok: [localhost] => (item={'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']})

      TASK [Create Dockerfiles from image names] *************************************
      skipping: [localhost] => (item={'image': 'milcom/centos7-systemd', 'name': 'centos7', 'pre_build_image': True, 'privileged': True})
      skipping: [localhost] => (item={'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 
      'name': 'ubuntu', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']})

      TASK [Discover local Docker images] ********************************************
      ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'milcom/centos7-systemd', 'name': 'centos7', 'pre_build_image': True, 'privileged': True}, 'ansible_loop_var': 'item', 'i': 0, 'ansible_index_var': 'i'})ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 
      'ubuntu', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']}, 'ansible_loop_var': 'item', 'i': 1, 'ansible_index_var': 'i'})

      TASK [Build an Ansible compatible image (new)] *********************************
      skipping: [localhost] => (item=molecule_local/milcom/centos7-systemd) 
      skipping: [localhost] => (item=molecule_local/jrei/systemd-ubuntu) 

      TASK [Create docker network(s)] ************************************************

      TASK [Determine the CMD directives] ********************************************
      ok: [localhost] => (item={'image': 'milcom/centos7-systemd', 'name': 'centos7', 'pre_build_image': True, 'privileged': True})
      ok: [localhost] => (item={'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']})

      TASK [Create molecule instance(s)] *********************************************
      changed: [localhost] => (item=centos7)
      changed: [localhost] => (item=ubuntu)

      TASK [Wait for instance(s) creation to complete] *******************************
      FAILED - RETRYING: Wait for instance(s) creation to complete (300 retries left).
      changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '730101796946.19875', 'results_file': '/home/alexd/.ansible_async/730101796946.19875', 'changed': True, 'failed': False, 'item': {'image': 'milcom/centos7-systemd', 'name': 'centos7', 'pre_build_image': True, 'privileged': True}, 'ansible_loop_var': 'item'})
      changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '400975955022.19904', 'results_file': '/home/alexd/.ansible_async/400975955022.19904', 'changed': True, 'failed': False, 'item': {'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']}, 'ansible_loop_var': 'item'})

      PLAY RECAP *********************************************************************
      localhost                  : ok=5    changed=2    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0

      INFO     Running test_filebeat > prepare
      WARNING  Skipping, prepare playbook not configured.
      INFO     Running test_filebeat > converge

      PLAY [Converge] ****************************************************************

      TASK [Gathering Facts] *********************************************************
      ok: [ubuntu]
      ok: [centos7]

      TASK [Include AnsiblePlaybook] *************************************************

      TASK [AnsiblePlaybook : Fail if unsupported system detected] *******************
      skipping: [centos7]
      skipping: [ubuntu]

      TASK [AnsiblePlaybook : include_tasks] *****************************************
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/tasks/download_yum.yml for centos7
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/tasks/download_apt.yml for ubuntu

      TASK [AnsiblePlaybook : Download filebeat rpm] *********************************
      ok: [centos7 -> localhost]

      TASK [AnsiblePlaybook : Copy filebeat to managed node] *************************
      changed: [centos7]

      TASK [AnsiblePlaybook : Download filebeat deb] *********************************
      ok: [ubuntu -> localhost]

      TASK [AnsiblePlaybook : Copy filebeat to managed node] *************************
      changed: [ubuntu]

      TASK [AnsiblePlaybook : include_tasks] *****************************************
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/tasks/install_yum.yml for centos7
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/tasks/install_apt.yml for ubuntu

      TASK [AnsiblePlaybook : Install filebeat yum] **********************************
      changed: [centos7]

      TASK [AnsiblePlaybook : Install filebeat deb] **********************************
      [WARNING]: Updating cache and auto-installing missing dependency: python3-apt
      changed: [ubuntu]

      TASK [AnsiblePlaybook : Configure filebeat] ************************************
      changed: [centos7]
      changed: [ubuntu]

      TASK [AnsiblePlaybook : Set filebeat systemwork] *******************************
      changed: [centos7]
      changed: [ubuntu]

      TASK [AnsiblePlaybook : Load kibana dashboard] *********************************
      ok: [ubuntu]
      ok: [centos7]

      RUNNING HANDLER [AnsiblePlaybook : restart filebeat] ***************************
      changed: [ubuntu]
      changed: [centos7]

      PLAY RECAP *********************************************************************
      centos7                    : ok=10   changed=5    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
      ubuntu                     : ok=10   changed=5    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

      INFO     Running test_filebeat > idempotence

      PLAY [Converge] ****************************************************************

      TASK [Gathering Facts] *********************************************************
      ok: [ubuntu]
      ok: [centos7]

      TASK [Include AnsiblePlaybook] *************************************************

      TASK [AnsiblePlaybook : Fail if unsupported system detected] *******************
      skipping: [centos7]
      skipping: [ubuntu]

      TASK [AnsiblePlaybook : include_tasks] *****************************************
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/tasks/download_yum.yml for centos7
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/tasks/download_apt.yml for ubuntu

      TASK [AnsiblePlaybook : Download filebeat rpm] *********************************
      ok: [centos7 -> localhost]

      TASK [AnsiblePlaybook : Copy filebeat to managed node] *************************
      ok: [centos7]

      TASK [AnsiblePlaybook : Download filebeat deb] *********************************
      ok: [ubuntu -> localhost]

      TASK [AnsiblePlaybook : Copy filebeat to managed node] *************************
      ok: [ubuntu]

      TASK [AnsiblePlaybook : include_tasks] *****************************************
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/tasks/install_yum.yml for centos7
      included: /mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/tasks/install_apt.yml for ubuntu

      TASK [AnsiblePlaybook : Install filebeat yum] **********************************
      ok: [centos7]

      TASK [AnsiblePlaybook : Install filebeat deb] **********************************
      ok: [ubuntu]

      TASK [AnsiblePlaybook : Configure filebeat] ************************************
      ok: [centos7]
      ok: [ubuntu]

      TASK [AnsiblePlaybook : Set filebeat systemwork] *******************************
      ok: [ubuntu]
      ok: [centos7]

      TASK [AnsiblePlaybook : Load kibana dashboard] *********************************
      ok: [ubuntu]
      ok: [centos7]

      PLAY RECAP *********************************************************************
      centos7                    : ok=9    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
      ubuntu                     : ok=9    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

      INFO     Idempotence completed successfully.
      INFO     Running test_filebeat > side_effect
      WARNING  Skipping, side effect playbook not configured.
      INFO     Running test_filebeat > verify
      INFO     Running Ansible Verifier

      PLAY [Verify] ******************************************************************

      TASK [Example assertion] *******************************************************
      ok: [centos7] => {
          "changed": false,
          "msg": "All assertions passed"
      }
      ok: [ubuntu] => {
          "changed": false,
          "msg": "All assertions passed"
      }

      TASK [Filebeat install status] *************************************************
      ok: [centos7]
      ok: [ubuntu]

      TASK [Filebeat installed] ******************************************************
      ok: [centos7] => {
          "changed": false,
          "msg": "Filebeat is install!"
      }
      ok: [ubuntu] => {
          "changed": false,
          "msg": "Filebeat is install!"
      }

      TASK [Gathering facts] *********************************************************
      ok: [ubuntu]
      ok: [centos7]

      TASK [See service Filebeat] ****************************************************
      ok: [centos7] => {
          "msg": "running"
      }
      ok: [ubuntu] => {
          "msg": "running"
      }

      TASK [Verify Filebeat is running] **********************************************
      ok: [centos7] => {
          "changed": false,
          "msg": "Filebeat is running!"
      }
      ok: [ubuntu] => {
          "changed": false,
          "msg": "Filebeat is running!"
      }

      PLAY RECAP *********************************************************************
      centos7                    : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
      ubuntu                     : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

      INFO     Verifier completed successfully.
      INFO     Running test_filebeat > cleanup
      WARNING  Skipping, cleanup playbook not configured.
      INFO     Running test_filebeat > destroy

      PLAY [Destroy] *****************************************************************

      TASK [Destroy molecule instance(s)] ********************************************
      changed: [localhost] => (item=centos7)
      changed: [localhost] => (item=ubuntu)

      TASK [Wait for instance(s) deletion to complete] *******************************
      FAILED - RETRYING: Wait for instance(s) deletion to complete (300 retries left).
      changed: [localhost] => (item=centos7)
      changed: [localhost] => (item=ubuntu)

      TASK [Delete docker networks(s)] ***********************************************

      PLAY RECAP *********************************************************************
      localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

      INFO     Pruning extra files from scenario ephemeral directory

**Проверка пройдена успешно. Verify без ошибок, идемпотентность пройдена.**

___

**Работа с TOX**

**0. Создание docker образа:**

Необходимо создать аккаунт на `https://access.redhat.com/RegistryAuthentication`

Залогиниться в docker: `docker login https://registry.redhat.io`

Создание docker образа из dockerfile: `docker -t updatetox .`

**1. Запуск контейнера docker с помощью команды:**

      docker run -ti -v $(pwd):/opt/roles --privileged=True --name test -w /opt/roles updatetox /bin/bash

**2. Запуск команды `tox` внутри контейнера docker для роли `Elasticsearch`:**

      [root@docker-desktop elastic]# tox
      py36-ansible28 installed: ansible==2.8.20,ansible-lint==5.1.3,arrow==1.1.1,bcrypt==3.2.0,binaryornot==0.4.4,bracex==2.1.1,Cerberus==1.3.2,certifi==2021.5.30,cffi==1.14.6,chardet==4.0.0,charset-normalizer==2.0.6,click==8.0.1,click-help-colors==0.9.1,colorama==0.4.4,commonmark==0.9.1,cookiecutter==1.7.3,cryptography==35.0.0,dataclasses==0.8,distro==1.6.0,enrich==1.2.6,idna==3.2,importlib-metadata==4.8.1,Jinja2==3.0.1,jinja2-time==0.2.0,MarkupSafe==2.0.1,molecule==3.4.0,molecule-podman==0.3.0,packaging==21.0,paramiko==2.7.2,pathspec==0.9.0,pluggy==0.13.1,podman==3.2.1,poyo==0.5.0,pycparser==2.20,Pygments==2.10.0,PyNaCl==1.4.0,pyparsing==2.4.7,python-dateutil==2.8.2,python-slugify==5.0.2,pyxdg==0.27,PyYAML==5.4.1,requests==2.26.0,rich==10.11.0,ruamel.yaml==0.17.16,ruamel.yaml.clib==0.2.6,selinux==0.2.1,six==1.16.0,subprocess-tee==0.3.4,tenacity==8.0.1,text-unidecode==1.3,toml==0.10.2,typing-extensions==3.10.0.2,urllib3==1.26.7,wcmatch==8.2,yamllint==1.26.3,zipp==3.6.0
      py36-ansible28 run-test-pre: PYTHONHASHSEED='1991505935'
      py36-ansible28 run-test: commands[0] | molecule test
      INFO     default scenario test matrix: destroy, create, converge, destroy
      INFO     Performing prerun...
      WARNING  Failed to locate command: [Errno 2] No such file or directory: 'git': 'git'
      INFO     Guessed /opt/roles/elastic as project root directory
      WARNING  Computed fully qualified role name of elasticsearch_role does not follow current galaxy requirements.
      Please edit meta/main.yml and assure we can correctly determine full role name:        

      galaxy_info:
      role_name: my_name  # if absent directory name hosting role is used instead
      namespace: my_galaxy_namespace  # if absent, author is used instead

      Namespace: https://galaxy.ansible.com/docs/contributing/namespaces.html#galaxy-namespace-limitations
      Role: https://galaxy.ansible.com/docs/contributing/creating_role.html#role-names       

      As an alternative, you can add 'role-name' to either skip_list or warn_list.

      INFO     Using /root/.cache/ansible-lint/8a87c8/roles/elasticsearch_role symlink to current repository in order to enable Ansible to find the role using its expected full name.
      INFO     Added ANSIBLE_ROLES_PATH=~/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles:/root/.cache/ansible-lint/8a87c8/roles
      INFO     Running default > destroy
      INFO     Sanity checks: 'podman'

      PLAY [Destroy] ************************************************************************
      TASK [Destroy molecule instance(s)] ***************************************************changed: [localhost] => (item={'image': 'milcom/centos7-systemd', 'name': 'centos73', 'network': 'host', 'pre_build_image': True, 'privileged': True})
      changed: [localhost] => (item={'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu', 'network': 'host', 'pre_build_image': True, 'privileged': True, 
      'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']})

      TASK [Wait for instance(s) deletion to complete] **************************************changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '732705382813.26638', 'results_file': '/root/.ansible_async/732705382813.26638', 'changed': True, 'failed': False, 'item': {'image': 'milcom/centos7-systemd', 'name': 'centos73', 'network': 'host', 'pre_build_image': True, 'privileged': True}, 'ansible_loop_var': 'item'})
      changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '276179924067.26659', 'results_file': '/root/.ansible_async/276179924067.26659', 'changed': True, 'failed': False, 'item': {'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']}, 'ansible_loop_var': 'item'})

      PLAY RECAP ****************************************************************************localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

      INFO     Running default > create

      PLAY [Create] *************************************************************************
      TASK [Log into a container registry] **************************************************skipping: [localhost] => (item={'image': 'milcom/centos7-systemd', 'name': 'centos73', 
      'network': 'host', 'pre_build_image': True, 'privileged': True})
      skipping: [localhost] => (item={'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']})

      TASK [Check presence of custom Dockerfiles] *******************************************ok: [localhost] => (item={'image': 'milcom/centos7-systemd', 'name': 'centos73', 'network': 'host', 'pre_build_image': True, 'privileged': True})
      ok: [localhost] => (item={'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 
      'name': 'ubuntu', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']})

      TASK [Create Dockerfiles from image names] ********************************************skipping: [localhost] => (item={'image': 'milcom/centos7-systemd', 'name': 'centos73', 
      'network': 'host', 'pre_build_image': True, 'privileged': True})
      skipping: [localhost] => (item={'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']})

      TASK [Discover local Podman images] ***************************************************ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'milcom/centos7-systemd', 'name': 'centos73', 'network': 'host', 'pre_build_image': True, 'privileged': True}, 'ansible_loop_var': 'item', 'i': 0, 'ansible_index_var': 'i'})
      ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']}, 'ansible_loop_var': 'item', 'i': 1, 'ansible_index_var': 'i'})

      TASK [Build an Ansible compatible image] **********************************************skipping: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'milcom/centos7-systemd', 'name': 'centos73', 'network': 'host', 'pre_build_image': True, 'privileged': True}, 'ansible_loop_var': 'item', 'i': 0, 'ansible_index_var': 'i'})
      skipping: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']}, 'ansible_loop_var': 'item', 'i': 1, 'ansible_index_var': 'i'})

      TASK [Determine the CMD directives] ***************************************************ok: [localhost] => (item={'image': 'milcom/centos7-systemd', 'name': 'centos73', 'network': 'host', 'pre_build_image': True, 'privileged': True})
      ok: [localhost] => (item={'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 
      'name': 'ubuntu', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']})

      TASK [Create molecule instance(s)] ****************************************************changed: [localhost] => (item={'image': 'milcom/centos7-systemd', 'name': 'centos73', 'network': 'host', 'pre_build_image': True, 'privileged': True})
      changed: [localhost] => (item={'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu', 'network': 'host', 'pre_build_image': True, 'privileged': True, 
      'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']})

      TASK [Wait for instance(s) creation to complete] **************************************changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '380216599311.29026', 'results_file': '/root/.ansible_async/380216599311.29026', 'changed': True, 'failed': False, 'item': {'image': 'milcom/centos7-systemd', 'name': 'centos73', 'network': 'host', 'pre_build_image': True, 'privileged': True}, 'ansible_loop_var': 'item'})
      changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '258388910631.29166', 'results_file': '/root/.ansible_async/258388910631.29166', 'changed': True, 'failed': False, 'item': {'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']}, 'ansible_loop_var': 'item'})

      PLAY RECAP ****************************************************************************localhost                  : ok=5    changed=2    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0

      INFO     Running default > converge

      PLAY [Converge] ***********************************************************************
      TASK [Gathering Facts] ****************************************************************ok: [ubuntu]
      ok: [centos73]

      TASK [Include mnt-homeworks-ansible] **************************************************
      TASK [elastic : Fail if unsupported system detected] **********************************skipping: [centos73]
      skipping: [ubuntu]

      TASK [elastic : include_tasks] ********************************************************included: /opt/roles/elastic/tasks/download_yum.yml for centos73
      included: /opt/roles/elastic/tasks/download_apt.yml for ubuntu

      TASK [elastic : Download Elasticsearch's rpm] *****************************************ok: [centos73 -> localhost]

      TASK [elastic : Copy Elasticsearch to managed node] ***********************************changed: [centos73]

      TASK [elastic : Download Elasticsearch's deb] *****************************************ok: [ubuntu -> localhost]

      TASK [elastic : Copy Elasticsearch to manage host] ************************************changed: [ubuntu]

      TASK [elastic : include_tasks] ********************************************************included: /opt/roles/elastic/tasks/install_yum.yml for centos73
      included: /opt/roles/elastic/tasks/install_apt.yml for ubuntu

      TASK [elastic : Install Elasticsearch] ************************************************changed: [centos73]

      TASK [elastic : Install Elasticsearch] ************************************************[WARNING]: Updating cache and auto-installing missing dependency: python3-apt
      changed: [ubuntu]

      TASK [elastic : Configure Elasticsearch] **********************************************changed: [centos73]
      changed: [ubuntu]

      RUNNING HANDLER [elastic : restart Elasticsearch] *************************************skipping: [centos73]
      skipping: [ubuntu]

      PLAY RECAP ****************************************************************************centos73                   : ok=7    changed=3    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
      ubuntu                     : ok=7    changed=3    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0

      INFO     Running default > destroy

      PLAY [Destroy] ************************************************************************
      TASK [Destroy molecule instance(s)] ***************************************************changed: [localhost] => (item={'image': 'milcom/centos7-systemd', 'name': 'centos73', 'network': 'host', 'pre_build_image': True, 'privileged': True})
      changed: [localhost] => (item={'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu', 'network': 'host', 'pre_build_image': True, 'privileged': True, 
      'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']})

      TASK [Wait for instance(s) deletion to complete] **************************************changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '83818782853.9175', 'results_file': '/root/.ansible_async/83818782853.9175', 'changed': True, 'failed': False, 'item': {'image': 'milcom/centos7-systemd', 'name': 'centos73', 'network': 'host', 'pre_build_image': True, 'privileged': True}, 'ansible_loop_var': 'item'})  
      changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '195829607008.9196', 'results_file': '/root/.ansible_async/195829607008.9196', 'changed': True, 
      'failed': False, 'item': {'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 
      'name': 'ubuntu', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']}, 'ansible_loop_var': 'item'})

      PLAY RECAP ****************************************************************************localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

      INFO     Pruning extra files from scenario ephemeral directory
      _______________________________________ summary _______________________________________  py36-ansible28: commands succeeded
        congratulations :)

**3. Создание облегченного сценария для Molecule для роли `Kibana`:**

В файле `molecule.yml` добавлен сценарий:

    scenario:
      test_sequence:
        - destroy
        - create
        - converge
        - destroy

**4. Обновлен файл `tox.ini` для запуска сценария для роли `Kibana`:**

      [tox]
      minversion = 1.8
      basepython = python3.6
      envlist = py{36}-ansible{28}
      skipsdist = true

      [testenv]
      deps =
          -rtest-requirements.txt
          ansible28: ansible<2.9
          ansible29: ansible<2.10
          ansible210: ansible<3.0
          ansible30: ansible<3.1
      commands =
          {posargs:molecule test}

**5. Запуск команды `tox` внутри контейнера docker для роли `Kibana`:**

        [root@docker-desktop kibana]# tox
        py36-ansible28 installed: ansible==2.8.20,ansible-lint==5.1.3,arrow==1.1.1,bcrypt==3.2.0,binaryornot==0.4.4,bracex==2.1.1,Cerberus==1.3.2,certifi==2021.5.30,cffi==1.14.6,chardet==4.0.0,charset-normalizer==2.0.6,click==8.0.1,click-help-colors==0.9.1,colorama==0.4.4,commonmark==0.9.1,cookiecutter==1.7.3,cryptography==35.0.0,dataclasses==0.8,distro==1.6.0,enrich==1.2.6,idna==3.2,importlib-metadata==4.8.1,Jinja2==3.0.1,jinja2-time==0.2.0,MarkupSafe==2.0.1,molecule==3.4.0,molecule-podman==0.2.3,packaging==21.0,paramiko==2.7.2,pathspec==0.9.0,pluggy==0.13.1,podman==3.2.1,poyo==0.5.0,pycparser==2.20,Pygments==2.10.0,PyNaCl==1.4.0,pyparsing==2.4.7,python-dateutil==2.8.2,python-slugify==5.0.2,pyxdg==0.27,PyYAML==5.4.1,requests==2.26.0,rich==10.11.0,ruamel.yaml==0.17.16,ruamel.yaml.clib==0.2.6,selinux==0.2.1,six==1.16.0,subprocess-tee==0.3.4,tenacity==8.0.1,text-unidecode==1.3,toml==0.10.2,typing-extensions==3.10.0.2,urllib3==1.26.7,wcmatch==8.2,yamllint==1.26.3,zipp==3.6.0
        py36-ansible28 run-test-pre: PYTHONHASHSEED='1005359677'
        py36-ansible28 run-test: commands[0] | molecule test
        INFO     default scenario test matrix: destroy, create, converge, destroy
        INFO     Performing prerun...
        WARNING  Failed to locate command: [Errno 2] No such file or directory: 'git': 'git'
        INFO     Guessed /opt/roles/kibana as project root directory
        WARNING  Computed fully qualified role name of kibana does not follow current galaxy requirements.
        Please edit meta/main.yml and assure we can correctly determine full role name:        

        galaxy_info:
        role_name: my_name  # if absent directory name hosting role is used instead
        namespace: my_galaxy_namespace  # if absent, author is used instead

        Namespace: https://galaxy.ansible.com/docs/contributing/namespaces.html#galaxy-namespace-limitations
        Role: https://galaxy.ansible.com/docs/contributing/creating_role.html#role-names       

        As an alternative, you can add 'role-name' to either skip_list or warn_list.

        INFO     Using /root/.cache/ansible-lint/e3589c/roles/kibana symlink to current repository in order to enable Ansible to find the role using its expected full name.
        INFO     Added ANSIBLE_ROLES_PATH=~/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles:/root/.cache/ansible-lint/e3589c/roles
        INFO     Running default > destroy
        INFO     Sanity checks: 'podman'

        PLAY [Destroy] ************************************************************************
        TASK [Destroy molecule instance(s)] ***************************************************changed: [localhost] => (item={'image': 'milcom/centos7-systemd', 'name': 'centos71', 'network': 'host', 'pre_build_image': True, 'privileged': True})
        changed: [localhost] => (item={'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu1', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']})

        TASK [Wait for instance(s) deletion to complete] **************************************changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '869424525705.26782', 'results_file': '/root/.ansible_async/869424525705.26782', 'changed': True, 'failed': False, 'item': {'image': 'milcom/centos7-systemd', 'name': 'centos71', 'network': 'host', 'pre_build_image': True, 'privileged': True}, 'ansible_loop_var': 'item'})
        changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '618323983897.26803', 'results_file': '/root/.ansible_async/618323983897.26803', 'changed': True, 'failed': False, 'item': {'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu1', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']}, 'ansible_loop_var': 'item'})

        PLAY RECAP ****************************************************************************localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

        INFO     Running default > create

        PLAY [Create] *************************************************************************
        TASK [Log into a container registry] **************************************************skipping: [localhost] => (item={'image': 'milcom/centos7-systemd', 'name': 'centos71', 
        'network': 'host', 'pre_build_image': True, 'privileged': True})
        skipping: [localhost] => (item={'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu1', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']})

        TASK [Check presence of custom Dockerfiles] *******************************************ok: [localhost] => (item={'image': 'milcom/centos7-systemd', 'name': 'centos71', 'network': 'host', 'pre_build_image': True, 'privileged': True})
        ok: [localhost] => (item={'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 
        'name': 'ubuntu1', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']})

        TASK [Create Dockerfiles from image names] ********************************************skipping: [localhost] => (item={'image': 'milcom/centos7-systemd', 'name': 'centos71', 
        'network': 'host', 'pre_build_image': True, 'privileged': True})
        skipping: [localhost] => (item={'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu1', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']})

        TASK [Discover local Podman images] ***************************************************ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'milcom/centos7-systemd', 'name': 'centos71', 'network': 'host', 'pre_build_image': True, 'privileged': True}, 'ansible_loop_var': 'item', 'i': 0, 'ansible_index_var': 'i'})
        ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu1', 'network': 'host', 'pre_build_image': True, 'privileged': True, 
        'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']}, 'ansible_loop_var': 'item', 'i': 1, 'ansible_index_var': 'i'})

        TASK [Build an Ansible compatible image] **********************************************skipping: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'milcom/centos7-systemd', 'name': 'centos71', 'network': 'host', 'pre_build_image': True, 'privileged': True}, 'ansible_loop_var': 'item', 'i': 0, 'ansible_index_var': 'i'})
        skipping: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu1', 'network': 'host', 'pre_build_image': True, 'privileged': 
        True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']}, 'ansible_loop_var': 'item', 'i': 1, 'ansible_index_var': 'i'})

        TASK [Determine the CMD directives] ***************************************************ok: [localhost] => (item={'image': 'milcom/centos7-systemd', 'name': 'centos71', 'network': 'host', 'pre_build_image': True, 'privileged': True})
        ok: [localhost] => (item={'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 
        'name': 'ubuntu1', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']})

        TASK [Create molecule instance(s)] ****************************************************changed: [localhost] => (item={'image': 'milcom/centos7-systemd', 'name': 'centos71', 'network': 'host', 'pre_build_image': True, 'privileged': True})
        changed: [localhost] => (item={'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu1', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']})

        TASK [Wait for instance(s) creation to complete] **************************************changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '384249722970.30515', 'results_file': '/root/.ansible_async/384249722970.30515', 'changed': True, 'failed': False, 'item': {'image': 'milcom/centos7-systemd', 'name': 'centos71', 'network': 'host', 'pre_build_image': True, 'privileged': True}, 'ansible_loop_var': 'item'})
        changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '256243762635.30545', 'results_file': '/root/.ansible_async/256243762635.30545', 'changed': True, 'failed': False, 'item': {'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu1', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']}, 'ansible_loop_var': 'item'})

        PLAY RECAP ****************************************************************************localhost                  : ok=5    changed=2    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0

        INFO     Running default > converge

        PLAY [Converge] ***********************************************************************
        TASK [Gathering Facts] ****************************************************************ok: [ubuntu1]
        ok: [centos71]

        TASK [Include kibana] *****************************************************************
        TASK [kibana : Fail if unsupported system detected] ***********************************skipping: [centos71]
        skipping: [ubuntu1]

        TASK [kibana : include_tasks] *********************************************************included: /opt/roles/kibana/tasks/download_yum.yml for centos71
        included: /opt/roles/kibana/tasks/download_apt.yml for ubuntu1

        TASK [kibana : Download Kibana rpm] ***************************************************ok: [centos71 -> localhost]

        TASK [kibana : Copy kibana to managed node] *******************************************changed: [centos71]

        TASK [kibana : Download Kibana deb] ***************************************************changed: [ubuntu1 -> localhost]

        TASK [kibana : Copy kibana to managed node] *******************************************changed: [ubuntu1]

        TASK [kibana : include_tasks] *********************************************************included: /opt/roles/kibana/tasks/install_yum.yml for centos71
        included: /opt/roles/kibana/tasks/install_apt.yml for ubuntu1

        TASK [kibana : Install kibana yum] ****************************************************changed: [centos71]

        TASK [kibana : Install kibana apt] ****************************************************[WARNING]: Updating cache and auto-installing missing dependency: python3-apt
        changed: [ubuntu1]

        TASK [kibana : Configure Kibana] ******************************************************changed: [centos71]
        changed: [ubuntu1]

        RUNNING HANDLER [kibana : restart kibana] *********************************************changed: [centos71]
        changed: [ubuntu1]

        PLAY RECAP ****************************************************************************centos71                   : ok=8    changed=4    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
        ubuntu1                    : ok=8    changed=5    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

        INFO     Running default > destroy

        PLAY [Destroy] ************************************************************************
        TASK [Destroy molecule instance(s)] ***************************************************changed: [localhost] => (item={'image': 'milcom/centos7-systemd', 'name': 'centos71', 'network': 'host', 'pre_build_image': True, 'privileged': True})
        changed: [localhost] => (item={'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu1', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']})

        TASK [Wait for instance(s) deletion to complete] **************************************FAILED - RETRYING: Wait for instance(s) deletion to complete (300 retries left).
        changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '280760858326.12393', 'results_file': '/root/.ansible_async/280760858326.12393', 'changed': True, 'failed': False, 'item': {'image': 'milcom/centos7-systemd', 'name': 'centos71', 'network': 'host', 'pre_build_image': True, 'privileged': True}, 'ansible_loop_var': 'item'})
        changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '545808891619.12414', 'results_file': '/root/.ansible_async/545808891619.12414', 'changed': True, 'failed': False, 'item': {'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu1', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']}, 'ansible_loop_var': 'item'})

        PLAY RECAP ****************************************************************************localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

        INFO     Pruning extra files from scenario ephemeral directory
        _______________________________________ summary _______________________________________  py36-ansible28: commands succeeded
          congratulations :)

**6. Создание облегченного сценария для Molecule для роли `Filebeat`:**

В файле `molecule.yml` добавлен сценарий:

    scenario:
      test_sequence:
        - destroy
        - create
        - converge
        - destroy

**7. Обновлен файл `tox.ini` для запуска сценария для роли `Filebeat`:**

      [tox]
      minversion = 1.8
      basepython = python3.6
      envlist = py{36}-ansible{28}
      skipsdist = true

      [testenv]
      deps =
          -rtest-requirements.txt
          ansible28: ansible<2.9
          ansible29: ansible<2.10
          ansible210: ansible<3.0
          ansible30: ansible<3.1
      commands =
          {posargs:molecule test -s test_filebeat --destroy=always}

**8. Проверка запуска `tox` для роли `Filebeat`:**

        [root@docker-desktop filebeat]# tox
        py36-ansible28 installed: ansible==2.8.20,ansible-lint==5.1.3,arrow==1.1.1,bcrypt==3.2.0,binaryornot==0.4.4,bracex==2.1.1,Cerberus==1.3.2,certifi==2021.5.30,cffi==1.14.6,chardet==4.0.0,charset-normalizer==2.0.6,click==8.0.1,click-help-colors==0.9.1,colorama==0.4.4,commonmark==0.9.1,cookiecutter==1.7.3,cryptography==35.0.0,dataclasses==0.8,distro==1.6.0,enrich==1.2.6,idna==3.2,importlib-metadata==4.8.1,Jinja2==3.0.1,jinja2-time==0.2.0,MarkupSafe==2.0.1,molecule==3.4.0,molecule-podman==0.3.0,packaging==21.0,paramiko==2.7.2,pathspec==0.9.0,pluggy==0.13.1,podman==3.2.1,poyo==0.5.0,pycparser==2.20,Pygments==2.10.0,PyNaCl==1.4.0,pyparsing==2.4.7,python-dateutil==2.8.2,python-slugify==5.0.2,pyxdg==0.27,PyYAML==5.4.1,requests==2.26.0,rich==10.11.0,ruamel.yaml==0.17.16,ruamel.yaml.clib==0.2.6,selinux==0.2.1,six==1.16.0,subprocess-tee==0.3.4,tenacity==8.0.1,text-unidecode==1.3,toml==0.10.2,typing-extensions==3.10.0.2,urllib3==1.26.7,wcmatch==8.2,yamllint==1.26.3,zipp==3.6.0
        py36-ansible28 run-test-pre: PYTHONHASHSEED='4112008623'
        py36-ansible28 run-test: commands[0] | molecule test -s test_filebeat --destroy=always 
        INFO     test_filebeat scenario test matrix: destroy, create, converge, destroy
        INFO     Performing prerun...
        WARNING  Failed to locate command: [Errno 2] No such file or directory: 'git': 'git'
        INFO     Guessed /opt/roles/filebeat as project root directory
        WARNING  Computed fully qualified role name of filebeat does not follow current galaxy 
        requirements.
        Please edit meta/main.yml and assure we can correctly determine full role name:        

        galaxy_info:
        role_name: my_name  # if absent directory name hosting role is used instead
        namespace: my_galaxy_namespace  # if absent, author is used instead

        Namespace: https://galaxy.ansible.com/docs/contributing/namespaces.html#galaxy-namespace-limitations
        Role: https://galaxy.ansible.com/docs/contributing/creating_role.html#role-names       

        As an alternative, you can add 'role-name' to either skip_list or warn_list.

        INFO     Using /root/.cache/ansible-lint/eb47fa/roles/filebeat symlink to current repository in order to enable Ansible to find the role using its expected full name.        
        INFO     Added ANSIBLE_ROLES_PATH=~/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles:/root/.cache/ansible-lint/eb47fa/roles
        INFO     Running test_filebeat > destroy
        INFO     Sanity checks: 'podman'

        PLAY [Destroy] ************************************************************************
        TASK [Destroy molecule instance(s)] ***************************************************changed: [localhost] => (item={'image': 'milcom/centos7-systemd', 'name': 'centos72', 'network': 'host', 'pre_build_image': True, 'privileged': True})
        changed: [localhost] => (item={'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu2', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']})

        TASK [Wait for instance(s) deletion to complete] **************************************changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '243096827595.26060', 'results_file': '/root/.ansible_async/243096827595.26060', 'changed': True, 'failed': False, 'item': {'image': 'milcom/centos7-systemd', 'name': 'centos72', 'network': 'host', 'pre_build_image': True, 'privileged': True}, 'ansible_loop_var': 'item'})
        changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '247477866913.26081', 'results_file': '/root/.ansible_async/247477866913.26081', 'changed': True, 'failed': False, 'item': {'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu2', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']}, 'ansible_loop_var': 'item'})

        PLAY RECAP ****************************************************************************localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

        INFO     Running test_filebeat > create

        PLAY [Create] *************************************************************************
        TASK [Log into a container registry] **************************************************skipping: [localhost] => (item={'image': 'milcom/centos7-systemd', 'name': 'centos72', 
        'network': 'host', 'pre_build_image': True, 'privileged': True})
        skipping: [localhost] => (item={'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu2', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']})

        TASK [Check presence of custom Dockerfiles] *******************************************ok: [localhost] => (item={'image': 'milcom/centos7-systemd', 'name': 'centos72', 'network': 'host', 'pre_build_image': True, 'privileged': True})
        ok: [localhost] => (item={'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 
        'name': 'ubuntu2', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']})

        TASK [Create Dockerfiles from image names] ********************************************skipping: [localhost] => (item={'image': 'milcom/centos7-systemd', 'name': 'centos72', 
        'network': 'host', 'pre_build_image': True, 'privileged': True})
        skipping: [localhost] => (item={'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu2', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']})

        TASK [Discover local Podman images] ***************************************************ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'milcom/centos7-systemd', 'name': 'centos72', 'network': 'host', 'pre_build_image': True, 'privileged': True}, 'ansible_loop_var': 'item', 'i': 0, 'ansible_index_var': 'i'})
        ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu2', 'network': 'host', 'pre_build_image': True, 'privileged': True, 
        'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']}, 'ansible_loop_var': 'item', 'i': 1, 'ansible_index_var': 'i'})

        TASK [Build an Ansible compatible image] **********************************************skipping: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'milcom/centos7-systemd', 'name': 'centos72', 'network': 'host', 'pre_build_image': True, 'privileged': True}, 'ansible_loop_var': 'item', 'i': 0, 'ansible_index_var': 'i'})
        skipping: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu2', 'network': 'host', 'pre_build_image': True, 'privileged': 
        True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']}, 'ansible_loop_var': 'item', 'i': 1, 'ansible_index_var': 'i'})

        TASK [Determine the CMD directives] ***************************************************ok: [localhost] => (item={'image': 'milcom/centos7-systemd', 'name': 'centos72', 'network': 'host', 'pre_build_image': True, 'privileged': True})
        ok: [localhost] => (item={'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 
        'name': 'ubuntu2', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']})

        TASK [Create molecule instance(s)] ****************************************************changed: [localhost] => (item={'image': 'milcom/centos7-systemd', 'name': 'centos72', 'network': 'host', 'pre_build_image': True, 'privileged': True})
        changed: [localhost] => (item={'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu2', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']})

        TASK [Wait for instance(s) creation to complete] **************************************changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '545348826689.26398', 'results_file': '/root/.ansible_async/545348826689.26398', 'changed': True, 'failed': False, 'item': {'image': 'milcom/centos7-systemd', 'name': 'centos72', 'network': 'host', 'pre_build_image': True, 'privileged': True}, 'ansible_loop_var': 'item'})
        changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '435374981525.26429', 'results_file': '/root/.ansible_async/435374981525.26429', 'changed': True, 'failed': False, 'item': {'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu2', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']}, 'ansible_loop_var': 'item'})

        PLAY RECAP ****************************************************************************localhost                  : ok=5    changed=2    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0

        INFO     Running test_filebeat > converge

        PLAY [Converge] ***********************************************************************
        TASK [Gathering Facts] ****************************************************************ok: [ubuntu2]
        ok: [centos72]

        TASK [Include AnsiblePlaybook] ********************************************************
        TASK [filebeat : Fail if unsupported system detected] *********************************skipping: [centos72]
        skipping: [ubuntu2]

        TASK [filebeat : include_tasks] *******************************************************included: /opt/roles/filebeat/tasks/download_yum.yml for centos72
        included: /opt/roles/filebeat/tasks/download_apt.yml for ubuntu2

        TASK [filebeat : Download filebeat rpm] ***********************************************changed: [centos72 -> localhost]

        TASK [filebeat : Copy filebeat to managed node] ***************************************changed: [centos72]

        TASK [filebeat : Download filebeat deb] ***********************************************changed: [ubuntu2 -> localhost]

        TASK [filebeat : Copy filebeat to managed node] ***************************************changed: [ubuntu2]

        TASK [filebeat : include_tasks] *******************************************************included: /opt/roles/filebeat/tasks/install_yum.yml for centos72
        included: /opt/roles/filebeat/tasks/install_apt.yml for ubuntu2

        TASK [filebeat : Install filebeat yum] ************************************************changed: [centos72]

        TASK [filebeat : Install filebeat deb] ************************************************[WARNING]: Updating cache and auto-installing missing dependency: python3-apt
        changed: [ubuntu2]

        TASK [filebeat : Configure filebeat] **************************************************changed: [centos72]
        changed: [ubuntu2]

        TASK [filebeat : Set filebeat systemwork] *********************************************changed: [ubuntu2]
        changed: [centos72]

        TASK [filebeat : Load kibana dashboard] ***********************************************ok: [centos72]
        ok: [ubuntu2]

        RUNNING HANDLER [filebeat : restart filebeat] *****************************************changed: [centos72]
        changed: [ubuntu2]

        PLAY RECAP ****************************************************************************centos72                   : ok=10   changed=6    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
        ubuntu2                    : ok=10   changed=6    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

        INFO     Running test_filebeat > destroy

        PLAY [Destroy] ************************************************************************
        TASK [Destroy molecule instance(s)] ***************************************************changed: [localhost] => (item={'image': 'milcom/centos7-systemd', 'name': 'centos72', 'network': 'host', 'pre_build_image': True, 'privileged': True})
        changed: [localhost] => (item={'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 'name': 'ubuntu2', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']})

        TASK [Wait for instance(s) deletion to complete] **************************************FAILED - RETRYING: Wait for instance(s) deletion to complete (300 retries left).
        FAILED - RETRYING: Wait for instance(s) deletion to complete (299 retries left).
        FAILED - RETRYING: Wait for instance(s) deletion to complete (298 retries left).       
        FAILED - RETRYING: Wait for instance(s) deletion to complete (297 retries left).       
        changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '334466083935.5091', 'results_file': '/root/.ansible_async/334466083935.5091', 'changed': True, 
        'failed': False, 'item': {'image': 'milcom/centos7-systemd', 'name': 'centos72', 'network': 'host', 'pre_build_image': True, 'privileged': True}, 'ansible_loop_var': 'item'})changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '923422881658.5111', 'results_file': '/root/.ansible_async/923422881658.5111', 'changed': True, 
        'failed': False, 'item': {'command': '/usr/sbin/init', 'image': 'jrei/systemd-ubuntu', 
        'name': 'ubuntu2', 'network': 'host', 'pre_build_image': True, 'privileged': True, 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:rw']}, 'ansible_loop_var': 'item'})

        PLAY RECAP ****************************************************************************localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

        INFO     Pruning extra files from scenario ephemeral directory
        _______________________________________ summary _______________________________________  py36-ansible28: commands succeeded
          congratulations :)


**Ссылки на репозиторий:**

Добавление молекулы:
https://github.com/AlexDies/filebeat-role/tree/2.0.0
https://github.com/AlexDies/kibana-role/tree/2.0.0

Добавление tox:
https://github.com/AlexDies/kibana-role/tree/2.1.0
https://github.com/AlexDies/filebeat-role/tree/2.1.0


