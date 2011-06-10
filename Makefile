CC        := g++ -Wall -O -g3 -fPIC -fno-common

uname_S := $(shell sh -c 'uname -s 2>/dev/null || echo not')
ifeq ($(uname_S),Darwin)
	EXTRA := -liconv
endif

PREFIX = /usr/local

MODULES   := zxing zxing/common zxing/common/reedsolomon zxing/datamatrix zxing/datamatrix/decoder zxing/datamatrix/detector zxing/oned zxing/qrcode zxing/qrcode/detector zxing/qrcode/decoder
SRC_DIR   := $(addprefix src/,$(MODULES))
BUILD_DIR := $(addprefix build/,$(MODULES))

SRC       := $(foreach sdir,$(SRC_DIR),$(wildcard $(sdir)/*.cpp))
OBJ       := $(patsubst src/%.cpp,build/%.o,$(SRC))
INCLUDES  := -Isrc

vpath %.cpp $(SRC_DIR)

define make-goal
$1/%.o: %.cpp
	$(CC) $(INCLUDES) -c $$< -o $$@
endef

.PHONY: all checkdirs clean include install

all: checkdirs build/libzxing.so

build/libzxing.so: $(OBJ)
	g++ -shared -o $@ $^ $(EXTRA)

checkdirs: $(BUILD_DIR)

$(BUILD_DIR):
	mkdir -p $@

clean:
	rm -rf include/
	rm -rf build/
	rm -rf bin/
	rm -rf lib/

install: include
	cp -p build/libzxing.so $(PREFIX)/lib/libzxing.so
	cp -Rp include/zxing $(PREFIX)/include

include:
	mkdir -p include
	find src -type d -exec mkdir include/\{\} \;
	find src -name *.h -exec cp -Rf \{\} include/\{\} \;
	mv include/src/zxing include/zxing;
	rm -rf include/src

$(foreach bdir,$(BUILD_DIR),$(eval $(call make-goal,$(bdir))))
