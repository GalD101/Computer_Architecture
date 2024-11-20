# Compiler and flags
CC := gcc
CFLAGS := -w

# List of all sources
SRCS := $(wildcard file_*.c)

# List of object files
OBJS := $(patsubst %.c, %.o, $(SRCS)) # use patsubst to replace .c with .o

# Main executable
MAIN := main

# Phony targets
.PHONY: all clean

# Default target
all: $(MAIN)

# Linking
$(MAIN): $(OBJS) main.o
	$(CC) $(CFLAGS) -o $@ $^

# Compiling all sources
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Clean
clean:
	rm -f $(OBJS) main.o $(MAIN)

