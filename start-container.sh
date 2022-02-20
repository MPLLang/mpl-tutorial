#!/bin/bash

DIR=$(git rev-parse --show-toplevel)
cd $DIR

echo "building container at $DIR"

cmd="docker build . -t mpl-tutorial"
echo -e "\n$cmd"
eval $cmd || \
( echo -e "\ndocker failed; retrying with sudo"; \
  echo -e "\nsudo $cmd"; \
  eval "sudo $cmd" \
)
if [[ $? -ne 0 ]]; then
  echo "aborting...";
  exit 1
fi

echo -e "\nstarting container at $DIR"

cmd="docker run --rm -v $DIR:/root/mpl-tutorial -it mpl-tutorial /bin/bash"
echo -e "\n$cmd"
eval $cmd || \
( echo -e "\ndocker failed; retrying with sudo"; \
  echo -e "\nsudo $cmd"; \
  eval "sudo $cmd" \
)
if [[ $? -ne 0 ]]; then
  echo "aborting...";
  exit 1
fi
