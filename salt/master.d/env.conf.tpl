pillar_roots:
  {{SALT_ENV.split('/')[-1:][0]}}:
  - salt/{{SALT_ENV}}/pillars
file_roots:
  {{ENV.split('/')[-1:][0]}}:
  - salt/{{SALT_ENV}}/states

