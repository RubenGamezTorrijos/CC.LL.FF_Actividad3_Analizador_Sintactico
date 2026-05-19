CC=gcc
FLEX=flex
BISON=bison
CFLAGS=-Wall -Wno-unused-function

# Directorio de fuentes
SRC_DIR=src

# Nombre del ejecutable
TARGET=minilang

all: $(TARGET)

$(TARGET): $(SRC_DIR)/parser.tab.c $(SRC_DIR)/lex.yy.c $(SRC_DIR)/main.c
	$(CC) $(CFLAGS) -I$(SRC_DIR) -o $(TARGET) $(SRC_DIR)/parser.tab.c $(SRC_DIR)/lex.yy.c $(SRC_DIR)/main.c

$(SRC_DIR)/parser.tab.c $(SRC_DIR)/parser.tab.h: $(SRC_DIR)/parser.y
	$(BISON) -d -o $(SRC_DIR)/parser.tab.c $(SRC_DIR)/parser.y

$(SRC_DIR)/lex.yy.c: $(SRC_DIR)/scanner.l $(SRC_DIR)/parser.tab.h
	$(FLEX) -o $(SRC_DIR)/lex.yy.c $(SRC_DIR)/scanner.l

clean:
	rm -f $(TARGET) $(SRC_DIR)/*.tab.c $(SRC_DIR)/*.tab.h $(SRC_DIR)/*.yy.c $(SRC_DIR)/*.o
	rm -rf *.zip

.PHONY: all clean
