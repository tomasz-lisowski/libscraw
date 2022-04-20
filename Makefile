include lib/make-pal/pal.mak
DIR_SRC:=src
DIR_INCLUDE:=include
DIR_BUILD:=build
DIR_LIB:=lib
CC:=gcc
AR:=ar

MAIN_NAME:=$(LIB_PREFIX)scraw
MAIN_SRC:=$(wildcard $(DIR_SRC)/*.c)
MAIN_OBJ:=$(MAIN_SRC:$(DIR_SRC)/%.c=$(DIR_BUILD)/%.o)
MAIN_DEP:=$(MAIN_OBJ:%.o=%.d)
MAIN_CC_FLAGS:=-g -Werror -Wno-unused-parameter -W -Wall -Wextra -Wconversion -Wshadow \
	-fPIC -DDEBUG \
	-I$(DIR_INCLUDE)
MAIN_AR_FLAGS:=-rcs

ifeq ($(OS),Windows_NT)
	MAIN_CC_FLAGS+=-lwinscard
else
	MAIN_CC_FLAGS+=
endif

all:
	$(MAKE) -j all-conc
all-conc: main

# Create static library.
main: $(DIR_BUILD) $(DIR_BUILD)/$(MAIN_NAME).$(EXT_LIB_STATIC)
$(DIR_BUILD)/$(MAIN_NAME).$(EXT_LIB_STATIC): $(MAIN_OBJ)
	$(AR) $(MAIN_AR_FLAGS) $(@) $(^)

# Compile source files to object files.
$(DIR_BUILD)/%.o: $(DIR_SRC)/%.c
	$(CC) $(<) -o $(@) $(MAIN_CC_FLAGS) -c -MMD

# Recompile source files after a header they include changes.
-include $(MAIN_DEP)

$(DIR_BUILD):
	$(call pal_mkdir,$(@))
clean:
	$(call pal_rmdir,$(DIR_BUILD))

.PHONY: all all-conc main clean
