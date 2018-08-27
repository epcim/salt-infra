
# https://docs.saltstack.com/en/latest/topics/cloud/openstack.html
# https://docs.openstack.org/os-client-config/latest/user/configuration.html#config-files

devcloud:
  driver: openstack
  region_name: RegionOne
  auth:
    username: #FIXME, 'you'
    password: #FIXME, 'password'
    project_name: #FIXME, 'Default'
    user_domain_name: 'default'
    domain_name: 'default'
    auth_url: # FIXME, 'https://your-openstack-public-endpoint:5000/v3'
  verify: False
  regions:
    - name: RegionOne
      values:
        networks:
        # public
        - name: #FIXME, ID or NAME
          routes_externally: true
