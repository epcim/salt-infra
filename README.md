
# Repository to Salt infrastructure deployment

Minimal salt setup for infra bootstrap or single shot.
Git ops based workflow.
Reusable, pillars and states comes as independent repository per salt env.
Usage is like with "ansible", ie: define hosts, pillars, states and apply.

Supported workflows:

1. use locally with salt-ssh, salt-cloud to manage hosts masterless
2. deploy salt-master with docker-compose
3. deploy salt-master to Kubernetes

Main features:

* master-less setup:
  - repo with states leveraging salt-ssh
  - salt-master running in a container
  - 3rd party formulas fetched on the fly
* salt-master setup:
  - master image cicd and pre-installed formulas
  - docker-compose and kubernetes deployment
* other
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

Specific:
- Salt model, is this repository
  - used to tight everything together
- Salt environment, (under ./salt/env) can be "base, dev, prod" or named per your clusters names
  - it's salt-master agnostic specification for the infrastructure
  - you can do diff between these to transfer states and pillars
  - you can re-use somebody else and mix your own setup in model

## TL;DR locally

    git clone https://github.com/epcim/salt-sniper

    # mind `salt/master`, `salt/roster`, ...
    # mind `salt/pillars` and `salt/states` for customizations

    # add your models / envs (ie: env/base, env/test, env/prod)
    git submodule add https://github.com/epcim/salt-model-base salt/env/base
    git submodule add https://github.com/epcim/salt-model-apealive salt/env/apealive
    git submodule add https://github.com/epcim/salt-model-ipxeboot salt/env/ipxeboot

    export SALT_ENVS="$(ls --color=never salt/env)"
    for ENV in $SALT_ENVS; do
      export ENV
      pipenv run envtpl --keep-template salt/master.d/env.conf.tpl -o salt/master.d/${ENV}.conf
    done

    # fetch dependencies formulas (your own way)
    find ./salt/env -name Formulafile |\
      xargs -r -I% SALT_FORMULA_ROOT=./salt/formulas ./salt/Formulafile %

    # You are done!
    salt-ssh \* user.list_users


### Local setup

```sh
# ubuntu
apt-get install -y python-pipenv jq direnv

# osx
brew install pipenv direnv jq

direnv allow .
pipenv install
pipenv shell
```

Direnv is optional.
Setup local python enviornment and custom dependencies:

```
$EDITOR ./Pipfile
pipenv update
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

### docker-compose

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

