# PixeLAW Deployer
Auto deploys approved apps in a world

## Approved Apps
A JSON file that contains an array of apps that will be deployed to the world. The app must be using the correct
version of the PixeLAW core (otherwise it will be ignored by the auto deployer).

### Adding an app
Make a pull request to this repository, and follow the following format to add your app into the approvedApps.json.
````json
{
  "name": "put the name of your app here",
  "git-repository": "add the git repo url here",
  "contracts-directory": "path to your contracts directory relative to the root folder",
  "scripts": [
    "list the custom scripts needed to initialize your app", 
    "do not include initialize and upload_manifest"
  ]
}
````

## Running the deployer
To run the deployer, simply run the following:
````shell
bash deploy.sh
````