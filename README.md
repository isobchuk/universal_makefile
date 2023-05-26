# Universal Makefile

Universal Makefile with extended features to build bare-metal targets

## Description

Universal Makefile for the cross-compilation of the embedded projects using Windows.
For configuration components and third-party libs folders, defines, configurations and flags should be chosen.
Main Features:

1. Use the target file to define the build configuration.
2. Automatic search for .h, .hpp, .c, .cpp files:
   - It is supposed that the application's .c and .cpp files are located in $(sources) folder and .h and .hpp files are located in $(includes). Also, it is possible to add sub-folders there (Automatic search for .h, .hpp, .c, .cpp files).
   - $(components) - folder for the other logical components (Automatic search for .h, .hpp, .c, .cpp files).
   - $(third_party) - folder for the external libs, warnings are disabled for this folder (Automatic search for .h, .hpp, .c, .cpp files).
3. The git branch and commit can be added to the firmware with the corresponding flag.
4. The project name and configuration are added to the firmware.
5. Partly rebuilding is supported.
6. Different configurations can be added.
7. Firmware files that will be generated: .map, .dis, .elf, .bin, .hex.

## Usage

Users have to set up only the target file for the project. The build process is fully performed in the Makefile.

Add the target and the Makefile to the root of your project.

In the repository, the example target file is located. It was written for the next project structure (only main files and folders with headers and/or sources inside):

    ├── components
    │   ├── constexpr_parameter
    │   ├── hal
    │   ├── nrf5340
    │   ├── printf
    │   └── system_time
    ├── sources
    ├── ThirdParty
    │   └──rtt
    ├── linker.ld
    ├── Makefile
    └──  target.mk

The "target.mk" is fully commented so it should be used as a reference. However, some additional explanations will be provided.

The project name that will be provided to the firmware (through define):

```bash
PROJECT_NAME    = NFC
```

The folder for the firmware result files will be created inside the project root:

```bash
RESULT_FOLDER   = build
```

The defines can be defined for the different configurations (all, debug and release in this case):
*Note: Provide defines without -D prefix*

```bash
DEFINES         =
DEFINES_DEBUG   =
DEFINES_RELEASE = NDEBUG
```

The special flags for the different configurations (The name of the current configuration will be provided to the project sources):

```bash
ifeq ($(BUILD), release)
CONFIGURATION   = release
DEFINES         += $(DEFINES_RELEASE)
OPTIMIZE        =-Os
else
CONFIGURATION   = debug
DEFINES         += $(DEFINES_DEBUG)
OPTIMIZE        =-Os
endif
```

The flags to use std lib and git data (0 - not using, otherwise - using)

```bash
STD_LIB         := 1
GIT_DATA        := 1
```
