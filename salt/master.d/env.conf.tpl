
include:
  - salt/{{SALT_ENV}}/master.d/*.conf

pillar_roots:
  {{SALT_ENV.split('/')[-1:][0]}}:
  - salt/{{SALT_ENV}}/pillars

file_roots:
  {{SALT_ENV.split('/')[-1:][0]}}:
  - salt/{{SALT_ENV}}/states

