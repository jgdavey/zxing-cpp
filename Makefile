CC        := g++ -Wall -O -g3
LD        := ar rc

UTIL_INCLUDE := -I/usr/local/include/ImageMagick -Isrc
UTIL_LIBS = -lMagick++ -lMagickWand -lMagickCore -liconv

MODULES   := zxing zxing/common zxing/common/reedsolomon zxing/datamatrix zxing/datamatrix/decoder zxing/datamatrix/detector zxing/oned zxing/qrcode zxing/qrcode/detector zxing/qrcode/decoder
SRC_DIR   := $(addprefix src/,$(MODULES))
BUILD_DIR := $(addprefix build/,$(MODULES))

SRC       := $(foreach sdir,$(SRC_DIR),$(wildcard $(sdir)/*.cpp))
OBJ       := $(patsubst src/%.cpp,build/%.o,$(SRC))
INCLUDES  := -Isrc

vpath %.cpp $(SRC_DIR) src/util

define make-goal
$1/%.o: %.cpp
	$(CC) $(INCLUDES) -c $$< -o $$@
endef

.PHONY: all checkdirs clean

all: checkdirs build/zxing.a util

build/zxing.a: $(OBJ)
	$(LD) $@ $^
	ranlib $@

checkdirs: $(BUILD_DIR)

$(BUILD_DIR):
	mkdir -p $@

clean:
	rm -rf build/
	rm -rf bin/
	rm -rf lib/

install:
	mkdir -p lib bin
	cp -f build/zxing.a lib/zxing
	mv -f build/qrdecode bin

$(foreach bdir,$(BUILD_DIR),$(eval $(call make-goal,$(bdir))))

util: main.o MagickBitmapSource.o
	$(CC) -o build/qrdecode $(addprefix build/,$^) $(UTIL_LIBS) build/zxing.a

main.o: main.cpp
	$(CC) -c $(UTIL_INCLUDE) -o build/$@ $<

MagickBitmapSource.o: MagickBitmapSource.cpp
	$(CC) -c $(UTIL_INCLUDE) -o build/$@ $<
