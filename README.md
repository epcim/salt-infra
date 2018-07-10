
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

## Usage

TBD

