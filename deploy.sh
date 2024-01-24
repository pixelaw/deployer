#!/bin/bash

# Load variables from .env file
source .env

# Parse JSON using jq tool
json=$(cat approvedApps.json)

length=$(echo ${json} | jq '. | length')

# Check if RPC_URL environment variable exists
if [ -z "${RPC_URL}" ]; then
  # If not, set it
  RPC_URL="https://api.cartridge.gg/x/${WORLD_NAME}/katana"
fi

if [ ! -d "dist" ]; then
  # If not, create it
  mkdir dist
fi


# make directory dist if it does not exist and all apps cloned there should be inside that directory
cd dist

rm -r ./*

dist_dir=$(pwd)

echo "----------------------------------------------------------------------------"
echo "Deploying ${length} apps"

for (( i=0; i<${length}; i++ ))
do
  app=$(echo ${json} | jq -r ".[${i}]")
  name=$(echo ${app} | jq -r ".name")
  git_repo=$(echo ${app} | jq -r '."git-repository"')
  contracts_dir=$(echo ${app} | jq -r '."contracts-directory"')
  scripts=$(echo ${app} | jq -r ".scripts[]")

  echo "----------------------------------------------------------------------------"
  echo "[${i}] App: ${name}"

  echo "Cloning repository (${git_repo}) to ${i}"
  git clone ${git_repo} ${i}

  rm -rf ${i}/.git

  cd ${i}/${contracts_dir}

  echo "Building contract"
  sozo build

  sed -i 's#rpc_url = ".*"#rpc_url = "'"$RPC_URL"'"#' Scarb.toml
  sed -i 's/account_address = ".*"/account_address = "'"$ACCOUNT_ADDRESS"'"/' Scarb.toml
  sed -i 's/private_key = ".*"/private_key = "'"$PRIVATE_KEY"'"/' Scarb.toml


  echo "Deploying the contract"

  sozo migrate --name $WORLD_NAME

  scarb run initialize
  scarb run upload_manifest $MANIFEST_URL

  for script in ${scripts}
  do
    echo "scarb run ${script}"
    scarb run ${script}
    sleep 10
  done

  cd $dist_dir

done

echo "----------------------------------------------------------------------------"
echo "Completed deployment successfully"
echo "----------------------------------------------------------------------------"
