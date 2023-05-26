# The current target
include target.mk

# Configuration of the defines and targets
DEFINES 	:= $(addprefix -D, $(DEFINES))
COMPONENTS 	:= $(addprefix $(COMPONENTS_FOLDER)\, $(COMPONENTS))
THIRD_PARTY := $(addprefix $(THIRD_PARTY_FOLDER)\, $(THIRD_PARTY))
INCLUDES 	:= $(addprefix -I, $(APP_INCLUDES_FOLDER)  $(addprefix $(APP_INCLUDES_FOLDER)\, $(APP_SUB_FOLDERS)) $(INCLUDES) $(COMPONENTS) $(THIRD_PARTY))
SOURCES 	= $(APP_SOURCES_FOLDER) $(COMPONENTS) $(THIRD_PARTY) $(addprefix $(APP_SOURCES_FOLDER)\, $(APP_SUB_FOLDERS))
OBJ			= $(foreach file,$(SOURCES),$(patsubst   %.cpp,%.o,$(wildcard   $(file)/*.cpp))) $(foreach file,$(SOURCES),$(patsubst   %.c,%.o,$(wildcard   $(file)/*.c)))

# Information about the project
DEFINES 	+=-DPROJECT_NAME='"$(PROJECT_NAME)"' -DCONFIGURATION='"$(CONFIGURATION)"'

# Information from git
ifneq ($(GIT_DATA), 0)
GIT_COMMIT	= $(shell git log --pretty=format:'%H (%ad)' --date=iso8601 -1)
GIT_BRANCH	= $(shell git rev-parse --abbrev-ref HEAD)
DEFINES 	+= -DGIT_COMMIT='"$(GIT_COMMIT)"' -DGIT_BRANCH='"$(GIT_BRANCH)"'
endif

# Usage of the standart library
ifeq ($(STD_LIB), 0)
LDFLAGS 	+= -nostdlib
endif

# Building target
all: $(BIN_FOLDER)/$(PROJECT_NAME).elf
	$(OBJDUMP) -d -z -S $(BIN_FOLDER)/$(PROJECT_NAME).elf > $(BIN_FOLDER)/$(PROJECT_NAME).dis
	$(OBJCOPY) -O ihex $(BIN_FOLDER)/$(PROJECT_NAME).elf $(BIN_FOLDER)/$(PROJECT_NAME).hex
	$(OBJCOPY) -O binary $(BIN_FOLDER)/$(PROJECT_NAME).elf $(BIN_FOLDER)/$(PROJECT_NAME).bin
	$(SIZE) $(BIN_FOLDER)/$(PROJECT_NAME).elf

$(BIN_FOLDER)/$(PROJECT_NAME).elf: $(BUILD_FOLDER) $(addprefix $(BUILD_FOLDER)/, $(OBJ))
	$(CXX) -Wl,-gc-sections -T$(LDSCRIPT) $(addprefix $(BUILD_FOLDER)/, $(OBJ)) $(COMMONFLAGS) $(CXXFLAGS) $(LDFLAGS) -Xlinker -Map=$(BIN_FOLDER)/$(PROJECT_NAME).map -o $(BIN_FOLDER)/$(PROJECT_NAME).elf

$(BUILD_FOLDER)/%.o: %.cpp
	$(if $(findstring $(THIRD_PARTY_FOLDER), $<), \
	$(CXX) $(COMMONFLAGS) $(CXXFLAGS) -MMD -c $< -o $@ , \
	$(CXX) $(COMMONFLAGS) $(CXXFLAGS) $(WARNINGS) $(WARNINGS_CPP) -MMD -c $< -o $@)

$(BUILD_FOLDER)/%.o: %.c
	$(if $(findstring $(THIRD_PARTY_FOLDER), $<), \
	$(CC) $(COMMONFLAGS) $(CFLAGS) -MMD -c $< -o $@ , \
	$(CC) $(COMMONFLAGS) $(CFLAGS) $(WARNINGS) -MMD -c $< -o $@)

$(BUILD_FOLDER):
	$(shell mkdir $(addprefix $(BUILD_FOLDER)\, $(SOURCES)))

# Searching for .d files for partly rebuilding
include $(wildcard $(addprefix $(BUILD_FOLDER)/, $(patsubst   %.o,%.d,$(OBJ))))

# Clean
clean:
	$(shell rmdir /s /q $(RESULT_FOLDER))