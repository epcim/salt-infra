
# I'm a Gangster so here is my "gun".

This repository is minimal salt bootstrap workflow for thees who ever considered
use salt modern, light.

The focus is on minimal bootstrap process, simple git based workflow, reusable states.
It bit target's "ansible like" usage, but "keep calm".

The overall "minimalist" concepts:

1. Clone model repo, fetch formulas, use salt-ssh, salt-cloud to manage hosts master-less
2. Clone model repo, start containerized salt-master, use salt-ssh, salt-cloud to saltify/shoot minions
3. Do (1) to bootstrap your salt-master from foundation node and do (2) to deploy salted infrastructure.

Main features:

* master-less setup, repo with states leveraging salt-ssh
* salt-master running in a container docker/k8s
* formulas pre-installed in stable salt-master container
* formulas fetched on the fly from multiple git sources
* infrastructure as a code, pillars are "treated" as your infrastructure model

Optional:

* use multiple ext_pillars
  - reclass as node classifier
  - nacl for pillar encryption
  - ...
* salt(ed) container matrix builds per salt/os/arch/[reclass|formula|...] version
* re-use share system and service "level" pillar data with best-practice default values


## Setup

    # direnv is optional
    apt-get install -y direnv python-pipenv

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
    SALT_ENV=env/staging

## Usage

### Basic

    # update use() function, to specify formulas to use
    $EDITOR ./Formulafile

    # update rooster with your minions
    $EDITOR salt/roster

    # install formulas
    ./Formulafile

    # salt it!
    salt-ssh master user.list_users
    salt-ssh master virtng.list_vms
    salt-ssh master pillar.items
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

Clone your model repository, example:

    git clone https://github.com/epcim/salt-models salt/reclass

Enable reclass:

    cp salt/examples/reclass.conf salt/master.d/

Note: Mind `salt/reclass/pillars` are added to salt pillar path.

Now configure your model.
Note: The steps below are for my `salt-models` and if you will use another model you will want to take other actions.

    # mind, there is salt/reclass/pillars, regular salt pillars
    # and there is salt/reclass/classes/k8s.mirantis.lab/.docs with
    # - nodes-saltmaster.yml
    # - pillars-saltmaster.yml

    # now you can link/copy example salt-master spec. to your nodes directory
    cp salt/reclass/classes/k8s.mirantis.lab/.doc/reclass-node-saltmaster.yml salt/reclass/nodes/cfg01.k8s.mirantis.lab.yml

    # similarly for ignition salt pillar spec.
    cp salt/reclass/classes/k8s.mirantis.lab/.doc/salt-ignition-pillar.yml salt/reclass/pillars/minion/cfg01.k8s.mirantis.lab.yml


    # update your foundation configuration
    vim salt/reclass/nodes/foundation.yml

    # update defaults
    vim salt/reclass/nodes/**/*.yml
    vim salt/reclass/pillars/top.sls

Finally, let's check it.

TBD

    python -m reclass.cli --inventory
    salt-run pillar.items
    salt-ssh foundation pillar.items

## Backlog 

Things to do later.

Use pre installed salt master container (https://github.com/epcim/docker-salt-formulas) and salt-ssh from it with SSH agent forwarded:

     # forward local ssh-agent
     docker run -rm -t -i -v $(dirname $SSH_AUTH_SOCK) $SALT_MASTER_VOLUMES -e SSH_AUTH_SOCK=$SSH_AUTH_SOCK $SALT_MASTER_IMAGE /bin/bash

Generate roster file for TF with jinja ;)

    https://gist.github.com/epcim/9df044c53d2dca3cd7115419a487ec02

