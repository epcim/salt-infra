#!/bin/bash
# UPDATE local cluster with system and service classses

# Usage:
# ./sync-classes.sh [docker image] [destination reclass model path]

DMODEL=${1:-$PWD}
SIMAGE=${2:-epcim/salt:saltmaster-reclass-ubuntu-xenial-salt-stable-formula-master}

SOURCE=${RECLASS_ROOT:-/srv/salt/reclass}
DMODEL=$(realpath $DMODEL)

# get list of used classes                                                         # filter system/service and replace "." with "/"
declare -a classes
classes=($(cat $(find ${DMODEL} -name '*.yml')| sed -ne '/classes:/,/^[\w*]+/p;' |sed -n '/^\s*-/p' |sed -e 's/^[ -]*//g' | sed -e 's:\.:/:g' | grep -e '^\/*system\|^\/*service' |sort -u ))

# copy
if [[ -n "${classes[@]}" ]]; then
  docker run --rm -i -v $DMODEL:/model --entrypoint bash ${SIMAGE} <<-EOF
    # debug
    #for cls in ${classes[@]}; do
    #  echo rsync -avhmL --recursive --include "***\$cls***" --include='*/' --exclude='*' ${SOURCE}/classes/ /model ;
    #done;

    # rsync with pattern
    for cls in ${classes[@]}; do
      rsync -avhmL --recursive --include "***\$cls***" --include='*/' --exclude='*' ${SOURCE}/classes/ /model | grep '^[systemservice]*/' ;
    done;
	EOF

  # replace path to class

  # fix ownership
  U=$USER
  [[ -d $DMODEL/service ]] && sudo chown $U -R $DMODEL/service || true
  [[ -d $DMODEL/system  ]] && sudo chown $U -R $DMODEL/system  || true
fi
