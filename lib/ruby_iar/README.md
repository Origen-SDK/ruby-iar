## Ruby-Iar

Ruby-IAR provides Ruby bindings to programmatically drive the
[IAR Embedded Workbench](https://www.iar.com/iar-embedded-workbench/) toolchain.

Ruby-IAR features a:

* Configuration Manager: Programamtically add, remove, and modify configurations.
* Project Manager: Programamtically add, remove, group, and enable/disable project files.
* Toolchain Launcher: Executes the <code>iarbuild</code> tool and parses the output.

Please note that Ruby-IAR DOES NOT provide any bindings to the IAR toolchain other
than <code>iarbuild</code>.

### Sample Usage

The guide below will take you through some very basic usage on the command line.
This guide assumes that you already have IAR Embedded Workbench installed and
have proper licensing in place. It also assumes that Ruby is already installed
and available.

#### Download the Ruby-gem

#### Setup Your IAR Path

#### Build A New Project

Ruby-IAR includes a dummy project that can be used to try out features. From
your terminal, create this project with <code>ruby-iar new_project [path to new project]</code>.
The path to the new project is optional with its omittance creating the project at your
current directory.

This command will end by printing another command which will open the IAR IDE
with this project. With that, you can develop your code as needed using IAR's
environment. But that though, take note a few things:

* There are two configurations by default: <code>Debug</code> and <code>Regression</code>.
* The <code>Debug</code> configuration is set to output an executable but the <code>Regression</code>
configuration will output an s-record (something easily comparable as its just a text file).
* There is a dummy main file available, which simply returns a <code>0</code>.
* A linker default linker is also available, but this is highly unlikely to work on any
real device.

#### Run The Build Tool

The initial project is enough for us to build a simple s-record. From your
terminal, run:

~~~
ruby-iar build Regression
~~~

Upon running this, you'll see the <code>iarbuild</code> utility (provided by IAR itself)
go to work. Ruby-IAR will parse the output, color-code certain portions, and print
the results. The last line will be the location of the output. In our case,
(recall we used the Regression configuration) this will be an s-record.

#### Conclusion

That's all there is to it! A setup like this can be used to automate
builds across various configurations. Other guides will cover the more advanced
IAR configurations and the programatic view of the gem.

### Command Line Options

* Build Options
* Logging
* Using The Preprocessor

### Scripting With Ruby-IAR

The following section assumes that

* You can IAR Embedded Workbench and a proper license configured.
* The <code>ruby-iar/code> gem has been installed and is accessible (either from the system
  or from a Bundler build).

This section will take you through the features available when writing
Ruby scripts.

#### Quick-Start

#### Instantiation Options & Environment Configurations

#### Dealing With Project Files & Groups

* Adding
* Removing
* Grouping
* Enabling & Disabling

#### Configuration Management

* Adding new configurations
* Removing existing configurations
* Manipulating configurations
* Enumerated options
* Running arbitrary configuration blocks

#### Building Projects

* Build Options
* Building The Project
* Logging

### Spec Driver
