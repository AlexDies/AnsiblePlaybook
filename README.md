Данный playbook устанавливает `Elasticsearch` и `Kibana`. Для работы этих служб также устанавливается `Java`.

**Имеются следующие параметры:**
`java_jdk_version` - необходимая версия java
`java_oracle_jdk_package` - версия пакета java
`elastic_version` - необходимая версия elasticsearch
`elastic_home` - каталог установки elasticsearch
`kibana_version` - необходимая версия kibana
`kibana_home`  - каталог установки kibana

**Включает следующие тэги:**
`tags: kibana` - определяет таски плея kibana
`tags: elastic` - определяет таски плея elasticsearch
`tags: java` - определяет таски плея java
