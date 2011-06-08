CC        := g++ -Wall -O -g3
LD        := ar rc

MODULES   := zxing zxing/common zxing/common/reedsolomon zxing/datamatrix zxing/datamatrix/decoder zxing/datamatrix/detector zxing/oned zxing/qrcode zxing/qrcode/detector zxing/qrcode/decoder
SRC_DIR   := $(addprefix src/,$(MODULES))
BUILD_DIR := $(addprefix build/,$(MODULES))

SRC       := $(foreach sdir,$(SRC_DIR),$(wildcard $(sdir)/*.cpp))
OBJ       := $(patsubst src/%.cpp,build/%.o,$(SRC))
INCLUDES  := -Isrc

UTIL_INCLUDE := -I/usr/local/include/ImageMagick -Isrc
UTIL_LIBS := -lMagick++ -lMagickWand -lMagickCore -liconv
UTIL_SRC  := src/util/main.cpp src/util/MagickBitmapSource.cpp
UTIL_OBJ  := $(patsubst src/util/%.cpp,%.o,$(UTIL_SRC))

vpath %.cpp $(SRC_DIR) src/util

define make-goal
$1/%.o: %.cpp
	$(CC) $(INCLUDES) -c $$< -o $$@
endef

.PHONY: all checkdirs checkutildirs clean

all: checkdirs build/zxing.a util

build/zxing.a: $(OBJ)
	$(LD) $@ $^
	ranlib $@

checkdirs: $(BUILD_DIR) checkutildirs

$(BUILD_DIR):
	mkdir -p $@

checkutildirs:
	@mkdir -p build/util/

clean:
	rm -rf build/
	rm -rf bin/
	rm -rf lib/

install:
	mkdir -p lib bin
	cp -f build/zxing.a lib/zxing
	mv -f build/qrdecode bin

$(foreach bdir,$(BUILD_DIR),$(eval $(call make-goal,$(bdir))))

util: checkutildirs $(UTIL_OBJ)
	$(CC) -o build/qrdecode $(addprefix build/util/,$(UTIL_OBJ)) $(UTIL_LIBS) build/zxing.a

$(UTIL_OBJ):
	$(CC) -c $(UTIL_INCLUDE) -o build/util/$@ $(patsubst %.o,src/util/%.cpp,$@)
