SRC=.\src
BIN=.\bin
UTILS=.\utils
NFLAGS=-fbin

all:	$(SRC)\kernel.asm $(SRC)\bootsect.asm
	cd $(SRC)
	nasm $(NFLAGS) kernel.asm -o .$(BIN)\kernel.bin
	nasm $(NFLAGS) bootsect.asm -o .$(BIN)\bootsect.bin
	
	cd ..
	copy emptyfat.ima $(UTILS)\DoOrS.ima
	move $(BIN)\kernel.bin $(UTILS)
	cd $(UTILS)
	fat12 -a DoOrS.ima kernel.bin
	move DoOrS.ima .$(BIN)
	move kernel.bin .$(BIN)	
	
boot: $(BIN)\bootsect.bin
	$(UTILS)\fdimage -q $(BIN)\bootsect.bin A:
	
kern: $(BIN)\kernel.bin
	copy $(BIN)\kernel.bin A:
	
vboot: emptyfat.ima
	copy emptyfat.ima $(BIN)\DoOrS.ima
	$(UTILS)\bootwrite $(BIN)\DoOrS.ima $(BIN)\bootsect.bin
	
vkern: $(BIN)\kernel.bin emptyfat.ima
	copy emptyfat.ima $(UTILS)\DoOrS.ima
	move $(BIN)\kernel.bin $(UTILS)
	cd $(UTILS)
	fat12 -a DoOrS.ima kernel.bin
	move DoOrS.ima .$(BIN)
	move kernel.bin .$(BIN)
	
clean:
	del $(BIN)\*.bin $(BIN)\*.ima	
	