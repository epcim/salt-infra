pillar_opts: False

pillar_roots:
  base:
  - salt/env/{{ENV}}/reclass/pillars

reclass: &reclass
  storage_type: yaml_fs
  inventory_base_uri: ./salt/env/{{ENV}}/reclass/
  ignore_class_notfound: True
  ignore_class_regexp:
  - '.*'

ext_pillar:
  - reclass: *reclass

master_tops:
  reclass: *reclass

