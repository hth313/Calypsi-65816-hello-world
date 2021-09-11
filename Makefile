VPATH = src

FOENIX = module/Calypsi-65816-Foenix

# Common source files
ASM_SRCS =
C_SRCS = main.c

MODEL = --code-model=large --data-model=small
LIB_MODEL = lc-sd

FOENIX_LIB = $(FOENIX)/foenix-$(LIB_MODEL).a
FOENIX_LINKER_RULES = $(FOENIX)/linker-files/foenix-u.scm

# Object files
OBJS = $(ASM_SRCS:%.s=obj/%.o) $(C_SRCS:%.c=obj/%.o)
OBJS_DEBUG = $(ASM_SRCS:%.s=obj/%-debug.o) $(C_SRCS:%.c=obj/%-debug.o)

obj/%.o: %.s
	as65816 --core=65816 $(MODEL) --target=foenix --debug --list-file=$(@:%.o=%.lst) -o $@ $<

obj/%.o: %.c
	cc65816 --core=65816 $(MODEL) --target=foenix --debug --list-file=$(@:%.o=%.lst) -o $@ $<

obj/%-debug.o: %.s
	as65816 --core=65816 $(MODEL) --debug --list-file=$(@:%.o=%.lst) -o $@ $<

obj/%-debug.o: %.c
	cc65816 --core=65816 $(MODEL) --debug --list-file=$(@:%.o=%.lst) -o $@ $<

hello.elf: $(OBJS_DEBUG)
	ln65816 --debug -o $@ $^ linker-large-small.scm clib-$(LIB_MODEL).a --list-file=hello-debug.lst --cross-reference --rtattr printf=reduced --semi-hosted

hello.pgz:  $(OBJS) $(FOENIX_LIB)
	ln65816 -o $@ $^ $(FOENIX_LINKER_RULES) clib-$(LIB_MODEL)-foenix.a --output-format=pgz --list-file=hello-foenix.lst --cross-reference --rtattr printf=reduced --rtattr cstartup=foenix

$(FOENIX_LIB):
	(cd $(FOENIX) ; make all)

clean:
	-rm $(OBJS) $(OBJS:%.o=%.lst) $(OBJS_DEBUG) $(OBJS_DEBUG:%.o=%.lst) $(FOENIX_LIB)
	-rm hello.elf hello.pgz hello-debug.lst hello-foenix.lst
	-(cd $(FOENIX) ; make clean)
