; -*- asm -*-
; G-Pascal C64 byte-perfect-3.1 2012-02-22 cjb

;*******************************************************************
;
; Conversion to CC65 Assembler format and other mungings by Chris
; Baird <cjb@brushtail.apana.org.au> in 2012. This particular release
; of the file produces a byte-perfect copy of the G-Pascal 3.1
; software for the Commodore 64, as released and sold in 1986.
;
; To build:
;	ca65 gpascal.a
; 	[...0.16 seconds later!]
;	ld65 -o gpascal.bin -t none -S 32768 gpascal.o
;
; Or as I have in a Makefile:
;
; all:
;	ca65 -l gpascal.lst gpascal.a
;	ld65 -t none -S 32768 gpascal.o
;	dd if=a.out bs=1 skip=88 of=0.
;	printf "\000\200" >gpascal.prg
;	cat 0. >>gpascal.prg
;	rm -f 0. a.out
;
; As this is a derivative work, you probably don't want to bother Nick
; about the hacks I've done to it... And I (cjb) don't really intend
; to maintain or develop this Commodore64 version of the software.
; (From now on, I'll be working on porting it to other 6502 systems in
; my collection that've begged for their own Pascal for years!)
;
; This file has a number of totally ugly assembler hacks left in, both
; mine and Nick's, but have been left in for the goal of making it
; byte-perfect with the original code.
;
;*******************************************************************

;********************************************************************
;
; COPYRIGHT
;
; GPascal is copyright 1986 to 2011 by Nick Gammon. All rights
; reserved worldwide.
;
; GPascal is not in the public domain and Nick Gammon keeps its
; copyright.
;
; PERMISSION TO DISTRIBUTE
;
; Permission is hereby granted, free of charge, to any person
; obtaining a copy of this software and associated documentation files
; (the "Software"), to deal in the Software without restriction,
; including without limitation the rights to use, copy, modify, merge,
; publish, distribute, sublicense, and/or sell copies of the Software,
; and to permit persons to whom the Software is furnished to do so,
; subject to the following conditions:
;
; The above copyright notice and this permission notice shall be
; included in all copies or substantial portions of the Software.
;
; LIMITATION OF LIABILITY
;
; The software is provided "as is", without warranty of any kind,
; express or implied, including but not limited to the warranties of
; merchantability, fitness for a particular purpose and
; noninfringement. In no event shall the authors or copyright holders
; be liable for any claim, damages or other liability, whether in an
; action of contract, tort or otherwise, arising from, out of or in
; connection with the software or the use or other dealings in the
; software.
;
;*******************************************************************

;*******************************************************************
;
; For further information on this software, including the history of
; how it came to be, visit
; http://www.supercoders.com.au/blog/nickgammongpascal.shtml and
; http://www.gammon.com.au/GPascal/source/
;
;*******************************************************************

;************************************************
; G-PASCAL COMPILER
; for Commodore 64
; PART 1
; Authors_ Nick Gammon & Sue Gobbett
; Copyright (C) 1986 - Gambit Games.
;***********************************************

	P1	= $8013
	P2	= $8DD4
	P3	= $992E
	P4	= $A380
	P5	= $B384
	P6	= $BCB8
	;
	STACK	= $100
	INBUF	= $33C
	KBD_BUF	= $277
	HIMEM	= $283
	COLOR	= $286
	HIBASE	= $288
	AUTODN	= $292
	BITNUM	= $298
	BAUDOF	= $299
	RODBS	= $29D
	RODBE	= $29E
	ENABRS	= $2A1		; RS232 enables
	WARM_STR= $302		; basic warm start vector
	CINV	= $314		; hardware interrupt vector
	;
	SPACE	= $20
	CR	= $D
	FF	= $C
	LF	= $A
	MAX_STK	= 32
	NEW_STK	= $FF
	;
	VIC	= $D000
	SID	= $D400
	CIA1	= $DC00
	CIA2	= $DD00
	DATAREG	= $DD01
	DDRB	= $DD03
	FLAG	= $DD0D
	BORDER	= $D020
	BKGND	= $D021
	;
	COUT	= $FFD2
	STOP	= $FFE1
	GETIN	= $FFE4
	CHKOUT	= $FFC9
	CLRCHN	= $FFCC
	UNLSN	= $FFAE
	UNTKL	= $FFAB
	CHRIN	= $FFCF
	CHKIN	= $FFC6
	PLOT	= $FFF0
	CHROUT	= $FFD2
	CINT	= $FF81
	IOINIT	= $FF84
	CLALL	= $FFE7
	SETMSG	= $FF90
	SETLFS	= $FFBA
	SETNAM	= $FFBD
	OPEN	= $FFC0
	LOAD	= $FFD5
	READST	= $FFB7
	SAVE	= $FFD8
	RAMTAS	= $FF87
	RESTOR	= $FF8A
	MEMTOP	= $FF99
	UNTLK	= $FFAB
	CLOSE	= $FFC3

	;***********************************************
	; PASCAL WORK AREAS
	;***********************************************

	LINE_CNT= $2		; 2 BYTES
	LINE_NO	= LINE_CNT
	REG	= $4		; 2 BYTES
	ROWL	= REG
	ROWH	= REG+1
	SRCE	= REG
	REG2	= $6		; 2 BYTES
	DEST	= REG2
	WX	= $8		; 2 BYTES
	ERR_RTN	= $B		; 2 BYTES
	SYMTBL	= $D
	TOKEN	= $16
	TKNADR	= $17		; 2 BYTES
	TKNLEN	= $19
	EOF	= $1A
	LIST	= $1B
	NXTCHR	= $1C		; 2 BYTES
	VALUE	= $1E		; 3 BYTES
	DIGIT	= $21
	NOTRSV	= $22
	FRAME	= $23		; 2 BYTES
	LEVEL	= $25
	PCODE	= $26
	P 	= PCODE
	PNTR	= PCODE
	ACT_PCDA= $28		; 2 BYTES
	DISPL	= $2A		; 2 BYTES
	OFFSET	= $2C		; 2 BYTES
	OPND	= $2E		; 3 BYTES
	DCODE	= $31
	ENDSYM	= $32		; 2 BYTES
	ARG	= $34
	PROMPT	= $35
	WORKD	= $36		; 2 BYTES
	ERRNO	= $38
	RTNADR	= $39		; 2 BYTES
	BSAVE	= $3B
	WORK	= $3C		; 2 BYTES
	PRCITM	= $3E		; 2 BYTES
	DSPWRK	= $40		; 2 BYTES
	PFLAG	= $42
	T 	= ENDSYM	; STACK POINTER 2 BYTES
	TMP_PNTR= T
	BASE	= $45		; 2 BYTES
	TO	= BASE
	DATA	= $47		; 2 BYTES
	RUNNING	= $49
	UPR_CASE= $4A
	SCE_LIM	= $4B		; 2 BYTES
	FUNCTION= SCE_LIM
	SPRITENO= SCE_LIM+1
	STK_USE	= $4D
	VOICENO	= STK_USE
	SYMITM	= $4E		; 2 BYTES
	FROM	= SYMITM
	SYNTAX	= $50
	CHK_ARY	= $51
	SECRET	= $52
	VAL_CMP	= $53
	CTRLC_RT= $54		; 2 BYTES
	END_PCD	= $56		; 2 BYTES
	REGB	= $58
	REG2B	= $59
	LEFTCOL	= $5A
	SIGN	= $5B
	TEMP	= $5C		; 2 BYTES
	CALL	= $5E		; 2 BYTES
	COUNT	= $60
	LNCNT	= $61
	LS	= $62
	PCSVD	= $63		; 2 BYTES
	FIRST	= $65
	DBGTYP	= $66
	DBGFLG	= $67
	DEFP	= $68		; 2 BYTES
	DEFS	= $6A		; 2 BYTES
	DATTYP	= $6C
	DOS_FLG	= DATTYP
	A5	= $6D		; 2 BYTES
	MASK	= A5
	COLL_REG= A5+1
	ST	= $90
	DFLTN	= $99		; input device
	QUEUE	= $C6
	INDX	= $C8
	LXSP	= $C9
	BLNSW	= $CC
	BLNON	= $CF
	CRSW	= $D0
	BASL	= $D1
	CH	= $D3
;
	P_STACK	= $CED0		; P-CODE STACK
	S_ANIMCT= $CED8		; count of frames
	S_ANIMPS= $CEE0		; current position
	S_ANIMCC= $CEE8		; current frame count
	S_ANIMFM= $CEF0		; no. of frames
	S_POINTR= $CEF8		; pointers - 16 per sprite
	SID_IMG	= $CF7C
	S_ACTIVE= $CF98
	S_XPOS	= $CFA0		; 3 bytes each
	S_YPOS	= $CFB8		; 2 bytes each
	S_XINC	= $CFC8		; 3 bytes each
	S_YINC	= $CFE0		; 2 bytes each
	S_COUNT	= $CFF0		; 2 bytes each
;
	.org $02A7

COUNT1:  .res 1
COUNT2:  .res 1
SYM_USE: .res 2			; 2 BYTES
SAVCUR:  .res 6			; 6 BYTES
BPOINT:	 .res 20

	CALL_P	= BPOINT
	CALL_A	= BPOINT+1
	CALL_X	= BPOINT+2
	CALL_Y	= BPOINT+3
	FNC_VAL	= BPOINT+15
	REMAIN	= BPOINT+4
	XPOSL	= BPOINT+15
	XPOSH	= BPOINT+16
	YPOS	= BPOINT+17
	CNTR	= BPOINT+10
	ECNTR	= BPOINT
	EPNTR	= $43
	REP_FROM= BPOINT+2
	REP_TO	= BPOINT+3
	REP_LEN	= BPOINT+4
	PNTR_HI	= BPOINT+5
	IN_LGTH	= BPOINT+6
	LENGTH	= BPOINT+7
	FROM_ST	= BPOINT+9
	NUM_LINS= BPOINT+11
	ED_COM	= BPOINT+13
	TO_LINE	= BPOINT+15
	FND_FROM= BPOINT+17
	FND_TO	= BPOINT+18
	FND_POS	= BPOINT+19

LASTP:    .res 2
INCHAR:   .res 1
IO_A:     .res 1
IO_Y:     .res 1
IO_X:     .res 1
CURR_CHR: .res 1
HEX_WK:   .res 1
          .res 2
STK_AVL:  .res 1
STK_PAGE: .res 1
STK_WRK:  .res 1
STK_RT:   .res 2
BEG_STK:  .res 1
XSAVE:    .res 1
RES:      .res 3		; 3 BYTES
MCAND:    .res 3		; 3 BYTES
	DIVISOR	= MCAND
DVDN:     .res 3		; 3 BYTES
RMNDR:    .res 1
TEMP1:    .res 2
BIN_WRK:  .res 3
ASC_WRK:  .res 10
DEF_PCD:  .res 1
REP_SIZE: .res 1
NLN_FLAG: .res 1
Q_FLAG:   .res 1
FND_FLG:  .res 1
FND_LEN:  .res 1
UC_FLAG:  .res 1
TRN_FLAG: .res 1
GLB_FLAG: .res 1
INT_RTN:  .res 2	; address to return to after a timer interrupt
INT_TEMP: .res 1	; for interrupt service routine
INT_TMP1: .res 1
INT_TMP2: .res 1
QT_TGL:   .res 1	      ; quote toggle
QT_SIZE:  .res 1	      ; number of characters in reserved words

;***********************************************
; ADDRESS CONSTANTS ETC.
;***********************************************

        .org $8000
        JMP START
        JMP RESTART

          .res 3
TS:	  .word $4000
SYM_SIZE: .byte 16
LHB:	  .byte "["
RHB:	  .byte "]"
QUOT_SYM: .byte 34         ; QUOTE SYMBOL
DELIMIT:  .byte "."        ; FIND/REPLACE DELIMITER
PR_CHAN:  .byte 4          ; PRINTER CHANNEL
DISK_CHN: .byte 8          ; DISK CHANNEL
          .byte  0         ; SPARE FOR NOW

;***********************************************
; SYMBOL TABLE STUFF
;***********************************************

	SYMPRV	= 0
	SYMLVL	= 2
	SYMTYP	= 3
	SYMDSP	= 4
	SYMARG	= 6
	SYMSUB	= 6          ; MAX SUBSCRIPT+1
	SYMDAT	= 8          ; VARIABLE TYPE
	SYMLEN	= 9
	SYMNAM	= 10         ; NAME

;***********************************************
; PART 3 START
;***********************************************

	START	= P3
	RESTART	= START+3
	.scope
	EXIT_CMP= RESTART
	DSP_BIN	= P3+6
	ST_CMP	= P3+9
	ST_SYN	= P3+12
	DEBUG	= P3+15
	BELL1X	= P3+24

;***********************************************
; VECTORS
;***********************************************

        JMP INIT
        JMP GETNEXT
        JMP COMSTL
        JMP ISITHX
        JMP ISITAL
        JMP ISITNM
        JMP CHAR
        JMP GEN2_B
        JMP DISHX
        JMP ERROR
        JMP GETCHK
        JMP CHKTKN
        JMP GENNOP
        JMP GENADR
        JMP GENNJP
        JMP GENNJM
        JMP TKNWRK
        JMP PRBYTE
        JMP GTOKEN
        JMP WRKTKN
        JMP FIXAD
        JMP PSHWRK
        JMP PULWRK
        JMP PC
        JMP PT
        JMP PL
        JMP TOKEN1
        JMP GETANS
        JMP PUTSP
        JMP DISPAD
        JMP CROUT
        JMP SHLVAL
        JMP GET_NUM
        JMP GET_HEX
        JMP FND_END
        JMP PAUSE
        JMP HOME
        JMP RDKEY
        JMP GENJMP
        JMP GENRJMP

	; These are DICT token values to produce the
	; following..
	; 5,14,"g-pASCAL",
	; "COMPILER", ""vERSION 3.1 sER# 5001",13,
	; "wRITTEN BY nICK gAMMON ","AND sUE gOBBETT",13
	; "cOPYRIGHT 1983","gAMBIT",gAMES",
	; "p.o. bOX 124 iVANHOE 3079 vIC aUSTRALIA",13
US:	.byte $D1,$BA,$D2,$D6,$D3,$CE,$CF,$D0


;***********************************************
; PART 5 VECTORS
;***********************************************

	EDITOR	= P5
	PUT_LINE= P5+12

;***********************************************
; PART 6 VECTORS
;***********************************************

	BLOCK	= P6

;***********************************************
;
; INITIALIZE
;
;***********************************************

NOSCE:	.byte "NO",$BF,$0D	; "NO SOURCE\n"

INIT: 	LDA #0
        STA EOF
        STA LIST
        STA LEVEL
        STA DCODE
        STA RUNNING
        STA PRCITM
        STA PRCITM+1
        STA LINE_CNT
        STA LINE_CNT+1
        STA REGB
        LDA #<US
        LDX #>US
        LDY #8
        JSR PT
        LDA SYMTBL+1
        STA SYM_USE+1
        STA ENDSYM+1
        LDA TS
        SEC
        SBC #1
        STA NXTCHR
        LDA TS+1
        SBC #0
        STA NXTCHR+1
        JSR FND_END
        LDA P
        STA ACT_PCDA
        LDA P+1
        STA ACT_PCDA+1
        JSR LINE
        LDA EOF
        BEQ GOT_END2
        LDA #<NOSCE
        LDX #>NOSCE
        JSR PL
        JMP ERRRTN

;***********************************************
; FIND TEXT END
;***********************************************

FND_END:
        LDA TS
        STA PCODE
        LDA TS+1
        STA PCODE+1
        LDY #0
FND_TXTE:
        LDA (P),Y
        BEQ GOT_ENDS
        INC P
        BNE FND_TXTE
        INC P+1
        BNE FND_TXTE
GOT_ENDS:
        INC P
        BNE GOT_END2
        INC P+1
GOT_END2:
        RTS

;***********************************************
; GET NEXT CHAR FROM INPUT
;***********************************************

GETNEXT:
        LDY #1
        LDA (NXTCHR),Y
LINE4: 	RTS

;***********************************************
; INPUT A LINE
;***********************************************

LINE:	JSR GETNEXT
        BNE LINE1		; NULL= EOF
        INC EOF
        RTS
LINE1:
        LDA NXTCHR
        CLC
        ADC #1
        STA A5
        LDA NXTCHR+1
        ADC #0
        STA A5+1
        INC LINE_CNT
        BNE LINE3
        INC LINE_CNT+1
LINE3:
        LDA LIST
        BEQ LINE2
        JSR DISP
        RTS
LINE2:
        LDA LINE_CNT
        AND #15
        BNE LINE4
        LDA #'*'
        JMP PC

;***********************************************
; GET A CHARACTER
;***********************************************

CHAR:
        INC NXTCHR
        BNE CHAR2
        INC NXTCHR+1
CHAR2:
        LDY #0
        LDA (NXTCHR),Y
        CMP #CR
        BNE CHAR1
        JSR LINE		; END OF LINE
        LDA EOF
        BEQ CHAR
        LDA #0			; END OF FILE MARKER
CHAR1:
        STA  CURR_CHR
        RTS

CROUT:  LDA  #CR
        JMP  PC

;***********************************************
; COMPARE STRING
;***********************************************

COMSTL: DEY
        BMI COMS8
        LDA (SRCE),Y
        CMP #$C1
        BCC COMS1		; BLT = "BCC"
        CMP #$DB
        BCS COMS1		; BGE = "BCS"
        AND #$7F		; CONVERT TO U/C
COMS1:
        CMP (DEST),Y
        BEQ COMSTL
COMS9:	RTS			; NOT EQUAL
COMS8:	LDA #0
        RTS			; EQUAL

;***********************************************
; IS IT HEX?
;***********************************************

ISITHX: CMP #'0'
        BCC NOTHX
        CMP #'9'+1
        BCC ISHX
        CMP #'A'
        BCC NOTHX
        CMP #'F'+1
        BCC ISHX_A
        CMP #$C1
        BCC NOTHX
        CMP #$C7
        BCS NOTHX
        AND #$7F		; convert to upper case
ISHX_A:
        SEC
        SBC #7
ISHX:
        SEC
        SBC #'0'
        CLC
        RTS
NOTHX:
        SEC
        RTS

;***********************************************
; IS IT ALPHA
;***********************************************

ISITAL: CMP #'A'
        BCC NOTAL
        CMP #'Z'+1
        BCC ISAL
        CMP #$C1
        BCC NOTAL
        CMP #$DB
        BCC ISAL
NOTAL:
        SEC
        RTS
ISAL:
        CLC
        RTS

;***********************************************
; IS IT NUMERIC?
;***********************************************

ISITNM: CMP #'0'
        BCC NOTNUM
        CMP #'9'+1
        BCC ISNUM
NOTNUM:
        SEC
        RTS
ISNUM:
        CLC
        RTS

;***********************************************
;
; GET TOKEN !!!
; *********
;
; RESERVED WORD TABLE
;
;***********************************************

RSVWRD:	.byte 3, $81, "GET"
        .byte 5, $82, "CONST"
        .byte 3, $83, "VAR"
        .byte 5, $84, "ARRAY"
        .byte 2, $85, "OF"
        .byte 9, $86, "PROCEDURE"
        .byte 8, $87, "FUNCTION"
        .byte 5, $88, "BEGIN"
        .byte 3, $89, "END"
        .byte 2, $8A, "OR"
        .byte 3, $8B, "DIV"
        .byte 3, $8C, "MOD"
        .byte 3, $8D, "AND"
        .byte 3, $8E, "SHL"
        .byte 3, $8F, "SHR"
        .byte 3, $90, "NOT"
        .byte 3, $91, "MEM"
        .byte 2, $92, "IF"
        .byte 4, $93, "THEN"
        .byte 4, $94, "ELSE"
        .byte 4, $95, "CASE"
        .byte 5, $96, "WHILE"
        .byte 2, $97, "DO"
        .byte 6, $98, "REPEAT"
        .byte 5, $99, "UNTIL"
        .byte 3, $9A, "FOR"
        .byte 2, $9B, "TO"
        .byte 6, $9C, "DOWNTO"
        .byte 5, $9D, "WRITE"
        .byte 4, $9E, "READ"
        .byte 4, $9F, "CALL"
	; $A0 not used because of clash with shift/space
        .byte 4, $A1, "CHAR"
        .byte 4, $A2, "MEMC"
        .byte 6, $A3, "CURSOR"
        .byte 3, $A4, "XOR"
        .byte 12,$A5, "DEFINESPRITE"
        .byte 4, $A6, "PLOT"
        .byte 6, $A7, "GETKEY"
        .byte 5, $A8, "CLEAR"
        .byte 7, $A9, "ADDRESS"
        .byte 4, $AA, "WAIT"
        .byte 3, $AB, "CHR"
        .byte 3, $AC, "HEX"
        .byte 12,$AD, "SPRITEFREEZE"
        .byte 5, $AE, "CLOSE"
        .byte 3, $AF, "PUT"
        .byte 6, $DF, "SPRITE"
        .byte 14,$E0, "POSITIONSPRITE"
        .byte 5, $E1, "VOICE"
        .byte 8, $E2, "GRAPHICS"
        .byte 5, $E3, "SOUND"
        .byte 8, $E4, "SETCLOCK"
        .byte 6, $E5, "SCROLL"
        .byte 13,$E6, "SPRITECOLLIDE"
        .byte 13,$E7, "GROUNDCOLLIDE"
        .byte 7, $E8, "CURSORX"
        .byte 7, $E9, "CURSORY"
        .byte 5, $EA, "CLOCK"
        .byte 6, $EB, "PADDLE"
        .byte 7, $EC, "SPRITEX"
        .byte 8, $ED, "JOYSTICK"
        .byte 7, $EE, "SPRITEY"
        .byte 6, $EF, "RANDOM"
        .byte 8, $F0, "ENVELOPE"
        .byte 7, $F1, "SCROLLX"
        .byte 7, $F2, "SCROLLY"
        .byte 12,$F3, "SPRITESTATUS"
        .byte 10,$F4, "MOVESPRITE"
        .byte 10,$F5, "STOPSPRITE"
        .byte 11,$F6, "STARTSPRITE"
        .byte 13,$F7, "ANIMATESPRITE"
        .byte 3, $F8, "ABS"
        .byte 7, $F9, "INVALID"
        .byte 4, $FA, "LOAD"
        .byte 4, $FB, "SAVE"
        .byte 4, $FC, "OPEN"
        .byte 12,$FD, "FREEZESTATUS"
        .byte 7, $FE, "INTEGER"
        .byte 7, $FF, "WRITELN"
RSVEND:	.byte 0,0		; END OF TABLE


GETTKN:
GTOKEN: JSR CHAR
        BNE TOKEN1		; ZERO= EOF
        STA TOKEN
        RTS
TOKEN1:
        CMP #32
        BEQ GTOKEN		; BYPASS SPACE
        CMP #160		; ALSO BYPASS SHIFT/SPACE
        BEQ GTOKEN
        CMP #$10		; DLE?
        BNE TOKEN1_A
        INC NXTCHR
        BNE DLE_OK
        INC NXTCHR+1
DLE_OK:
        JMP GTOKEN
TOKEN1_A:
        CMP #'('
        BEQ TOKEN1_B
        JMP TOKEN2
TOKEN1_B:
        JSR GETNEXT
        CMP #'*'
        BEQ TOKEN3     ; COMMENT
        JMP TKN26_A    ; BACK TO PROCESS '('
TOKEN3:		       ; BYPASS COMMENTS
        JSR CHAR
        BNE TOKEN4
        LDX #7         ; NO } FOUND
        JSR ERROR
TOKEN4:
        CMP #$10       ; dle
        BNE TOKEN4_A   ; n
        INC NXTCHR     ; bypass count
        BNE TOKEN3
        INC NXTCHR+1
        BNE TOKEN3
TOKEN4_A:
        CMP #'%'       ; COMPILER DIRECTIVE?
        BNE TOKEN4_B   ; NO SUCH LUCK
        JSR CHAR       ; AND WHAT MIGHT THE DIRECTIVE BE?
        AND #$7F       ; convert case
        CMP #'A'       ; ADDRESS OF P-CODES?
        BNE TOKEN4_D   ; NOPE
        JSR GTOKEN     ; RE-CALL GTOKEN TO FIND THE ADDRESS
        CMP #'N'       ; NUMBER?
        BEQ TOKEN4_C   ; YES
        LDX #2
        JSR ERROR      ; 'Constant expected'
TOKEN4_C:
        LDA VALUE
        STA P
        STA ACT_PCDA   ; also save for run
        LDA VALUE+1
        STA P+1        ; STORE NEW P-CODE ADDRESS
        STA ACT_PCDA+1
        CMP #$08       ; TOO LOW?
        BCC TOKEN4_I   ; YES - ERROR
        CMP #$40       ; TOO HIGH
        BCC TOKEN3J    ; NOPE
        BNE TOKEN4_I   ; YES
;
; here if address is $40XX - CHECK THAT XX IS ZERO
;
        LDA P
        BEQ TOKEN3J    ; YES - THANK GOODNES
TOKEN3J:
        JMP TOKEN3     ; BACK AGAIN

; here if address is outside range $0800 to $4000
;
TOKEN4_I:
	LDX  #30
        JSR  ERROR      ; crash it

TOKEN4_D:
         CMP  #'L'       ; COMMENCE LISTING?
         BNE  TOKEN4_E   ; NOPE
TOKEN4_H:
         PHA
         LDA  LIST       ; ALREADY LISTING THE FILE?
         BNE  TOKEN4_F   ; YEP
         JSR  DISP       ; NO - SO DISPLAY THIS LINE THEN
TOKEN4_F:
         PLA
         STA  LIST       ; SET LISTING FLAG
         JMP  TOKEN3     ; BACK FOR NEXT COMMENT
;
TOKEN4_E:
         CMP  #'P'       ; P-CODES LIST?
         BNE  TOKEN4_G   ; NOPE
         STA  DCODE      ; SET DISPLAY P-CODE FLAG
         BEQ  TOKEN4_H   ; GO BACK AS IF FOR LIST
;
TOKEN4_G:
         EOR  #'N'       ; NO-LIST?
         BNE  TOKEN4_B   ; NOPE - FORGET IT THEN
         STA  DCODE
         STA  LIST       ; (A) MUST BE ZERO - CLEAR BOTH FLAGS
         BEQ  TOKEN3J    ; BACK FOR NEXT COMMENT
;
;
TOKEN4_B:
         CMP  #'*'
         BNE  TOKEN3J
         JSR  GETNEXT
         CMP  #')'
         BNE  TOKEN3J
         JSR  CHAR       ; BYPASS *
         JMP  GTOKEN
;
; HERE IF NOT COMMENT OR SPACE
;
TOKEN2:
        LDX NXTCHR
        STX TKNADR
        LDX NXTCHR+1
        STX TKNADR+1
        LDX #1
        STX TKNLEN     ; DEFAULT LENGTH=1
        DEX
        STX SIGN
        STX VALUE+1    ; FOR STRINGS
        STX VALUE+2
        STX NOTRSV
        JSR ISITAL
        BCS TOKEN5     ; NOT ALPHA
        LDA #'I'
        STA TOKEN      ; IDENTIFIER
TOKEN7:
        JSR GETNEXT
        JSR ISITAL
        BCC TKN18      ; ALPHA
        CMP #'_'       ; UNDERSCORE?
        BEQ TKN18_A    ; YEP
        JSR ISITNM
        BCS TOKEN6     ; END OF IDENT
TKN18_A:
	INC NOTRSV
TKN18:
        JSR CHAR
        INC TKNLEN
        BNE TOKEN7
TOKEN6:
        LDA NOTRSV
        BNE TKN19
        LDA #<RSVWRD
        STA WX
        LDA #>RSVWRD
        STA WX+1
TOKEN8:
        LDY #0
        LDA (WX),Y
        BNE TOKEN9     ; MORE TO GO
TKN19:
        LDA TOKEN
        RTS

; SEARCH FOR RESERVED WORD
;
TOKEN9:
         LDA  (WX),Y     ; LENGTH OF WORD
         CMP  TKNLEN     ; SAME?
         BNE  TKN10      ; CAN'T BE IT THEN
         TAY             ; LENGTH
         LDA  TKNADR
         STA  SRCE
         LDA  TKNADR+1
         STA  SRCE+1
         LDA  WX
         CLC
         ADC  #2
         STA  DEST
         LDA  WX+1
         ADC  #0
         STA  DEST+1
         JSR  COMSTL
         BNE  TKN10      ; NOT FOUND
         LDY  #1
         LDA  (WX),Y
         STA  TOKEN
         RTS
TKN10:
         LDY  #0
         LDA  (WX),Y     ; LENGTH
         CLC
         ADC  #2
         ADC  WX
         STA  WX
         BCC  TOKEN8
         INC  WX+1
         BNE  TOKEN8

;***********************************************
; NOT IDENTIFIER
;***********************************************

TOKEN5:
         JSR  ISITNM
         BCC  GET_NUM
         JMP  TKN12
GET_NUM:
         SEC
         SBC  #'0'
         STA  VALUE
         LDA  #0
         STA  VALUE+1
         STA  VALUE+2
TKN13:          ; NEXT DIGIT
         JSR  GETNEXT
         JSR  ISITNM
         BCC  TKN14      ; MORE DIGITS
TKN13A:
         LDA  SIGN
         BEQ  TKN13B
         SEC
         LDA  #0
         TAX
         SBC  VALUE
         STA  VALUE
         TXA
         SBC  VALUE+1
         STA  VALUE+1
         TXA
         SBC  VALUE+2
         STA  VALUE+2
TKN13B:
         LDA  #'N'
         STA  TOKEN
         CLC
         RTS
TKN14:
         JSR  CHAR
         SEC
         SBC  #'0'
         STA  DIGIT
         INC  TKNLEN
         JSR  SHLVAL
         LDA  VALUE
         LDX  VALUE+1
         LDY  VALUE+2
         JSR  SHLVAL
         JSR  SHLVAL
         ADC  VALUE
         STA  VALUE
         TXA
         ADC  VALUE+1
         STA  VALUE+1
         TYA
         ADC  VALUE+2
         STA  VALUE+2
         BCS  TKN16
         LDA  VALUE
         ADC  DIGIT
         STA  VALUE
         BCC  TKN13
         INC  VALUE+1
         BNE  TKN13
         INC  VALUE+2
         BEQ  TKN16
         BMI  TKN16
         JMP  TKN13
;
TKN16_B:
	PLA
        PLA             ; CUT STACK
TKN16:
        LDA RUNNING
        BPL TKN16_A
        SEC
        RTS
TKN16_A:
        LDX #30
        JSR ERROR
;
SHLVAL:
        ASL VALUE
        ROL VALUE+1
        ROL VALUE+2
        BCS TKN16_B
        RTS
;
;***********************************************
; NOT A NUMBER
;***********************************************
TKN12:
         CMP  QUOT_SYM
         BNE  TKN17
         INC  TKNADR
         BNE  TKN12_A
         INC  TKNADR+1
TKN12_A:
         DEC  TKNLEN
TKN30_A:
         JSR  GETNEXT
         CMP  #CR
         BNE  TKN31
         LDX  #8         ; MISSIG QUOTE
         JSR  ERROR
TKN31:
         CMP  QUOT_SYM
         BNE  TKN20
         JSR  CHAR
         JSR  GETNEXT    ; ANOTHER?
         CMP  QUOT_SYM
         BEQ  TKN20      ; IMBEDDED QUOTE
         LDY  #3
         CPY  TKNLEN
         BCC  TKN31_A
         LDY  TKNLEN
TKN31_A:
	DEY
        BMI TKN31_B
        LDA (TKNADR),Y
        STA VALUE,Y
        BNE TKN31_A
TKN31_B:
         LDA  TKNLEN
         BNE  TKN21
         LDX  #14        ; BAD STRING
         JSR  ERROR
TKN21:
         LDA  QUOT_SYM
         STA  TOKEN
         RTS
TKN20:
         JSR  CHAR
         INC  TKNLEN
         BNE  TKN30_A
;***********************************************
; NOT A STRING
;***********************************************
TKN17:
         CMP  #'$'
         BNE  TKN29
         JSR  GETNEXT
         JSR  ISITHX
         BCC  TKN22
         LDA  #'$'
         STA  TOKEN
         RTS
TKN22:
GET_HEX:
         STA  VALUE
         LDA  #0
         STA  VALUE+1
         STA  VALUE+2
TKN24:
         JSR  CHAR
         JSR  GETNEXT
         JSR  ISITHX
         BCC  TKN23
         JMP  TKN13A
TKN23:
         INC  TKNLEN
         LDX  #4
TKN15:
        JSR SHLVAL
        DEX
        BNE TKN15
        CLC
        ADC VALUE
        STA VALUE
        BCC TKN24
        INC VALUE+1
        BNE TKN24
        INC VALUE+2
        BNE TKN24
TKN16J:	JMP TKN16
;
;***********************************************
; NOT $ OR HEX LITERAL
;***********************************************
TKN29:
         CMP  #':'
         BNE  TKN25
         JSR  GETNEXT
         CMP  #'='
         BNE  TKN26_A
         JSR  CHAR
         INC  TKNLEN
         LDA  #'A'
TKN26:
         STA  TOKEN
         RTS
TKN26_A:
         LDY  #0
         LDA  (NXTCHR),Y
         BNE  TKN26
TKN25:
         CMP  #'<'
         BNE  TKN27
         JSR  GETNEXT
         CMP  #'='
         BNE  TKN28
         JSR  CHAR
         INC  TKNLEN
         LDA  #$80
         BNE  TKN26
TKN27:
         CMP  #'>'
         BNE  TKN30
         JSR  GETNEXT
         CMP  #'='
         BNE  TKN26_A
         JSR  CHAR
         INC  TKNLEN
         LDA  #$81
         BNE  TKN26
TKN28:
         CMP  #'>'
         BNE  TKN26_A
         JSR  CHAR
         INC  TKNLEN
         LDA  #'U'
         BNE  TKN26
TKN30:	CMP  #'-'
         BNE  TKN31_C
         STA  SIGN
TKN32:	JSR  GETNEXT
         JSR  ISITNM
         BCS  TKN26_A
         JSR  CHAR
         JMP  TOKEN5
TKN31_C: CMP  #'+'
         BNE  TKN26_A
         BEQ  TKN32

;***********************************************
; DISPLAY A LINE

DISP: 	JSR DISPAD1
        JSR PUT_LINE   ; display right-justified line no.
        LDA CH
        STA LEFTCOL
        LDA #$40
        STA RUNNING
        LDA A5
        LDX A5+1
        JSR PL
        LDA #0
        STA RUNNING
        RTS
;
; DISPLAY IN HEX
;
DISHX:	JSR  PRBYTE
        JMP  PUTSP

;***********************************************
; DISPLAY ERROR
;***********************************************

ERRLIT:	.byte 14         ; SWITCH TO LOWER CASE
        .byte "***",$BD	 ; '*** ERROR'

ERROR:	STX ERRNO
        LDA RUNNING
        BEQ ERR7
        JMP ERR6
ERR7:
         LDA  LIST
         BNE  ERR1
         JSR  CROUT
         JSR  DISP
ERR1:
         LDA  TKNADR
         SEC
         SBC  A5
         PHA             ; CHARS UP TO ERROR POINT
         LDY  #5
         LDA  #<ERRLIT
         LDX  #>ERRLIT
         JSR  PT
         PLA
         STA  TEMP       ; BYTES TO ERROR POINT
         CLC
         ADC  LEFTCOL
         SBC  #8
         TAX
;
; ALLOW FOR SPACE COUNTS
;
         LDY  #0
         STY  QT_TGL
         STY  QT_SIZE
ERR1_A:
         CPY  TEMP
         BCS  ERR2       ; DONE
         LDA  (A5),Y
         BMI  ERR1_D     ; could be reserved word
         CMP  #$10       ; DLE?
         BEQ  ERR1_B     ; YES
         CMP  QUOT_SYM   ; quote?
         BNE  ERR1_C     ; no
         LDA  QT_TGL
         EOR  #1
         STA  QT_TGL     ; flip flag
ERR1_C:	INY             ; ONTO NEXT
         BNE  ERR1_A
;
; here to allow for spaces in expanded reserved word
;
ERR1_D:	STY  IO_Y
         LDY  QT_TGL
         BNE  ERR1_F     ; ignore if in quotes
         CMP  #$B0
         BCC  ERR1_E
         CMP  #$DF
         BCC  ERR1_F     ; not in range
;
ERR1_E:	STA  IO_A       ; token
         JSR  PC_LOOK
         CLC
         ADC  QT_SIZE
         STA  QT_SIZE
ERR1_F:	LDY  IO_Y
         INY
         BNE  ERR1_A     ; done
;
;
ERR1_B:
         INY
         LDA  (A5),Y     ; SPACE COUNT
         AND  #$7F       ; CLEAR 8-BIT
         STA  TEMP+1
         TXA
         CLC
         ADC  TEMP+1
         TAX
         DEX
         DEX             ; ALLOW FOR DLE/COUNT
         BNE  ERR1_C
;
ERR2:
         TXA
         CLC
         ADC  QT_SIZE
         TAX
ERR3:
         JSR  PUTSP
         DEX
         BNE  ERR3
         LDA  #'^'
         JSR  PC
         JSR  CROUT
         LDX  #9
ERR5:
         JSR  PUTSP
         DEX
         BNE  ERR5
ERR6:
         DEC  ERRNO
         LDA  ERRNO
         ASL
         CLC
         ADC  #<ERRTBL
         STA  REG
         LDA  #>ERRTBL
         ADC  #0
         STA  REG+1
         LDY  #1
         LDA  (REG),Y
         TAX
         DEY
         LDA  (REG),Y
         JSR  PL         ; DISPLAY ERROR
ERRRTN:
         LDA  #0
         STA  QUEUE
         JMP  (ERR_RTN)

;***********************************************
; ERROR TABLE
;***********************************************

ERRTBL:
	.word ERR01,ERR02,ERR03,ERR04
        .word ERR05,ERR06,ERR07,ERR08
        .word ERR09,ERR10,ERR11,ERR12,ERR13,ERR14,ERR15,ERR16
        .word ERR17,ERR18,ERR19,ERR06,ERR21,ERR22,ERR23,ERR24
        .word ERR25,ERR26,ERR27,ERR28,ERR29,ERR30,ERR31
        .word ERR32,ERR33,ERR34,ERR35,ERR36,ERR37,ERR38

ERR01:	.byte "mEMORY",$B1,$0D
ERR02:	.byte $B2,$B4,$0D
ERR03:	.byte "=",$B4,$0D
ERR04:	.byte $B3,$B4,$0D
ERR05:	.byte ",",$C1," :",$B4,$0D
ERR06:	.byte "BUG",$0D
ERR07:	.byte "*)",$B4,$0D
ERR08:	.byte $B7,$B8,$0D
ERR09:	.byte ".",$B4,$0D
ERR10:	.byte ";",$B4,$0D
ERR11:	.byte "uNDECLARED",$B3,$0D
ERR12:	.byte $B6,$B3,$0D
ERR13:	.byte ":=",$B4,$0D
ERR14:	.byte $BB,$B8,$C0,$BE," LENGTH",$0D
ERR15:	.byte $BA," LIMITS EXCEEDED",$0D
ERR16:	.byte "then",$B4,$0D
ERR17:	.byte ";",$C1," end",$B4,$0D
ERR18:	.byte "do",$B4,$0D
ERR19:	.byte $B7,$C4,$0D
ERR21:	.byte "uSE",$C0," PROCEDURE",$B3," IN EXPRESSION",$0D
ERR22:	.byte ")",$B4,$0D
ERR23:	.byte $B6," FACTOR",$0D
ERR24:	.byte $C9,$BC,$0D
ERR25:	.byte "begin",$B4,$0D
ERR26:	.byte $22,$C0,$22,$B4,$0D
ERR27: 	.byte $C6,$B1,$0D
ERR28:	.byte $22,$C2,$22,$C1," downto",$B4,$0D
ERR29:	.byte $B8,$BB,$C2,"O BIG",$0D
ERR30:	.byte $CC," OUT",$C0,$D8,$0D
ERR31:	.byte "(",$B4,$0D
ERR32:	.byte ",",$B4,$0D
ERR33:	.byte "[",$B4,$0D
ERR34:	.byte "]",$B4,$0D
ERR35:	.byte $D9,"S",$BC,"ED",$0D
ERR36:	.byte "dATA",$C9," NOT RECOGNISED",$0D
ERR37:	.byte $C4,$C8,$B1,$0D
ERR38:	.byte "dUPLICATE",$B3,$0D

;***********************************************
; GET A TOKEN - CHECK THAT IT
; IS THE SAME AS IN "A", IF NOT
; CALL ERROR "X"
;***********************************************

GETCHK: STA BSAVE
        TXA
        PHA
        JSR GTOKEN
        CMP BSAVE
        BEQ CHKOK
        PLA
        TAX
CHKNOK: JSR ERROR
CHKOK: 	PLA
        RTS

;***********************************************
; CHECK TOKEN AGREES WITH "A",
; IF NOT, GIVE ERROR "X"
;***********************************************
CHKTKN:
         CMP  TOKEN
         BNE  CHKNOK
         RTS
;
;***********************************************
; GENERATE P-CODES - NO OPERANDS
;***********************************************
GENNOP:
         LDY  SYNTAX
         BNE  GEN1
         STA  (PCODE),Y
         PHA
         JSR  DISPAD
         PLA
         LDX  DCODE
         BEQ  GEN1
         JSR  DISHX
         JSR  CROUT
GEN1:
         LDA  #1
         BNE  GEN2_B
;***********************************************
; GENERATE P-CODES - WITH ADDRESS
;***********************************************
GENADR:
         LDY  SYNTAX
         BNE  GEN2
         STA  (PCODE),Y
         PHA
         LDA  DISPL
         INY
         STA  (PCODE),Y
         LDA  OFFSET
         INY
         STA  (PCODE),Y
         LDA  OFFSET+1
         INY
         STA  (PCODE),Y
         JSR  DISPAD
         PLA
         LDX  DCODE
         BEQ  GEN2
         JSR  DISHX
         LDA  DISPL
         JSR  DISHX
         LDA  OFFSET
         JSR  DISHX
         LDA  OFFSET+1
         JSR  DISHX
         JSR  CROUT
GEN2:
         LDA  #4
GEN2_B:
         CLC
         ADC  PCODE
         STA  PCODE
         BCC  GEN2_A
         INC  PCODE+1
GEN2_A:
         LDA  SYNTAX
         BNE  GEN2_C
         LDA  PCODE+1
         CMP  #>(P1-$18)
         BCC  GEN2_C
         BNE  GEN_FULL
         LDA  PCODE
         CMP  #<(P1-$18)
         BCC  GEN2_C
GEN_FULL:
	LDX #1         ; MEM FULL
        JSR ERROR
GEN2_C:
DISP9:	RTS

;***********************************************
; GENERATE P-CODES - JUMP ADDRESS
;***********************************************

GENRJMP:
         PHA
         LDA  OPND
         SEC
         SBC  PCODE
         STA  OPND
         LDA  OPND+1
         SBC  PCODE+1
         STA  OPND+1
         PLA
         JMP  GENJMP
;
GENNJP:
        LDA  #60        ; JMP
GENNJM:	LDX  #0
        STX  OPND
        STX  OPND+1
;
GENJMP:
         LDY  SYNTAX
         BNE  GEN3
         STA  (PCODE),Y
         PHA
         LDA  OPND
         INY
         STA  (PCODE),Y
         LDA  OPND+1
         INY
         STA  (PCODE),Y
         JSR  DISPAD
         PLA
         LDX  DCODE
         BEQ  GEN3
         JSR  DISHX
         LDA  OPND
         JSR  DISHX
         LDA  OPND+1
         JSR  DISHX
         JSR  CROUT
GEN3:
         LDA  #3
         JMP  GEN2_B

;***********************************************
; DISPLAY PCODE ADDRESS
;***********************************************
DISPAD:
         LDA  DCODE
         BEQ  DISP9
DISPAD1:
         LDA  #'('
         JSR  PC
         LDA  PCODE+1
         JSR  PRBYTE
         LDA  PCODE
         JSR  PRBYTE
         LDA  #')'
         JSR  PC
         JMP  PUTSP

;***********************************************
; FIXUP ADDRESSES
;***********************************************

FIXAD:
         LDY  SYNTAX
         BNE  DISP9
         LDY  #1
         LDA  PCODE
         SEC
         SBC  WORK
         STA  (WORK),Y
         INY
         LDA  PCODE+1
         SBC  WORK+1
         STA  (WORK),Y
         LDA  DCODE
         BEQ  PSH9
         LDA  #<FIXM1
         LDX  #>FIXM1
         LDY  #8
         JSR  PT
         LDA  WORK+1
         JSR  PRBYTE
         LDA  WORK
         JSR  DISHX
         LDA  #<FIXM2
         LDX  #>FIXM2
         LDY  #9
         JSR  PT
         LDA  PCODE+1
         JSR  PRBYTE
         LDA  PCODE
         JSR  DISHX
         JMP  CROUT

FIXM1:	.byte "jUMP AT "
FIXM2:	.byte "CHANGED",$C2
        .byte " "

;***********************************************
; PUSH 'WORK' ONTO STACK
;***********************************************

PSHWRK:
        STA  BSAVE
        PLA
        TAX
        PLA
        TAY
        LDA  WORK+1
        PHA
        LDA  WORK
        PHA
        TYA
        PHA
        TXA
        PHA
        LDA  BSAVE
PSH9:	RTS

;***********************************************
; PULL 'WORK' FROM STACK
;***********************************************

PULWRK:
        STA  BSAVE
        PLA
        TAX
        PLA
        TAY
        PLA
        STA  WORK
        PLA
        STA  WORK+1
        TYA
        PHA
        TXA
        PHA
        LDA  BSAVE
        RTS

;***********************************************
; PRINTING SUBROUTINES
;***********************************************

PRCHAR:
        STX  XSAVE
        PHA
        CMP  QUOT_SYM
        BNE  PR_NTQT
        PHA
        LDA  QT_TGL
        EOR  #1
        STA  QT_TGL
        PLA
PR_NTQT:
        PHA
        JSR  COUT
        PLA
        LDX  PFLAG      ; printing?
        BEQ  PR_NPTR
        PHA
        LDX  #4
        JSR  CHKOUT     ; direct to printer
        PLA

; The fiddling around below is because
; the capital letters in our messages (which are really
; lowercase here) do not print properly. So if we are not
; running a program or in quote mode, then we will convert
; what we think is 'lower case' to the equivalent in
; 'shifted' upper case (8 bit on).

         LDX  RUNNING    ; running?
         CPX  #12
         BEQ  PR_POK     ; yes - ignore
         LDX  QT_TGL     ; in quotes?
         BNE  PR_POK     ; yes - ignore
         CMP  #'a'       ; upper case (on C64)?
         BCC  PR_POK     ; nope
         CMP  #'z'+1
         BCS  PR_POK     ; nope
         CLC
         ADC  #$60       ; 'a' (hex 61) now becomes hex C1
;
PR_POK:
         JSR  COUT
         JSR  CLRCHN     ; back to screen
PR_NPTR:
         JSR  STOP
         BEQ  ABORT      ; abort list
         LDA  QUEUE      ; keys in kbd queue?
         BEQ  PR_NOT     ; nope
         LDA  KBD_BUF    ; get item in queue
         CMP  #$20       ; SPACE
         BNE  PR_NOT
         PLA
PAUSE:	PHA
        TYA
        PHA
        JSR  GETIN      ; clear that entry
PR_WAIT:
         JSR  GETIN      ; wait for another
         BEQ  PR_WAIT
         JSR  STOP       ; stop key?
         BNE  PR_ONWD
ABORT:
         JSR  GETIN      ; clear keyboard buffer
         JMP  (CTRLC_RT)
PR_ONWD: PLA
         TAY
PR_NOT:
         PLA
PRCHR_X:
         LDX  XSAVE
         RTS
;
;
;
PRBYTE:	PHA
        LSR
        LSR
        LSR
        LSR
        JSR  PRHEXZ
        PLA
PRHEX:
        AND  #$0F
PRHEXZ:	ORA  #$30
        CMP  #$3A
        BCC  PRHEX1
        ADC  #$26
PRHEX1:	JMP  PRCHAR

PUTSP:
        LDA  #32
        BNE  PRHEX1

PC:
        PHA
        JSR  IOSAVE
        PLA
        BPL  PC3
        LDX  RUNNING
        CPX  #12
        BNE  PC1        ; interpreting
PC9:	LDA  IO_A
        BMI  PC3
PC1:
        LDA  QT_TGL
        BNE  PC9
        LDY  #0
        LDA  IO_A
        CMP  #$B0
        BCC  PC_RSVD
        CMP  #$DF
        BCS  PC_RSVD
        CPX  #$40       ; in Editor?
        BEQ  PC9
        JSR  PUTSP
        LDX  #<DICT
        STX  REG
        LDX  #>DICT
        STX  REG+1
PC6:
        LDA  (REG),Y
        CMP  #$FF
        BEQ  PC7
        LDA  IO_A
        CMP  (REG),Y
        BEQ  PC5
        INY
        BNE  PC6
        INC  REG+1
        BNE  PC6
PC5:
        INY
        BNE  PC5_A
        INC  REG+1
PC5_A:
        LDA  (REG),Y
        BMI  PC2
        JSR  PRCHAR
         JMP  PC5
PC7:
PC3:
         JSR  PRCHAR
PC2:
         JMP  IOREST
;
PC_LOOK:          ; lookup reserved word for PC and ERROR
         LDA  #<RSVWRD
         STA  REG
         LDA  #>RSVWRD
         STA  REG+1
PC_RSVD1:
	INY
        LDA  (REG),Y    ; token
        BEQ  PC_LOOK9   ; end
        CMP  IO_A
        BEQ  PC_RSVD2   ; found
        DEY
        LDA  (REG),Y    ; length
        CLC
        ADC  #2
        ADC  REG
        STA  REG
        BCC  PC_RSVD1
        INC  REG+1
        BNE  PC_RSVD1
PC_RSVD2:
	DEY
        LDA  (REG),Y
PC_LOOK9:
	RTS
;
PC_RSVD:
	JSR  PC_LOOK
        BEQ  PC7        ; not found
        TAX
        INY
        INY
PC_RSVD3:
	LDA  (REG),Y
        JSR  PRCHAR
        INY
        DEX
        BNE  PC_RSVD3
        JSR  PUTSP
        BEQ  PC2        ; done!
;
;
PT:
         STA  REG2
         STX  REG2+1
         TYA
         TAX
         LDY  #0
         STY  QT_TGL
PT6:
         LDA  (REG2),Y
         JSR  PC
         INY
         DEX
         BNE  PT6
         RTS
;
PL:
         STA  REG2
         STX  REG2+1
         LDY  #0
         STY  QT_TGL
PL5:
         LDA  (REG2),Y
         CMP  #$10       ; DLE
         BEQ  PL5A
         JSR  PC
         INY
         CMP  #CR
         BNE  PL5
         RTS
PL5A:
         INY
         LDA  (REG2),Y
         AND  #$7F       ; STRIP 8-BIT
         TAX
PL5B:
         JSR  PUTSP
         DEX
         BNE  PL5B
         INY
         JMP  PL5
;
;

DICT: 	.byte $B0, "p-CODES"
        .byte $B1, "FULL"
        .byte $B2, "cONSTANT"
        .byte $D0, "p.o. bOX 124 iVANHOE 3079 vIC aUSTRALIA",$0D
        .byte $B3, "iDENTIFIER"
        .byte $B4, "EXPECTED"
        .byte $B5, "MISSING"
        .byte $CF, "gAMES",$0D
        .byte $B6, "iLLEGAL"
        .byte $B7, "iNCORRECT"
        .byte $D2, "vERSION 3.1 sER# 5001",$0D
        .byte $B8, "STRING"
        .byte $B9, "dO YOU WANT"
        .byte $BA, "COMPILER"
        .byte $D4, "<c>OMPILE"
        .byte $BB, "LITERAL"
        .byte $BC, "MISMATCH"
        .byte $D5, "<s>YNTAX"
        .byte $BD, "eRROR"
        .byte $CE, "gAMBIT"
        .byte $BE, "ZERO"
        .byte $D3, "cOPYRIGHT 1983"
        .byte $BF, "SOURCE FILE"
        .byte $D7, "<q>UIT"
        .byte $C0, "OF"
        .byte $C1, "OR"
        .byte $C2, "TO"
        .byte $D1, 5,14,"g-pASCAL"
        .byte $C3, "ENDED AT "
        .byte $C4, "sYMBOL"
        .byte $D6, "wRITTEN BY nICK gAMMON AND sUE gOBBETT",$0D
        .byte $C6, "sTACK"
        .byte $C7, "iNSTRUCTION"
        .byte $D8, "rANGE"
        .byte $C8, "TABLE"
        .byte $C9, "tYPE"
        .byte $CA, "LIST"
        .byte $CB, "? y/n "
        .byte $CC, "nUMBER"
        .byte $CD, "lINE"
        .byte $D9, "pARAMETER"
        .byte $DA, "<e>DIT,"
        .byte $DB, "<"
EDICT:	.byte $FF

;
GETANS:
         JSR  PT
         JSR  RDKEY
         AND  #$7F
         PHA
         CMP  #$20
         BCS  GET1
         LDA  #$20
GET1:
         JSR  PC
         JSR  CROUT
         PLA
GETAN9:
         RTS
;
;
IOSAVE:
         STA  IO_A
         STX  IO_X
         STY  IO_Y
         RTS
;
IOREST:
         LDY  IO_Y
         LDX  IO_X
         LDA  IO_A
         RTS
;
;---- TKNADR --> WORK
;
TKNWRK:
         PHA
         LDA  TKNADR
         STA  WORK
         LDA  TKNADR+1
         STA  WORK+1
         PLA
         RTS
;
;---- WORK --> TKNADR
;
WRKTKN:
         PHA
         LDA  WORK
         STA  TKNADR
         LDA  WORK+1
         STA  TKNADR+1
         PLA
         RTS
;
;
RDKEY:
         LDA  #0
         STA  BLNSW      ; blink cursor
         STA  AUTODN     ; scroll
         JSR  GETIN
         CMP  #0
         BEQ  RDKEY      ; LOOP UNTIL GOT A CHARACTER
         PHA
         LDA  #0
         STA  BLNON
         PLA
         STA  BLNSW      ; stop blinking
         RTS
;
HOME:
         LDA  #147
         JMP  COUT
;
;
         .byte  0          ; END OF FILE

	.endscope

;************************************************
; PASCAL COMPILER
; for Commodore 64
; PART 2
; Authors_ Nick Gammon & Sue Gobbett
;  SYM $9000
;***********************************************

	.scope

;***********************************************
; PART 1 VECTORS
;***********************************************

	V1	= P1
	INIT	= V1
	GETNEXT	= V1+3
	COMSTL	= V1+6
	ISITHX	= V1+9
	ISITAL	= V1+12
	ISITNM	= V1+15
	CHAR	= V1+18
	GEN2_B	= V1+21
	DISHX	= V1+24
	ERROR	= V1+27
	GETCHK	= V1+30
	CHKTKN	= V1+33
	GENNOP	= V1+36
	GENADR	= V1+39
	GENNJP	= V1+42
	GENNJM	= V1+45
	TKNWRK	= V1+48
	PRBYTE	= V1+51
	GTOKEN	= V1+54
	WRKTKN	= V1+57
	FIXAD	= V1+60
	PSHWRK	= V1+63
	PULWRK	= V1+66
	PC	= V1+69
	PT	= V1+72
	PL	= V1+75
	PC8	= V1+78
	GETANS	= V1+81
	PUTSP	= V1+84
	DISPAD	= V1+87
	CROUT	= V1+90
	SHLVAL	= V1+93
	GET_NUM	= V1+96
	GET_HEX	= V1+99
	FND_ENQ	= V1+102
	PAUSE	= V1+105
	HOME	= V1+108
	RDKEY	= V1+111
	GENJMP	= V1+114
	GENRJMP	= V1+117

;***********************************************
; PART 2 STARTS HERE
;***********************************************

	.res 10			;xxxcjb
        ;.org $8DD4 ; P2

;***********************************************
; PART 2 VECTORS
;***********************************************

         JMP STMNT
         JMP EXPRES
         JMP CHKLHP
         JMP CHKRHP
         JMP CHKLHB
         JMP CHKRHB
         JMP LOOKUP
         JMP CHKDUP
         JMP CONDEC
         JMP VARDEC
         JMP CONST
         JMP GETSUB
         JMP W_STRING
         JMP WRKTKN
         JMP SYMWRK
         JMP WRKSYM
         JMP PSHPCODE
         JMP CHK_STAK
         JMP SEARCH
         JMP ADDSYM
         JMP TKNJMP

;***********************************************
; PART 6 VECTORS
;***********************************************

	BLOCK = P6

;
CHKLHP:
         LDA  #'('
         LDX  #31
         JMP  GETCHK
;
CHKRHP:
         LDA  #')'
         LDX  #22
         JSR  CHKTKN
         JMP  GTOKEN
;
GETSUB:
         JSR  CHKLHB
         JSR  EXPRES
         JMP  CHKRHB
;
CHKLHB:
         LDA  LHB
         LDX  #33
         JSR  GETCHK
         JMP  GTOKEN
;
CHKRHB:
         LDA  RHB
         LDX  #34
         JSR  CHKTKN
         JMP  GTOKEN
;
GET_LEV:
         LDA  LEVEL
         LDY  #SYMLVL
         SEC
         SBC  (SYMITM),Y
         STA  DISPL
         RTS
;
GET_DAT:
         LDY  #SYMDAT
         LDA  (SYMITM),Y
         STA  DATTYP
         RTS
;
;
;***********************************************
;SEARCH SYMBOL TABLE
;***********************************************
SEARCH:
         LDA  ENDSYM
         STA  SYMITM
         LDA  ENDSYM+1
         STA  SYMITM+1
SEA1:
         LDY  #SYMPRV
         LDA  (SYMITM),Y
         TAX
         INY
         LDA  (SYMITM),Y
         STA  SYMITM+1   ; PREVIOUS LINK
         TXA
         STA  SYMITM
         ORA  SYMITM+1
         BNE  SEA2       ; MORE TO GO
         RTS             ; FINISHED
SEA2:
         LDY  #SYMLEN
         LDA  (SYMITM),Y
         CMP  TKNLEN
         BNE  SEA1       ; WRONG LENGTH
         LDA  SYMITM
         CLC
         ADC  #SYMNAM
         STA  DEST
         LDA  SYMITM+1
         ADC  #0
         STA  DEST+1
         LDA  TKNADR
         STA  SRCE
         LDA  TKNADR+1
         STA  SRCE+1
         LDY  TKNLEN
         JSR  COMSTL
         BNE  SEA1       ; NOT THAT ONE
         JSR  GET_DAT
         LDY  #SYMLVL
         LDA  (SYMITM),Y
         TAX             ; LEVEL
         LDY  #SYMTYP
         LDA  (SYMITM),Y
         STA  BSAVE
         CMP  #'C'       ; CONSTANT
         BNE  SEA4
         LDY  #SYMDSP
         LDA  (SYMITM),Y
         STA  VALUE
         INY
         LDA  (SYMITM),Y
         STA  VALUE+1
         INY
         LDA  (SYMITM),Y
         STA  VALUE+2
         JMP  SEA3
SEA4:          ; NOT CONSTANT
         CMP  #'V'       ; VARIABLE?
         BEQ  SEA5       ; YES
         CMP  #'Y'       ; ARGUMENT?
         BNE  SEA3       ; NO
SEA5:
         JSR  GET_OFF
SEA3:
         LDA  BSAVE
         RTS             ; SHOULD SET 'NEQ' FLAG

;***********************************************
; ADD SYMBOL TO SYMBOL TABLE
;***********************************************

ADDSYM: LDX  ENDSYM
        STX  SYMITM
        LDX  ENDSYM+1
        STX  SYMITM+1
        LDY  #SYMTYP
        STA  (SYMITM),Y
        LDY  #SYMLVL
        PHA
        LDA  LEVEL
        STA  (SYMITM),Y
        LDY  #SYMLEN
        LDA  TKNLEN
        STA  (SYMITM),Y
        TAY
        DEY
        LDA  SYMITM
        CLC
        ADC  #SYMNAM
        STA  DEST
        LDA  SYMITM+1
        ADC  #0
        STA  DEST+1
ADD1:
        LDA  (TKNADR),Y
        CMP  #$C1
        BCC  ADD2
        AND  #$7F       ; UPPER CASE
ADD2:
        STA  (DEST),Y
        DEY
        BPL  ADD1
        LDA  DEST
        CLC
        ADC  TKNLEN
        STA  ENDSYM
        LDA  DEST+1
        ADC  #0
        STA  ENDSYM+1
        LDA  SYM_USE+1
        CMP  ENDSYM+1
        BCC  SYM_NEW
        BNE  SYM_LOW
        LDA  SYM_USE
        CMP  ENDSYM
        BCS  SYM_LOW
SYM_NEW:
	LDA  ENDSYM
        STA  SYM_USE
        LDA  ENDSYM+1
        STA  SYM_USE+1
SYM_LOW:
        LDA  ENDSYM+1
        CMP  HIMEM+1
        BCC  SYM_NTFL
        BNE  SYM_FULL
        LDA  ENDSYM
        CMP  HIMEM
         BCC  SYM_NTFL
SYM_FULL:
	LDX  #37
        JSR  ERROR
SYM_NTFL:
;
        PLA
        TAX             ; ENTRY TYPE
        CMP  #'C'       ; CONSTANT??
        BNE  ADD4
        LDY  #SYMDSP
        LDA  VALUE
        STA  (SYMITM),Y
        INY
        LDA  VALUE+1
        STA  (SYMITM),Y
        INY
        LDA  VALUE+2
        STA  (SYMITM),Y
        JMP  ADD9
ADD4:
        LDY  #SYMDAT
        LDA  #1
        STA  (SYMITM),Y
        TXA
        CMP  #'V'
        BNE  ADD9
        LDY  #SYMDSP+1
        LDA  FRAME+1
        STA  (SYMITM),Y
         DEY
         LDA  FRAME
         STA  (SYMITM),Y
         INC  FRAME
         BNE  ADD9
         INC  FRAME+1
ADD9:
         LDY  #SYMPRV
         LDA  SYMITM
         STA  (ENDSYM),Y
         INY
         LDA  SYMITM+1
         STA  (ENDSYM),Y
         RTS
;
;***********************************************
; JUMP ON TOKEN
; X/Y = START OF TABLE
; END OF TABLE IS A NULL
; A = TOKEN
;***********************************************
TKNJMP:
         STX  REG
         STY  REG+1
         TAX
JMP1:
         LDY  #0
         LDA  (REG),Y
         BNE  JMP2
         TXA
         RTS
JMP2:
         TXA
         CMP  (REG),Y
         BNE  JMP3
         PLA
         PLA             ; REMOVE RETURN ADDRESS
         INY
         LDA  (REG),Y
         STA  REG2
         INY
         LDA  (REG),Y
         STA  REG2+1
         TXA
         JMP  (REG2)
JMP3:
         LDA  REG
         CLC
         ADC  #3
         STA  REG
         BCC  JMP1
         INC  REG+1
         BNE  JMP1
;
LOOKUP:
        JSR  SEARCH
        BNE  LOOK1
        LDX  #11
        JSR  ERROR
LOOK1:	RTS
;
CHKDUP:	JSR  SEARCH
        BEQ  DUP9
        TXA
        CMP  LEVEL
        BNE  DUP9
        LDX  #38
        JSR  ERROR
DUP9:	RTS

;
; CONSTANT DEC
;

CONDEC:
         LDA  #'I'
         LDX  #4
         JSR  CHKTKN
         JSR  TKNWRK
         LDA  TKNLEN
         PHA
         LDA  #'='
         LDX  #3
         JSR  GETCHK
         JSR  GTOKEN
         JSR  CONST
         JSR  WRKTKN
         PLA
         STA  TKNLEN
         JSR  CHKDUP
         LDA  #'C'
         JSR  ADDSYM
         JMP  GTOKEN
;
;
;--- SYMITM --> WORK
;
SYMWRK:
         PHA
         LDA  SYMITM
         STA  WORK
         LDA  SYMITM+1
         STA  WORK+1
         PLA
         RTS
;
;--- WORK --> SYMITM
;
WRKSYM:
         PHA
         LDA  WORK
         STA  SYMITM
         LDA  WORK+1
         STA  SYMITM+1
         PLA
         RTS
;
; PUSH PCODE ONTO STACK
;
PSHPCODE:
         STA  BSAVE
         PLA
         TAX
         PLA
         TAY
         LDA  PCODE+1
         PHA
         LDA  PCODE
         PHA
         TYA
         PHA
         TXA
         PHA
         LDA  BSAVE
         RTS
;
GET_OFF:
         PHA
         LDY  #SYMDSP
         LDA  (SYMITM),Y
         STA  OFFSET
         INY
         LDA  (SYMITM),Y
         STA  OFFSET+1
         LDY  #SYMTYP
         LDA  (SYMITM),Y
         CMP  #'V'
         BEQ  GETO_1
         CMP  #'A'
         BEQ  GETO_1
         CMP  #'Y'
         BNE  GETO_2
GETO_1:
         SEC
         LDA  #$FD
         SBC  OFFSET
         STA  OFFSET
         LDA  #$FF
         SBC  OFFSET+1
         STA  OFFSET+1
GETO_2:
         PLA
         RTS
;
GETEXPR:
         JSR  GTOKEN
         JMP  EXPRES
;
;
PCD_WRKD:
         PHA
         LDA  PCODE
         STA  WORKD
         LDA  PCODE+1
         STA  WORKD+1
         PLA
         RTS
;
WRK_OPND:
         PHA
         LDA  WORK
         STA  OPND
         LDA  WORK+1
         STA  OPND+1
         PLA
         RTS
;
WRKD_WRK:
         PHA
         LDA  WORKD
         STA  WORK
         LDA  WORKD+1
         STA  WORK+1
         PLA
         RTS
;
WRK_WRKD:
         PHA
         LDA  WORK
         STA  WORKD
         LDA  WORK+1
         STA  WORKD+1
         PLA
         RTS
;
GET_COMM:
         LDA  #','
         LDX  #32
         JMP  CHKTKN
;
GET_ITEM:
         JSR  GET_COMM   ; check for comma
         JMP  GETEXPR
;
VAL_MOVE:
         PHA
         CLC
         LDA  VALUE
         STA  DISPL
         BPL  VAL_1
         SEC
VAL_1:
         LDA  VALUE+1
         BEQ  VAL_2
         SEC
VAL_2:
         STA  OFFSET
         LDA  VALUE+2
         STA  OFFSET+1
         BEQ  VAL_3
         SEC
VAL_3:
         BCC  VAL_5
         LDA  #0
         JSR  GENADR
         PLA
         RTS
VAL_5:
         LDA  VALUE
         ORA  #$80
         JSR  GENNOP
         PLA
         RTS
;
;
CHK_STAK:
        TSX
        TXA
        CMP  #MAX_STK
        BCC  STK_FULL
        RTS
STK_FULL:
STK_ERR:
	LDX  #27
        JSR  ERROR      ; FULL

;
; CONST
;

CONST:
         LDA  TOKEN
         CMP  #'N'
         BEQ  CONST9
         CMP  #'I'
         BEQ  CONST1
         CMP  QUOT_SYM
         BNE  CONST3
         LDX  TKNLEN
         CPX  #4
         BCC  CONST9
         JMP  FACERR1    ; STRING TOO BIG
CONST1:	JSR  SEARCH
        BNE  CONST2
CONST3:
         LDX  #2
         JSR  ERROR
CONST2:	CMP  #'C'
         BNE  CONST3
CONST9:	RTS
;
; VARIABLE DEC
;
VARDEC:	LDA  #'I'
         LDX  #4
         JSR  CHKTKN
         JSR  CHKDUP
         LDA  #'V'
         JSR  ADDSYM
         JMP  GTOKEN
;
; SIMPLE EXPRESSION
;
SIMEXP:
         LDA  TOKEN
         CMP  #'+'
         BEQ  SIM1
         CMP  #'-'
         BNE  SIM2
SIM1:	PHA
         JSR  GTOKEN
         JSR  TERM
         PLA
         CMP  #'-'
         BNE  SIM3
         LDA  #2
         JSR  GENNOP     ; NEGATE
SIM3:	LDA  TOKEN
         CMP  #'+'
         BEQ  SIM4
         CMP  #'-'
         BEQ  SIM4
         CMP  #$8A       ; OR
         BEQ  SIM4
         CMP  #$A4       ; XOR
         BEQ  SIM4
         RTS
SIM4:	PHA
         JSR  GTOKEN
         JSR  TERM
         PLA
         CMP  #'-'
         BEQ  SIM5
         CMP  #'+'
         BEQ  SIM6
         CMP  #$A4       ; XOR
         BEQ  SIM8
         LDA  #26        ; OR
SIM7:	JSR  GENNOP
	JMP  SIM3
SIM5:	LDA  #6         ; MINUS
        BNE  SIM7
SIM6:	LDA  #4         ; PLUS
        BNE  SIM7
SIM2:	JSR  TERM
        JMP  SIM3
SIM8:	LDA  #58        ; XOR
        BNE  SIM7
;
; TERM
;
TERMT1:	.byte '*'
        .word  TERM1
        .byte $8B
        .word  TERM1
        .byte '/'
        .word  TERM1
        .byte $8D
        .word  TERM1
        .byte $8C
        .word  TERM1
        .byte $8E
        .word  TERM1
        .byte $8F
        .word  TERM1
        .byte 0
;
TERM:	JSR  FACTOR
TERM2:	LDX  #<TERMT1
        LDY  #>TERMT1
        LDA  TOKEN
        JSR  TKNJMP
        RTS
;
TERM1:	PHA
        JSR  GTOKEN
        JSR  FACTOR
        PLA
        LDX  #<TERMT3
        LDY  #>TERMT3
        JSR  TKNJMP
;
TERM4:	LDA  #10
TERM3:	JSR  GENNOP
        JMP  TERM2
TERM5:	LDA  #27        ; AND
        BNE  TERM3
TERM6:	LDA  #11        ; MOD
        BNE  TERM3
TERM7:	LDA  #34
        BNE  TERM3
TERM8:	LDA  #36
        BNE  TERM3
TERM9:	LDA  #8
        BNE  TERM3
;
TERMT3:	.byte $8B
        .word  TERM4
        .byte '/'
        .word  TERM4
        .byte $8D
        .word  TERM5
        .byte $8C
        .word  TERM6
        .byte $8E
        .word  TERM7
        .byte $8F
        .word  TERM8
        .byte '*'
        .word  TERM9
        .byte 0

;
; FACTOR
;
FACTOR:	JSR  CHK_STAK
        LDA  TOKEN
        LDX  #<FACTB1
        LDY  #>FACTB1
        JSR  TKNJMP
        LDX  #23
        JSR  ERROR
;
IDENT:	JSR  LOOKUP
IDENT1:	CMP  #'P'
         BNE  IDENT2
         LDX  #21
         JSR  ERROR
IDENT2:	CMP  #'Y'
         BNE  IDENT3
         LDA  #0
         STA  OPND+1
         LDA  #3
         STA  OPND
         LDY  #SYMPRV
         LDA  (SYMITM),Y
         TAX
         INY
         LDA  (SYMITM),Y
         STA  SYMITM+1
         TXA
         STA  SYMITM
         LDA  #59
         JSR  GENJMP
         JMP  FNCPRC
;
IDENT3:	CMP  #'A'
         BEQ  IDENT4
         CMP  #'C'
         BNE  IDENT5
         JSR  VAL_MOVE
         JMP  IDENT7
;
FACAD1:	LDA  #12
         JSR  IDENT5_A
         JMP  CHKRHP
;
IDENT5:	LDA  #44
IDENT5_A: PHA
;
        STX  BSAVE
        LDA  LEVEL
        SEC
        SBC  BSAVE
        STA  DISPL
        PLA
IDENT6:	CLC
        ADC  DATTYP
        JSR  GENADR
IDENT7:	JMP  GTOKEN
;
FACAD2:	LDA  #14
        JSR  IDENT4_A
        JMP  CHKRHP
;
IDENT4:	LDA  #48
IDENT4_A: PHA
;
        JSR  SYMWRK
        JSR  PSHWRK
        JSR  GETSUB
        JSR  PULWRK
        JSR  WRKSYM
        JSR  GET_DAT
        JSR  GET_LEV
        JSR  GET_OFF
        PLA
        CLC
        ADC  DATTYP
        JMP  GENADR
;
; ADDRESS (IDENTIFIER)
;
;
FACADR:
         JSR  CHKLHP
         JSR  GET_LOOK
         CMP  #'V'
         BEQ  FACAD1
         CMP  #'A'
         BEQ  FACAD2
         LDX  #23
         JSR  ERROR
;
;
FACSTR:	LDA  TKNLEN
         CMP  #4
         BCC  FACNUM
FACERR1: LDX  #29        ; STRING TOO BIG
         JSR  ERROR
FACNUM:
         JSR  VAL_MOVE
         JMP  IDENT7
;
PAREN:	JSR  GETEXPR
         JMP  CHKRHP
;
FACMEM:	LDA  #0
         STA  DATTYP
         BEQ  FACM2
FACMMC:	LDA  #1
         STA  DATTYP
FACM2:	LDA  DATTYP
         PHA
         JSR  GETSUB
         PLA
         CLC
         ADC  #46
         BNE  GENNOP1
;
FACNOT:	 JSR  GTOKEN
         JSR  FACTOR
         LDA  #32
GENNOP1: JMP  GENNOP
;
SPCL_FAC: JSR  TKNCNV
FACRND1: JSR  GENNOP
         JMP  GTOKEN
;
S_FREEZE: LDA  #$15
         BNE  WAIT1_J
;
CLOSE_FL: LDA  #$5F
         BNE  WAIT1_J
;
GET: 	LDA  #$60
        BNE  WAIT1_J
;
PUT:	LDA  #$61
        BNE  WAIT1_J
;
;
SPC_FAC2:
	JSR  TKNCNV
WAIT1_J:
	JMP  WAIT_1     ; now get its argument
;
TKNCNV:
         LDA  TOKEN
         SEC
         SBC  #$A0
         RTS
;
FACGTKY:
	LDA  #7
        BNE  FACRND1    ; getkey
;
FACTB1:	.byte 'I'
        .word  IDENT
        .byte 'N'
        .word  FACNUM
FACTQT1:
	.byte $22        ; QUOTE SYMBOL
        .word FACSTR
        .byte '('
        .word PAREN
        .byte $91
        .word FACMEM     ; MEM
        .byte $90
        .word FACNOT
        .byte $A2
        .word FACMMC     ; MEMC
        .byte $A9
        .word FACADR
        .byte $E6
        .word SPCL_FAC   ; spritecollide
        .byte $E7
        .word SPCL_FAC   ; bkgndcollide
        .byte $E8
        .word SPCL_FAC   ; cursorx
        .byte $E9
        .word SPCL_FAC   ; cursory
        .byte $EA
        .word SPC_FAC2   ; clock
        .byte $EB
        .word SPC_FAC2   ; paddle
        .byte $ED
        .word SPC_FAC2   ; joystick
        .byte $EF
        .word SPCL_FAC   ; random
        .byte $F0
        .word SPCL_FAC   ; envelope
        .byte $F1
        .word SPCL_FAC   ; scrollx
        .byte $F2
        .word SPCL_FAC   ; scrolly
        .byte $F3
        .word SPC_FAC2   ; spritestatus
        .byte $A7
        .word FACGTKY    ; getkey
        .byte $EC
        .word SPC_FAC2   ; spritex
        .byte $EE
        .word SPC_FAC2   ; spritey
        .byte $F9
        .word SPCL_FAC   ; invalid
        .byte $F8
        .word SPC_FAC2   ; abs
        .byte $FD
        .word SPCL_FAC   ; freezestatus
        .byte 0

;
; EXPRESSION
;

EXPRES:	JSR  CHK_STAK
        JSR  SIMEXP
        LDA  TOKEN
        LDX  #<EXPTB1
        LDY  #>EXPTB1
        JSR  TKNJMP
        RTS
;
EXPTB1:	.byte '='
        .word  EXPR1
        .byte 'U'
        .word  EXPR1
        .byte '<'
        .word  EXPR1
        .byte $80
        .word  EXPR1
        .byte $81
        .word  EXPR1
        .byte '>'
        .word  EXPR1
        .byte 0
;
EXPR1:	PHA
        JSR  GTOKEN
        JSR  SIMEXP
        PLA
        LDX  #<EXPTB3
        LDY  #>EXPTB3
        JSR  TKNJMP
;
EXPTB3:	.byte '='
        .word  EXPR2
        .byte 'U'
        .word  EXPR3
        .byte '<'
        .word  EXPR4
        .byte $81
        .word  EXPR5
        .byte '>'
        .word  EXPR6
        .byte $80
        .word  EXPR7
        .byte 0
;
EXPR2:	LDA  #16
EXPR8:	JSR  GENNOP
         RTS
EXPR3:	LDA  #18
         BNE  EXPR8
EXPR4:	LDA  #20
         BNE  EXPR8
EXPR5:	LDA  #22
         BNE  EXPR8
EXPR6:	LDA  #24
         BNE  EXPR8
EXPR7:	LDA  #25
         BNE  EXPR8
;
; STATEMENT
;
STMNT:	JSR  CHK_STAK
        LDA  TOKEN
        LDX  #<STMNT1
        LDY  #>STMNT1
        JSR  TKNJMP
        RTS
;
STMNT1:	.byte 'I'
        .word ASSIGN
        .byte $92
        .word IF
        .byte $9A
        .word FOR
        .byte $96
        .word WHILE
        .byte $95
        .word CASE
        .byte $98
        .word REPEAT
        .byte $88
        .word BEG
        .byte $9E
        .word READ
        .byte $9D
        .word WRITE
        .byte $91
        .word MEM
        .byte $9F
        .word CALLSB
        .byte $A2
        .word MEMC
        .byte $A3
        .word CURSOR
        .byte $A5
        .word DEF_SPRT
        .byte $A6
        .word HPLOT
        .byte $AA
        .word WAIT
        .byte $81
        .word GET
        .byte $AD
        .word S_FREEZE   ; freezesprite (n)
        .byte $AE
        .word CLOSE_FL
        .byte $AF
        .word PUT
        .byte $DF
        .word SPRITE
        .byte $E0
        .word MVE_SPRT
        .byte $E1
        .word VOICE
        .byte $E2
        .word GRAPHICS
        .byte $E3
        .word SOUND
        .byte $E4
        .word SETCLOCK
        .byte $E5
        .word SCROLL
        .byte $A8
        .word CLEAR
        .byte $F4
        .word MVE_SPRT   ; movesprite (6 args)
        .byte $F5
        .word SPC_FAC2   ; stopsprite
        .byte $F6
        .word SPC_FAC2   ; startsprite
        .byte $F7
        .word ANIM_SPT
        .byte $FA
        .word LOAD_FIL
        .byte $FB
        .word SAVE_FIL
        .byte $FC
        .word OPEN_FIL
        .byte $FF
        .word WRITELN
        .byte 0

;
; ASSIGNMENT
;

ASSIGN:	JSR  LOOKUP
ASS1: 	LDX  #<ASSTB1
        LDY  #>ASSTB1
        JSR  TKNJMP
        LDX  #24
        JSR  ERROR
;
ASSTB1:	.byte 'A'
        .word  ASSARR
        .byte 'V'
        .word  ASSVAR
        .byte 'Y'
        .word  ASSVAR
        .byte 'P'
        .word FNCPRC
        .byte 0

;
ASSARR:	JSR  SYMWRK
         JSR  PSHWRK
         LDA  #54
         CLC
         ADC  DATTYP
         PHA
         JSR  GETSUB
         JMP  ASS2
;
ASSVAR:	JSR  SYMWRK
         JSR  PSHWRK
         LDA  #50
         CLC
         ADC  DATTYP
         PHA
         JSR  GTOKEN
ASS2:	LDA  #'A'
         LDX  #13
         JSR  CHKTKN
         JSR  GETEXPR
         PLA
         JSR  PULWRK
         JSR  WRKSYM
         PHA
         JSR  GET_LEV
         JSR  GET_OFF
         PLA
         JMP  GENADR
;
; LOAD/SAVE
;
OPEN_FIL:
LOAD_FIL:
SAVE_FIL:
         JSR  ARGS3
         PHA
         JSR  GET_COMM
         LDA  QUOT_SYM
         LDX  #8         ; " expected
         JSR  GETCHK
         PLA
         JSR  W_STRING
         JMP  CHKRHP
;
;
; WRITELN
;
WRITELN:
	JSR  GTOKEN     ; SEE IF ( PRESENT
        CMP  #'('
        BNE  WRITELN9   ; NOPE
        JSR  WRIT9
WRITELN9:
         LDA  #$5E       ; OUTPUT C/R
         JMP  GENNOP

;
; WRITE
;

WRITE:	JSR  CHKLHP
WRIT9:	JSR  GTOKEN
         CMP  QUOT_SYM
         BNE  WRIT1
         LDA  #35
         JSR  W_STRING
         JMP  WRIT5
;
W_STRING:
         JSR  GENNOP
         LDA  TKNLEN
         JSR  GENNOP
         LDY  #0
WRIT2:	LDA  (TKNADR),Y
         CMP  QUOT_SYM
         BNE  WRIT10
         INY
WRIT10:	INY
         TAX             ; save A temporarily
         TYA             ; save Y on stack
         PHA
         TXA
         JSR  GENNOP
         PLA
         TAY
         DEC  TKNLEN
         BNE  WRIT2
         JMP  GTOKEN
;
WRIT1:          ; here if not string
         CMP  #$AB       ; CHR?
         BEQ  W_CHR      ; yes
         CMP  #$AC       ; HEX?
         BEQ  W_HEX      ; yes
         JSR  EXPRES     ; just ordinary number - get it
         LDA  #30        ; output number
         JSR  GENNOP
WRIT5:	LDA  TOKEN
         CMP  #','
         BEQ  WRIT9
         JMP  CHKRHP
;
; here for write (chr(x))
;
W_CHR:
         LDA  #31        ; output character
W_CHR1:
         JSR  WAIT_1     ; process expression in parentheses
         JMP  WRIT5      ; back for next item
;
; here for write (hex(x))
;
W_HEX:
         LDA  #33        ; output hex
         BNE  W_CHR1
;
;
;
; GET NEXT TOKEN - MUST BE IDENTIFIER
; THEN LOOK IT UP IN SYMBOL TABLE
;
GET_LOOK:
	LDA  #'I'
        LDX  #4
        JSR  GETCHK
        JMP  LOOKUP

;
; READ
;
READ:	JSR  CHKLHP
READ8:	JSR  GET_LOOK
READ2:	JSR  SYMWRK
         JSR  PSHWRK
         LDX  #0
         STX  COUNT1
         CMP  #'A'
         BEQ  READ3
         CMP  #'V'
         BEQ  READ9
         LDX  #12
         JSR  ERROR
READ9:	JSR  GTOKEN
READ11:	PHA
         LDA  #28
         CLC
         ADC  DATTYP
         TAX
         PLA
READ4:	CMP  #'$'
         BNE  READ6
         LDX  #23
READ5:	TXA
         PHA
         JSR  GTOKEN
         PLA
         TAX
READ6:	TXA
         JSR  GENNOP
         JSR  PULWRK
         JSR  WRKSYM
         JSR  GET_DAT
READ10:	JSR  GET_LEV
         JSR  GET_OFF
         LDA  #50
         LDX  COUNT1
         BEQ  READ7
         LDA  #54
READ7:	CLC
         ADC  DATTYP
         JSR  GENADR
READ7_A: LDA  TOKEN
         CMP  #','
         BEQ  READ8
         JSR  CHKRHP
         RTS
READ3:	LDA  DATTYP
         PHA
         JSR  GTOKEN
         CMP  LHB
         BEQ  READ3_A
         PLA
         STA  DATTYP
         BNE  READ3_B
         LDX  #24
         JSR  ERROR
READ3_B: JSR  PULWRK
         JSR  WRKSYM
         LDA  #37        ; READ STRING
         JSR  GENNOP
         JSR  GET_LEV
         JSR  GET_OFF
         LDY  #SYMSUB
         LDA  (SYMITM),Y
         JSR  GENADR     ; A = LENGTH
         JMP  READ7_A
;
READ3_A: JSR  GETEXPR
         JSR  CHKRHB
         INC  COUNT1
         PLA
         STA  DATTYP
         LDA  TOKEN
         JMP  READ11
;
; CLEAR
;
CLEAR:	LDA  #9
         JMP  SCROLL_1

;
; CURSOR
;
CURSOR:	 LDA  #19
         PHA
;
;
TWO_OP:	 JSR  CHKLHP
         JSR  GETEXPR
ONE_OP2: JSR  GET_ITEM
ONE_OP:	 JSR  CHKRHP
         PLA
         JMP  GENNOP
;
; GRAPHICS/SOUND/SPRITE/MOVESPRITE/VOICE
;
GRAPHICS:
SOUND:
SPRITE:
MVE_SPRT:
VOICE:
         JSR  TKNCNV
         PHA             ; SAVE FOR LATER
         JSR  CHKLHP
VOICE_1:
         JSR  GETEXPR
         JSR  GET_ITEM
         PLA
         PHA
         CMP  #$54       ; 6-arg move sprite
         BEQ  VOICE_3
         CMP  #$42       ; graphics
         BCS  VOICE_2    ; only 2 arguments wanted
         JSR  GET_ITEM
         JMP  VOICE_2
VOICE_3:          ; want 4 more args
         JSR  GET_ITEM
         JSR  GET_ITEM
         JSR  GET_ITEM
         JSR  GET_ITEM
VOICE_2:
         PLA
         PHA
         JSR  GENNOP
         LDA  TOKEN
         CMP  #','
         BEQ  VOICE_1    ; another 3
         PLA
         JMP  CHKRHP
;
; Process 3 arguments
;
ARGS3:
         JSR  TKNCNV
         PHA
         JSR  CHKLHP
         JSR  GETEXPR
         JSR  GET_ITEM
         JSR  GET_ITEM
         PLA
         RTS
;
; SETCLOCK ( hours, mins, secs, 10ths. )
;
SETCLOCK:
         JSR  ARGS3
         PHA
         JMP  ONE_OP2
;
WAIT:	LDA  #57
WAIT_1:	PHA
         JSR  CHKLHP
         JSR  GETEXPR
         JMP  ONE_OP
;
; SCROLL
;
SCROLL:
         LDA  #69
SCROLL_1: PHA
         JMP  TWO_OP
;
ANIM_SPT:
         LDA  #$57
         PHA
         LDA  #17        ; count plus 16 pointers
         BNE  DEF_SPT2
;
;
; DEFINESPRITE
;
DEF_SPRT:
         LDA  #1         ; PCODE
         PHA
         LDA  #21        ; row count
DEF_SPT2:	PHA
         JSR  CHKLHP
         JSR  GETEXPR    ; sprite pointer
DEF_1:	JSR  GET_ITEM   ; next row
         PLA
         TAX
         DEX             ; one less row
         BEQ  DEF_8      ; zero? none left
         TXA
         PHA
         LDA  TOKEN
         CMP  #','
         BEQ  DEF_1      ; more supplied
;
; no more supplied - zero out rest
;
DEF_2:	LDA  #$80       ; load zero pcode
         JSR  GENNOP
         PLA
         TAX
         DEX
         BEQ  DEF_8      ; all done
         TXA
         PHA
         BNE  DEF_2      ; do another
DEF_8:	JSR  CHKRHP
         PLA             ; pcode for define/animate sprite
GENNOP2: JMP  GENNOP
;
;
; HPLOT
;
HPLOT:	JSR  CHKLHP
         JSR  GETEXPR    ; colour
         LDA  #3
         PHA
         JSR  GET_ITEM
         JMP  ONE_OP2
;
;
; MEM
;
MEM:	LDA  #0
         PHA
         BEQ  MEM2
MEMC:	LDA  #1
         PHA
MEM2:	JSR  GETSUB
         LDA  #'A'
         LDX  #13
         JSR  CHKTKN
         JSR  GETEXPR
         PLA
         CLC
         ADC  #52
         BNE  GENNOP2
;
; CALL ABSOLUTE ADDRESS
;
CALLSB:	JSR  CHKLHP
         JSR  GETEXPR
         JSR  CHKRHP
         LDA  #43
         BNE  GENNOP2
;
; FUNCTION OR PROCEDURE CALL
;
FNCPRC:	LDA  #0
         STA  COUNT1
         LDY  #SYMARG
         LDA  (SYMITM),Y
         BEQ  FNC1
         JSR  CHKLHP
FNC2:	LDA  COUNT1
         PHA
         JSR  SYMWRK
         JSR  PSHWRK
         JSR  GETEXPR
         JSR  PULWRK
         JSR  WRKSYM
         PLA
         STA  COUNT1
         INC  COUNT1
         LDA  TOKEN
         CMP  #','
         BEQ  FNC2
         LDA  COUNT1
         LDY  #SYMARG
         CMP  (SYMITM),Y
         BEQ  FNC3
         LDX  #35
         JSR  ERROR
FNC3:	JSR  CHKRHP
         JMP  FNC5
FNC1:	JSR  GTOKEN
FNC5:	JSR  GET_LEV
         JSR  GET_OFF
         LDY  #SYMDAT
         LDA  (SYMITM),Y
         BNE  FNC5A
         LDA  OFFSET
         SEC
         SBC  PCODE
         STA  OFFSET
         LDA  OFFSET+1
         SBC  PCODE+1
         STA  OFFSET+1
         LDA  #39
         BNE  FNC5B
FNC5A:	LDA  #56
FNC5B:	JSR  GENADR
         LDA  COUNT1
         BEQ  FNC4
         LDA  COUNT1     ; TIMES 3
         ASL
         BCS  FNC6
         ADC  COUNT1
         STA  COUNT1
         BCS  FNC6
         LDA  #0
         SEC
         SBC  COUNT1
         STA  OPND
         LDA  #$FF
         STA  OPND+1
         LDA  #59
         JSR  GENJMP
FNC4:	RTS
FNC6:	LDX  #15
         JSR  ERROR
;
;
; IF
;
IF:	JSR  GETEXPR
         LDA  #$93
         LDX  #16
         JSR  CHKTKN
         JSR  GTOKEN
         JSR  PSHPCODE
         LDA  #61
         JSR  GENNJM
         JSR  STMNT
         LDA  TOKEN
         CMP  #$94       ; ELSE
         BEQ  IF1
IF2:	JSR  PULWRK
         JSR  FIXAD
         RTS
IF1:	JSR  PULWRK     ; HERE FOR ELSE
         JSR  WRK_WRKD
         JSR  PSHPCODE
         JSR  GENNJP
         JSR  WRKD_WRK
         JSR  FIXAD
         JSR  GTOKEN
         JSR  STMNT
         JMP  IF2
;
; BEGIN
;
BEG:	JSR  GTOKEN
         JSR  STMNT
         LDA  TOKEN
         CMP  #';'
         BEQ  BEG
         LDA  #$89       ; END
         LDX  #17
         JSR  CHKTKN
         JMP  GTOKEN
;
; REPEAT
;
REPEAT:	JSR  PSHPCODE
REP1:	JSR  GTOKEN
         JSR  STMNT
         LDA  TOKEN
         CMP  #';'
         BEQ  REP1
         LDA  #$99
         LDX  #10
         JSR  CHKTKN
         JSR  GETEXPR
         JSR  PULWRK
         JSR  WRK_OPND
         LDA  #61
         JMP  GENRJMP
;
; WHILE
;
WHILE:	JSR  PSHPCODE
        JSR  GETEXPR
        JSR  PSHPCODE
        LDA  #61
        JSR  GENNJM
        LDA  #$97
        LDX  #18
        JSR  CHKTKN
        JSR  GTOKEN
        JSR  STMNT
        JSR  PULWRK
        JSR  WRK_WRKD
        JSR  PULWRK
        JSR  WRK_OPND
        LDA  #60
        JSR  GENRJMP
        JSR  WRKD_WRK
        JMP  FIXAD

;
; CASE
;
CASE:	JSR  GETEXPR
        LDA  #$85       ; OF
        LDX  #25
        JSR  CHKTKN
        LDA  #1
        STA  COUNT1
CASE7:	LDA  #0
        STA  COUNT2
CASE2:
        LDA  #42        ; make copy of selector
        JSR  GENNOP
        JSR  GETEXPR    ; next expression to compare
        LDA  #16
        JSR  GENNOP
        LDA  TOKEN
        CMP  #':'
        BEQ  CASE1
        LDA  #','
        LDX  #5
        JSR  CHKTKN
        JSR  PSHPCODE
        LDA  #62
        JSR  GENNJM
        INC  COUNT2
        JMP  CASE2
CASE1:	JSR  PCD_WRKD
        LDA  #61
        JSR  GENNJM
        LDA  COUNT2
        BEQ  CASE3
CASE4:	JSR  PULWRK
        JSR  FIXAD
        DEC  COUNT2
        BNE  CASE4
CASE3:	JSR  WRKD_WRK
         JSR  PSHWRK
         JSR  GTOKEN
         LDA  COUNT1
         PHA
         JSR  STMNT
         PLA
         STA  COUNT1
         LDA  TOKEN
         CMP  #$94       ; ELSE
         BEQ  CASE5
         CMP  #';'
         BNE  CASE6
         JSR  PCD_WRKD
         JSR  GENNJP
         JSR  PULWRK
         JSR  FIXAD
         JSR  WRKD_WRK
         JSR  PSHWRK
         INC  COUNT1
         JMP  CASE7
CASE5:	JSR  PCD_WRKD
         JSR  GENNJP
         JSR  PULWRK
         JSR  FIXAD
         JSR  WRKD_WRK
         JSR  PSHWRK
         JSR  GTOKEN
         LDA  COUNT1
         PHA
         JSR  STMNT
         PLA
         STA  COUNT1
CASE6:	LDA  #$89       ; END
         LDX  #17
         JSR  CHKTKN
         LDA  COUNT1
         BEQ  CASE8
CASE9:	JSR  PULWRK
         JSR  FIXAD
         DEC  COUNT1
         BNE  CASE9
CASE8:	JSR  FOR6
         JMP  GTOKEN
;
; FOR
;
FOR:	LDA  #'I'
         LDX  #4
         JSR  GETCHK
         JSR  LOOKUP
FOR1:	CMP  #'V'
         BEQ  FOR2
         CMP  #'Y'
         BEQ  FOR2
         LDX  #12
         JSR  ERROR
FOR2:	JSR  ASSVAR
         JSR  SYMWRK
         LDA  #0
         STA  COUNT1
         LDA  TOKEN
         CMP  #$9B       ; TO
         BEQ  FOR3
         LDA  #$9C       ; DOWNTO
         LDX  #28
         JSR  CHKTKN
         DEC  COUNT1
FOR3:	LDA  COUNT1
         PHA
         JSR  PSHWRK
         JSR  GETEXPR
         JSR  PULWRK
         JSR  WRKSYM
         PLA
         STA  COUNT1
         JSR  PSHPCODE
         LDA  #42
         JSR  GENNOP
         JSR  GET_LEV
         JSR  GET_OFF
         JSR  GET_DAT
         CLC
         ADC  #44
         JSR  GENADR
         LDA  #22        ; UP (GEQ)
         LDX  COUNT1
         BEQ  FOR4
         LDA  #25        ; DOWN (LEQ)
FOR4:	JSR  GENNOP
         JSR  PSHPCODE
         LDA  #61
         JSR  GENNJM
         LDA  COUNT1
         PHA
         JSR  SYMWRK
         JSR  PSHWRK
         LDA  #$97
         LDX  #18
         JSR  CHKTKN
         JSR  GTOKEN
         JSR  STMNT
         JSR  PULWRK
         JSR  WRKSYM
         JSR  GET_LEV
         JSR  GET_DAT
         JSR  GET_OFF
         LDA  DATTYP
         CLC
         ADC  #44
         JSR  GENADR
         PLA
         STA  COUNT1
         LDA  #38
         LDX  COUNT1
         BEQ  FOR5
         LDA  #40        ; DEC
FOR5:	JSR  GENNOP
         LDA  #50
         CLC
         ADC  DATTYP
         JSR  GENADR
         JSR  PULWRK
         JSR  WRK_WRKD
         JSR  PULWRK
         JSR  WRK_OPND
         LDA  #60
         JSR  GENRJMP
         JSR  WRKD_WRK
         JSR  FIXAD
FOR6:	LDA  #$FF
         STA  OPND+1
         LDA  #$FD
         STA  OPND
         LDA  #59
         JMP  GENJMP

         BRK

	.endscope

;************************************************
; PASCAL COMPILER
; for Commodore 64
; PART 3
; Authors_ Nick Gammon & Sue Gobbett
;   SYM $9000
;***********************************************

	.scope

;***********************************************
; PART 1 VECTORS
;***********************************************

	V1	= P1
	INIT	= V1
	GETNEXT	= V1+3
	COMSTL	= V1+6
	ISITHX	= V1+9
	ISITAL	= V1+12
	ISITNM	= V1+15
	CHAR	= V1+18
	GEN2_B	= V1+21
	DISHX	= V1+24
	ERROR	= V1+27
	GETCHK	= V1+30
	CHKTKN	= V1+33
	GENNOP	= V1+36
	GENADR	= V1+39
	GENNJP	= V1+42
	GENNJM	= V1+45
	TKNWRK	= V1+48
	PRBYTE	= V1+51
	GTOKEN	= V1+54
	SPARE2	= V1+57
	FIXAD	= V1+60
	PSHWRK	= V1+63
	PULWRK	= V1+66
	PC	= V1+69
	PT	= V1+72
	PL	= V1+75
	TOKEN1	= V1+78
	GETANS	= V1+81
	PUTSP	= V1+84
	DISPAD	= V1+87
	CROUT	= V1+90
	SHLVAL	= V1+93
	GET_NUM	= V1+96
	GET_HEX	= V1+99
	FND_END	= V1+102
	PAUSE	= V1+105
	HOME	= V1+108
	RDKEY	= V1+111
	GENJMP	= V1+114
	GENRJMP	= V1+117
	US	= V1+120
	V1_NEXT	= V1+23      ; AVAILABLE
;***********************************************
; PART 2 VECTORS
;***********************************************
	V2	= P2
	TKNJMP	= V2+60
;
;
;***********************************************
; PART 4 VECTORS
;***********************************************
	INTERJ	= P4
	DIS4	= P4+3
	BREAK	= P4+6
	CHK_ERR	= P4+9       ; invalid parameter in function call
	MAIN	= P4+12
	MAINP	= P4+15
	CHK_TOP	= P4+18
	TRUE2	= P4+21
	PULTOP	= P4+24
	S_PNT2	= P4+27
	MASKS	= P4+30      ; 8 bytes
	XMASKS	= P4+38      ; 8 bytes
	;
;***********************************************
; PART 5 VECTORS
;***********************************************
	EDITOR	= P5
	GETLN	= P5+3
	GETLNZ	= P5+6
	GETLN1	= P5+9

;***********************************************
; PART 6 VECTORS
;***********************************************

	BLOCK	= P6

;***********************************************
; PART 3 STARTS HERE
;***********************************************

	.res 1
        ;.org $992E ; P3

;***********************************************
; PART 3 VECTORS
;***********************************************

         JMP START
         JMP RESTART
         JMP DSP_BIN
         JMP  ST_CMP
         JMP  ST_SYN
         JMP  DEBUG
         JMP  ST_EDI
         JMP  ST_FIL
         JMP  BELL1X
         JMP  MOV_SPT
         JMP  SPT_STAT
         JMP  SPRT_X
         JMP  SPRT_Y
         JMP  STOP_SPT
         JMP  STRT_SPT
         JMP  ANM_SPT
         JMP  LOADIT
         JMP  SAVEIT
         JMP  FREEZE_S
         JMP  FR_STAT
         JMP  X_OPEN
         JMP  X_CLOSE
         JMP  X_PUT
         JMP  X_GET

;***********************************************
; COMPILER MAINLINE
;***********************************************

ENDMSG:	.byte $B0,$C3
ENDMG2:	.byte $D4
        .byte " FINISHED: NO",$BD
        .byte "S",$0D
FIL_MSG:
	.byte $0D,$DB
        .byte "l>OAD,",$DB
        .byte "a>PPEND, ",$DB
        .byte "p>RINT, ",$DB
        .byte "d>OS,",$0D,$DB
        .byte "s>AVE,",$DB
        .byte "n>OPRINT,",$DB
        .byte "v>ERIFY,",$D7
        .byte ",",$0D,$DA,$DB
        .byte "c>ATALOG,",$DB
        .byte "o>BJECT ? "
MSG1:	.byte 13,$DA,$D4,",",$DB
        .byte "d>EBUG,",$DB
        .byte "f>ILES,",$0D,$DB
        .byte "r>UN, ",$D5
        .byte ", ",$DB
        .byte "t>RACE,",$D7
        .byte " ? "
MSG4:	.byte $C4,$C8,$C3
MSG6:	.byte "nO VALID",$D4
        .byte " DONE BEFORE",$0D
;
PRBYTECR:
         JSR  PRBYTE
         JMP  CROUT
;
DOS_COLD:
         LDX  #0
         LDY  #$A0
         CLC
         JSR  MEMTOP     ; normal Basic top of memory
         LDA  #47
         STA  $1         ; MAKE BASIC AVAILABLE
         JMP  ($A000)
;
;
;
COMPIL:	LDX  #NEW_STK
        TXS
        LDX  #0
        LDY  #$D0       ; use spare memory
        CLC
        JSR  MEMTOP     ; set top of memory
        LDA  #<ST_EDI
        STA  ERR_RTN
        LDA  #>ST_EDI
        STA  ERR_RTN+1
        LDA  HIMEM+1
        SEC
        SBC  SYM_SIZE
        STA  SYMTBL+1
        LDA  HIMEM
        STA  SYMTBL
        STA  SYM_USE
        STA  ENDSYM
;
;
        JSR  HOME
        JSR  INIT
        JSR  GTOKEN
        LDY  #0
        STY  VAL_CMP
        TYA
        STA  (ENDSYM),Y
        INY
        STA  (ENDSYM),Y
        JSR  BLOCK
        LDA  #'.'
        LDX  #9
        JSR  CHKTKN
        LDA  #0
        LDX  #19
        JSR  GETCHK
        JSR  CROUT
        LDA  #<ENDMSG
        LDX  #>ENDMSG
        LDY  #2
        JSR  PT
        LDA  PCODE+1
        STA  END_PCD+1
        JSR  PRBYTE
        LDA  PCODE
        STA  END_PCD
        JSR  PRBYTECR
        LDA  #<MSG4
        LDX  #>MSG4
        LDY  #3
        JSR  PT
        LDA  SYM_USE+1
        JSR  PRBYTE
        LDA  SYM_USE
        JSR  PRBYTECR
        LDA  #<ENDMG2
        LDX  #>ENDMG2
        JSR  PL
        LDX  SYNTAX
        BNE  END_CMP
        INX
        STX  VAL_CMP
END_CMP:
        JMP  ST1
;
CHK_VAL:
        LDA  VAL_CMP
        BNE  CHK_VAL9
        LDA  #<MSG6
        LDX  #>MSG6
        JSR  PL
        JMP  ST1
CHK_VAL9:
BELL1X:          ; no bell yet
        RTS
;
CHK_RUN:
	JSR  CHK_VAL
        JMP  INTERP

;
; START
;
MAIN_TBL:
         .byte 'C'
         .word   ST_CMP
         .byte 'R'
         .word   ST_RUN
         .byte 'S'
         .word   ST_SYN
         .byte 'E'
         .word   ST_EDI
         .byte 'Q'
         .word   ST_QUI
         .byte 'D'
         .word   ST_DEB
         .byte 'T'
         .word   ST_TRA
         .byte 'F'
         .word   ST_FIL
         .byte  $0
FIL_TBL:
         .byte 'E'
         .word   ST_EDI
         .byte 'Q'
         .word   ST1
         .byte 'A'
         .word   ST_APP
         .byte 'L'
         .word   ST_LOA
         .byte 'S'
         .word   ST_WRI
         .byte 'V'
         .word   ST_VFY
         .byte 'P'
         .word   ST_PRI
         .byte 'N'
         .word   ST_NOP
         .byte 'O'
         .word   ST_OBJ
         .byte 'C'
         .word   ST_CAT
         .byte 'D'
         .word   ST_DOS
         .byte  $0
;
;
;
;
; here for cold start - initialize all C64 routines
; do ram test, clear text file to null etc. etc.
;
START:
         SEI
         LDX  #0
         STX  VIC+$16    ; clear reset bit in VIC
         DEX
         TXS
         JSR  IOINIT
         NOP
         NOP
         NOP             ; instead of JSR RAMTAS
         JSR  RESTOR
         JSR  CINT
         JSR  INITIO
         CLI
         LDA  TS
         STA  REG
         LDA  TS+1
         STA  REG+1
         LDA  #0
         TAY
         STA  (REG),Y    ; NULL EDIT FILE
         STY  VAL_CMP
         TAX
         LDY  #$D0       ; use spare memory
         CLC
         JSR  MEMTOP     ; set top of memory
         LDA  CINV
         STA  INT_RTN
         LDA  CINV+1
         STA  INT_RTN+1  ; interrupt return address
         JMP  REST1
;
RESTART:
         SEI
         LDA  INT_RTN
         STA  CINV
         LDA  INT_RTN+1
         STA  CINV+1
         CLI
         CLD
         LDX  #$FF
         TXS             ; reset stack
         JSR  CLALL      ; close any files run left open
         JSR  CINT       ; reset video
         JSR  INITIO
;
REST1:
         JSR  PROFF
         LDA  #$C0
         JSR  SETMSG
         LDA  #0
         STA  RUNNING
         LDA  #6         ; BLUE
         STA  BORDER
         STA  BKGND      ; BACKGROUND TO BLUE
         LDA  #<RESTART
         STA  WARM_STR
         STA  CTRLC_RT
         LDA  #>RESTART
         STA  WARM_STR+1
         STA  CTRLC_RT+1
         JSR  HOME
         LDA  #<US
         LDX  #>US
         LDY  #8
         JSR  PT
ST1:	LDA  #<MSG1
        LDX  #>MSG1
        LDY  #43
        JSR  GETANS
        LDX  #<MAIN_TBL
        LDY  #>MAIN_TBL
;
         JSR  TKNJMP
ST1_JUMP: JMP  ST1
;
;
ZERO_SID:
         LDY  #24
         LDA  #0
ZERO_1:	STA  SID,Y
         DEY
         BPL  ZERO_1
         RTS
;
INITIO:
         JSR  IOINIT
         JSR  CLALL
         JSR  ZERO_SID
         LDA  #47
         STA  $0         ; data direction register
         LDA  #46
         STA  $1         ; disable Basic
         LDA  #0
         STA  $F8        ; de-allocate RS232 buffers
         STA  $FA
         STA  ST         ; clear ST flag
         STA  ENABRS     ; clear RS232 enables
         LDA  #4
         STA  HIBASE     ; normal video page
         RTS
;
ST_CMP:
         LDA  #0
         STA  SYNTAX
         JMP  COMPIL
ST_SYN:
         STA  SYNTAX
         JMP  COMPIL
ST_RUN:
         LDA  #0
         STA  DBGFLG
         STA  DCODE
         JMP  CHK_RUN
ST_EDI:
         JMP  EDITOR
ST_FIL:
         LDX  #$FF
         TXS             ; reset stack
         LDA  #<FIL_MSG
         LDX  #>FIL_MSG
         LDY  #85
         JSR  GETANS
         LDX  #<FIL_TBL
         LDY  #>FIL_TBL
         STA  TOKEN      ; in case we want to know
         JSR  TKNJMP
ST_FIL9:
         JMP  ST_FIL
;
QUIT_MSG: .byte  $D7,$CB

ST_QUI:
         LDA  #<QUIT_MSG
         LDX  #>QUIT_MSG
         LDY  #2
         JSR  GETANS
         CMP  #'Y'
         BNE  ST1_JUMP
         JMP  DOS_COLD   ; COLDSTART DOS
ST_DEB:
         STA  DBGFLG
         STA  DCODE
         JMP  CHK_RUN
ST_TRA:
         ORA  #$80
         STA  DBGFLG
         STA  DCODE
         JMP  CHK_RUN
ST_PRI:
         JSR  PRON
         JMP  ST_FIL
ST_NOP:
         JSR  PROFF
         JMP  ST_FIL

FILE_MSG: .byte "fILE NAME? "
FILE_MG2: .byte $DB
          .byte "c>ASSETTE OR",$DB
          .byte "d>ISK? "
FILE_MG3: .byte "cOMMAND? "

;
GET_FILE:
         LDA  #<FILE_MG2
         LDX  #>FILE_MG2
         LDY  #21
         JSR  GETANS
         CMP  #'D'
         BEQ  GET_FIL1
         CMP  #'C'
         BEQ  GET_FIL0
         JMP  ST_FIL9
GET_FIL1: LDA  DISK_CHN   ; serial bus disk drive
         BNE  GET_FIL8
GET_FIL0: LDA  #1         ; datasette
GET_FIL8: STA  REG2B
         LDA  #<FILE_MSG
         LDX  #>FILE_MSG
         LDY  #11
         JSR  PT
GET_FIL2:
         JSR  GETLN1
         STX  TKNLEN
         CPX  #0
         BMI  GET_FIL4
         BNE  GET_FIL3
         LDA  TOKEN      ; zero length ok on cassette load
         CMP  #'V'
         BEQ  GET_FIL9   ; verify
         CMP  #'A'
         BEQ  GET_FIL9   ; append
         CMP  #'L'
         BNE  GET_FIL4   ; not load
GET_FIL9: LDA  REG2B
         CMP  #1         ; cassette?
         BEQ  GET_FIL7   ; yes - hooray!
GET_FIL4: JMP  ST_FIL
GET_FIL3:          ; no check on alpha file name now
GET_FILA: LDY  #19
GET_FIL5: LDA  INBUF,Y
         STA  BPOINT,Y
         DEY
         BPL  GET_FIL5
GET_FIL7:
;
; if disk load/save etc. open error channel (15)
;
         LDX  REG2B
         CPX  DISK_CHN   ; disk?
         BNE  GET_FILB   ; nope
         LDA  #15
         TAY             ; error channel
         JSR  SETLFS
         LDA  #0         ; no command
         JSR  SETNAM
         JSR  OPEN       ; right - it's open
;
GET_FILB:
         LDA  #1         ; logical file number
         LDX  REG2B      ; 1 = cassette, 8 = disk
         LDY  #0         ; secondary address
         JSR  SETLFS
         LDA  TKNLEN
         CMP  #20
         BCC  GET_FIL6
         LDA  #20
GET_FIL6:
         LDX  #<BPOINT
         LDY  #>BPOINT   ; temporary buffer as INBUF is tape buffer
         JMP  SETNAM     ; setup file name
;
CATALOG: .byte "$"
DISK_MSG: .byte "dISK:"

;
ST_CAT:
;
; here for directory list
;
         LDA  #1
         LDX  DISK_CHN
         LDY  #0         ; relocated load
         STY  REGB
         JSR  SETLFS
         LDA  #1         ; $ length
         LDX  #<CATALOG
         LDY  #>CATALOG
         JSR  SETNAM
         LDA  #0         ; load
         LDX  #<$C000     ; use symbol table
         STX  TKNADR
         LDY  #>$C000    ; for directory
         STY  TKNADR+1
         JSR  LOAD
         BCS  ST_FILJ    ; error on load
         JSR  CROUT
         JSR  CROUT
         LDA  #<DISK_MSG
         LDX  #>DISK_MSG
         LDY  #5
         JSR  PT
         JMP  CAT_STRT   ; no sector count for first line
CAT_LOOP:
         LDY  #1
         LDA  (TKNADR),Y ; end?
         BNE  CAT_MORE   ; no
         INY
         LDA  (TKNADR),Y
         BEQ  CAT_END    ; finished
         DEY
CAT_MORE:
         INY
         INY             ; bypass line number link
         LDA  (TKNADR),Y ; no_ sectors
         STA  REG
         INY
         LDA  (TKNADR),Y ; no_ sectors
         STA  REG+1
         JSR  DSP_BIN    ; display sector count
         JSR  PUTSP
CAT_STRT:
         LDY  #5
CAT_CNT:
         LDA  (TKNADR),Y
         BEQ  CAT_CNTD   ; found end of this line
         INY
         BNE  CAT_CNT
CAT_CNTD:
         STY  TKNLEN     ; size of this entry
         TYA
         SEC
         SBC  #5         ; forget initial stuff
         TAY             ; read for PT
         LDA  TKNADR
         CLC
         ADC  #5
         PHA
         LDA  TKNADR+1
         ADC  #0
         TAX
         PLA
         JSR  PT         ; at last! - display the info
         JSR  CROUT
         LDA  TKNADR
         CLC
         ADC  TKNLEN
         STA  TKNADR
         BCC  CAT_LOOP
         INC  TKNADR+1
         BNE  CAT_LOOP
CAT_END:
ST_FILJ: JMP  ST_FIL
;
ST_VFY:
         JSR  GET_FILE
         LDX  TS
         LDY  TS+1
         LDA  #1
         BNE  ST_LOA1
;
DOS_ERR: .byte 13,$BD
         .byte ": "

;
FIN_DOS:
         PHP
         JSR  CROUT
         JSR  READST     ; check status (verify error etc_)
         AND  #$BF       ; ignore end-of-file
         BEQ  FIN_DOS2   ; ok
         PHA
         LDA  #<DOS_ERR
         LDX  #>DOS_ERR
         LDY  #4
         JSR  PT
         PLA
         JSR  PRBYTECR
FIN_DOS2:
         LDA  REG2B
         CMP  DISK_CHN
         BNE  FIN_DOS9
         PLP             ; back to initial carry flag
         JMP  ST_ERR     ; read error channel if disk
FIN_DOS9:
         PLP
         JMP  ST_FIL
;
ST_LOA:
         JSR  GET_FILE
         LDA  #0
         STA  VAL_CMP
         LDX  TS
         LDY  TS+1
ST_LOA1: JSR  LOAD
ST_LOA2: JMP  FIN_DOS
;
;
ST_OBJ:
         JSR  CHK_VAL
         JSR  GET_FILE
         LDA  ACT_PCDA
         STA  TEMP
         LDA  ACT_PCDA+1
         STA  TEMP+1
         LDX  END_PCD
         LDY  END_PCD+1
ST_OBJ1: LDA  #TEMP
         JSR  SAVE
ST_OBJ2: JMP  FIN_DOS
;
ST_WRI:
         JSR  GET_FILE
         JSR  FND_END
         LDA  TS
         STA  TEMP
         LDA  TS+1
         STA  TEMP+1
         LDX  P
         LDY  P+1
         JMP  ST_OBJ1
;
;
ST_APP:
         JSR  GET_FILE
         LDA  #0
         STA  VAL_CMP
         JSR  FND_END
         LDA  P
         SEC
         SBC  #1
         TAX
         LDA  P+1
         SBC  #0
         TAY
         LDA  #0
         BEQ  ST_LOA1
;
DOS_MSG: .byte "cODE: "
;
; DOS
;
ST_DOS:
         LDA  #<FILE_MG3  ; 'Command?'
         LDX  #>FILE_MG3
         LDY  #9
         JSR  PT
         JSR  GETLN1     ; get response
         CPX  #0
         BEQ  ST_DOS9    ; nosing
         STX  TKNLEN
         LDX  DISK_CHN   ; now open disk channel 15
         LDA  #15
         TAY             ; command channel
         JSR  SETLFS
         LDX  #<INBUF
         LDY  #>INBUF
         LDA  TKNLEN
         JSR  SETNAM     ; send command
         JSR  OPEN
         BCS  ST_DOS8
ST_ERR:
         LDX  #15
         JSR  CHKIN      ; read error channel
         BCS  ST_DOS8
         JSR  GETLN1     ; read it
         JSR  CLRCHN     ; back to keyboard
         LDA  #<DOS_MSG
         LDX  #>DOS_MSG
         LDY  #6
         JSR  PT
         LDA  #<INBUF
         LDX  #>INBUF
         JSR  PL         ; display the message
ST_DOS8: LDA  #15        ; close command channel
         JSR  CLOSE
ST_DOS9: JMP  ST_FIL     ; finito
;
;
PRON:
        LDA #4
        STA PFLAG
        LDX PR_CHAN    ; printer
        LDY #0         ; normal mode
        JSR SETLFS
        JSR OPEN       ; printer is unit 1
        BCC XXXRTS        ; open OK

;
PROFF:
        LDA  #0
        STA  PFLAG
        JMP  CLALL      ; close all files (incl. printer & screen )

;
UNPACK:
        PHA
        CLC
        ROR
        CLC
        ROR
        CLC
        ROR
        CLC
        ROR
        ORA  #$30
        STA  ASC_WRK,X
        INX
        PLA
        AND  #$0F
        ORA  #$30
        STA  ASC_WRK,X
        INX
XXXRTS: RTS

;
;
BIN_TBL:
        .byte $76,$85,$04,$01
        .byte $36,$55,$06,$00
        .byte $96,$40,$00,$00
        .byte $56,$02,$00,$00
        .byte $16,$00,$00,$00
        .byte $01,$00,$00,$00

;
DSP_BIN:
         LDA  REG
         LDX  REG+1
         LDY  REGB
         BPL  OUT_PLUS
         LDA  #'-'
         JSR  PC
         SEC
         LDA  #0
         SBC  REG
         PHA
         LDA  #0
         SBC  REG+1
         TAX
         LDA  #0
         SBC  REGB
         TAY
         PLA
OUT_PLUS:
         STA  BIN_WRK
         STX  BIN_WRK+1
         STY  BIN_WRK+2
         LDA  #$F0
         STA  REG2
         LDA  #0
         STA  VALUE
         STA  VALUE+1
         STA  TEMP
         STA  TEMP+1
         TAX
         LDY  #2
OUT4:
         LDA  BIN_WRK,Y
         AND  REG2
         STA  REG2+1
         BEQ  OUT2
         LDA  REG2
         BPL  OUT1
         LSR  REG2+1
         LSR  REG2+1
         LSR  REG2+1
         LSR  REG2+1
OUT1:
         SED
         LDA  TEMP
         CLC
         ADC  BIN_TBL,X
         STA  TEMP
         LDA  TEMP+1
         ADC  BIN_TBL+1,X
         STA  TEMP+1
         LDA  VALUE
         ADC  BIN_TBL+2,X
         STA  VALUE
         LDA  VALUE+1
         ADC  BIN_TBL+3,X
         STA  VALUE+1
         CLD
         DEC  REG2+1
         BNE  OUT1
OUT2:
         INX
         INX
         INX
         INX
         LDA  REG2
         EOR  #$FF
         STA  REG2
         BPL  OUT4
         DEY
         BPL  OUT4
OUT3:
         LDX  #0
         LDA  VALUE+1
         JSR  UNPACK
         LDA  VALUE
         JSR  UNPACK
         LDA  TEMP+1
         JSR  UNPACK
         LDA  TEMP
         JSR  UNPACK
         LDX  #7         ; ZERO SUPPRESS
         LDY  #0
OUT5:	LDA  ASC_WRK,Y
         CMP  #'0'
         BNE  OUT6
         INY
         DEX
         BNE  OUT5
OUT6:	LDA  ASC_WRK,Y
         STY  BIN_WRK
         STX  BIN_WRK+1
         JSR  PC
         LDY  BIN_WRK
         LDX  BIN_WRK+1
         INY
         DEX
         BPL  OUT6
DB9:	RTS

;
DM1:	.byte " sTACK: "
DM2:	.byte " bASE:  "
DM4:	.byte "rUNNING",$0D

;
DEBUG:
DB11:	JSR  DISPAD
         LDA  P
         STA  WORK
         LDA  P+1
         STA  WORK+1
         LDX  #4
         JSR  DIS4
         JSR  CROUT
         LDX  DBGFLG
         BMI  DB9        ; TRACE ONLY
         LDA  #<DM1
         LDX  #>DM1
         LDY  #8
         JSR  PT
         LDA  T+1
         JSR  PRBYTE
         LDA  T
         JSR  DISHX
         LDA  #'='
         JSR  PC
         LDA  T
         STA  WORK
         LDA  T+1
         STA  WORK+1
         LDX  #8
         JSR  DIS4
         JSR  CROUT
         LDA  #<DM2
         LDX  #>DM2
         LDY  #8
         JSR  PT
         LDA  BASE+1
         JSR  PRBYTE
         LDA  BASE
         JSR  DISHX
         LDA  #'='
         JSR  PC
         LDA  BASE
         SEC
         SBC  #6
         STA  WORK
         LDA  BASE+1
         SBC  #0
         STA  WORK+1
         LDX  #6
         JSR  DIS4
         JMP  CROUT
;
;
; INTERPRETER INITIALIZATION
;
INTERP:
         PHP
         PLA
         STA  CALL_P
         LDA  ACT_PCDA
         STA  P
         LDA  ACT_PCDA+1
         STA  P+1
         LDA  #<BREAK
         STA  ERR_RTN
         STA  CTRLC_RT
         LDA  #>BREAK
         STA  ERR_RTN+1
         STA  CTRLC_RT+1
         LDA  #<DM4
         LDX  #>DM4
         JSR  PL
         LDY  #12
         STY  RUNNING
         LDA  #<P_STACK
         STA  T
         STA  BASE
         LDA  #>P_STACK
         STA  T+1
         STA  BASE+1
         LDA  #0
         STA  DOS_FLG
         STA  COLL_REG
         STA  MASK
         LDY  #7
INTER_LP:
	STA  S_ACTIVE,Y
         STA  S_ANIMCT,Y
         DEY
         BPL  INTER_LP
;
; now process our sprite table on timer interrupts
;
         SEI
         LDA  #<TIMER_IN
         STA  CINV
         LDA  #>TIMER_IN
         STA  CINV+1
         CLI
         JMP  INTERJ
;
;
SPT_STAT:
         JSR  GET_SPT
         LDA  S_ACTIVE,X
         JMP  TRUE2
;
MOV_SPT:
         JSR  PULTOP
         STA  BPOINT+10
         STX  BPOINT+11  ; moves
         JSR  PULTOP
         STA  BPOINT+12
         STX  BPOINT+13  ; yinc
         JSR  PULTOP
         STA  BPOINT+14
         STX  BPOINT+15  ; xinc
         STY  BPOINT+16
         JSR  PULTOP
         STA  BPOINT+17  ; y pos
         JSR  PULTOP
         STA  BPOINT+18
         STX  BPOINT+19  ; x pos
         JSR  GET_SPT
         SEI
         LDA  BPOINT+10
         STA  S_COUNT,X
         LDA  BPOINT+11
         STA  S_COUNT+8,X
         LDA  BPOINT+12
         STA  S_YINC,X
         LDA  BPOINT+13
         STA  S_YINC+8,X
         LDA  BPOINT+14
         STA  S_XINC,X
         LDA  BPOINT+15
         STA  S_XINC+8,X
         LDA  BPOINT+16
         STA  S_XINC+16,X
         LDA  BPOINT+17
         STA  S_YPOS+8,X
         LDA  BPOINT+18
         STA  S_XPOS+8,X
         LDA  BPOINT+19
         STA  S_XPOS+16,X
         LDA  #0
         STA  S_YPOS,X
         STA  S_XPOS,X
         LDA  #1
         STA  S_ACTIVE,X
         JSR  POS_SPRT
         LDA  MASKS,X
         ORA  VIC+$15    ; activate it
         STA  VIC+$15
         CLI
         JMP  MAIN
;
ANM_SPT:
         LDA  #16
         STA  BPOINT     ; pointer count
ANM_1:
         JSR  PULTOP     ; get pointer
         LDY  BPOINT
         STA  BPOINT,Y
         DEC  BPOINT
         BNE  ANM_1      ; more
         LDA  #254
         JSR  CHK_TOP    ; frames per pointer
         TAY
         INY             ; back to supplied value
         STY  BPOINT+18  ; frame change count
         JSR  GET_SPT
         STA  BPOINT+19  ; sprite
         INX
         TXA             ; next one (so we can work backwards)
         ASL
         ASL
         ASL
         ASL             ; times 16
         TAY
         LDX  #16        ; pointer count
         SEI
ANM_3:
         LDA  BPOINT,X
         BEQ  ANM_2      ; not used
         INC  BPOINT     ; count used ones
ANM_2:
         DEY
         STA  S_POINTR,Y
         DEX
         BNE  ANM_3      ; more
         LDY  BPOINT+19  ; sprite
         LDA  BPOINT     ; used count
         STA  S_ANIMFM,Y
         LDA  BPOINT+18  ; frame count
         STA  S_ANIMCT,Y
         LDA  #0
         STA  S_ANIMPS,Y
         STA  S_ANIMCC,Y
         CLI
         STY  SPRITENO
         LDA  BPOINT+1   ; first pointer
         STA  FNC_VAL
         JMP  S_PNT2     ; now point to first
;
SPRT_X:
         JSR  GET_SPT
         ASL
         TAY
         LDA  VIC,Y      ; Low byte
         STA  REG
         LDA  VIC+$10
         AND  MASKS,X    ; high bit
         BEQ  SPRT_X1    ; off
         LDA  #1         ; mark on
SPRT_X1: STA  REG+1
         JMP  MAINP      ; push result
;
SPRT_Y:
         JSR  GET_SPT
         ASL
         TAY
         LDA  VIC+1,Y
         JMP  TRUE2      ; result
;
STOP_SPT:
         LDA  #0
         PHA
CHNG_SPT:
         JSR  GET_SPT
         PLA             ; get new status
         STA  S_ACTIVE,X ; mark inactive/active
         JMP  MAIN
;
STRT_SPT:
         LDA  #1
         PHA
         BNE  CHNG_SPT
;
TIMER_IN:          ; here for timer interrupts
;
; first look for collisions
;
         LDA  VIC+25     ; interrupt register
         AND  #$84       ; sprite-sprite collision?
         CMP  #$84
         BNE  TIMER2     ; nope - normal interrupt
         STA  VIC+25     ; re-enable
         LDA  VIC+30     ; collision register
         TAX             ; save it
         AND  MASK
         BEQ  FORGET     ; wrong sprite - forget interrupt
         STX  COLL_REG   ; save interrupt register
         LDX  #1
         STX  INT_TEMP
         DEX
TIM_COL1: LDA  COLL_REG
         AND  INT_TEMP   ; this sprite involved?
         BEQ  TIM_COL2   ; no
         LDA  #0
         STA  S_ACTIVE,X ; yes - stop it
TIM_COL2: INX             ; next sprite
         ASL  INT_TEMP   ; next mask
         BNE  TIM_COL1   ; more to go
         STA  MASK       ; stop further tests
         LDA  VIC+26
         AND  #$FB       ; stop interrupts
         STA  VIC+26
FORGET:	PLA
        TAY
        PLA
        TAX
        PLA
        RTI             ; off we go

;
TIMER2:          ; here for non-collision interrupts
         CLD
         LDX  #0
TIMER_CK: LDA  S_ACTIVE,X ; sprite active?
         BNE  TIMER_AC   ; yes
TIMER_NX: INX
         CPX  #8
         BNE  TIMER_CK   ; more to go
         JMP  (INT_RTN)
;
TIMER_AC:          ; here for active one
         CLC
         LDA  S_XINC,X
         ADC  S_XPOS,X
         STA  S_XPOS,X
         LDA  S_XINC+8,X
         ADC  S_XPOS+8,X
         STA  S_XPOS+8,X
         LDA  S_XINC+16,X
         ADC  S_XPOS+16,X
         STA  S_XPOS+16,X
         CLC
         LDA  S_YINC,X
         ADC  S_YPOS,X
         STA  S_YPOS,X
         LDA  S_YINC+8,X
         ADC  S_YPOS+8,X
         STA  S_YPOS+8,X
         SEC
         LDA  S_COUNT,X
         SBC  #1
         STA  S_COUNT,X
         LDA  S_COUNT+8,X
         SBC  #0
         STA  S_COUNT+8,X
         BPL  TIMER_ON
         LDA  #0         ; finished with this oe
         STA  S_ACTIVE,X ; turn it off
TIMER_ON:
         JSR  POS_SPRT
         LDA  S_ANIMCT,X
         BEQ  NO_ANIM
;
; now animate the pointers
;
         LDY  S_ANIMCC,X ; current frame count
         INY
         TYA
         CMP  S_ANIMCT,X ; reached limit?
         BCS  NEW_FRAM   ; yes
         STA  S_ANIMCC,X ; no - save it
         BCC  NO_ANIM    ; that's all
NEW_FRAM:
         LDA  #0
         STA  S_ANIMCC,X ; back to start
         LDY  S_ANIMPS,X ; which position next?
         INY
         TYA
         CMP  S_ANIMFM,X ; limit?
         BCC  ANIM_OK    ; no
         LDA  #0         ; YES
ANIM_OK:
         STA  S_ANIMPS,X ; save current position
         TXA             ; sprite
         ASL
         ASL
         ASL
         ASL             ; times 16
         ORA  S_ANIMPS,X ; plus frame number
         TAY
         LDA  S_POINTR,Y ; get pointer
         STA  INT_TEMP
;
; now point the sprite
;
         LDA  CIA2+2
         PHA
         AND  #$FC
         STA  CIA2+2
         LDA  CIA2
         AND  #3
         EOR  #$FF
         ASL
         ASL
         ASL
         ASL
         ASL
         ASL
         STA  INT_TMP2   ; bank
         PLA
         STA  CIA2+2
         LDA  REG
         PHA
         LDA  REG+1
         PHA
         LDA  VIC+$18
         AND  #$F0       ; video base
         LSR
         LSR
         CLC
         ADC  #3
         ADC  INT_TMP2   ; add bank
         STA  REG+1
         LDA  #$F8
         STA  REG
         TXA             ; sprite
         TAY
         LDA  INT_TEMP   ; pointer
         STA  (REG),Y
         PLA
         STA  REG+1
         PLA
         STA  REG
NO_ANIM: JMP  TIMER_NX
;
POS_SPRT:
         LDA  S_XPOS+16,X
         AND  #1
         BEQ  POS_1      ; high-order zero
         LDA  MASKS,X
POS_1:	STA  INT_TEMP
         LDA  XMASKS,X
         AND  VIC+$10
         ORA  INT_TEMP
         STA  VIC+$10
         TXA
         ASL
         TAY
         LDA  S_XPOS+8,X
         STA  VIC,Y
         LDA  S_YPOS+8,X
         STA  VIC+1,Y
         RTS
;
GET_SPT:
         LDA  #7
         JSR  CHK_TOP
         TAX
         RTS
;
LOA_SVE:          ; get ready for load/save
         JSR  PULTOP     ; load/verify flag
         STA  SCE_LIM
         STX  SCE_LIM+1
         JSR  PULTOP
         STA  TEMP       ; address to load/save
         STX  TEMP+1
         JSR  PULTOP     ; device number
         TAX             ; device
         LDA  #1         ; file 1
         LDY  #0
LOA_SVE1: JSR  SETLFS
         LDY  #0
         LDA  (P),Y      ; length of name
         PHA
         LDA  P          ; address of name
         CLC
         ADC  #1
         TAX
         LDA  P+1
         ADC  #0
         TAY
         PLA             ; size of name
         JSR  SETNAM
         CLC
         ADC  #1         ; bypass length
         ADC  P
         STA  P
         BCC  LOADIT1
         INC  P+1
LOADIT1:
         RTS
;
LOADIT:
         JSR  LOA_SVE
         LDA  SCE_LIM    ; load/verify flag
         LDX  TEMP
         LDY  TEMP+1     ; address
         JSR  LOAD
         STX  CALL_X
         STY  CALL_Y
LOADIT2: BCS  LOADIT3    ; error in accumulator
LOADIT4: JSR  READST     ; otherwise check READST
LOADIT3:
         STA  DOS_FLG
         JMP  MAIN       ; done
;
SAVEIT:
         JSR  LOA_SVE
         LDX  SCE_LIM
         LDY  SCE_LIM+1
         CPY  TEMP+1     ; end less than start?
         BCC  SAVE_ERR   ; yes - oops
         BNE  SAVE_OK    ; not equal - must be greater (OK)
         CPX  TEMP       ; high order same - is low order less than start?
         BCC  SAVE_ERR   ; yes - oops
         BEQ  SAVE_ERR   ; even same is no good
SAVE_OK:
         LDA  #TEMP
         JSR  SAVE
         JMP  LOADIT2
;
SAVE_ERR: JMP  CHK_ERR    ; start address >= end address
;
X_OPEN:          ; OPEN A FILE
         JSR  PULTOP     ; secondary address
         STA  TEMP
         JSR  PULTOP     ; device
         STA  TEMP+1
         JSR  PULTOP     ; unit
         LDX  TEMP+1     ; device
         LDY  TEMP       ; secondary address
         JSR  LOA_SVE1   ; now SETLFS and process file name
         JSR  OPEN       ; now open the file
         JMP  LOADIT2    ; and see the result
;
X_CLOSE:          ; CLOSE A FILE
         JSR  PULTOP     ; file number
         JSR  CLOSE
         JMP  LOADIT2    ; and see the result
;
X_PUT:
         JSR  PULTOP     ; file number
         TAX             ; zero (clear channel?)
         BEQ  X_PUT0
         JSR  CHKOUT
         JMP  LOADIT2    ; result
;
X_GET:
         JSR  PULTOP     ; file number
         TAX             ; zero (clear channel?)
         BEQ  X_GET0
         JSR  CHKIN
         JMP  LOADIT2    ; result
;
X_GET0:
X_PUT0:
         JSR  CLRCHN     ; clear channels
         JMP  MAIN
;
;
;
FREEZE_S:
         SEI
         STY  COLL_REG   ; no collision yet
         LDA  VIC+25
         AND  #$84       ; clear any pending interrupts
         STA  VIC+25
         LDA  VIC+30     ; clear any current collisions
         JSR  PULTOP     ; mask
         STA  MASK
         CMP  #0         ; none?
         BEQ  FREEZE1    ; yes - disable interrupts
         LDA  VIC+26
         ORA  #4         ; enable interrupts
FREEZE2: STA  VIC+26
         CLI
         JMP  MAIN
;
FREEZE1: LDA  VIC+26
         AND  #$FB
         JMP  FREEZE2
;
FR_STAT:
         LDA  COLL_REG
         JMP  TRUE2
;
;
         ;BRK

	.endscope

;***********************************************
; PASCAL COMPILER
; for Commodore 64
; PART 4
; Authors_ Nick Gammon & Sue Gobbett
;  HIMEM_$8500  SYM $9500
;***********************************************

	.scope

	V1	= P1
	INIT	= V1
	GETNEXT	= V1+3
	COMSTL	= V1+6
	ISITHX	= V1+9
	ISITAL	= V1+12
	ISITNM	= V1+15
	CHAR	= V1+18
	GEN2_B	= V1+21
	DISHX	= V1+24
	ERROR	= V1+27
	PRBYTE	= V1+51
	GTOKEN	= V1+54
	SPARE2	= V1+57
	FIXAD	= V1+60
	PSHWRK	= V1+63
	PULWRK	= V1+66
	PC	= V1+69
	PT	= V1+72
	PL	= V1+75
	TOKEN1	= V1+78
	GETANS	= V1+81
	PUTSP	= V1+84
	DISPAD	= V1+87
	CROUT	= V1+90
	GET_NUM	= V1+96
	GET_HEX	= V1+99
	PAUSE	= V1+105
	HOME	= V1+108
	RDKEY	= V1+111

;***********************************************
; PART 3 VECTORS
;***********************************************

	V3	= P3
	START	= V3
	RESTART	= V3+3
	DSP_BIN	= V3+6
	ST_CMP	= P3+9
	ST_SYN	= P3+12
	DEBUG	= P3+15
	BELL1_AX	= P3+24
	MOV_SPT	= P3+27
	SPT_STAT	= P3+30
	SPRT_X	= P3+33
	SPRT_Y	= P3+36
	STOP_SPT	= P3+39
	STRT_SPT	= P3+42
	ANM_SPT	= P3+45
	LOADIT	= P3+48
	SAVEIT	= P3+51
	FREEZE_S	= P3+54
	FR_STAT	= P3+57
	X_OPEN	= P3+60
	X_CLOSE	= P3+63
	X_PUT	= P3+66
	X_GET	= P3+69

;***********************************************
; PART 5 VECTORS
;***********************************************

	EDITOR	= P5
	GETLN	= P5+3
	GETLNZ	= P5+6
	GETLN1	= P5+9

;***********************************************
; PART 4 STARTS HERE
;***********************************************

        ;.org $A380 ; P4

;***********************************************
; PART 4 VECTORS
;***********************************************

        JMP  INTERJ
        JMP  DIS4
        JMP  BREAK
        JMP  CHK_ERR
        JMP  MAIN
        JMP  MAINP
        JMP  CHK_TOP
        JMP  TRUE2
        JMP  PULTOP
        JMP  S_PNT2

MASKS: 	.byte $01,$02,$04,$08,$10,$20,$40,$80
XMASKS: ; complement of above
        .byte $FE,$FD,$FB,$F7,$EF,$DF,$BF,$7F

;
DM5:	.byte $B6,$C7,$0D
DM6:	.byte "bREAK ...",$0D
DM7:	.byte $BD," OCCURRED AT",$B0,32

;
; DISPLAY (X) CHARACTERS FROM (WORK)
;
DIS4:	TXA
        PHA
        JSR  PUTSP
        PLA
        TAX
DIS5:	LDY  #0
        LDA  (WORK),Y
        INC  WORK
        BNE  DIS5_A
        INC  WORK+1
DIS5_A:
        TAY
        TXA
        PHA
        TYA
        JSR  DISHX
        PLA
        TAX
        DEX
        BNE  DIS5
        RTS

; INTERPRETER INITIALIZATION
;
INTERJ:
        LDA  #$7F
        STA  CIA2+13
        JMP  SOUND_CL   ; clear SID, go to MAIN

;
;
BELL1:
        PHA
        LDA  #0
        STA  RUNNING
        JSR  CROUT
        PLA
        RTS

;
RUNERR:	JSR  BELL1
        LDA  #<DM7
        LDX  #>DM7
        LDY  #15
        JSR  PT
        LDA  LASTP+1
        JSR  PRBYTE
        LDA  LASTP
        JSR  DISHX
FINISHD:
        LDA  #0
        STA  QUEUE      ; clear keyboard queue
        JSR  CROUT
        LDA  #<FIN_MSG
        LDX  #>FIN_MSG
        LDY  #30
        JSR  PT
        JSR  RDKEY      ; wait till message seen
        JMP  RESTART

;
FIN_MSG: .byte "RUN FINISHED - PRESS A KEY ..."

;
CHK_KBD:
         CMP  #$AA       ; COMMODORE/N
         BNE  CHK_NOTN
         JSR  GETIN
         LDA  #0
         STA  DBGFLG
         SEC
         RTS
CHK_NOTN:
	CMP  #$A3       ; COMMODORE/T
        BNE  CHK_NOTT
        JSR  GETIN
        LDA  #$80
        STA  DBGFLG
        STA  DCODE
        SEC
        RTS
CHK_NOTT:
	CMP  #$AC       ; COMMODORE/D
        BNE  CHK_NOTD
        JSR  GETIN
        LDA  #1
        STA  DBGFLG
        STA  DCODE
        SEC
        RTS
CHK_NOTD:
	CLC
        RTS

;
OUTCR:
        JSR  CROUT      ; OUTPUT C/R
        JMP  MAIN

;
LOWLIT:	STY  REG+1
        AND  #$7F
        STA  REG
MAINP:	JSR  PSHTOP
MAIN:	LDA  DBGFLG
        BEQ  MAIN_2
        JSR  DEBUG
MAIN_2:
        JSR  STOP
        BNE  MAIN_3
        JMP  BREAK      ; stop pressed
MAIN_3:	LDA  QUEUE      ; key in queue?
        BEQ  MAIN_OK    ; no
        LDA  KBD_BUF    ; what is it?
        JSR  CHK_KBD
MAIN_OK:
        LDA  P
        STA  LASTP
        LDA  P+1
        STA  LASTP+1
        LDY  #0
        STY  REGB
        LDA  (P),Y
        BMI  MAIN_5
        CMP  #$62
        BCS  INVINS
MAIN_5:
        INC  P
        BNE  MAIN_1
        INC  P+1
MAIN_1:
        TAX
        BMI  LOWLIT
        LDA  EXADTBH,X
        PHA
        LDA  EXADTBL,X
        PHA
        RTS

;
NOTIMP:
INVINS:
         LDA  #<DM5
         LDX  #>DM5
NOTIM1:
         JSR  BELL1
         JSR  PL
         JMP  RUNERR
;
BREAK:
         LDA  #<DM6
         LDX  #>DM6
         JMP  NOTIM1
;
EXADTBH:
         .hibytes LIT-1
         .hibytes DEF_SPRT-1
         .hibytes NEG-1
         .hibytes HPLOT-1
         .hibytes ADD-1
         .hibytes TOHPLOT-1
         .hibytes SUB-1
         .hibytes GETKEY-1
         .hibytes MUL-1
         .hibytes CLEAR-1
         .hibytes DIV-1
         .hibytes MOD-1
         .hibytes ADRNN-1
         .hibytes ADRNC-1
         .hibytes ADRAN-1
         .hibytes ADRAC-1
         .hibytes EQL-1
         .hibytes FINISHD-1
         .hibytes NEQ-1
         .hibytes CUR-1
         .hibytes LSS-1
         .hibytes FREEZE_S-1
         .hibytes GEQ-1
         .hibytes INH-1
         .hibytes GTR-1
         .hibytes LEQ-1
         .hibytes ORR-1
         .hibytes XXXAND-1
         .hibytes INP-1
         .hibytes INPC-1
         .hibytes OUT-1
         .hibytes OUTC-1
         .hibytes XXXEOR-1
         .hibytes OUH-1
         .hibytes SHL-1
         .hibytes OUS-1
         .hibytes SHR-1
         .hibytes INS-1
         .hibytes XXXINC-1
         .hibytes CLL-1
         .hibytes XXXDEC-1
         .hibytes RTN-1
         .hibytes MOV-1
         .hibytes CLA-1
         .hibytes LOD-1
         .hibytes LODC-1
         .hibytes XXXLDA-1
         .hibytes LDAC-1
         .hibytes LDI-1
         .hibytes LDIC-1
         .hibytes STO-1
         .hibytes STOC-1
         .hibytes XXXSTA-1
         .hibytes STAC-1
         .hibytes STI-1
         .hibytes STIC-1
         .hibytes ABSCLL-1
         .hibytes WAIT-1
         .hibytes XOR-1
         .hibytes INT-1
         .hibytes XXXJMP-1
         .hibytes JMZ-1
         .hibytes JM1-1
         .hibytes SPRITE-1
         .hibytes MVE_SPRT-1
         .hibytes VOICE-1
         .hibytes GRAPHICS-1
         .hibytes SOUND-1
         .hibytes SET_CLK-1
         .hibytes SCROLL-1
         .hibytes SP_COLL-1
         .hibytes BK_COLL-1
         .hibytes CURSORX-1
         .hibytes CURSORY-1
         .hibytes CLOCK-1
         .hibytes PADDLE-1
         .hibytes SPRT_X-1
         .hibytes JOY-1
         .hibytes SPRT_Y-1
         .hibytes OSC3-1
         .hibytes VOICE3-1
         .hibytes SCROLLX-1
         .hibytes SCROLLY-1
         .hibytes SPT_STAT-1
         .hibytes MOV_SPT-1
         .hibytes STOP_SPT-1
         .hibytes STRT_SPT-1
         .hibytes ANM_SPT-1
         .hibytes ABS-1
         .hibytes INVALID-1
         .hibytes LOADIT-1
         .hibytes SAVEIT-1
         .hibytes X_OPEN-1
         .hibytes FR_STAT-1
         .hibytes OUTCR-1
         .hibytes X_CLOSE-1
         .hibytes X_GET-1
         .hibytes X_PUT-1
EXADTBL:
         .lobytes LIT-1
         .lobytes DEF_SPRT-1
         .lobytes NEG-1
         .lobytes HPLOT-1
         .lobytes ADD-1
         .lobytes TOHPLOT-1
         .lobytes SUB-1
         .lobytes GETKEY-1
         .lobytes MUL-1
         .lobytes CLEAR-1
         .lobytes DIV-1
         .lobytes MOD-1
         .lobytes ADRNN-1
         .lobytes ADRNC-1
         .lobytes ADRAN-1
         .lobytes ADRAC-1
         .lobytes EQL-1
         .lobytes FINISHD-1
         .lobytes NEQ-1
         .lobytes CUR-1
         .lobytes LSS-1
         .lobytes FREEZE_S-1
         .lobytes GEQ-1
         .lobytes INH-1
         .lobytes GTR-1
         .lobytes LEQ-1
         .lobytes ORR-1
         .lobytes XXXAND-1
         .lobytes INP-1
         .lobytes INPC-1
         .lobytes OUT-1
         .lobytes OUTC-1
         .lobytes XXXEOR-1
         .lobytes OUH-1
         .lobytes SHL-1
         .lobytes OUS-1
         .lobytes SHR-1
         .lobytes INS-1
         .lobytes XXXINC-1
         .lobytes CLL-1
         .lobytes XXXDEC-1
         .lobytes RTN-1
         .lobytes MOV-1
         .lobytes CLA-1
         .lobytes LOD-1
         .lobytes LODC-1
         .lobytes XXXLDA-1
         .lobytes LDAC-1
         .lobytes LDI-1
         .lobytes LDIC-1
         .lobytes STO-1
         .lobytes STOC-1
         .lobytes XXXSTA-1
         .lobytes STAC-1
         .lobytes STI-1
         .lobytes STIC-1
         .lobytes ABSCLL-1
         .lobytes WAIT-1
         .lobytes XOR-1
         .lobytes INT-1
         .lobytes XXXJMP-1
         .lobytes JMZ-1
         .lobytes JM1-1
         .lobytes SPRITE-1
         .lobytes MVE_SPRT-1
         .lobytes VOICE-1
         .lobytes GRAPHICS-1
         .lobytes SOUND-1
         .lobytes SET_CLK-1
         .lobytes SCROLL-1
         .lobytes SP_COLL-1
         .lobytes BK_COLL-1
         .lobytes CURSORX-1
         .lobytes CURSORY-1
         .lobytes CLOCK-1
         .lobytes PADDLE-1
         .lobytes SPRT_X-1
         .lobytes JOY-1
         .lobytes SPRT_Y-1
         .lobytes OSC3-1
         .lobytes VOICE3-1
         .lobytes SCROLLX-1
         .lobytes SCROLLY-1
         .lobytes SPT_STAT-1
         .lobytes MOV_SPT-1
         .lobytes STOP_SPT-1
         .lobytes STRT_SPT-1
         .lobytes ANM_SPT-1
         .lobytes ABS-1
         .lobytes INVALID-1
         .lobytes LOADIT-1
         .lobytes SAVEIT-1
         .lobytes X_OPEN-1
         .lobytes FR_STAT-1
         .lobytes OUTCR-1
         .lobytes X_CLOSE-1
         .lobytes X_GET-1
         .lobytes X_PUT-1

GETADR:	LDY  #0
        LDA  (P),Y
        STA  COUNT1
        LDA  BASE+1
        LDX  BASE
GET2:
        STA  DATA+1
        STX  DATA
        TAY
        LDA  COUNT1
        BEQ  GET1
        SEC
        TXA
        SBC  #2
        STA  WORK
        TYA
        SBC  #0
        STA  WORK+1
        LDY  #0
        LDA  (WORK),Y
        INY
        TAX
        LDA  (WORK),Y
        DEC  COUNT1
        JMP  GET2
GET1:
         LDY  #1
         CLC
         LDA  (P),Y
         ADC  DATA
         STA  DATA
         INY
         LDA  (P),Y
         ADC  DATA+1
         STA  DATA+1
         LDA  P
         CLC
         ADC  #3
         STA  P
         BCC  GET1_A
         INC  P+1
GET1_A:
         RTS
PULTOP:
         LDY  #0
         LDA  (T),Y
         STA  REG
         INY
         LDA  (T),Y
         STA  REG+1
         INY
         LDA  (T),Y
         STA  REGB
         LDA  T
         CLC
         ADC  #3
         STA  T
         BCC  PUL_END
         INC  T+1
PUL_END:
         LDA  REG
         LDX  REG+1
         LDY  REGB
         RTS
PULBOTH: JSR  PULTOP     ; PULLS BOTH OF THEM
PULTOP2:
         LDY  #0
         LDA  (T),Y
         STA  REG2
         INY
         LDA  (T),Y
         STA  REG2+1
         INY
         LDA  (T),Y
         STA  REG2B
         LDA  T
         CLC
         ADC  #3
         STA  T
         BCC  PUL2_END
         INC  T+1
PUL2_END:
         LDA  REG2
         LDX  REG2+1
         LDY  REG2B
         RTS
PSHTOP:
         SEC
         LDA  T
         SBC  #3
         STA  T
         BCS  PSH1
         DEC  T+1
PSH1:
         LDY  #0
         LDA  REG
         STA  (T),Y
         INY
         LDA  REG+1
         STA  (T),Y
         INY
         LDA  REGB
         STA  (T),Y
         RTS
GETLIT:
         LDY  #0
         LDA  (P),Y
         STA  REG
         INY
         LDA  (P),Y
         STA  REG+1
         LDA  P
         CLC
         ADC  #2
         STA  P
         BCC  GET_END
         INC  P+1
GET_END: RTS
;
;
LIT:	JSR  GETLIT
         DEY
         LDA  (P),Y
         STA  REGB
         INC  P
         BNE  LIT1
         INC  P+1
LIT1:
         JMP  MAINP
;
NEG:	JSR  PULTOP
         SEC
         LDA  #0
         SBC  REG
         STA  REG
         LDA  #0
         SBC  REG+1
         STA  REG+1
         LDA  #0
         SBC  REGB
         STA  REGB
         JMP  MAINP
;
;
ADD:	JSR  PULBOTH
         CLC
         ADC  REG
         STA  REG
         TXA
         ADC  REG+1
         STA  REG+1
         TYA
         ADC  REGB
         STA  REGB
         JMP  MAINP
;
SUB:	JSR  SUBSTK
         JMP  MAINP
;
MUL:
         JSR  FNDSGN
         LDX  #24
MUL5:	ASL  RES
         ROL  RES+1
         ROL  RES+2
         ASL  DVDN
         ROL  DVDN+1
         ROL  DVDN+2
         BCC  MUL6
         CLC
         LDA  MCAND
         ADC  RES
         STA  RES
         LDA  MCAND+1
         ADC  RES+1
         STA  RES+1
         LDA  MCAND+2
         ADC  RES+2
         STA  RES+2
MUL6:	DEX
         BNE  MUL5
         JMP  FIXSGN
;
CHK_TOP:
         PHA             ; limit
         JSR  PULTOP
         DEC  REG        ; make zero relative
         LDA  REG+1
         ORA  REGB
         BNE  CHK_ERR
         PLA
         CMP  REG
         BCC  CHK_ERR    ; too big
         LDA  REG
         RTS             ; ok
;
CHK_ERR:
         LDA  #<CHK_MG
         LDX  #>CHK_MG
         JMP  NOTIM1
;
CHK_MG:	.byte $B6,$D9," IN FUNCTION CALL",$0D

;
MVE_SPRT:
         JSR  PULTOP
         STA  YPOS
         JSR  PULTOP
         STA  XPOSL
         TXA
         AND  #1
         STA  XPOSH
         LDA  #7
         JSR  CHK_TOP
         TAX             ; sprite number
         LDA  #0
         STA  S_ACTIVE,X ; non-active now
         LDA  XPOSH
         BEQ  MVE_1
         LDA  MASKS,X
MVE_1:	STA  TEMP
         LDA  XMASKS,X
         AND  VIC+$10
         ORA  TEMP       ; set high order x bit on/off
         STA  VIC+$10
         TXA
         ASL
         TAX
         LDA  XPOSL
         STA  VIC,X      ; low order 8 bits of position
         LDA  YPOS
         STA  VIC+1,X    ; Y co-ord
         JMP  MAIN
;
INVALID:
         LDA  DOS_FLG
         JMP  TRUE2
;
SP_COLL:
         LDA  VIC+30
         JMP  TRUE2
;
BK_COLL:
         LDA  VIC+31
         JMP  TRUE2
;
CURSORX:
         SEC
         JSR  PLOT
         INY
         TYA
         JMP  TRUE2
;
CURSORY:
         SEC
         JSR  PLOT
         INX
         TXA
         JMP  TRUE2
;
CLOCK:
         LDA  #3
         JSR  CHK_TOP
         TAX
         LDA  CIA2+8,X   ; 1 = 10ths, 2 = secs etc.
         STA  TEMP+1
         AND  #$7F
         PHA
         LSR
         LSR
         LSR
         LSR
         ASL
         STA  TEMP       ; times 2
         ASL
         ASL             ; times 8
         ADC  TEMP       ; times 10
         STA  TEMP
         PLA
         AND  #$0F
         CLC
         ADC  TEMP
         CPX  #3         ; asking for hours, oh newt?
         BNE  CLOCK_2    ; forget it then
         CMP  #12        ; 12 o'clock?
         BNE  CLOCK_3    ; no
         LDA  #0         ; make 12=0 so output looks right
CLOCK_3: LDY  TEMP+1     ; PM?
         BPL  CLOCK_2
         CLC
         ADC  #12
CLOCK_2:
         JMP  TRUE2      ; answer
;
PADL_RD:
         SEI
         LDA  CIA1+2     ; save ddr register
         PHA
         LDA  #$C0
         STA  CIA1+2     ; set porta for read
         TXA             ; which paddle to read
         STA  CIA1
         LDY  #$81       ; wait a while
PDLRD_2:
         NOP
         DEY
         BNE  PDLRD_2
         LDA  SID+25     ; x value
         STA  REG
         LDA  SID+26
         STA  REG+1
         JMP  JOY_RD1
;
WAIT:
         JSR  PULTOP     ; raster line
WAIT_DLY: LDA  VIC+$11    ; msb bit of raster
         AND  #$80
         CMP  REG+1
         BCC  WAIT_DLY   ; not yet
         LDA  VIC+$12    ; other bits
         CMP  REG
         BCC  WAIT_DLY   ; too low
         JMP  MAIN
;
PADDLE:
         LDA  #1
         JSR  CHK_TOP
         BNE  PADDLE2
;
PADDLE1:
         LDX  #$40
PADL2_A:
         JSR  PADL_RD
         JMP  MAINP
;
PADDLE2:
         LDX  #$80
         BNE  PADL2_A

;
JOY_RD:	SEI
        LDA CIA1+2,Y
        PHA
        LDA #0
        STA CIA1+2,Y		; DDR
        LDA CIA1,Y		; read joystick
        AND #$1F
        EOR #$1F		; reverse
        TAX
JOY_RD1:
	PLA
        STA CIA1+2,Y
        LDA #$7F		;was $00 in the V3.0 source -cjb
        STA CIA1
        TXA
        CLI
        RTS

;
JOY: 	LDA #1
        JSR CHK_TOP
        BNE JOY2

;
JOY1: 	LDY #1
JOY1_A: JSR JOY_RD
        JMP TRUE2

;
JOY2:
         LDY  #0
         BEQ  JOY1_A
;
OSC3:
         LDA  SID+27
         JMP  TRUE2
;
VOICE3:
         LDA  SID+28
         JMP  TRUE2
;
SCROLLX:
         LDA  VIC+$16
SCROLLX1: AND  #7
         JMP  TRUE2
;
SCROLLY:
         LDA  VIC+$11
         JMP  SCROLLX1
;
ADDIT:	TAX
         BEQ  ADDIT_9
         LDA  #0
         CLC
ADDIT_1: ADC  #1
         DEX
         BNE  ADDIT_1
ADDIT_9: RTS

;
SET_CLK:
         LDA  CIA2+14
         ORA  #$80
         STA  CIA2+14
         LDA  CIA2+15
         AND  #$7F
         STA  CIA2+15
         JSR  PULTOP
         PHA
         JSR  PULTOP
         PHA
         JSR  PULTOP
         PHA
         JSR  PULTOP
         LDX  #0
         CMP  #12
         BCC  CLK_AM
         LDX  #$80
         SEC
         SBC  #12        ; back to range 0 to 11
CLK_AM:	STX  CNTR
         SED
         JSR  ADDIT
         ORA  CNTR
         STA  CIA2+11
         PLA
         JSR  ADDIT
         STA  CIA2+10
         PLA
         JSR  ADDIT
         STA  CIA2+9
         PLA
         JSR  ADDIT
         STA  CIA2+8
         CLD
         JMP  MAIN
;
SCROLL:
         JSR  PULTOP
         AND  #7         ; y co-ord
         STA  FNC_VAL
         LDA  VIC+$11
         AND  #$F8
         ORA  FNC_VAL
         STA  VIC+$11
         JSR  PULTOP
         AND  #7         ; x co-ord
         STA  FNC_VAL
         LDA  VIC+$16
         AND  #$F8
         ORA  FNC_VAL
         STA  VIC+$16
         JMP  MAIN
;
GET_BNK:
         LDA  CIA2+2
         AND  #$FC
         STA  CIA2+2     ; set data direction to read
         LDA  CIA2
         AND  #3         ; video bank
         EOR  #$FF       ; make zero relative
         ASL
         ASL
         ASL
         ASL
         ASL
         ASL
         STA  TEMP+1
         RTS
;
CLEAR:
         JSR  PULTOP
         AND  #$0F
         STA  FNC_VAL    ; colour
         JSR  PULTOP
         ASL
         ASL
         ASL
         ASL
         ORA  FNC_VAL
         STA  FNC_VAL
         JSR  GET_BNK
         LDA  VIC+$18    ; character base
         AND  #$0E
         ASL
         ASL
         ORA  TEMP+1
         STA  TEMP+1
         CMP  #$04
         BCS  CLR_2
CLR_ERR: JMP  CHK_ERR    ; too low
CLR_2:	LDA  #0
         STA  TEMP
         LDA  VIC+17     ; mode
         AND  #$20
         BEQ  CLR_ERR    ; not bit map
         LDA  #<8000      ; hi-res (bit map)
         STA  REG
         LDA  #>8000
         STA  REG+1
         LDY  #0
         TYA
         JSR  CLR_LOOP   ; clear character memory
         JSR  GET_BNK
         LDA  VIC+$18    ; now do screen memory
         AND  #$F0
         LSR
         LSR
         ORA  TEMP+1
         STA  TEMP+1
         CMP  #$04
         BCS  CLR_3
         JMP  CHK_ERR    ; too low
CLR_3:
         LDA  #0
         TAY
         STA  TEMP
         LDA  #<1000
         STA  REG
         LDA  #>1000
         STA  REG+1
         LDA  FNC_VAL    ; colour
         JSR  CLR_LOOP   ; clear screen memory
         JMP  MAIN
;
CLR_LOOP:
	STA  (TEMP),Y
        INC  TEMP
        BNE  CLR_1
        INC  TEMP+1
CLR_1:
         DEC  REG
         LDX  REG
         CPX  #$FF
         BNE  CLR_LOOP
         DEC  REG+1
         BPL  CLR_LOOP
         RTS
;
GETKEY:
         JSR  GETIN
         JMP  TRUE2
;
;
SPRITE:
         JSR  PULTOP
         STA  FNC_VAL
         LDA  #6
         JSR  CHK_TOP    ; FUNCTION
         STA  FUNCTION
         LDA  #7
         JSR  CHK_TOP
         STA  SPRITENO
         LDA  FUNCTION
         BEQ  SPRT_COL   ; set colour
         CMP  #1
         BEQ  SPRT_PNT   ; point sprite
         ASL
         TAX             ; offset into table
         LDA  SPRT_TB-4,X
         STA  TEMP
         LDA  SPRT_TB-3,X
         STA  TEMP+1
         LDX  SPRITENO
         LDY  #0
         LDA  FNC_VAL
         AND  #1
         BEQ  SPRT_1
         LDA  MASKS,X
SPRT_1:	STA  TEMP1
         LDA  XMASKS,X
         AND  (TEMP),Y
         ORA  TEMP1      ; set bit
         JMP  GR_4
;
SPRT_COL:
         LDX  SPRITENO
         LDA  FNC_VAL
         AND  #15
         STA  VIC+$27,X  ; set colour
         JMP  MAIN
;
SPRT_PNT:
         LDA  #0
         LDY  SPRITENO
         STA  S_ANIMCT,Y
S_PNT2:
         JSR  GET_BNK
         LDA  VIC+$18
         AND  #$F0       ; video base
         LSR
         LSR
         CLC
         ADC  #3
         ADC  TEMP+1     ; add bank
         STA  TEMP+1
         LDA  #$F8
         STA  TEMP       ; sprite pointers
         LDY  SPRITENO
         LDA  FNC_VAL
         JMP  GR_4       ; point sprite pointer

;
SPRT_TB:
        .word VIC+$1C
        .word VIC+$1D
        .word VIC+$17
        .word VIC+$1B
        .word VIC+$15

;
W_BASE:
         JSR  GET_BNK
         LDA  FNC_VAL
         AND  #$0F
         ASL
         ASL             ; times 4
         ORA  TEMP+1     ; bank
         STA  HIBASE
         JMP  MAIN
;
GRAPHICS:
         JSR  PULTOP
         STA  FNC_VAL
         LDA  #17
         JSR  CHK_TOP
         STA  FUNCTION
         CMP  #17
         BEQ  W_BASE     ; write base
         CMP  #6
         BNE  GR_3
         LDA  CIA2+2
         ORA  #3         ; set data direction register
         STA  CIA2+2
         LDA  FNC_VAL
         EOR  #$FF
         STA  FNC_VAL
         LDA  FUNCTION
GR_3:	ASL
         ASL
         CLC
         ADC  FUNCTION   ; times 5
         TAX
         LDA  G_TABLE,X  ; address to patch
         STA  TEMP
         LDA  G_TABLE+1,X
         STA  TEMP+1
         LDA  G_TABLE+2,X ; mask
         AND  FNC_VAL
         LDY  G_TABLE+3,X ; bit to shift left
         BEQ  GR_1       ; none
GR_2:	ASL
        DEY
        BNE  GR_2
GR_1:	STA  FNC_VAL
        LDA  (TEMP),Y   ; old value of location
        AND  G_TABLE+4,X ; mask out required bits
        ORA  FNC_VAL    ; or in new bits
GR_4:	STA  (TEMP),Y   ; new value
        JMP  MAIN       ; finished!

;
G_TABLE:
;
; graphics controls
;
        .word VIC+$11    ; hires
        .byte $01,$05,$DF
        .word VIC+$16    ; multicolour
        .byte $01,$04,$EF
        .word VIC+$11    ; ext. bkgnd
        .byte $01,$06,$BF
        .word VIC+$16    ; 40 cols
        .byte $01,$03,$F7
        .word VIC+$11    ; 25 lines
        .byte $01,$03,$F7
        .word VIC+$11    ; blank screen
        .byte $01,$04,$EF
        .word CIA2       ; bank select
        .byte $03,$00,$FC
        .word VIC+$18    ; char gen base
        .byte $07,$01,$F1
        .word VIC+$18    ; video base
        .byte $0F,$04,$0F
        .word $286       ; cursor colour
        .byte $0F,$00,$F0
        .word VIC+$20    ; border colour
        .byte $0F,$00,$F0
        .word VIC+$21    ; other colours
        .byte $0F,$00,$F0
        .word VIC+$22
        .byte $0F,$00,$F0
        .word VIC+$23
        .byte $0F,$00,$F0
        .word VIC+$24
        .byte $0F,$00,$F0
        .word VIC+$25
        .byte $0F,$00,$F0
        .word VIC+$26
        .byte $0F,$00,$F0
;
; voice controls
;
        .word SID+5      ; attack
        .byte $0F,$04,$0F
        .word SID+5      ; decay
        .byte $0F,$00,$F0
        .word SID+6      ; sustain
        .byte $0F,$04,$0F
        .word SID+6      ; release
        .byte $0F,$00,$F0
        .word SID+4      ; play
        .byte $01,$00,$FE
        .word SID+4      ; sync
        .byte $01,$01,$FD
        .word SID+4      ; ring mod
        .byte $01,$02,$FB
        .word SID+4      ; triangle
        .byte $01,$04,$EF
        .word SID+4      ; sawtooth
        .byte $01,$05,$DF
        .word SID+4      ; pulse
        .byte $01,$06,$BF
        .word SID+4      ; noise
        .byte $01,$07,$7F
        .word SID+4      ; test
        .byte $01,$03,$F7
;
; sound controls
;
        .word SID+24     ; volume
        .byte $0F,$00,$F0
        .word SID+23     ; resonance
        .byte $0F,$04,$0F
        .word SID+24     ; low pass
        .byte $01,$04,$EF
        .word SID+24     ; band pass
        .byte $01,$05,$DF
        .word SID+24     ; high pass
        .byte $01,$06,$BF
        .word SID+24     ; cutoff voice3
        .byte $01,$07,$7F
;
; end of table
;

;
DEF_SPRT:
         LDA  #240       ; will become 60
         STA  TEMP
         JSR  GET_BNK
         LDY  #63        ; get pointer off stack first
         LDA  (T),Y
         LSR
         ROR  TEMP
         LSR
         ROR  TEMP
         CLC
         ADC  TEMP+1     ; add in bank
         STA  TEMP+1
         CMP  #$04       ; too low?
         BCS  DEF_2      ; no
         JMP  CHK_ERR
DEF_2:	LDA  #21
DEF_1:	PHA             ; save counter
         JSR  PULTOP     ; get row
         LDY  #2         ; do it in reverse order
         LDA  REG
         STA  (TEMP),Y
         DEY
         LDA  REG+1
         STA  (TEMP),Y
         DEY
         LDA  REGB
         STA  (TEMP),Y
         DEC  TEMP
         DEC  TEMP
         DEC  TEMP       ; (will not cross page boundary)
         PLA
         TAX             ; counter
         DEX
         TXA
         BNE  DEF_1      ; more to go
         JSR  PULTOP     ; discard pointer (read earlier)
         JMP  MAIN
;
VOICE:
         JSR  PULTOP
         STA  FNC_VAL
         STX  FNC_VAL+1
         LDA  #14
         JSR  CHK_TOP
         STA  FUNCTION
         LDA  #2
         JSR  CHK_TOP
         STA  VOICENO
         STA  TEMP1      ; save for filter
         ASL
         ASL
         ASL             ; times 8
         SEC
         SBC  VOICENO    ; times 7
         STA  VOICENO
         LDA  FUNCTION
         BEQ  FREQ
         CMP  #1
         BEQ  WIDTH
         CMP  #2
         BEQ  FILTER
         CLC
         ADC  #14        ; bypass 17 graphics entries ( minus 3 not in table )
VC_3:	STA  FUNCTION
         ASL
         ASL
         CLC
         ADC  FUNCTION   ; times 5
         TAX
         LDA  G_TABLE,X
         CLC
         ADC  VOICENO    ; low-order address
         STA  TEMP
         LDA  G_TABLE+1,X
         STA  TEMP+1
         LDA  G_TABLE+2,X ; mask
         AND  FNC_VAL
         LDY  G_TABLE+3,X ; bits to shift
         BEQ  VC_1
VC_2:	ASL
         DEY
         BNE  VC_2
VC_1:	STA  FNC_VAL
         LDY  TEMP       ; offset into SID image
         LDA  SID_IMG,Y  ; get previous value
         AND  G_TABLE+4,X ; mask out new bits
         ORA  FNC_VAL    ; new value
         STA  SID_IMG,Y  ; new value
         LDY  #0
         JMP  GR_4       ; and do SID itself
;
FREQ:
         LDX  VOICENO
         LDA  FNC_VAL
         STA  SID,X
         LDA  FNC_VAL+1
         STA  SID+1,X
         JMP  MAIN
;
WIDTH:
         LDX  VOICENO
         LDA  FNC_VAL
         STA  SID+2,X
         LDA  FNC_VAL+1
         AND  #$F
         STA  SID+3,X
         JMP  MAIN
;
FILTER:
         LDX  TEMP1      ; un-multiplied voice
         LDA  FNC_VAL
         AND  #1
         BEQ  FILT_1
         LDA  MASKS,X
FILT_1:	STA  TEMP
         LDA  XMASKS,X
         AND  SID_IMG+23
         ORA  TEMP
         STA  SID+23
         STA  SID_IMG+23
         JMP  MAIN
;
SOUND:
         STY  VOICENO    ; not voice relative
         JSR  PULTOP
         STA  FNC_VAL
         STX  FNC_VAL+1
         STY  FNC_VAL+2
         LDA  #8
         JSR  CHK_TOP
         BEQ  SOUND_CL
         CMP  #1
         BEQ  SOUND_F
         CMP  #2
         BEQ  DELAY
         CLC
         ADC  #26        ; bypass 17 graphics + 12 voice - 3 not in table
         JMP  VC_3       ; handle with table
;
SOUND_CL: LDY  #24
         LDA  #0
SOUND_C1: STA  SID,Y
         STA  SID_IMG,Y
         DEY
         BPL  SOUND_C1
         JMP  MAIN
;
SOUND_F: LDA  FNC_VAL
         AND  #7
         STA  SID+21
         LDA  FNC_VAL
         LSR  FNC_VAL+1
         ROR
         LSR  FNC_VAL+1
         ROR
         LSR  FNC_VAL+1
         ROR
         STA  SID+22
         JMP  MAIN
;
DELAY:
         LDA  CIA2+14
         AND  #$C0
         STA  CIA2+14
         LDA  #0
         STA  CIA2+15
         LDA  FNC_VAL
         STA  CIA2+6
         LDA  FNC_VAL+1
         STA  CIA2+7
         LDA  #$66       ; calibrated to give 100'ths of a second
         STA  CIA2+4
         LDA  #$26
         STA  CIA2+5
         LDA  #$59       ; one shot/ count TA
         STA  CIA2+15    ; start TB
         LDA  CIA2+14
         ORA  #$11
         STA  CIA2+14    ; start TA
DEL_WAIT: LDA  CIA2+15    ; finished?
         AND  #1
         BNE  DEL_WAIT   ; nope
         JMP  MAIN
;
;
CUR:	LDA  #40
        JSR  CHK_TOP
CUR1: 	PHA
        LDA  #25
        JSR  CHK_TOP
CUR2: 	TAX
        PLA
        TAY
        CLC
        JSR  PLOT       ; SET CURSOR POSITION
        JMP  MAIN

;
MOD:	JSR  FNDSGN
        JSR  DIVIDE
        LDA  REMAIN
        STA  RES
        LDA  REMAIN+1
        STA  RES+1
        LDA  REMAIN+2
        STA  RES+2
        JMP  DIV14

;
DIVBY0:	.byte "dIVIDE BY",$BE,$0D

;
DIV:	JSR  FNDSGN
        JSR  DIVIDE
DIV14:	JMP  FIXSGN

;
DIVIDE:	LDA  DIVISOR
        ORA  DIVISOR+1
        ORA  DIVISOR+2
        BNE  DIV1
        LDA  #<DIVBY0
        LDX  #>DIVBY0
        JMP  NOTIM1

;
DIV1:	JSR  ZERRES     ; zero result
        STA  REMAIN
        STA  REMAIN+1
        STA  REMAIN+2
        LDA  #24
L_5:	STA  CNTR
L_10:
        ASL  DVDN
        ROL  DVDN+1
        ROL  DVDN+2
        ROL  REMAIN
        ROL  REMAIN+1
        ROL  REMAIN+2
        SEC
        LDA  REMAIN
        SBC  DIVISOR
        TAX
        LDA  REMAIN+1
        SBC  DIVISOR+1
        TAY
        LDA  REMAIN+2
        SBC  DIVISOR+2
        BMI  L_20
        STA  REMAIN+2
        TYA
        STA  REMAIN+1
        TXA
        STA  REMAIN
        SEC
        BCS  L_30
L_20:
         CLC
L_30:
        ROL  RES
        ROL  RES+1
        ROL  RES+2
        DEC  CNTR
        BNE  L_10
        RTS

;
ABS:	JSR  PULTOP
        JSR  ABSREG
        JMP  INP3

;
ZERRES:	LDA  #0
        STA  RES
        STA  RES+1
        STA  RES+2
        RTS

;
ABSREG:	LDA  REGB
        BPL  ABS1
        SEC
        LDA  #0
        SBC  REG
        TAX
        LDA  #0
        SBC  REG+1
        TAY
        LDA  #0
        SBC  REGB
        JMP  ABS2
ABS1:	LDX  REG
        LDY  REG+1
        LDA  REGB
ABS2:	RTS

;
FNDSGN:	JSR  ZERRES     ; zero result
        JSR  PULTOP
        JSR  PULTOP2
        LDA  REGB
        AND  #$80
        STA  RMNDR
        LDA  REG2B
        AND  #$80
        EOR  RMNDR
        STA  RMNDR
        JSR  ABSREG
        STA  DIVISOR+2
        STY  DIVISOR+1
        STX  DIVISOR
        LDA  REG2B
        BPL  MUL3
        SEC
        LDA  #0
        SBC  REG2
        TAX
        LDA  #0
        SBC  REG2+1
        TAY
        LDA  #0
        SBC  REG2B
        JMP  MUL4
MUL3:	LDX  REG2
        LDY  REG2+1
        LDA  REG2B
MUL4:	STX  DVDN
        STY  DVDN+1
        STA  DVDN+2
        RTS

;
FIXSGN:	LDA  RMNDR
         BPL  MUL7
         SEC
         LDA  #0
         SBC  RES
         TAX
         LDA  #0
         SBC  RES+1
         TAY
         LDA  #0
         SBC  RES+2
         JMP  MUL8
MUL7:	LDX  RES
         LDY  RES+1
         LDA  RES+2
MUL8:	JMP  INP3

;
EQL:	JSR  PULBOTH
         CMP  REG
         BNE  FALSE
         TXA
         CMP  REG+1
         BNE  FALSE
         TYA
         CMP  REGB
         BNE  FALSE
;
TRUE:	LDA  #1
TRUE2:	STA  REG
         LDA  #0
         STA  REG+1
TRUE1:	STA  REGB
         JMP  MAINP
;
FALSE:	LDA  #0
         STA  REG
         STA  REG+1
         BEQ  TRUE1
;
;
SUBSTK:	JSR  PULBOTH
         SEC
         SBC  REG
         STA  REG
         TAY
         TXA
         SBC  REG+1
         STA  REG+1
         TAX
         LDA  REG2B
         SBC  REGB
         STA  REGB
         RTS
;
NEQ:	JSR  SUBSTK
         BNE  TRUE
         TYA
         BNE  TRUE
         TXA
         BNE  TRUE
         BEQ  FALSE
;
LSS:	JSR  SUBSTK
         BMI  TRUE
         BPL  FALSE
;
GTR:	JSR  SUBSTK
         BMI  FALSE
         BNE  TRUE
         TYA
         BNE  TRUE
         TXA
         BNE  TRUE
         BEQ  FALSE
;
GEQ:	JSR  SUBSTK
         BMI  FALSE
         BPL  TRUE
;
LEQ:	JSR  SUBSTK
         BMI  TRUE
         BNE  FALSE
         TYA
         BNE  FALSE
         TXA
         BNE  FALSE
         BEQ  TRUE
;
XOR:	JSR  PULBOTH
         EOR  REG
         STA  REG
         TXA
         EOR  REG+1
         STA  REG+1
         TYA
         EOR  REGB
         JMP  TRUE1
;
ORR:	JSR  PULBOTH
         ORA  REG
         STA  REG
         TXA
         ORA  REG+1
         STA  REG+1
         TYA
         ORA  REGB
         JMP  TRUE1
;
XXXAND:	JSR  PULBOTH
         AND  REG
         STA  REG
         TXA
         AND  REG+1
         STA  REG+1
         TYA
         AND  REGB
         JMP  TRUE1
;
XXXEOR:	JSR  PULTOP
         LDA  REG
         BNE  EOR1
         LDA  REG+1
         BNE  EOR1
         LDA  REGB
         BNE  EOR1
         JMP  TRUE
EOR1:	JMP  FALSE

;
SHL:	JSR  PULTOP2
        AND  #$1F
        PHA
        JSR  PULTOP
        PLA
        STA  REG2
        BEQ  INC1
SHL1:	ASL  REG
        ROL  REG+1
        ROL  REGB
        DEC  REG2
        BNE  SHL1
        BEQ  INC1
;
SHR:	JSR  PULTOP2
         AND  #$1F
         PHA
         JSR  PULTOP
         PLA
         STA  REG2
         BEQ  INC1
SHR1:	LSR  REGB
         ROR  REG+1
         ROR  REG
         DEC  REG2
         BNE  SHR1
INC1:	JMP  MAINP
;
;
XXXINC:	CLC
         LDA  (T),Y
         ADC  #1
         STA  (T),Y
         INY
         LDA  (T),Y
         ADC  #0
         STA  (T),Y
         INY
         LDA  (T),Y
         ADC  #0
INC2:	STA  (T),Y
         JMP  MAIN
;
XXXDEC:	SEC
         LDA  (T),Y
         SBC  #1
         STA  (T),Y
         INY
         LDA  (T),Y
         SBC  #0
         STA  (T),Y
         INY
         LDA  (T),Y
         SBC  #0
         JMP  INC2
;
MOV:	LDA  (T),Y
         PHA
         INY
         LDA  (T),Y
         PHA
         INY
         LDA  (T),Y
         PHA
         LDA  T
         SEC
         SBC  #3
         STA  T
         BCS  MOV1
         DEC  T+1
MOV1:	PLA
         STA  (T),Y
         DEY
         PLA
         STA  (T),Y
         DEY
         PLA
         STA  (T),Y
         JMP  MAIN
;
LODC:	JSR  GETADR
LOD3:	LDY  #2
LOD3_A:	LDA  #0
         STA  REG+1
         STA  REGB
         LDA  (DATA),Y
         STA  REG
         JMP  MAINP
;
LOD:	JSR  GETADR
LOD2:	LDY  #0
         LDA  (DATA),Y
         STA  REG
         INY
         LDA  (DATA),Y
         STA  REG+1
         INY
         LDA  (DATA),Y
         JMP  TRUE1
;
LDAC:	JSR  PULTOP
        STA  DATA
        STX  DATA+1
        LDY  #0
        BEQ  LOD3_A
;
XXXLDA:	JSR  PULTOP
         STA  DATA
         STX  DATA+1
         JMP  LOD2
;
GETIDC:
         JSR  PULTOP2
         JSR  GETADR
         JMP  GETID2
;
GETIDX:
         JSR  PULTOP2
         ASL  REG2
         ROL  REG2+1
         CLC
         ADC  REG2
         STA  REG2
         TXA
         ADC  REG2+1
         STA  REG2+1     ; TIMES 3
         JSR  GETADR
;
GETID2:	LDA  DATA
         SEC
         SBC  REG2
         STA  DATA
         LDA  DATA+1
         SBC  REG2+1
         STA  DATA+1
         RTS
;
LDIC:	JSR  GETIDC
         JMP  LOD3
;
LDI:	JSR  GETIDX
         JMP  LOD2
;
STOC:	JSR  GETADR
         JSR  PULTOP
         LDY  #2
STO5:	STA  (DATA),Y
         JMP  MAIN
;
STO:	JSR  GETADR
         JSR  PULTOP
STO2:	LDY  #0
         STA  (DATA),Y
         INY
         TXA
         STA  (DATA),Y
         LDA  REGB
         INY
         BNE  STO5
;
XXXSTA:	JSR  PULBOTH
        LDY  #0
        LDA  REG
        STA  (REG2),Y
        INY
        LDA  REG+1
        STA  (REG2),Y
        INY
        LDA  REGB
STA5:	STA  (REG2),Y
        JMP  MAIN

;
STAC:	JSR  PULTOP
        JSR  PULTOP2
        LDA  REG
        LDY  #0
        BEQ  STA5

;
STIC:	JSR  PULTOP
         STA  TEMP
         JSR  GETIDC
         LDA  TEMP
         LDY  #2
         BNE  STO5
;
STI:	JSR  PULTOP
         STA  TEMP
         STX  TEMP+1
         TYA
         PHA
         JSR  GETIDX
         LDY  #0
         LDA  TEMP
         STA  (DATA),Y
         LDA  TEMP+1
         INY
         STA  (DATA),Y
         PLA
         INY
         BNE  STO5
;
RTN:	LDA  BASE
         SEC
         SBC  #6
         STA  WORK
         LDA  BASE+1
         SBC  #0
         STA  WORK+1
         LDY  #0
         LDA  (WORK),Y
         STA  P
         INY
         LDA  (WORK),Y
         STA  P+1
         LDA  BASE+1
         STA  T+1
         LDA  BASE
         STA  T
         SEC
         SBC  #4
         STA  WORK
         LDA  BASE+1
         SBC  #0
         STA  WORK+1
         LDY  #0
         LDA  (WORK),Y
         STA  BASE
         INY
         LDA  (WORK),Y
         STA  BASE+1
         JMP  MAIN
;
;
;
INP:
         STY  SIGN
         STY  DOS_FLG
         DEY
         STY  RUNNING
         LDY  #8
         JSR  GETLN1
         LDA  #<INBUF
         STA  NXTCHR
         LDA  #>INBUF
         STA  NXTCHR+1
         LDA  INBUF
         JSR  CHK_KBD
         BCS  INP
         CMP  #'-'
         BNE  INP1
         STA  SIGN
         INC  NXTCHR
         LDA  INBUF+1
INP1:
         JSR  ISITNM
         BCS  BAD_INP
INP_OK:
         JSR  GET_NUM
INP4:	BCS  BAD_INP
         JSR  GETNEXT    ; followed by c/r?
         AND  #$7F
         CMP  #$0D
         BNE  BAD_INP    ; no
         LDX  VALUE
         LDY  VALUE+1
         LDA  VALUE+2
INP3:	STY  REG+1
         STX  REG
         LDX  #12
         STX  RUNNING
         JMP  TRUE1
;
BAD_INP: LDA  #1
        STA  DOS_FLG
        LDA  #0
        TAX
        TAY
        BEQ  INP3

;
OUT:	JSR  PULTOP
        JSR  DSP_BIN
        JMP  MAIN
;
OUH:	JSR  PULTOP
        LDA  REGB
        JSR  PRBYTE
        LDA  REG+1
        JSR  PRBYTE
        LDA  REG
        JSR  PRBYTE
        JMP  MAIN

;
OUS: 	LDA  P
        CLC
        ADC  #1
        STA  WORK
        LDA  P+1
        ADC  #0
        STA  WORK+1
        LDA  (P),Y
        STA  COUNT1     ; NO. OF CHARS
        CLC
        ADC  #1
        ADC  P
        STA  P
        BCC  OUS1
        INC  P+1
OUS1:	LDA  WORK
        LDX  WORK+1
        LDY  COUNT1
        JSR  PT
        JMP  MAIN

;
INH:
         STY  SIGN
         STY  DOS_FLG
         DEY
         STY  RUNNING
         LDY  #6
         JSR  GETLN1
         LDA  #>(INBUF-1)
         STA  NXTCHR+1
         LDA  #<(INBUF-1)
         STA  NXTCHR
         LDA  INBUF
         JSR  CHK_KBD
         BCS  INH
         JSR  ISITHX
         BCC  INH_OK
BAD_INP2: JMP  BAD_INP
INH_OK:
         JSR  GET_HEX
         JMP  INP4
;
ABSCLL:
         STY  CALL
         STY  CALL+1
         JMP  CLL_A
;
CLL:
         LDA  LASTP
         STA  CALL
         LDA  LASTP+1
         STA  CALL+1
CLL_A:
         LDA  (P),Y
         STA  COUNT1
         INY
         CLC
         LDA  (P),Y
         ADC  CALL
         STA  CALL
         INY
         LDA  (P),Y
         ADC  CALL+1
         STA  CALL+1
         LDA  P
         CLC
         ADC  #3
         STA  P
         BCC  CLL4
         INC  P+1
CLL4:
         LDA  BASE+1
         LDX  BASE
CLL2:
         STA  DATA+1
         STX  DATA
         TAY
         LDA  COUNT1
         BEQ  CLL3
         SEC
         TXA
         SBC  #2
         STA  WORK
         TYA
         SBC  #0
         STA  WORK+1
         LDY  #0
         LDA  (WORK),Y
         INY
         TAX
         LDA  (WORK),Y
         DEC  COUNT1
         JMP  CLL2
CLL3:
         LDA  T
         STA  TEMP
         LDA  T+1
         STA  TEMP+1
         LDA  DATA
         STA  REG+1
         LDA  DATA+1
         STA  REGB
         LDA  BASE+1
         STA  REG
         JSR  PSHTOP
         LDA  BASE
         STA  REGB
         LDA  TEMP
         STA  BASE
         LDA  TEMP+1
         STA  BASE+1
         LDA  P
         STA  REG
         LDA  P+1
         STA  REG+1
         JSR  PSHTOP
         LDA  CALL
         STA  P
         LDA  CALL+1
         STA  P+1
         CLC
         LDA  T
         ADC  #6
         STA  T
         BCC  CLL5
         INC  T+1
CLL5:
         JMP  MAIN
;
CLA:	JSR  PULTOP
        LDA  CALL_P
        PHA
        LDA  CALL_A
        LDX  CALL_X
        LDY  CALL_Y
        PLP
        JSR  CLL_JMP
        PHP
        STA  CALL_A
        STX  CALL_X
        STY  CALL_Y
        PLA
        STA  CALL_P
        JMP  MAIN
CLL_JMP: JMP  (REG)

;
INT:	JSR  GETLIT
         SEC
         LDA  T
         SBC  REG
         STA  T
         LDA  T+1
         SBC  REG+1
         STA  T+1
         CMP  #$C0
         BCC  INT_ERR
         JMP  MAIN
;
INT_ERR:
         LDA  #<INT_ERRM
         LDX  #>INT_ERRM
         JMP  NOTIM1

;
INT_ERRM: .byte $C6,$B1,$0D	; stack full

;
XXXJMP:	JSR  GETLIT
        CLC
        LDA  REG
        ADC  LASTP
        STA  P
        LDA  REG+1
        ADC  LASTP+1
        STA  P+1
        JMP  MAIN
;
JMZ:	JSR PULTOP
        LDA REG
        ORA REG+1
        BNE NOJUMP
        BEQ XXXJMP

;
NOJUMP:	JSR  GETLIT
        JMP  MAIN

;
JM1:	JSR PULTOP
        ORA REG+1
        BNE XXXJMP
        BEQ NOJUMP

;
INPC:	JSR  RDKEY
        JSR  CHK_KBD
        BCS  INPC
INPC1:  STA  REG
        LDA  #0
        STA  REG+1
        JMP  MAINP

;
OUTC:	JSR  PULTOP
        LDA  REG
        JSR  PC
        JMP  MAIN

;
INS:
         LDA  (P),Y
         STA  TEMP
         INC  P
         BNE  INS3
         INC  P+1
INS3:
         LDY  TEMP
         JSR  GETLN1
         LDA  INBUF
         JSR  CHK_KBD
         BCS  INS3
         TXA
         CLC
         ADC  #1
         CMP  TEMP
         BCC  INS1
         LDA  TEMP
INS1:
         STA  TEMP+1
         JSR  GETADR
         LDY  #3
         LDX  #0
INS2:
         DEC  DATA
         LDA  DATA
         CMP  #$FF
         BNE  INS4
         DEC  DATA+1
INS4:
         LDA  INBUF,X
         STA  (DATA),Y
         INX
         DEC  TEMP+1
         BNE  INS2
         JMP  MAIN
;
HPLOT:
         JSR  PULTOP
         LDA  REGB
         BNE  HPL_ERR
         LDA  REG
         CMP  #200
         BCC  HPLOT_1
HPL_ERR: JMP  CHK_ERR    ; too big
HPLOT_1: STA  YPOS
         JSR  PULTOP
         LDA  VIC+$16
         AND  #$10
         STA  VOICENO    ; multi-colour flag
         BEQ  HPLOT_SI
         ASL  REG
         ROL  REG+1      ; double x co-ord
HPLOT_SI:
         LDA  REG
         STA  XPOSL
         TAX
         LDA  REG+1
         TAY
         CPX  #$40
         SBC  #1
         BCC  HPLOT_2
         JMP  CHK_ERR    ; too big
HPLOT_2: STY  XPOSH
         JSR  PULTOP
         LDA  REG
         AND  #3
         STA  TEMP1+1    ; colour
         LDA  YPOS
         AND  #$F8
         STA  ROWL
         LDA  #0
         ASL  ROWL
         ROL             ; X 2
         ASL  ROWL
         ROL             ; X 4
         ASL  ROWL
         ROL             ; X 8
         STA  TEMP+1
         LDY  ROWL
         STY  TEMP       ; save it
         ASL  ROWL
         ROL             ; X 16
         ASL  ROWL
         ROL             ; X 32
         CLC
         STA  ROWH
         LDA  ROWL
         ADC  TEMP       ; now add 8 giving 40
         STA  ROWL
         LDA  ROWH
         ADC  TEMP+1
         STA  ROWH
;
         JSR  GET_BNK
         LDA  VIC+$18
         AND  #$0E
         ASL
         ASL
         ORA  TEMP+1     ; character base
         STA  TEMP+1
         LDA  XPOSL
         AND  #$F8
         CLC
         ADC  ROWL
         STA  ROWL
         LDA  XPOSH
         ORA  TEMP+1     ; bank
         ADC  ROWH
         STA  TEMP+1
         LDA  YPOS
         AND  #7
         ORA  ROWL
         STA  TEMP
         LDA  XPOSL
         AND  #7
         TAX
         LDA  VOICENO    ; multi-colour?
         BEQ  POS_2      ; no
         LDA  TEMP1+1    ; colour
         LDY  HSHIFT,X   ; bits to shift
         BEQ  POS_3      ; none
POS_4:	ASL
         DEY
         BNE  POS_4
POS_3:	STA  TEMP1
         LDA  H2MASKS,X  ; bits to mask out
         BNE  POS_5
;
POS_2:
         LDA  TEMP1+1    ; colour
         BEQ  POS_1
         LDA  HMASKS,X
POS_1:	STA  TEMP1
         LDY  #0
         LDA  XHMASKS,X
POS_5:
         AND  (TEMP),Y
         ORA  TEMP1
         STA  (TEMP),Y
         JMP  MAIN
;
HMASKS:  .byte $80,$40,$20,$10,$08,$04,$02,$01
XHMASKS: .byte $7F,$BF,$DF,$EF,$F7,$FB,$FD,$FE
HSHIFT:  .byte $06,$06,$04,$04,$02,$02,$00,$00
H2MASKS: .byte $3F,$3F,$CF,$CF,$F3,$F3,$FC,$FC

;
TOHPLOT: JMP  HPLOT

;
ADRNC:
         JSR  GETADR
ADRNC2:
         LDA  DATA
         CLC
         ADC  #2
         STA  DATA
         BCC  ADRN2
         INC  DATA+1
         BCS  ADRN2
ADRNN:
         JSR  GETADR
ADRN2:
         LDA  DATA
         STA  REG
         LDA  DATA+1
         STA  REG+1
         JMP  MAINP
;
ADRAN:
         JSR  GETIDX
         JMP  ADRN2
;
ADRAC:
        JSR  GETIDC
        JMP  ADRNC2

;
        BRK

	.endscope

;***********************************************
; PASCAL COMPILER
; for Commodore 64
; PART 5
; Authors_ Nick Gammon & Sue Gobbett
;  SYM $9000
;***********************************************

	.scope

;***********************************************
; PART 1 VECTORS
;***********************************************

	V1	= P1
	INIT	= V1
	GETNEXT	= V1+3
	COMSTL	= V1+6
	ISITHX	= V1+9
	ISITAL	= V1+12
	ISITNM	= V1+15
	CHAR	= V1+18
	GEN2_B	= V1+21
	DISHX	= V1+24
	ERROR	= V1+27
	GETCHK	= V1+30
	CHKTKN	= V1+33
	GENNOP	= V1+36
	GENADR	= V1+39
	GENNJP	= V1+42
	GENNJM	= V1+45
	TKNWRK	= V1+48
	SEARCH	= V1+51
	ADDSYM	= V1+54
	SPARE2	= V1+57
	FIXAD	= V1+60
	PSHWRK	= V1+63
	PULWRK	= V1+66
	PC	= V1+69
	PT	= V1+72
	PL	= V1+75
	TOKEN1	= V1+78
	GETANS	= V1+81
	PUTSP	= V1+84
	DISPAD	= V1+87
	CROUT	= V1+90
	SHLVAL	= V1+93
	GET_NUM	= V1+96
	GET_HEX	= V1+99
	FND_ENQ	= V1+102
	PAUSE	= V1+105
	HOME	= V1+108
	RDKEY	= V1+111

;***********************************************
; PART 2 VECTORS
;***********************************************
	V2	= P2
	TKNJMP	= V2+60

;***********************************************
; PART 3 VECTORS
;***********************************************

	V3	= P3
	START	= V3
	RESTART	= V3+3
	DSP_BIN	= V3+6
	ST_CMP	= V3+9
	ST_SYN	= V3+12
	DEBUG	= V3+15
	ST_EDI	= V3+18
	ST_FIL	= V3+21
	BELL1X	= V3+24

;***********************************************
; PART 4 VECTORS
;***********************************************

	INTERJ	= P4

;***********************************************
; PART 5 STARTS HERE
;***********************************************

	.res 6
        ;.org $B384 ; P5

;***********************************************
; TEXT EDITOR
;***********************************************

        JMP  EDITOR
        JMP  GETLN
        JMP  GETLNZ
        JMP  GETLN1
        JMP  PUT_LINE

GT_NO_EM: .byte $B6,$CC,$0D
GET_ERR1: .byte "pARDON? (",$C9
          .byte " h FOR HELP )",$0D
DEL_ERR1: .byte $B6,$D8,$0D
FULL_ERR: .byte $BF,$B1,$0D
MOD_QN1:  .byte " MODIFY "
DEL_QN1:  .byte " DELETE "
DEL_QN2:  .byte " LINES",$CB
DEL:	  .byte " dELETED",$0D
HELP_1:	  .byte 13
HELP_2:	  .byte "tHE COMMANDS ARE :",$0D
HELP_3:	  .byte 13
HELP_4:	  .byte $D4,$0D
HELP_5:	  .byte $DB
          .byte "d>ELETE",$CD,$CC,$D8,$0D
HELP_5A:  .byte $DB
          .byte "f>IND  ",$CD,$CC,$D8
          .byte " .",$B8
          .byte " .",$0D
HELP_6:	  .byte $DB
          .byte "i>NSERT",$CD,$CC,$0D
HELP_7:	  .byte $DB
          .byte "l>IST  ",$CD,$CC,$D8,$0D
HELP_8:	  .byte $DB
          .byte "m>ODIFY",$CD,$CC,$D8,$0D
HELP_9:	  .byte $D7,$0D
HELP_9A:  .byte $DB
          .byte "r>EPLACE",$CD,$CC,$D8
          .byte " .OLD.NEW.",$0D
HELP_10:  .byte $D5,$0D
FND_ERR1: .byte $B7,$B8,$0D

;
; Editor jump table
;
ED_TBL:
         .byte  'Q'
         .word  WRAP
         .byte  'I'
         .word  INSERT
         .byte  'H'
         .word  HELP
         .byte  'M'
         .word  MODIFY
         .byte  'D'
         .word  DELETE
         .byte  'L'
         .word  LISTLNS
         .byte  'F'
         .word  LISTLNS
         .byte  'R'
         .word  LISTLNS
         .byte  'N'
         .word  NLIST
         .byte  'C'
         .word  ST_CMP
         .byte  'S'
         .word  ST_SYN
         .byte  0
;
EDITOR:
         LDA  #<ST_EDI
         STA  CTRLC_RT
         LDA  #>ST_EDI
         STA  CTRLC_RT+1
;
GET_COM:
         LDX  #$FF
         TXS
         JSR  CROUT
         JSR  GET_C1
         JMP  GET_COM    ; back for next command
;***********************************************
GET_C1:
         LDA  #$80
         STA  RUNNING
         LDA  #0
         STA  NLN_FLAG
         LDA  #58		;colon
         JSR  COUT       ; editor prompt
         JSR  GET_LINE
         CPX  #0
         BEQ  GET_C1
         LDA  INBUF
         AND  #$7F
         STA  ED_COM
         LDX  #<ED_TBL
         LDY  #>ED_TBL
         JSR  TKNJMP
         LDA  #<GET_ERR1
         LDX  #>GET_ERR1
         JMP  PL
;
NLIST:
         LDA  #1
         STA  NLN_FLAG
         JMP  LISTLNS
;
;
HELP:
;***********************************************
         LDA  #12
         STA  ECNTR
         LDA  #<HELP_1
         LDX  #>HELP_1
PRT_HELP:
         JSR  PL
         TYA
         CLC
         ADC  REG2
         TAY
         LDA  REG2+1
         ADC  #0
         TAX
         TYA
         DEC  ECNTR
         BNE  PRT_HELP
         RTS
;
; read input line - tokenize - count chars to c/r
;
GET_LINE:
         JSR  GETLN1
         LDA  INBUF
         CMP  #160    ; if first char on line shift/space remember it
         PHP	      ; save processor flags
;
; now tidy input line for automatic tokenisation
;
         LDA  #<INBUF
         LDX  #>INBUF
         JSR  TIDY_ENT   ; off we go
         LDX  #0
GET_LIN9: LDA  INBUF,X    ; count up to c/r
         CMP  #$0D
         BEQ  GET_LIN8   ; found it
         INX
         BNE  GET_LIN9   ; try again
GET_LIN8: STX  IN_LGTH    ; save length
         PLP             ; back to result of earlier comparison
         RTS
;
;
INSERT:
;***********************************************
IN_2:
         LDY  #0
         JSR  GET_NO
         BCC  IN_5
         RTS
IN_5:
         JSR  FIND_LN
IN_10:
         JSR  PT_LN_NO
         JSR  GET_LINE
         BEQ  IN_11      ; stay in input mode if shift/space
         CPX  #0
         BNE  IN_11
         RTS
IN_11:
         JSR  INST_TXT
; MOVE LINE FROM INPUT
; BUFFER INTO TEXT
         LDA  #<INBUF
         STA  TO
         LDA  #>INBUF
         STA  TO+1
         LDA  #0
         STA  LENGTH+1
         LDA  IN_LGTH
         STA  LENGTH
         BEQ  IN_22      ; zero length - no move
         JSR  MV_TXT_L
IN_22:
         LDA  PNTR
         CLC
         ADC  LENGTH
         STA  PNTR
         LDA  PNTR+1
         ADC  LENGTH+1
         STA  PNTR+1
         LDA  #CR
         LDY  #0
         STA  (PNTR),Y
         JSR  INC_PNTR
         JMP  IN_10
;
;
INST_TXT:
; MAKE ROOM IN TEXT
         LDA  PNTR
         STA  FROM
         STA  FROM_ST
         STA  EPNTR
         LDA  PNTR+1
         STA  FROM+1
         STA  FROM_ST+1
         STA  EPNTR+1
         JSR  FIND_END
         LDA  FROM
         CLC
         ADC  IN_LGTH
         STA  TO
         LDA  FROM+1
         ADC  #0
         STA  TO+1
; SOURCE TOO BIG ?
         CLC
         LDA  TO
         ADC  LENGTH
         STA  EPNTR
         LDA  TO+1
         ADC  LENGTH+1
         STA  EPNTR
         CMP  #>(P1-$18)   ; start of G-Pascal
         BCC  IN_13
         LDA  #<FULL_ERR
         LDX  #>FULL_ERR
         JSR  PL
         JMP  GET_COM
IN_13:
         JSR  INC_TO
         JSR  MV_TXT_R
         LDA  FROM_ST
         STA  FROM
         LDA  FROM_ST+1
         STA  FROM+1
         RTS

;
GET_NO:
;***********************************************
; RETURNS THE
; NUMBER IN VALUE
         INY
         CPY  IN_LGTH
         BNE  GET_NO_2
         LDY  #0
         STY  VALUE
         STY  VALUE+1
         CLC
         RTS
GET_NO_2:
         LDA  INBUF,Y
         CMP  #32
         BEQ  GET_NO
         JSR  ISITNM
         BCC  GET_NO_5
GT_NO_ER:
         LDA  #<GT_NO_EM
         LDX  #>GT_NO_EM
         JSR  PL
         SEC
         RTS
GET_NO_5:
         STY  PNTR
         PHA
         TYA
         CLC
         ADC  #<INBUF
         STA  NXTCHR
         LDA  #0
         STA  SIGN
         ADC  #>INBUF
         STA  NXTCHR+1
         PLA
         JSR  GET_NUM
         BCS  GT_NO_ER
         LDA  VALUE+2
         BNE  GT_NO_ER
         RTS
;
FIND_LN:
;***********************************************
         LDA  TS
         STA  PNTR
         LDA  TS+1
         STA  PNTR+1
         LDY  #0
         LDX  #0
         STY  LINE_NO
         STY  LINE_NO+1
         LDA  VALUE
         BNE  FL_5
         LDA  VALUE+1
         BNE  FL_5
         RTS
FL_LOOP:
         JSR  INC_PNTR
FL_5:
         LDA  (PNTR),Y
         BNE  FL_10
         STX  LINE_NO
         RTS
FL_10:
         CMP  #CR
         BNE  FL_LOOP
         INX
         BNE  FL_15
         INC  LINE_NO+1
FL_15:
         CPX  VALUE
         BNE  FL_LOOP
         LDA  LINE_NO+1
         CMP  VALUE+1
         BNE  FL_LOOP
         STX  LINE_NO
         JMP  INC_PNTR
;
FIND_END:
; RETURNS LENGTH OF TEXT
; FROM 'POINTER' TO END
; OF FILE IN 'LENGTH'
         LDX  #1
         STX  ECNTR
         LDY  #0
         STY  ECNTR+1
FE_5:	LDA  (EPNTR),Y
         BNE  FE_10
         STX  LENGTH
         LDX  ECNTR+1
         STX  LENGTH+1
         RTS
FE_10:	INX
         BNE  FE_15
         INC  ECNTR+1
FE_15:
         INC  EPNTR
         BNE  FE_5
         INC  EPNTR+1
         JMP  FE_5
;
MV_TXT_L:
; NOTE_ MOVING TEXT
; FROM 'TO' TO 'FROM'
; POSITIONS
         JSR  ZRO_CNTR
MV_5:	LDA  (TO),Y
         STA  (FROM),Y
         JSR  INC_ECNTR
         LDA  ECNTR
         CMP  LENGTH
         BNE  MV_10
         LDA  ECNTR+1
         CMP  LENGTH+1
         BNE  MV_10
         RTS
MV_10:
         INY
         BNE  MV_5
         INC  FROM+1
         INC  TO+1
         JMP  MV_5
MV_TXT_R:
; NOTE TO > FROM
; Y ZEROED IN ZRO_CNTR
         JSR  ZRO_CNTR
         LDA  FROM
         CLC
         ADC  LENGTH
         STA  FROM
         LDA  FROM+1
         ADC  LENGTH+1
         STA  FROM+1
         LDA  TO
         CLC
         ADC  LENGTH
         STA  TO
         LDA  TO+1
         ADC  LENGTH+1
         STA  TO+1
         JMP  MVR_10
MVR_5:	LDA  (FROM),Y
         STA  (TO),Y
         JSR  INC_ECNTR
         LDA  ECNTR
         CMP  LENGTH
         BNE  MVR_10
         LDA  ECNTR+1
         CMP  LENGTH+1
         BNE  MVR_10
         RTS
MVR_10:
         DEY
         CPY  #$FF
         BNE  MVR_5
         DEC  FROM+1
         DEC  TO+1
         JMP  MVR_5
;
ZRO_CNTR:
;***********************************************
         LDY  #0
         STY  ECNTR
         STY  ECNTR+1
         STY  VAL_CMP
         RTS
;
INC_ECNTR:
;***********************************************
         INC  ECNTR
         BNE  INC_C_5
         INC  ECNTR+1
INC_C_5:
         RTS
;
INC_PNTR:
;***********************************************
         INC  PNTR
         BNE  INC_5
         INC  PNTR+1
INC_5:	RTS
;
MODIFY:
;***********************************************
         JSR  LISTLNS
         BCC  MOD_10
         RTS
MOD_10:
         JSR  DELETE
         LDY  #0
         JSR  GET_NO
         DEC  VALUE
         LDA  VALUE
         CMP  #$FF
         BNE  MOD_20
         DEC  VALUE+1
MOD_20:
         LDA  #'I'       ; FOOL INSERT
         STA  ED_COM
         JMP  IN_5
;
DELETE:
;***********************************************
         JSR  GETRANGE
         BCC  DEL_20
         RTS
DEL_20:
         JSR  DEC_FROM
         JSR  FRM_ADDR
         LDA  LINE_NO
         STA  TEMP
         LDA  LINE_NO+1
         STA  TEMP+1
         JSR  TO_ADDR
         LDA  PNTR
         STA  EPNTR
         LDA  PNTR+1
         STA  EPNTR+1
         JSR  FIND_END
         LDA  LINE_NO
         SEC
         SBC  TEMP
         STA  NUM_LINS
         LDA  LINE_NO+1
         SBC  TEMP+1
         STA  NUM_LINS+1
         LDA  NUM_LINS
         CMP  #5
         BCS  DEL_45
         LDA  NUM_LINS+1
         BEQ  DEL_55
DEL_45:
         LDA  #$B9
         JSR  PC
         LDA  #$C2
         JSR  PC
         LDA  ED_COM
         CMP  #'M'
         BEQ  DEL_50
         LDA  #<DEL_QN1
         LDX  #>DEL_QN1
         BNE  DEL_52
DEL_50:
         LDA  #<MOD_QN1
         LDX  #>MOD_QN1
DEL_52:
         LDY  #$8
         JSR  PT
         JSR  PUT_NO
         LDA  #<DEL_QN2
         LDX  #>DEL_QN2
         LDY  #7
         JSR  GETANS
         CMP  #'Y'
         BEQ  DEL_55
         JMP  GET_COM
DEL_55:
         JSR  MV_TXT_L
         LDA  ED_COM
         CMP  #'M'
         BNE  DEL_60
         RTS
DEL_60:
         JSR  CROUT
         JSR  PUT_NO
         LDA  #<DEL
         LDX  #>DEL
         JMP  PL
;
PUT_NO:
;***********************************************
         LDA  NUM_LINS
         STA  REG
         LDA  NUM_LINS+1
         STA  REG+1
         LDA  #0
         STA  REGB
         JMP  DSP_BIN
;
LISTLNS:
;***********************************************
         LDA  INBUF+1
         CMP  DELIMIT
         BEQ  LIS_5
         LDA  IN_LGTH
         CMP  #1
         BNE  LIS_10
; PRINT ALL
LIS_5:	LDA  #0
         TAY
         STA  LINE_NO
         STA  LINE_NO+1
         LDA  TS
         STA  FROM
         LDA  TS+1
         STA  FROM+1
         LDA  #$FF
         STA  TO_LINE
         STA  TO_LINE+1
         BNE  LIS_33
LIS_10:
         JSR  GETRANGE
         BCC  LIS_20
         RTS
LIS_20:
         LDA  TO
         STA  TO_LINE
         LDA  TO+1
         STA  TO_LINE+1
         INC  LINE_NO
         BNE  LIS_31
         INC  LINE_NO+1
LIS_31:
         JSR  DEC_FROM
         JSR  FRM_ADDR
LIS_33:	LDA  ED_COM
         CMP  #'R'       ; REPLACE?
         BEQ  LIS_33A    ; YES
         CMP  #'F'       ; FIND ?
         BEQ  LIS_33A    ; YES
         JMP  LIS_55
LIS_33A:
         LDY  #0
         STY  QT_SIZE
         STY  NUM_LINS
         STY  NUM_LINS+1
         STY  TRN_FLAG
         STY  GLB_FLAG
         STY  Q_FLAG
LIS_34:	LDA  INBUF,Y
         CMP  DELIMIT
         BEQ  LIS_35     ; FOUND OPENER
         INY
         CPY  IN_LGTH
         BNE  LIS_34
LIS_34A: LDA  #<FND_ERR1
         LDX  #>FND_ERR1
         JMP  GETR_31
;
LIS_35:
         INY
         STY  FND_FROM
LIS_36:	CPY  IN_LGTH
         BEQ  LIS_34A
         LDA  INBUF,Y
         CMP  DELIMIT
         BEQ  LIS_37     ; FOUND CLOSER
         INY
         BNE  LIS_36
;
LIS_37:
         STY  FND_TO
         SEC
         LDA  FND_TO
         SBC  FND_FROM
         STA  REP_SIZE
         STA  FND_LEN
;
         LDA  ED_COM
         CMP  #'R'       ; REPLACE?
         BNE  LIS_45     ; NOPE
         INY
         STY  REP_FROM   ; START OF NEW STRING
LIS_38:
         CPY  IN_LGTH
         BEQ  LIS_34A    ; NO DELIMITER
         LDA  INBUF,Y
         CMP  DELIMIT
         BEQ  LIS_39     ; END
;
; now see if new string contains spaces or DLE's -
; if so we need to flag a tidy for later (to amalgamate
; multiple spaces/DLE's etc.
;
         CMP  #$10       ; DLE?
         BEQ  LIS_38A    ; yes
         CMP  #32	 ; space?
         BNE  LIS_38B    ; no - forget it
LIS_38A: INC  QT_SIZE    ; flag it
LIS_38B:
         INY
         BNE  LIS_38
;
LIS_39:
         STY  REP_TO
         SEC
         LDA  FND_TO
         SBC  FND_FROM
         STA  FND_LEN
         SEC
         LDA  REP_TO
         SBC  REP_FROM
         STA  REP_SIZE
         SBC  FND_LEN
         STA  REP_LEN    ; DIFFERENCE IN STRING LENGTHS
;
;
; NOW LOOK FOR FLAG
;
LIS_45:	INY
LIS_46:	CPY  IN_LGTH    ; MORE ON LINE?
         BEQ  LIS_50     ; NO
         LDA  INBUF,Y
         CMP  #32
         BEQ  LIS_45     ; IGNORE SPACES
         AND  #$7F       ; make sure in lower (upper?) case ...
LIS_47:	CMP  #'G'       ; GLOBAL?
         BNE  LIS_48     ; NO
         STA  GLB_FLAG   ; FLAG IT
         LDA  FND_LEN
         BEQ  LIS_ERR
         BNE  LIS_45
;
;
LIS_48:	CMP  #'T'       ; TRANSLATE?
         BNE  LIS_49     ; NO -
         STA  TRN_FLAG
         BEQ  LIS_45
LIS_49:	CMP  #'Q'       ;QUIET?
         BNE  LIS_ERR
         STA  Q_FLAG
         BEQ  LIS_45
LIS_ERR: JMP  LIS_34A    ; NONE - ERROR

;
LIS_50:	LDA  REP_LEN
         STA  IN_LGTH
         DEC  IN_LGTH
LIS_55:	JSR  DISPLAY
         CLC
         RTS
;
DISPLAY:
; PRINT LINE
         LDY  #0
DIS_5:
;
         JSR  STOP
         BEQ  DIS_RTS
DIS_5_OK:
         LDA  (FROM),Y
         BEQ  DIS_WRAP
         LDA  LINE_NO+1
         CMP  TO_LINE+1
         BCC  DIS_15
         LDA  LINE_NO
         CMP  TO_LINE
         BCC  DIS_15
DIS_WRAP:
         LDA  ED_COM
         CMP  #'R'
         BEQ  DIS_WR1
         CMP  #'F'
         BNE  DIS_RTS
DIS_WR1: JMP  FND_END
DIS_RTS:
         RTS
;
;
DIS_15:
         LDA  ED_COM
         CMP  #'R'
         BEQ  DIS_0      ; REPLACE
         CMP  #'F'
         BEQ  DIS_0      ; YES
         JMP  DIS_4      ; NOT FIND
DIS_0:
         LDY  #0
         STY  FND_FLG    ; NOTHING FOUND YET ON THIS LINE
DIS_0A:	STY  FND_POS
DIS_1:          ; HERE FOR EACH CHAR
         LDY  FND_POS
         LDX  FND_FROM
DIS_2:          ; INNER LOOP
         CPX  FND_TO
         BEQ  DIS_35     ; END OF STRING - FOUND IT !!!
         LDA  (FROM),Y   ; CHAR FROM FILE
         CMP  #CR        ; END OF LINE?
         BNE  DIS_2A     ; NO
         LDA  ED_COM
         CMP  #'F'
         BEQ  DIS_2C
         CMP  #'R'
         BNE  DIS_16J
DIS_2C:	LDA  FND_FLG
         BEQ  DIS_16J    ; NOTHING REPLACED ON THIS LINE
         JMP  DIS_80     ; DISPLAY IT
DIS_16J:
         JMP  DIS_16     ; YES - DON'T DISPLAY
DIS_2A:
;
; TRANSLATE TO UPPER CASE IF REQUESTED
;
         BIT  TRN_FLAG
         BVC  DIS_2AB    ; nope
         CMP  #$C1
         BCC  DIS_2AB
         CMP  #$DB
         BCS  DIS_2AB
         AND  #$7F
DIS_2AB:
         CMP  INBUF,X
         BNE  DIS_3      ; NO MATCH
         INY
         INX
         BNE  DIS_2      ; MORE IN STRING
DIS_3:	INC  FND_POS
         CMP  #$10       ; DLE?
         BNE  DIS_1      ; no - OK to process next char
         INC  FND_POS    ; bypass space count
; confused with CONST )
         BNE  DIS_1      ; process next char in line
;
DIS_35:          ; COUNT FOUND
         INC  NUM_LINS
         BNE  DIS_35A
         INC  NUM_LINS+1
DIS_35A: LDA  ED_COM
         STA  FND_FLG    ; MARK FOUND
         CMP  #'R'       ; REPLACE?
         BNE  DIS_70     ; NO
         LDA  REP_LEN    ; NEW STRING SAME LENGTH?
         BNE  DIS_40     ; NOPE - HARD ONE
DIS_36A: LDY  FND_POS
         LDX  REP_FROM   ; MOVE FROM HERE
         LDA  #0
         STA  VAL_CMP    ; COMPILE NO LONGER VALID
DIS_36:
         CPX  REP_TO     ; END OF NEW STRING?
         BEQ  DIS_70     ; YES
         LDA  INBUF,X
         STA  (FROM),Y
         INY
         INX
         BNE  DIS_36     ; BACK FOR MORE
;
DIS_70:
         LDA  GLB_FLAG   ; DO ALL ON LINE?
         BEQ  DIS_80     ; NO - FINISHED THEN
         LDA  FND_POS    ; POINT TO END OF NEW STRING
         CLC
         ADC  REP_SIZE
         TAY
         JMP  DIS_0A     ; BACK FOR ANOTHER GO
;
;
DIS_40:          ; NEW STRING DIFFERENT LENGTH
         BMI  DIS_60     ; NEW SMALLER THAN OLD
;
; HERE IF NEW BIGGER THAN OLD
;
         CLC
         LDA  FROM       ; CALC_ ADDRESS OF NEW TEXT
         PHA
         ADC  FND_POS
         STA  PNTR
         LDA  FROM+1
         PHA
         ADC  #0
         STA  PNTR+1
         JSR  INST_TXT   ; MAKE ROOM
DIS_45:
         PLA
         STA  FROM+1
         PLA
         STA  FROM
         JMP  DIS_36A    ; NOW MOVE IN NEW STRING
;
DIS_60:          ; NEW SMALLER THAN OLD
         LDA  FROM
         PHA
         CLC
         LDA  FND_POS
         ADC  FND_LEN
         ADC  FROM
         STA  TO
         STA  EPNTR      ; (FOR FIND LENGTH)
         LDA  FROM+1
         PHA
         ADC  #0
         STA  TO+1
         STA  EPNTR+1
         JSR  FIND_END   ; FIND LENGTH OF FILE
         CLC
         LDA  TO
         ADC  REP_LEN    ; (WHICH IS NEGATIVE)
         STA  FROM
         LDA  TO+1
         ADC  #$FF
         STA  FROM+1
         JSR  MV_TXT_L   ; SHIFT TEXT LEFT
         JMP  DIS_45     ; NOW TO MOVE IN NEW TEXT
;
;
DIS_80:
         LDA  Q_FLAG
         BEQ  DIS_4
         JMP  DIS_16     ; NO DISPLAY - 'QUIET' MODE
;
;
DIS_4:
         JSR  PT_LN_NO
         LDA  #$40       ; Expand reserved words but not others (not upper case)
         STA  RUNNING
         LDA  FROM
         LDX  FROM+1
         JSR  PL
         LDA  #$80
         STA  RUNNING    ; back to normal
         JMP  DIS_17
DIS_16:	INC  LINE_NO
         BNE  DIS_17
         INC  LINE_NO+1
;
; GET POSN NEXT LINE
DIS_17:	LDY  #0
DIS_20:
         LDA  (FROM),Y
         JSR  INC_FROM
         CMP  #CR
         BNE  DIS_20
         JMP  DISPLAY
;
;
FND_END:
         JSR  CROUT
         JSR  PUT_NO
         LDA  ED_COM
         CMP  #'F'
         BEQ  FND_END2
         LDA  #<RPLCD
         LDX  #>RPLCD
         JSR  PL
         LDA  NUM_LINS
         ORA  NUM_LINS+1
         BEQ  FND_RTS    ; no need if nothing done
         LDA  QT_SIZE    ; new string contain spaces?
         BEQ  FND_RTS    ; no - no Tidy needed
         JSR  TIDY       ; clean up what we've done
FND_RTS: RTS
;
FND_END2:
         LDA  #<FND
         LDX  #>FND
         JMP  PL
;
RPLCD:	.byte " REPLACED",$0D
FND:	.byte " FOUND",$0D

;
PT_LN_NO:
        INC  LINE_NO
        BNE  PT_LN_10
        INC  LINE_NO+1
PT_LN_10:
         LDA  NLN_FLAG   ; LINE NUMBERS?
         BNE  DIS_4A     ; NOPE
PUT_LINE:
	LDA  LINE_NO    ; entry here from compiler
        STA  REG
        LDX  LINE_NO+1
        STX  REG+1
        LDY  #0
        STY  REGB
        CPX  #>1000
        BCC  LT_1000
        BNE  PT_GO
        CMP  #<1000
        BCS  PT_GO
LT_1000: INY
        CPX  #0
        BNE  PT_GO
        CMP  #100
        BCS  PT_GO
        INY
        CMP  #10
        BCS  PT_GO
        INY
PT_GO:	TYA
        BEQ  PT_FIN
        PHA
        JSR  PUTSP
        PLA
        TAY
        DEY
        BNE  PT_GO
PT_FIN:
        JSR  DSP_BIN
        JMP  PUTSP

;
GETRANGE:
;***********************************************
; GET 1ST NO
         LDY  #0
         JSR  GET_NO
         BCC  GETR_5
DIS_4A:	RTS
GETR_5:
         LDA  VALUE
         STA  FROM
         BNE  GETR_10
         LDA  VALUE+1
         BEQ  GETR_30
GETR_10:
         LDA  VALUE+1
         STA  FROM+1
; GET 2ND NO
         LDY  PNTR
GETR_15:
         INY
         CPY  IN_LGTH
         BEQ  GETR_16
         LDA  INBUF,Y
         CMP  DELIMIT
         BNE  GETR_20
GETR_16: LDA  FROM
         STA  TO
         LDA  FROM+1
         STA  TO+1
         CLC
         RTS
GETR_20:
         LDA  INBUF,Y
         CMP  #'0'
         BCC  GETR_22
         CMP  #'9'+1
         BCS  GETR_22
         JMP  GETR_15
GETR_22:
         JSR  GET_NO
         BCC  GETR_25
         RTS
GETR_25:
         LDA  VALUE
         STA  TO
         LDA  VALUE+1
         STA  TO+1
; CHECK RANGE
         LDA  TO
         SEC
         SBC  FROM
         LDA  TO+1
         SBC  FROM+1
         BMI  GETR_30
         CLC
         RTS
GETR_30:
         LDA  #<DEL_ERR1
         LDX  #>DEL_ERR1
GETR_31: JSR  PL
         SEC
         RTS
;
TO_ADDR:
        LDA  TO
        STA  VALUE
        LDA  TO+1
        STA  VALUE+1
        JSR  FIND_LN
        LDA  PNTR
        STA  TO
        LDA  PNTR+1
        STA  TO+1
        RTS

;
FRM_ADDR:
        LDA  FROM
        STA  VALUE
        LDA  FROM+1
        STA  VALUE+1
        JSR  FIND_LN
        LDA  PNTR
        STA  FROM
        LDA  PNTR+1
        STA  FROM+1
        RTS

;
; TIDY UP SOURCE FILE
;
; here to convert alphas to reserved words if possible
;
TIDY_AL:
         LDX  EPNTR      ; in quotes?
         BNE  TIDY_CH    ; yes - ignore
         LDX  FROM
         STX  NXTCHR     ; start of word
         LDX  FROM+1
         STX  NXTCHR+1
         JSR  TOKEN1
         DEC  TKNLEN
         LDY  #0
         CMP  #'I'       ; identifier?
         BNE  TIDY_RS    ; no - must be reserved
;
; get original letter back
;
         LDX  TKNLEN
         STX  QT_SIZE    ; ignore next (n - 1) letters
         LDA  (FROM),Y
         BNE  TIDY_CH    ; just copy it
;
TIDY_RS:          ; reserved word
         LDA  TKNLEN
         CLC
         ADC  FROM
         STA  FROM       ; add length of (token - 1)
         BCC  TIDY_RS1
         INC  FROM+1
TIDY_RS1:          ; bypass whole word in source
         INY
         LDA  (FROM),Y   ; followed by space?
         AND  #$7F
         CMP  #32
         BNE  TIDY_RS2   ; no
         JSR  INC_FROM   ; yes - ignore space
TIDY_RS2:
         LDA  TOKEN
         DEY             ; y is now zero again
         BEQ  TIDY_CH    ; use our new token
;
;
TIDY:
         LDA  TS
         LDX  TS+1
;
TIDY_ENT:
         STA  FROM
         STA  TO
         STA  REG2
         STX  FROM+1
         STX  TO+1
         STX  REG2+1
         LDA  #0
         STA  QT_SIZE    ; ALPHA BYPASS SIZE
         STA  EPNTR      ; QUOTE FLAG
;
TIDY_NXT:
         LDY  #0
         LDA  (FROM),Y
         BEQ  TIDY_END
         LDX  QT_SIZE    ; bypassing a non-reserved word?
         BEQ  TIDY_NX1   ; no
         DEX             ; one less to worry about
         STX  QT_SIZE
         BPL  TIDY_CH    ; still in middle - just copy character
TIDY_NX1:
         CMP  #13		; CARRIAGE RETURN
         BEQ  TIDY_CR
         CMP  QUOT_SYM
         BEQ  TIDY_QT
         CMP  #32		; SPACE?
         BEQ  TIDY_SPJ		; YES
         CMP  #160		; SHIFT/SPACE
         BEQ  TIDY_SPJ
         CMP  #$10       ; DLE?
         BEQ  TIDY_DLE
         JSR  ISITAL     ; alpha?
         BCC  TIDY_AL    ; yes
;
; COPY CHARACTER
;
TIDY_CH: STA  (TO),Y
         JSR  INC_TO
TIDY_LF: JSR  INC_FROM
         JMP  TIDY_NXT

TIDY_SPJ: JMP  TIDY_SP

TIDY_QT:
        PHA
        EOR  EPNTR      ; FLIP FLAG
        STA  EPNTR
        PLA
        BNE  TIDY_CH    ; STORE IT
;
TIDY_CR:
        STY  EPNTR      ; CLEAR QUOTE FLAG
        STY  QT_SIZE    ; AND ALPHA BYPASS COUNT
        JSR  CMP_END    ; AT START OF FILE?
        BEQ  TIDY_NSP   ; YES - OFF WE GO

;
; DROP TRAILING SPACES
;
TIDY_OK:
         JSR  DEC_TO
         AND  #$7F
         CMP  #32
         BEQ  TIDY_CR
;
         JSR  INC_TO     ; BACK TO LAST SPACE
TIDY_NSP:          ; END OF FILE/SPACES
         LDA  #$0D
         BNE  TIDY_CH
;
TIDY_END:
         JSR  CMP_END
         BEQ  TIDY_E2    ; AT START OF FILE
         JSR  DEC_TO     ; C/R BEFORE END?
         JSR  INC_TO
         CMP  #$0D
         BEQ  TIDY_E2    ; YES
         LDA  #$0D       ; NO - PUT ONE THERE
         STA  (TO),Y
         JSR  INC_TO
TIDY_E2:
         TYA
         STA  (TO),Y
         RTS
;
;
TIDY_DLE:
         STA  (TO),Y     ; COPY 2 CHARS REGARDLESS
         JSR  INC_TO
         JSR  INC_FROM
         LDA  (FROM),Y
         TAX             ; save temporarily
         INY
         LDA  (FROM),Y   ; another DLE?
         CMP  #$10
         BEQ  TIDY_DL2   ; yes
         AND  #$7F
         CMP  #32		; followed by a solitary space?
         BNE  TIDY_DL3   ; no
         INX             ; yes - add 1 to space count
         JSR  INC_FROM   ; and bypass the space
TIDY_DL3: TXA             ; back to space count
         LDY  #0
         JMP  TIDY_CH
;
; here for 2 DLE's in a row
;
TIDY_DL2:
         INY
         LDA  (FROM),Y   ; second space count
         AND  #$7F       ; strip 8 bit
         LDY  #0
         CLC
         ADC  (FROM),Y   ; add to first space count
         TAX             ; save in X
         JSR  INC_FROM   ; now bypass 2nd. DLE and its count
         JSR  INC_FROM
         BNE  TIDY_DL3   ; now copy over our new count
;
;
TIDY_SP:
         LDA  EPNTR
         BNE  TIDY_GQT   ; GOT QUOTE
         INY
         LDA  (FROM),Y   ; 2 SPACES IN ROW?
         CMP  #$10       ; space followed by DLE?
         BEQ  TIDY_BMP   ; yes - add 1 to DLE count
         AND  #$7F
         CMP  #32
         BEQ  TIDY_SPC   ; YES
         DEY             ; NO
TIDY_GQT:
         LDA  #32
         JMP  TIDY_CH
;
; here for a single space followed by a DLE and a space count
; - just add 1 to the space count following and ignore the
; current space
;
TIDY_BMP:
         TYA             ; Y contains 1
         CLC
         INY             ; now at space count
         ADC  (FROM),Y
         STA  (FROM),Y
         JMP  TIDY_LF
;
;
TIDY_SPC:          ; OUTPUT DLE
         DEY
         LDA  #$10
         STA  (TO),Y
         JSR  INC_TO
         LDX  #1         ; SPACE COUNT
TIDY_CNT:
         JSR  INC_FROM
         LDA  (FROM),Y
         AND  #$7F
         CMP  #32		; ANOTHER?
         BNE  TIDY_DNE		; NOPE
         INX
         BNE  TIDY_CNT
;
TIDY_DNE:
         CMP  #$0D       ; END OF LINE?
         BEQ  TIDY_IGN   ; YES - IGNORE THEM
         CMP  #$0A       ; SAME
         BEQ  TIDY_IGN
         TXA             ; SPACE COUNT
         ORA  #$80       ; SET BIT TO STOP CONFUSION WITH C/R
         STA  (TO),Y
         JSR  INC_TO
         JMP  TIDY_NXT   ; PROCESS CURRENT CHAR
;
TIDY_IGN:
         JSR  DEC_TO     ; FORGET DLE
         JMP  TIDY_NXT   ; PROCESS CHAR
;
;
INC_FROM:
        INC  FROM
        BNE  RTS1
        INC  FROM+1
RTS1:	RTS
;
INC_TO:
         INC  TO
         BNE  RTS1
         INC  TO+1
         RTS
;
DEC_TO:
         DEC  TO
         LDA  TO
         CMP  #$FF
         BNE  DEC_TO_9
         DEC  TO+1
DEC_TO_9:
         LDA  (TO),Y     ; SAVE TROUBLE LATER
         RTS
;
DEC_FROM:
         DEC  FROM
         LDA  FROM
         CMP  #$FF
         BNE  RTS1
         DEC  FROM+1
         RTS
;
CMP_END:
        LDA  TO
        CMP  REG2
        BNE  CMP_END9
        LDA  TO+1
        CMP  REG2+1
CMP_END9: RTS
;
;
WRAP: 	LDA  INBUF+1
        CMP  #'F'
        BNE  GET7_A
        JMP  ST_FIL     ; QF = GO TO FILES MENU
GET7_A: ; ORDINARY QUIT
        JMP  RESTART

;
GETLNZ:
GETLN:
GETLN1:
        LDY  #0
        LDX  DFLTN      ; input from keyboard (screen)?
        BNE  GET1       ; no - bypass fancy stuff (screws up disk)
;
; the code below ensures that we accept data from the
; column that the prompt ended, even if we change lines
;
        JSR  CHRIN      ; trigger read of line
        LDA  LXSP+1     ; old column
        STA  CH         ; make new column
        CMP  INDX       ; past logical end of line?
        BCC  GET4       ; no - is OK
        STY  CRSW       ; indicate line finished
        LDA  #$0D       ; dummy up a c/r
        BNE  GET_3
GET4:	LDA  #1         ; make sure we keep reading line
        STA  CRSW
GET1:	JSR  CHRIN
        STA  INBUF,Y    ; SAVE IN BUFFER
        INY
        AND  #$7F       ; c/r may have 8-bit set
        CMP  #$0D       ; END OF LINE?
        BNE  GET1       ; NOPE
        DEY
GET_3:	STA  INBUF,Y    ; proper c/r
        INY
        LDA  #0
        STA  INBUF,Y    ; zero after line for Tidy processing
        DEY
        TYA
        PHA
        JSR  CROUT
        PLA
        TAX             ; PUT INTO X
        RTS             ; RETURN

;
         BRK

	.endscope

;***********************************************
; PASCAL COMPILER
; for Commodore 64
; PART 6
; Authors_ Nick Gammon & Sue Gobbett
;  SYM $9000
;***********************************************

	.scope

;***********************************************
; PART 1 VECTORS
;***********************************************

	V1	= P1
	INIT	= V1
	GETNEXT	= V1+3
	COMSTL	= V1+6
	ISITHX	= V1+9
	ISITAL	= V1+12
	ISITNM	= V1+15
	CHAR	= V1+18
	GEN2_B	= V1+21
	DISHX	= V1+24
	ERROR	= V1+27
	GETCHK	= V1+30
	CHKTKN	= V1+33
	GENNOP	= V1+36
	GENADR	= V1+39
	GENNJP	= V1+42
	GENNJM	= V1+45
	TKNWRK	= V1+48
	PRBYTE	= V1+51
	GTOKEN	= V1+54
	SPARE2	= V1+57
	FIXAD	= V1+60
	PSHWRK	= V1+63
	PULWRK	= V1+66
	PC	= V1+69
	PT	= V1+72
	PL	= V1+75
	PC8	= V1+78
	GETANS	= V1+81
	PUTSP	= V1+84
	DISPAD	= V1+87
	CROUT	= V1+90
	SHLVAL	= V1+93
	GET_NUM	= V1+96
	GET_HEX	= V1+99
	FND_END	= V1+102
	PAUSE	= V1+105
	HOME	= V1+108
	RDKEY	= V1+111
	GENJMP	= V1+114
	GENRJMP	= V1+117

	.res 6
	;.org $BCB8 ; P6

        JMP  BLOCK

;***********************************************
; PART 2 VECTORS
;***********************************************

	V2	= P2
	STMNT	= V2
	EXPRES	= V2+3
	CHKLHP	= V2+6
	CHKRHP	= V2+9
	CHKLHB	= V2+12
	CHKRHB	= V2+15
	LOOKUP	= V2+18
	CHKDUP	= V2+21
	CONDEC	= V2+24
	VARDEC	= V2+27
	CONST	= V2+30
	GETSUB	= V2+33
	W_STRING= V2+36
	WRKTKN	= V2+39
	SYMWRK	= V2+42
	WRKSYM	= V2+45
	PSHPCODE= V2+48
	CHK_STAK= V2+51
	SEARCH	= V2+54
	ADDSYM	= V2+57
	TKNJMP	= V2+60

;***********************************************

CHKGET:
         JSR  CHKTKN
         JMP  GTOKEN
;
WRK_VAL:
         PHA
         LDA  WORK
         STA  VALUE
         LDA  WORK+1
         STA  VALUE+1
         PLA
         RTS
;
VAL_WRK:
         PHA
         LDA  VALUE
         STA  WORK
         LDA  VALUE+1
         STA  WORK+1
         PLA
         RTS
;
END_WRK:
         PHA
         LDA  ENDSYM
         STA  WORK
         LDA  ENDSYM+1
         STA  WORK+1
         PLA
         RTS
;
;***********************************************
;
;
; BLOCK
;
BLCKT1:	.byte $82
        .word BLKCNS
BLCKT2:	.byte $83
        .word BLKVAR
BLCKT3:	.byte $86
        .word BLKPRC
        .byte $87
        .word BLKFNC
        .byte $88
        .word BLKBEG
        .byte 0

;
BLOCK:	JSR  CHK_STAK
        LDA  #0
        STA  FRAME+1
        LDA  #6
        STA  FRAME
        LDA  PRCITM
        STA  WORK
        LDX  PRCITM+1
        STX  WORK+1
         ORA  PRCITM+1
        BEQ  BLK1

; HERE CHECK FOR CONSTRUCT_
;
; PROCEDURE ABCD;
; $1234;
;
; WHICH IS THE METHOD OF
; REFERRING TO EXTERNAL
; PROCEDURES
;
         LDA  TOKEN
         CMP  #'N'
         BNE  BLK1A
         LDY  #0
         LDA  (TKNADR),Y
         CMP  #'$'
         BNE  BLK1A
         LDY  #SYMDSP
         LDA  VALUE
         STA  (WORK),Y
         INY
         LDA  VALUE+1
         STA  (WORK),Y
         LDA  #1         ; FLAG ABSOLUTE PROCEDURE
         LDY  #SYMDAT
         STA  (WORK),Y
         LDA  #';'
         LDX  #10
         JMP  GETCHK
;
BLK1A:	LDY  #SYMDSP
         LDA  PCODE
         STA  (WORK),Y
         INY
         LDA  PCODE+1
         STA  (WORK),Y
         LDA  #0
         LDY  #SYMDAT
         STA  (WORK),Y   ; FLAG RELATIVE PROCEDURE
         JMP  BLK2
BLK1:	LDA  PCODE
         STA  WORK
         LDA  PCODE+1
         STA  WORK+1
BLK2:	JSR  PSHWRK
         JSR  GENNJP
         LDX  #<BLCKT1
         LDY  #>BLCKT1
BLK4:	LDA  TOKEN
         JSR  TKNJMP
         LDX  #25
         JSR  ERROR
;
;
; CONSTANT
;
BLKCNS:	JSR  GTOKEN
BLKCN1:	JSR  CONDEC
         LDA  #';'
         LDX  #10
         JSR  CHKGET
         LDX  #<BLCKT2
         LDY  #>BLCKT2
         JSR  TKNJMP
         JMP  BLKCN1
;
; VARIABLE
;
BLKVAR:	LDA  #0
         STA  COUNT1
BLKVR1:	JSR  GTOKEN
BLKVR6:	JSR  VARDEC
         INC  COUNT1
         BPL  BLKVR7
         JMP  BLKV13     ; ERROR
BLKVR7:	LDA  TOKEN
         CMP  #','
         BEQ  BLKVR1
         LDA  #58
         LDX  #5
         JSR  CHKGET
         CMP  #$84       ; ARRAY
         BEQ  BLKVR2
         CMP  #$FE       ; INTEGER
         BEQ  BLKVR8
         LDA  #$A1       ; CHAR
         LDX  #36
         JSR  CHKTKN
         JMP  BLKVR3
BLKVR8:	JSR  BLKVR9
BLKV10:	LDY  #SYMPRV
         LDA  (WORK),Y
         TAX
         INY
         LDA  (WORK),Y
         STA  WORK+1
         TXA
         STA  WORK       ; PREVIOUS ITEM
         LDY  #SYMDAT
         LDA  #0         ; INTEGER TYPE
         STA  (WORK),Y
         LDA  FRAME
         LDY  #SYMDSP
         STA  (WORK),Y
         INY
         LDA  FRAME+1
         STA  (WORK),Y
         CLC
         LDA  FRAME
         ADC  #3
         STA  FRAME
         BCC  BLKV10_A
         INC  FRAME+1
BLKV10_A:
         DEC  COUNT1
         BNE  BLKV10
         JMP  BLKVR3
;
; ARRAY [ N ] OF ...
;
BLKVR2:	JSR  CHKLHB
         JSR  CONST
         LDA  VALUE+2
         BNE  BLKV13
         LDA  VALUE
         CLC
         ADC  #1
         STA  VALUE
         LDA  VALUE+1
         BMI  BLKV13
         ADC  #0
         BPL  BLKVR4
BLKV13:	LDX  #15
         JSR  ERROR
BLKVR4:	STA  VALUE+1
         JSR  VAL_WRK
         JSR  GTOKEN
         JSR  CHKRHB
         LDA  #1
         STA  DATTYP
         LDA  #$85       ; OF
         LDX  #26
         JSR  CHKGET
         CMP  #$FE       ; INTEGER
         BNE  BLKV11
         DEC  DATTYP
         JSR  WRK_VAL
;
; MULTIPLY VALUE BY 3
;
         LDA  VALUE
         LDX  VALUE+1
         ASL  VALUE
         ROL  VALUE+1
         BCS  BLKV13
         ADC  VALUE
         STA  VALUE
         TXA
         ADC  VALUE+1
         BCS  BLKV13
         STA  VALUE+1
         JSR  VAL_WRK
         JMP  BLKV12
BLKV11:	LDA  #$A1       ; CHAR
         LDX  #36
         JSR  CHKTKN
BLKV12:	JSR  BLKVR9
         JMP  BLKVR5
BLKVR9:
         LDA  FRAME
         SEC
         SBC  COUNT1
         STA  FRAME
         LDA  FRAME+1
         SBC  #0
         STA  FRAME+1
         JSR  WRK_VAL
         LDA  ENDSYM
         STA  WORK
         LDA  ENDSYM+1
         STA  WORK+1
         RTS
BLKVR5:	LDY  #SYMPRV
         LDA  (WORK),Y
         TAX
         INY
         LDA  (WORK),Y
         STA  WORK+1
         TXA
         STA  WORK       ; PREVIOUS ITEM
         LDY  #SYMTYP
         LDA  #'A'
         STA  (WORK),Y
         LDY  #SYMDSP
         LDA  FRAME
         STA  (WORK),Y
         INY
         LDA  FRAME+1
         STA  (WORK),Y
         LDA  VALUE
         CLC
         ADC  FRAME
         STA  FRAME
         LDA  VALUE+1
         ADC  FRAME+1
         STA  FRAME+1
         LDY  #SYMDAT
         LDA  DATTYP
         STA  (WORK),Y
         LDY  #SYMSUB
         LDA  VALUE
         STA  (WORK),Y
         LDA  VALUE+1
         INY
         STA  (WORK),Y
         DEC  COUNT1
         BNE  BLKVR5
BLKVR3:	LDA  #';'
         LDX  #10
         JSR  GETCHK
         JSR  GTOKEN
         LDX  #<BLCKT3
         LDY  #>BLCKT3
         JSR  TKNJMP
         LDA  #0
         STA  COUNT1
         JMP  BLKVR6
;
; PROCEDURE DECLARATION
;
BLKPRC:	LDA  #'I'
         LDX  #4
         JSR  GETCHK
         LDA  #0
         STA  COUNT1
         JSR  CHKDUP
         LDA  #'P'
         JSR  ADDSYM
         INC  LEVEL
         LDA  SYMITM
         STA  PRCITM
         LDA  SYMITM+1
         STA  PRCITM+1
         JMP  BLKPR1
;
; FUNCTION DECLARATION
;
BLKFNC:	LDA  #'I'
         LDX  #4
         JSR  GETCHK
         JSR  CHKDUP
         LDA  #'F'
         JSR  ADDSYM
         INC  LEVEL
         LDA  #1
         STA  COUNT1
         LDA  SYMITM
         STA  PRCITM
         LDA  SYMITM+1
         STA  PRCITM+1
         LDA  #'Y'
         JSR  ADDSYM
;
; PROCEDURE AND FUNCTION COMMON CODE
;
BLKPR1:	LDA  COUNT1
         STA  COUNT2
         JSR  END_WRK
         JSR  PSHWRK
         LDA  FRAME
         STA  WORK
         LDA  FRAME+1
         STA  WORK+1
         JSR  PSHWRK
         JSR  GTOKEN
         CMP  #'('
         BNE  BLKPR2
BLKPR3:	JSR  GTOKEN
         JSR  VARDEC
         INC  COUNT1
         BPL  BLKPR6
         JMP  BLKV13
BLKPR6:	LDA  TOKEN
         CMP  #','
         BEQ  BLKPR3
         JSR  CHKRHP
BLKPR2:	LDA  PRCITM
         STA  WORK
         LDA  PRCITM+1
         STA  WORK+1
         LDY  #SYMARG
         LDA  COUNT1
         SEC
         SBC  COUNT2
         STA  (WORK),Y
         LDA  #';'
         LDX  #10
         JSR  CHKTKN
         LDA  COUNT1
         BEQ  BLKPR4
         JSR  END_WRK
         LDX  #$FD
BLKPR5:	LDY  #SYMPRV
         LDA  (WORK),Y
         PHA
         INY
         LDA  (WORK),Y
         STA  WORK+1
         PLA
         STA  WORK
         LDY  #SYMDAT
         LDA  #0
         STA  (WORK),Y
         LDY  #SYMDSP
         TXA
         STA  (WORK),Y
         SEC
         SBC  #3
         TAX
         LDA  #$FF
         INY
         STA  (WORK),Y
         DEC  COUNT1
         BNE  BLKPR5
BLKPR4:	JSR  GTOKEN
         JSR  BLOCK
         DEC  LEVEL
         JSR  PULWRK
         LDA  WORK
         STA  FRAME
         LDA  WORK+1
         STA  FRAME+1
         JSR  PULWRK
         LDA  WORK
         STA  ENDSYM
         LDA  WORK+1
         STA  ENDSYM+1
         LDA  #';'
         LDX  #10
         JSR  CHKGET
         LDX  #<BLCKT3
         LDY  #>BLCKT3
         JMP  BLK4
;
; BEGIN (COMPOUND STATEMENT)
;
BLKBEG:	JSR  GTOKEN
         JSR  PULWRK
         LDA  LEVEL
         BNE  BLKB1
BLKB3:	JSR  FIXAD
         JMP  BLKB2
BLKB1:	JSR  WRKSYM
         LDY  #SYMDSP
         LDA  (SYMITM),Y
         STA  WORK
         INY
         LDA  (SYMITM),Y
         STA  WORK+1
         LDY  #SYMDSP
         LDA  PCODE
         STA  (SYMITM),Y
         LDA  PCODE+1
         INY
         STA  (SYMITM),Y
         JMP  BLKB3
BLKB2:	LDA  FRAME
         STA  OPND
         LDA  FRAME+1
         STA  OPND+1
         LDA  #59
         JSR  GENJMP
BLKB5:	JSR  STMNT
         LDA  TOKEN
         CMP  #';'
         BNE  BLKB4
         JSR  GTOKEN
         JMP  BLKB5
BLKB4:	LDA  #$89       ; END
         LDX  #17
         JSR  CHKGET
         LDA  #41
         LDX  LEVEL
         BNE  BLKB6
         LDA  #17        ; STOP
TEST1:
BLKB6:	JMP  GENNOP

;
        BRK

	.endscope