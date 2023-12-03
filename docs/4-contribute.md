# SFINX Contribution

## How to work with this Project

### Prepare DevHub org

Log into any DevHub (you can use Developer org). Beforehand, activate all options in Setup -> DevHub.
Authorize in DevHub by using the command:

```shell
sf org login web --set-default-dev-hub --alias dev-hub
```

### Create a new dev environment

```shell
# Create a new scratch org
sf org create scratch --definition-file config/project-scratch-def.json --alias sfinx.dev1
```

```shell
# Open scratch org
sf org open --target-org sfinx.dev1
```

```shell
sf project retrieve start --target-org sfinx.demo
```

```shell
sf project deploy start --target-org sfinx.demo
```