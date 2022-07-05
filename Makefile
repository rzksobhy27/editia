UNAME_S = $(shell uname -s)

CC = clang
CFLAGS = -Wall -Wextra -pedantic -std=c11 -ggdb
CFLAGS += -Ilib/glfw/include/ -Ilib/glad/include/ -Ilib/cglm/include/ -Ilib/stb_image/
LDFLAGS = lib/glfw/src/libglfw3.a lib/glad/src/glad.o lib/cglm/libcglm.a lib/stb_image/stb_image.o -lm

# GLFW required frameworks on OSX
ifeq ($(UNAME_S), Darwin)
	LDFLAGS += -framework OpenGL -framework IOKit -framework CoreVideo -framework Cocoa
endif

ifeq ($(UNAME_S), Linux)
	LDFLAGS += -lGL -lX11 -lGLU -lOpenGL -ldl -lpthread
endif

SRC = $(wildcard src/*.c) $(wildcard src/**/*.c) $(wildcard src/**/**/*.c) $(wildcard src/**/**/**/*.c)
OBJ = $(SRC:.c=.o)
BIN = bin

.PHONY: all clean

all: dirs libs $(BIN)/output

dirs:
	mkdir -p $(BIN)

libs: lib/glfw/src/libglfw3.a lib/glad/src/glad.o lib/cglm/libcglm.a lib/stb_image/stb_image.o

lib/glfw/src/libglfw3.a:
	cd lib/glfw && cmake . && make

lib/glad/src/glad.o: lib/glad/src/glad.c
	cd lib/glad && $(CC) -o src/glad.o -Iinclude -c src/glad.c

lib/cglm/libcglm.a:
	cd lib/cglm && cmake . -DCGLM_STATIC=ON && make

lib/stb_image/stb_image.o: lib/stb_image/stb_image.c
	$(CC) $(CFLAGS) -o $(@) -c lib/stb_image/stb_image.c

$(BIN)/output: $(OBJ)
	$(CC) -o $(@) $(^) $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -o $(@) -c $(<)

run: all
	./$(BIN)/output

clean:
	rm -rf $(BIN) $(BIN)
