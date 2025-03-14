# SFINX Framework

SFINX is a set of program components united by a common philosophy of building Salesforce projects. 
You can use both the entire Framework and its individual modules.

## Quick Start

To integrate the framework into your project, you can take either a single module or the entire code from the `src`
folder.

### Demo Org

If you want to explore the SFINX framework capabilities, then:

**Step 1:** Clone this GitHub project to your local computer.

**Step 2:** Prepare any DevHub (for example Salesforce Developer Edition instance), it should be set as default DevHub
globally or for the project to make the `create-demo-org.sh` script work without errors.

**Step 3:** Run the following command (depending on your operating system, it may be necessary to grant execution 
rights to this script):

```shell
# Create a new demo scratch org
./scripts/create-demo-org.sh sfinx.demo
```

### Metadata Format

The project is developed in source code format. If you need the code in metadata format, run the following command in the project root:

```shell
sf project convert source --root-dir src --output-dir meta
```

### Integrating SFINX into an Existing Project

You can add the SFINX Framework to an existing project. Run the following command in your SFDX project root:

```shell
# Create a framework folder
git submodule add https://github.com/YOUR-ACCOUNT/YOUR-FRAMEWORK.git sfinx
# Enable sparse checkout
cd sfinx
git sparse-checkout init --cone
git sparse-checkout set src/sfinx
# Move src/sfinx/ to the correct location in your project
mv sfinx/src/sfinx force-app/
# Remove the empty framework/src/ folder
rm -rf sfinx/src
# Configure Git to ensure force-app/sfinx/ is linked to the framework repository:
echo "/force-app/sfinx/* merge=ours" >> .gitmodules
# Commit and push changes to GitHub
git add .
git commit -m "Integrated SFINX framework into src/sfinx"
git push origin main
```

## Modules

### Logger

First of all Logger is intended for collecting data about errors in those situations where you don't expect them, 
i.e. handling exceptional situations.

An example of using Logger when inserting data into a database in Apex code:

```java
List<Account> accounts = new List<Account>();
accounts.add(new Account());

try {
   insert accounts;
} catch(Exception e) {
   Logger.handle(e);
}
```



## Dive Deeper

1. [SFINX Framework Philosophy](docs/1-philosophy.md)
2. [Control Center App](docs/2-0-app.md)
3. Modules
    - Handler
    - Logger
    - Tester
4. [Contribute](docs/4-contribute.md)
