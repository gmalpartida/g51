AS=/opt/sdcc/bin/sdas8051
LD=/opt/sdcc/bin/sdld
VI=vim
RM=rm
UCSIM=/opt/sdcc/bin/ucsim_51
DIS51=/opt/dis51/dis51
SOCAT=socat
MINICOM=minicom
SCREEN=screen
HEXDUMP=hexdump
OBJCOPY=/opt/sdcc/bin/sdobjcopy
PACKIHX=/opt/sdcc/bin/packihx
MINIPRO=minipro
ROM="upd27c256a@dip28"

AS_FLAGS=-los -Iinc 
LD_FLAGS=-imjw -b VECTORS=0x0000 -b CSEG=0x0030 -b XSEG=0x0300 -b XSEG_UART_BUFFER=0x0000 -b XSEG_CMD_LINE_BUFFER=0x0100 -M
RM_FLAGS=-rf
UCSIM_FLAGS= -C $(UCSIM_FILE) -t 51 -s$(VPORT0) -X 11.0592 
SOCAT_FLAGS=-d -d PTY,link=$(VPORT0),raw,echo=0 PTY,link=$(VPORT1),raw,echo=0
MINICOM_FLAGS=-D $(VPORT1)
SCREEN_FLAGS= -S sim_uart
HEXDUMP_FLAGS = -C
OBJCOPY_FLAGS=-I ihex -O binary $(HEX_FILE)
MINIPRO_FLAGS=-p $(ROM) -w $(HEX_FILE)

include sources.mk

TARGET=$(notdir $(CURDIR))

SRC_DIR=src
BIN_DIR=bin
CFG_DIR=cfg
INC_DIR=inc

RELS = $(patsubst $(SRC_DIR)/%.asm, $(BIN_DIR)/%.rel, $(SRCS))
IHX_FILE=$(BIN_DIR)/$(TARGET).ihx
HEX_FILE=$(BIN_DIR)/$(TARGET).hex
BIN_FILE=$(BIN_DIR)/$(TARGET).bin
DIS_FILE=$(BIN_DIR)/$(TARGET).dis
VPORT0=/tmp/ttyV0
VPORT1=/tmp/ttyV1
UCSIM_FILE=$(CFG_DIR)/$(TARGET).ucsim

.PHONY: all, build, clean, edit, link, sim, bin, pack

all:bin

$(BIN_DIR)/%.rel : $(SRC_DIR)/%.asm
	$(AS) $(AS_FLAGS) $@ $<
 
build : $(RELS)

$(IHX_FILE): $(RELS)
	@mkdir -p $(dir $@)
	$(LD) $(LD_FLAGS) $(IHX_FILE) $(RELS)

link: $(IHX_FILE)

edit:
	$(VI) $(SRC_DIR)/$(TARGET).asm

dis: build
	$(DIS51) $(DIS51_FLAGS)	< $(HEX_FILE) > $(DIS_FILE)

bridge:
	$(SOCAT) $(SOCAT_FLAGS) 

uart: build
	$(MINICOM) $(MINICOM_FLAGS) 

screen:
	$(SCREEN) $(SCREEN_FLAGS) 

dump: bin
	$(HEXDUMP) $(HEXDUMP_FLAGS) $(BIN_FILE)

bin: pack 
	$(OBJCOPY) $(OBJCOPY_FLAGS) $(BIN_FILE)

pack: link
	$(PACKIHX) $(IHX_FILE) > $(HEX_FILE)

sim: link
	$(UCSIM) $(UCSIM_FLAGS) $(IHX_FILE)

flash:
	$(MINIPRO) $(MINIPRO_FLAGS)  

clean:
	$(RM) $(RM_FLAGS) $(BIN_DIR)/*

