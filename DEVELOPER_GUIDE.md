# Development Environment
This document describes how to set up the development environment.


# Java
JDK to run IDE, build and run the project.


## Java 1.8 (project)

## Java 21+ (IDE)

# IDE

## Eclipse
Download and run `EclipseInstaller`:

* https://www.eclipse.org/

Install **Eclipse IDE for Java Developers**:

* Choose ^ in the `EclipseInstaller` and install it.
* Use JDK 21+ to run the IDE.


### [Eclipse] project setup
**New Eclipse workspace**

* Create new Eclipse workspace - just choose (even non-existent)
  directory, like `eclipse-workspace` to start w/ clean state.

**Add JDK 1.8 to the workspace**:

*  Window / Preferences / Java / Installed JREs → Add...

**New Java Project**

* menu / New / New Java Project
    - project: `coaching-notebook`
    - uncheck "Use default location"
    - choose JDK/JRE 1.8.0 
    - click `Finish` button
* window / Package explorer (left sidebar)
    - review imported sources


## Build
What's where:

* Sources:
    * `src/`
* Dependencies:
    * `war/WEB-INF/lib/*.jar`
        - dependencies are pushed to Git 
          (not nice, but handy)

### [Eclipse] build
What's where:

* Classpath configuration:
    * `coaching-notebook/.classpath`
        - path to all src and .jar dependencies

**Build** the project in Eclipse IDE:

* window / Package Explorer view:
    - right click project name / Build path / Configure buil path
    - add .jar files from war/WEB-INF/lib to ^
* menu / Project / Clean
    - this will build the project automatically (if set as that)

# CLI

## Run
Build, enhance and run the project:

```
make run
```


