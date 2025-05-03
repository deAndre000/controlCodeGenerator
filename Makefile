# Configuración básica
ASM = nasm
LD = ld
TARGET = binaries/controlCodeGenerator

# Directorios
SRC_DIR = src
BUILD_DIR = objects
BIN_DIR = binaries
INCLUDE_DIR = include

# Flags
ASM_FLAGS = -f elf64 -I$(INCLUDE_DIR)/
LD_FLAGS = 

# Modo Debug (para gdb)
ASM_FLAGS_DEBUG = $(ASM_FLAGS) -g -F dwarf
LD_FLAGS_DEBUG = -g

# Archivos fuente (recursivos)
SRCS = $(shell find $(SRC_DIR) -name '*.asm')
OBJS = $(patsubst $(SRC_DIR)/%.asm, $(BUILD_DIR)/%.o, $(SRCS))

# Reglas principales
all: release

release: ASM_FLAGS := $(ASM_FLAGS)
release: $(TARGET)

debug: ASM_FLAGS := $(ASM_FLAGS_DEBUG)
debug: LD_FLAGS := $(LD_FLAGS_DEBUG)
debug: $(TARGET)

# Enlazado
$(TARGET): $(OBJS)
	@mkdir -p $(BIN_DIR)
	$(LD) $(LD_FLAGS) $^ -o $@

# Compilación de objetos
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.asm
	@mkdir -p $(dir $@)
	$(ASM) $(ASM_FLAGS) $< -o $@

# Limpieza
clean:
	rm -rf $(BUILD_DIR) $(BIN_DIR)

.PHONY: all release debug clean



