vbox-test:
    provider: virtualbox-config
    clonefrom: http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-vagrant.box

    # Optional
    power_on: True
    deploy: True
    ssh_username: ubuntu
    password: ubuntu

    #sudo:
    #sudo_password: a_password
    # Example minion config
    minion:
        master: foundation
    #make_master: True
