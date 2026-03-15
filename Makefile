NAME = main
ASM = nasm
LD = ld
ASMFLAGS = -f elf64
LDFLAGS = -o build/$(NAME)

SORT_ORDER ?= 1

ASMFLAGS += -D SORT_ORDER=$(SORT_ORDER)

all: $(NAME)

$(NAME): $(NAME).asm
	$(ASM) $(ASMFLAGS) $< -o build/$(NAME).o
	$(LD) $(LDFLAGS) build/$(NAME).o

clean:
	rm -f build/$(NAME).o build/$(NAME)

asc:
	$(MAKE) SORT_ORDER=1 all
	./build/$(NAME)

desc:
	$(MAKE) SORT_ORDER=2 all
	./build/$(NAME)

run: all
	./build/$(NAME)