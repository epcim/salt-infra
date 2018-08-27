ubuntu-test:

  # points back at provider configuration
  provider: local-kvm
  base_domain: xenial-server-cloudimg-amd64
  ip_source: ip-learning
  ssh_username: ubuntu
  password: ubuntu

  ## /tmp is mounted noexec.. do workaround
  #deploy_command: sh /tmp/.saltcloud/deploy.sh
  #script_args: -F
  ## grains to add to the minion

  #grains:
  #  clones-are-awesome: true
  ## override minion settings

  minion:
    master: foundation
    #master_port: 5506
