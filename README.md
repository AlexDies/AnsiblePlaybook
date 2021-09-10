# Самоконтроль выполненения задания

1. Где расположен файл с `some_fact` из второго пункта задания?

Файл располагается по пути group_vars/all/examp.yml

3. Какая команда нужна для запуска вашего `playbook` на окружении `test.yml`?

`ansible-playbook -i inventory/test.yml site.yml`

5. Какой командой можно зашифровать файл?

`ansible-vault encrypt (путь к файлу)`

7. Какой командой можно расшифровать файл?

`ansible-vault decrypt (путь к файлу)`

9. Можно ли посмотреть содержимое зашифрованного файла без команды расшифровки файла? Если можно, то как?

Да, можно. Команда: `ansible-vault view`

11. Как выглядит команда запуска `playbook`, если переменные зашифрованы?

`ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass`

13. Как называется модуль подключения к host на windows?

Модуль называется `psrp Run tasks over Microsoft PowerShell Remoting Protocol`

15. Приведите полный текст команды для поиска информации в документации ansible для модуля подключений ssh

`ansible-doc -t connection ssh`

17. Какой параметр из модуля подключения `ssh` необходим для того, чтобы определить пользователя, под которым необходимо совершать подключение?

      vars:
      - name: ansible_user
      - name: ansible_ssh_user