# SFINX Contribution

## How to work with this Project

### Prepare DevHub org

Log into any DevHub (you can use Developer org). Beforehand, activate all options in Setup -> DevHub.
Authorize in DevHub by using the command:

```shell
sf org login web --set-default-dev-hub --alias dev-hub
```

### Create a new dev environment

Run the bash script passing the alias for your dev environment as a parameter. The script will automatically 
create and configure a new scratch org with the installed SFINX Framework.

Example:

```shell
./scripts/create-demo-org.sh sfinx.demo sfinx.dev1
```
