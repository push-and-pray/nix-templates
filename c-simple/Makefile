CC := gcc
CPPFLAGS ?= -Iinclude
CFLAGS ?= -std=c17 -O2 -g -Wall -Wextra -Wpedantic
LDFLAGS ?=
LDLIBS ?=

BUILD_DIR := build
TARGET := $(BUILD_DIR)/server
SOURCES := $(wildcard src/*.c)
OBJECTS := $(SOURCES:src/%.c=$(BUILD_DIR)/%.o)
DEPENDS := $(OBJECTS:.o=.d)
FORMAT_FILES := $(shell find src include -type f \( -name '*.c' -o -name '*.h' \))

.PHONY: all clean compile-db format format-check lint run

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)

$(BUILD_DIR)/%.o: src/%.c
	@mkdir -p $(@D)
	$(CC) $(CPPFLAGS) $(CFLAGS) -MMD -MP -c -o $@ $<

run: $(TARGET)
	./$(TARGET)

compile-db:
	rm -f compile_commands.json
	$(MAKE) clean
	bear -- $(MAKE) all

format:
	clang-format -i $(FORMAT_FILES)

format-check:
	clang-format --dry-run --Werror $(FORMAT_FILES)

lint:
	clang-tidy $(SOURCES) -- $(CPPFLAGS) $(CFLAGS)

clean:
	rm -rf build

-include $(DEPENDS)
