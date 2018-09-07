

#https://gist.github.com/DavidWittman/5753545#

ubuntu-xenial:

  provider: my-openstack

  image: xenial-server-cloudimg-amd64
  size: tiny.m1

  # public network
  ip_pool: 3e868882-d59e-416a-90a1-48cc04cab723

  ssh_key_name: you
  ssh_key_file: /home/you/.ssh/id_rsa

  master:
    user: root
    interface: 0.0.0.0

