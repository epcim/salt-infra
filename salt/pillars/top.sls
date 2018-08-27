base:
  '*':
    - nodes.{{ grains['id'] }}
  'G@os:Ubuntu':
    - users
    - linux.system.motd

  'foundation':
    - reclass

#
#    - linux.system.repo2
#  'os:Ubuntu':
#    - match: grain
#    - linux.system.repo3
#  '^found*':
#    - match: pcreem.
#    - linux.system.repo
#  'f* and J@role.linux.system':
#    - match: compound
#    - users2
#  '192.0.0.0/16':
#    - match: ipcidr
#    - users


