
include:
  - salt/{{ENV}}/master.d/*.conf

pillar_roots:
  {{ENV.split('/')[-1:][0]}}:
  - salt/{{ENV}}/pillars

file_roots:
  {{ENV.split('/')[-1:][0]}}:
  - salt/{{ENV}}/states

