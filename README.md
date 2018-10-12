
# I'm a Gangster so here is my "gun" salt Salt.

This repository is minimal salt bootstrap workflow for thees who ever considered
use salt modern, light.

The focus is on minimal bootstrap process, simple git based workflow, reusable states.
It bit target's "ansible like" usage, but "keep calm".

The overall "minimalist" concepts:

1. Clone model repo, fetch base formulas, use salt-ssh, salt-cloud to manage hosts master-less
2. Clone model repo, start containerized salt-master, use salt-ssh, salt-cloud to saltify/shoot minions
3. Do (1) to bootstrap your salt-master from foundation node and do (2) to deploy salted infrastructure.

Main features:

* master-less setup, repo with states leveraging salt-ssh
* salt-master running in a container docker/k8s
* formulas pre-installed in stable salt-master container
* formulas fetched on the fly from multiple git sources
* infrastructure as a code, pillars are "treated" as your infrastructure model
* environments used as individual models, while still keeping salt envs

Optional:

* use multiple ext_pillars
  - reclass as node classifier
  - nacl for pillar encryption
  - ...
* enjoy multiple salt environments
* salt(ed) container matrix builds per salt/os/arch/[reclass|formula|...] version
* re-usable model, shared pillar data with best-practice default values

Finally, this repository assumes to be mounted as volume into an salt ready container.



## TL;DR

    git clone https://github.com/epcim/salt-gun

    # mind `salt/master`, `salt/roster`, ...
    # mind `salt/pillars` and `salt/states` for customizations

    # define salt env OR add this way your model to deployment
    export SALT_ENV=env/kubernetes
    envtpl --keep-template salt/master.d/env.conf.tpl -o salt/master.d/${SALT_ENV//\//_}.conf

    # add your model
    git clone https://github.com/epcim/salt-model-kubernetes salt/$SALT_ENV

    # add another model (optional)
    export SALT_ENV=env/workspace
    git clone https://github.com/epcim/salt-model-workspace salt/$SALT_ENV

    # add another salt environment of existing model (optional)
    cd salt/$SALT_ENV
    git worktree add --checkout -b staging ../$(basename $PWD)-staging origin/staging
    git worktree list

    # fetch some formulas (up to you)
    # find . -name Formulafile
    ./Formulafile

    # You are done!
    salt-ssh foundation user.list_users


## Setup

    # direnv is optional
    apt-get install -y python-pipenv jq direnv

### Configure shell environment

It is convenient to keep all setup environment variables used in one file.

For convenience, use `.envrc` on main directory of salt-gun and your model as you ENV/PROFILE file.

All examples below expect storing/sourcing used env variables in this file.

### Configure python env

To add custom python dependencies (reclass):

    $EDITOR ./Pipfile


### Activate virtual environment the environment

    # use direnv
    eval "$(direnv hook $SHELL)"
    direnv allow .

    # or
    pipenv install
    pipenv shell

### Configure salt

    # help yourself
    ls salt/examples

    # to enable reclass
    cp salt/examples/reclass.conf salt/master.d/

    # to enable salt-cloud
    cp salt/examples/cloud.provider/openstack.yml salt/cloud.providers.d/
    cp salt/examples/cloud.profile/openstack.yml salt/cloud.profile.d/
    vim salt/cloud.*/*.yml

### Configure salt environments

If you intend to use salt environments for (pillars, states) export SALT_ENV.

Example:

    # add to .envrc
    SALT_ENV=env/base

    # configure master
    envtpl --keep-template salt/master.d/env.conf.tpl -o salt/master.d/${SALT_ENV//\//_}.conf

    # If using multiple envs you may want to additionally set:
    #   top_file_merging_strategy: same
    #   env_order: ['base', 'prod', 'staging']
    #   default_top: base
    # docs: https://docs.saltstack.com/en/latest/ref/states/top.html#top-file-compilation-examples

## Usage

### Configure your salt model (pillar and sls files)

Configure salt, except master/minion configuration files means setup SLS for pillars and states.
These are located under `salt/states` and `salt/pillars`. If you are using environments, according
example used in this doc, then your pillars are at `salt/env/NAME/states` and `salt/env/NAME/pillars`.

Up to you now to fetch your states (formulas) and configure your pillars (metadata).

#### Fetch your formulas from git repo:

(Alternative)

I use this step only to fetch base formulas to bootstrap salt-master on the remote side (on the managed environment).

    # update use() function, to specify formulas to use
    $EDITOR ./Formulafile

#### Use containerized salt master

* Fetch your formulas from docker container
* Use container directly for individual actions/commands. State-less

TBD



### Basic

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

    # envtpl (jinja2 engine) is used to properly set $SALT_ENV variable
    export SALT_ENV=env/base
    envtpl --keep-template salt/master.d/reclass.conf.tpl

> Mind `salt/$ENV/reclass/pillars` are added to salt pillar path.

Now configure your model.

> The steps below follow my `models` rules, keep in mind you are free to customize.

Clone your model repository:

FIXME, TODO: set model as subrepo or do a trick with tracking other remote/branch

    git clone https://github.com/epcim/salt-model-kubernetes salt/$SALT_ENV

Add another environment from a branch (optional)

    cd salt/$SALT_ENV
    git worktree add --checkout -b staging ../staging origin/staging
    git worktree list


> Mind the `.doc(s)` folder on the example model repository.

Your `salt/$SALT_ENV` might have these folders:

  - pillars (initial/additional salt pillars)
  - states (additional salt states)
  - reclass (reclass classes)
  - docs


Let's setup your new remote salt-master:

    # set salt-master node
    cat salt/$SALT_ENV/docs/nodes-saltmaster.yml | envtpl | tee > salt/$SALT_ENV/reclass/nodes/<minion_id>.yml


If you will want to use salt-run (setup foundation node):

    ln -s salt/$SALT_ENV/reclass/nodes/<minion_id>.yml salt/$SALT_ENV/reclass/nodes/foundation.yml

    # update your foundation configuration, if needed
    vim salt/$SALT_ENV/reclass/nodes/foundation.yml


Let's run some checks:

    python -m reclass.cli --inventory
    salt-run pillar.items
    salt-ssh foundation pillar.items


### Usage with ext_pillar pillarstack

TBD

Clone your model.

Your `salt/$SALT_ENV` might have these folders:

  - pillars (initial/additional salt pillars)
  - states (additional salt states)
  - stack (reclass classes)
  - .doc


## Backlog

Things to do later.

Use pre installed salt master container (https://github.com/epcim/docker-salt-formulas) and salt-ssh from it with SSH agent forwarded:

     # forward local ssh-agent
     docker run -rm -t -i -v $(dirname $SSH_AUTH_SOCK) $SALT_MASTER_VOLUMES -e SSH_AUTH_SOCK=$SSH_AUTH_SOCK $SALT_MASTER_IMAGE /bin/bash

Generate roster file for TF with jinja ;)

    https://gist.github.com/epcim/9df044c53d2dca3cd7115419a487ec02

