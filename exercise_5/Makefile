# Define variables
CC = gcc
CFLAGS = -O0
TARGET = clique
PYTHON_SCRIPT = create-matrix.py
GRAPH_FILE = graph.txt
OUTPUT_FILE = output.txt
N = 27 # Default size of the graph, can be overridden

# Default target: Compile, generate graph if necessary, run program, and show output
all: $(TARGET) $(GRAPH_FILE)
	@echo "Running $(TARGET)..."
	@./$(TARGET) < $(GRAPH_FILE) > $(OUTPUT_FILE)
	@echo "Output from $(TARGET):"
	@cat $(OUTPUT_FILE)

# Generate the graph only if it doesn't exist
$(GRAPH_FILE):
	@echo "Generating graph..."
	@python3 $(PYTHON_SCRIPT) $(N) > $(GRAPH_FILE)

# Compile the C program with main.c
$(TARGET): main.c max-clique.c
	@echo "Compiling program..."
	$(CC) $(CFLAGS) -o $(TARGET) main.c max-clique.c

# Clean up build files
clean:
	@echo "Cleaning up..."
	rm -f $(TARGET) $(GRAPH_FILE) $(OUTPUT_FILE)
