
# Use Salt as a gun - point & shoot

This repository is minimal salt bootstrap workflow for thees who ever considered
use salt similarly as "ansible" or other tools.

The focus is on minimal bootstrap process, simple git based workflow, reusable states.

The overall concepts:

1. Clone model repo, start containerized salt-master, (use salt-ssh), shoot hosts with states
2. Clone model repo, fetch formulas, use salt-ssh, shoot hosts with states

Main features:

* salt-master as an docker image
* stable formulas pre-installed in salt-master
* easy setup, just `docker run` + mount volumes
* states to apply, node spec. is stored in git repository as a "model"

Optional:

* masterless/agentless use-case (optional, but default)
* ext_pillar reclass as node classifier
* salt(ed) container matrix builds per salt/reclass/formula/os version
* re-use share system and service "level" pillar data with best-practice default values


## Setup

    # direnv is optional
    apt-get install -y direnv python-pipenv

### Configure python env

To add custom python dependencies (reclass):

    $EDITOR ./Pipfile


### Activate virtual environment the environment

    # use direnv
    direnv allow .

    # or
    pipenv install
    pipenv shell

### Configure salt

    # example: enable reclass
    cp salt/examples.d/reclass.conf salt/master.d/

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

