# SFINX Framework

SFINX is a set of program components united by a common philosophy of building Salesforce projects. 
You can use both the entire Framework and its individual modules.

## Quick Start

To integrate the framework into your project, you can take either a single module or the entire code from the `src`
folder.

# Logger

First of all Logger is intended for collecting data about errors in those situations where you don't expect them, i.e. handling exceptional situations.

An example of using Logger when inserting data into a database in Apex code:

```java
try {
   insert accounts;
} catch(Exception e) {
   Logger.log(e);
}
```

### Demo Org

If you want to explore the SFINX framework capabilities, then:

**Step 1:** Clone this GitHub project to your local computer.

**Step 2:** Prepare any DevHub (for example Salesforce Developer Edition instance), it should be set as default DevHub 
globally or for the project.

**Step 3:** Run the following command (depending on your operating system, it may be necessary to grant execution rights to 
this script):

```shell
# Create a new demo scratch org
./scripts/create-demo-org.sh sfinx.demo
```


## Dive Deeper

1. [SFINX Framework Philosophy](docs/1-philosophy.md)
2. [Control Center App](docs/2-0-app.md)
3. Modules
    - Handler
    - Logger
    - Tester
4. [Contribute](docs/4-contribute.md)
