VPATH = src

# Common source files
ASM_SRCS =
C_SRCS = main.c

# Object files
OBJS = $(ASM_SRCS:%.s=%.o) $(C_SRCS:%.c=%.o)

%.o: %.s
	as65816 --core=65816 --debug --list-file=$(@:%.o=obj/%.lst) -o obj/$@ $<

%.o: %.c
	cc65816 --core=65816 --debug --list-file=$(@:%.o=obj/%.lst) -o obj/$@ $<

aout.elf: $(OBJS)
	(cd obj ; ln65816 --debug -o ../$@ $^ ../linker-large-small.scm clib-lc-sd.a -l --cross-reference --rtattr printf=reduced --semi-hosted)

clean:
	-(cd obj ; rm $(OBJS) $(OBJS:%.o=%.lst))
	-rm aout.elf
