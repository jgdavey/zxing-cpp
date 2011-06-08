CC := g++  -O -g3 -Wall
LD := g++ -c -O -g3 -Wall
INCLUDE := -I/usr/local/include/ImageMagick -I../../core/src
LIBS = -lMagick++ -lMagickWand -lMagickCore -liconv


all: main.o MagickBitmapSource.o
	$(CC) -o ../../build/qrdecode $(addprefix build/,$^) $(LIBS) ../../build/zxing.a

main.o: main.cpp MagickBitmapSource.o
	$(LD) $(INCLUDE) -o build/$@ $<

MagickBitmapSource.o: MagickBitmapSource.cpp
	$(LD) $(INCLUDE) -o build/$@ $<
