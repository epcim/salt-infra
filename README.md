
# Repository to Salt infrastructure deployment

DISCLAIMER:
- I have used this setup around 2018, on linux
- As of 2021 and on OSX, running salt locally (as ansible) does not work well for multiple bugs and issues (in salt-ssh, missing documentation for heist, pillarenvs, ...)
- Further I have decided for Ansible infrastructure bootstrap (as painless, more audience as well as examples.
  However later nodes are managed salt-minions.


--- 


Salt setup template repository.

- Reusable, pillars and states comes as independent repository per salt env.
- Usage is like with "ansible", ie: define hosts, pillars, states and apply.

Supported workflows:

1. use locally with salt-ssh/heist-salt to manage hosts (masterless)
2. deploy salt-master with docker-compose
3. deploy salt-master to Kubernetes

Main features:

* masterless setup:
  - repo with states leveraging salt-ssh
  - 3rd party formulas fetched on the fly
* salt-master setup:
  - dockerfile, kubernetes deployment
  - re-use the same repo as for bootstrap
* both
  - infrastructure as a code, pillars are "treated" as your infrastructure model
  - share/use environments with friends and re-use in your own salt-master setup
  - enjoy multiple salt environments (ie: mix pillar and file roots)

Optional:

* use multiple ext_pillars
  - reclass as node classifier
  - nacl for pillar encryption
  - ...

## What is, shortly

Salt terminology:
- Salt, an configuration mgmt (better Ansible ;).
- Grains, collected metadata about an minion
- States, are declarative definition of `state` you want to achieve (ie: 'pkg.installed')
- Pillars, is like configuration data for states (ie: configuration, secrets, ...)
- Formulas, composition of States, default Pilars (but either templates, grains, custom code)
- top.sls, used in States and Pillars direcrtory, to assign them to minions (by name, by grains,  ...)
- ...
- ... [Architecture](https://docs.saltproject.io/en/latest/topics/salt_system_architecture.html#what-is-salt)
- ... https://blog.networktocode.com/post/learn-salt-with-ansible-references/

Specific:
- Salt model, is this repository
  - it's like salt-master config directory to glue everything together
- Salt environment, (under ./salt/env) can be "base, dev, prod" or named per your clusters names
  - it's salt-master agnostic specification for the infrastructure
  - you can do diff between these to transfer states and pillars
  - you can re-use somebody else and mix your own setup in model


What to read:
- https://salt.tips
- heist-salt, Heist is to make deployment and management of Salt easy (once it's really working and docs available)

Salt
- instalation options, https://repo.saltproject.io/
- single binnary installation, https://repo.saltproject.io/salt/singlebin/

## TL;DR


```
git clone https://github.com/epcim/salt-sniper

# mind `salt/master`, `salt/roster`, ...
# mind `salt/pillars` and `salt/states` for customizations

# add your model / envs (ie: env/base, env/test, env/prod)
git submodule add https://github.com/epcim/salt-model-apealive salt/env/apealive
# or (multi env)
git submodule add https://github.com/epcim/salt-model-base salt/env/base
git submodule add https://github.com/epcim/salt-model-apealive salt/env/apealive
git submodule add https://github.com/epcim/salt-model-ipxeboot salt/env/ipxeboot

export SALT_ENVS="$(ls --color=never salt/env)"
for ENV in ${SALT_ENVS:-base}; do
  export ENV
  pipenv run envtpl --keep-template salt/master.d/env.conf.tpl -o salt/master.d/${ENV}.conf
done

# fetch dependencies formulas (your own way), this is what I use
find ./salt/env -name Formulafile |\
  xargs -r echo SALT_FORMULA_ROOT=./salt/formulas ./salt/Formulafile

# You are done!
salt-ssh \* test.ping

```


### Local setup

```sh
```

Direnv is optional.
Setup local python enviornment and custom dependencies:

```
$EDITOR ./Pipfile
pipenv update
```

### Bootstrap

Boostrap a foundation node. TODO

```sh
# ubuntu
sudo curl -fsSL -o /usr/share/keyrings/salt-archive-keyring.gpg https://repo.saltproject.io/py3/ubuntu/20.04/amd64/latest/salt-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/salt-archive-keyring.gpg arch=amd64] https://repo.saltproject.io/py3/ubuntu/20.04/amd64/latest focal main" |\
  sudo tee /etc/apt/sources.list.d/salt.list
sudo apt-get update
sudo apt-get install -y pipenv jq direnv salt-minion salt-ssh

# osx
brew install pipenv direnv jq salt

direnv allow .
pipenv install
pipenv shell

sudo apt-get install -y openssh-server salt-minion salt-ssh ssh-askpass

# optional, recomended if foundation = localhost
ssh-keygen
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
echo "$USER ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER
ssh localhost "sudo uptime" # to review

# apply foundation node states
salt-ssh -H
salt-ssh foundation state.show_top
salt-ssh foundation state.apply

# apply any other node
salt-ssh \* -H
salt-ssh \* state.apply test=true -i --roster-file=salt/env/apealive/roster

# optional
#sudo apt-get install -y salt-master
#sudo unlink /etc/systemd/system/multi-user.target.wants/salt-master.service
#sudo ln -s /etc/systemd/system/multi-user.target.wants/salt-master.service /lib/systemd/system/salt-master.service
```

### Configure salt-master

    # help yourself
    ls salt/examples

    $EDITOR salt/master.d/*.conf

### Multiple environments

If using multiple envs you may want to additionally set:
```
top_file_merging_strategy: same
env_order: ['base', 'prod', 'staging']
default_top: base
```

Docs: https://docs.saltstack.com/en/latest/ref/states/top.html#top-file-compilation-examples

## Deploy

### Heist

```
heist --log-level info salt.minion -t minion1 -R salt/roster.d # NOTE TESTED
```

### docker-compose

See:
- https://github.com/cdalvaro/docker-salt-master

```sh
git clone https://github.com/cdalvaro/docker-salt-master deploy-docker
cd deploy-docker
make release

# TODO
# update compose file, user local image, refer to local volumes (pillars, states)

cd ../
docker-compose up -d deploy-docker
```

### kubernetes

TBD

## Usage 

### Basics

    # update rooster with your minions
    $EDITOR salt/roster

    # install formulas
    ./Formulafile

    # salt it!
    salt-ssh foundation user.list_users
    salt-ssh foundation virtng.list_vms
    salt-ssh foundation pillar.items
    salt-ssh \* state.apply

    # list states
    salt-ssh \* state.show_states (>2018.3)
    salt-ssh \* pillar.get __reclass__:applications

### Ad-hoc shoots

    # alternative roster
    salt-ssh --roster sshconfig \* test.ping

    # TODO, salt-ssh -> saltify, contributors are welcome ;)
    # salt-ssh --roster cloud \* -r uptime



### Usage with ext_pillar reclass

Reclass (The fork I use: https://github.com/salt-formulas/reclass) is handy YAML merger. It allows you to keep your model
"static" pillar data structured and shared across your deployments, which drives your best-practice configuration to DRY and live.

Enable reclass:

    # envtpl (jinja2 engine) is used to properly set $ENV variable
    export ENV=base
    envtpl --keep-template salt/master.d/reclass.conf.tpl

> Mind `salt/$ENV/reclass/pillars` are added to salt pillar path.

Now configure your model.

> The steps below follow my `models` rules, keep in mind you are free to customize.


Let's setup your new remote salt-master:

    # set salt-master node
    cat salt/$ENV/docs/nodes-saltmaster.yml | envtpl | tee > salt/$ENV/reclass/nodes/<minion_id>.yml


If you will want to use salt-run (setup foundation node):

    ln -s salt/$ENV/reclass/nodes/<minion_id>.yml salt/$ENV/reclass/nodes/foundation.yml

    # update your foundation configuration, if needed
    vim salt/$ENV/reclass/nodes/foundation.yml


Let's run some checks:

    python -m reclass.cli --inventory
    salt-run pillar.items
    salt-ssh foundation pillar.items


### Usage with ext_pillar pillarstack

Your `salt/$ENV` might have these folders:

  - pillars (initial/additional salt pillars)
  - states (additional salt states)
  - stack (reclass classes)
  - docs

Enable saltclass in your `salt/master.d/$ENV.conf`

## Backlog

Things to do later.

Use pre installed salt master container (https://github.com/epcim/docker-salt-formulas) and salt-ssh from it with SSH agent forwarded:

     # forward local ssh-agent
     docker run -rm -t -i -v $(dirname $SSH_AUTH_SOCK) $SALT_MASTER_VOLUMES -e SSH_AUTH_SOCK=$SSH_AUTH_SOCK $SALT_MASTER_IMAGE /bin/bash

Generate roster file for TF with jinja ;)

    https://gist.github.com/epcim/9df044c53d2dca3cd7115419a487ec02

