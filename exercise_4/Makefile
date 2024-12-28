# Makefile to compile cache simulator
CC = gcc
CFLAGS = -Wall -Wextra -std=c11 -O2

all: cache

cache: cache_sim.c
	$(CC) $(CFLAGS) -o cache cache_sim.c

clean:
	rm -f cache
