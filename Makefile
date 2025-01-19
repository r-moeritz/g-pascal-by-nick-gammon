# Paths
SRCDIR := src
PASDIR := pas
OBJDIR := build
SRC    := $(wildcard $(SRCDIR)/*.asm)
PAS    := $(wildcard $(PASDIR)/*)
OBJ    := $(SRC:$(SRCDIR)/%.asm=$(OBJDIR)/%.obj)
BIN    := $(OBJ:$(OBJDIR)/%.obj=$(OBJDIR)/%.bin)
PRI    := $(BIN:$(OBJDIR)/%.bin=$(OBJDIR)/%.pri)
PRG    := $(PRI:$(OBJDIR)/%.pri=$(OBJDIR)/%.prg)
D64    := $(OBJDIR)/g-pascal.d64

# Commands
ASM = ca65 -o $@ $<
LNK = ld65 -o $@ -C c64.cfg -S 32768 $<
PAK = dd if=$< bs=1 skip=88 of=0. &&\
printf "\000\200" >$@ &&\
cat 0. >>$@ && rm -f 0.
CRU = exomizer sfx 32768 -q -o $@ $<
RM := rm -rf
MKDIR := mkdir -p
MKD64 := c1541 -format g-pascal,gp d64

# Rules
$(OBJDIR)/%.obj: $(SRCDIR)/%.asm
	$(ASM)

$(OBJDIR)/%.bin: $(OBJDIR)/%.obj
	$(LNK)

$(OBJDIR)/%.pri: $(OBJDIR)/%.bin
	$(PAK)

$(OBJDIR)/%.prg: $(OBJDIR)/%.pri
	$(CRU)

# Targets
.PHONY: all d64 prg clean

all: d64
prg: $(PRG)

d64: $(PRG)
	$(MKD64) $(D64) -attach $(D64) $(foreach p,$(PRG),-write $(p) $(subst .prg,,$(subst build/,,$(p)))) -attach $(D64) $(foreach p,$(PAS),-write $(p))

$(SRC): | $(OBJDIR)

$(OBJDIR):
	$(MKDIR) $(OBJDIR)

clean:
	$(RM) $(OBJDIR)
