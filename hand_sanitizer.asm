SENSOR	BIT 	p1.0
MOTOR 	BIT 	p3.0
MOTOR_2 BIT 	p3.1
RS	BIT	P2.5
RW 	BIT   	P2.6
EN 	BIT 	P2.7

LCD_DATA_PORT EQU P0

;=====================================================

	ORG 0H

;-------------------------------------------------------------------------------
;		SENSOR + MOTOR
;-------------------------------------------------------------------------------
restart:

	setb SENSOR ; set pin sensor sebagai input
	clr MOTOR
	clr MOTOR_2 ; matikan motor terlebih dahulu

idle:	jnb SENSOR, idle ; kalo buat proteus ini jnb, kalo pake switch emu jb
object: setb MOTOR
	jb SENSOR, object ; selama masih detect object nyalain motor

	cpl MOTOR

;-------------------------------------------------------------------------------
;		LCD INTERFACING PORT IN 8 BIT MODE
;-------------------------------------------------------------------------------
LCD_INITIAL:

	MOV DPTR, #CMD   ;SET UP INITIAL LCD

LOOP_INIT:
	MOVC A,@A+DPTR
	JZ NEXT
	ACALL LCD_WRITE_CMD
	ACALL DELAY_LCD
	CLR A
	INC DPTR
	SJMP LOOP_INIT

;-------------------------------------------------------------------------------
;		SET CURSOR AND WRITE DATA TO LCD
;-------------------------------------------------------------------------------

; FIRST TEXT
NEXT:

	CLR A
	MOV A,#82H   ;SET TO TEXT TO MIDDLE
	ACALL LCD_WRITE_CMD
	ACALL DELAY_LCD
	CLR A
	MOV DPTR, #KEEP

LOOP_NEXT:
	MOVC A,@A+DPTR
	JZ NEXT2
	ACALL LCD_WRITE_DATA
	ACALL DELAY_LCD
	CLR A
	INC DPTR
	SJMP LOOP_NEXT

; NUMBER
NEXT2:

	CLR A
	MOV A,#0C2H   ;SET TO TEXT TO SECOND ROW
	ACALL LCD_WRITE_CMD
	ACALL DELAY_LCD
	CLR A
	MOV DPTR, #NUM
 
	MOV R1, #3
	MOV R0, #0

PULUHAN:
	MOV A, 1
	JZ NEXT3 ; kalo m  isalkan R1 = 0 dan R0 = 0, maka lanjut
	MOV R0, #9
	DEC R1

SATUAN:
	MOV A, R1
	MOVC A, @A+DPTR
	ACALL LCD_WRITE_DATA
	ACALL DELAY_LCD

	MOV A, R0
	MOVC A, @A+DPTR
	ACALL LCD_WRITE_DATA
	ACALL DELAY_LCD

	ACALL DELAY

	MOV A,#0C2H   ; balikin ke tengah
	ACALL LCD_WRITE_CMD
	ACALL DELAY_LCD

	MOV A, 0 ; setiap R0 udah 0, puluhannya diganti
	JZ PULUHAN

	DEC R0 ; dia bakal ngecek R0 nya dulu sebelom di decrement lagi
	SJMP SATUAN

; DONE TEXT
NEXT3:
	MOV A,#01H   ;CLEAR
	ACALL LCD_WRITE_CMD
	ACALL DELAY

	MOV A,#82H   ;SET TO TEXT TO MIDDLE
	ACALL LCD_WRITE_CMD
	ACALL DELAY_LCD
	CLR A
	MOV DPTR, #CAUTION

LOOP_NEXT3:
	MOVC A,@A+DPTR
	JZ NEXT4
	ACALL LCD_WRITE_DATA
	ACALL DELAY_LCD
	CLR A
	INC DPTR
	SJMP LOOP_NEXT3

NEXT4:
	acall DELAY
	acall DELAY
	mov A,#01H   ; clear lcd
	acall LCD_WRITE_CMD
	acall DELAY
	mov A,#08H   ; turn off lcd
	acall LCD_WRITE_CMD
	acall DELAY_LCD
	ljmp restart

;--------------------------------------------------------------------------------
;		COMMAND FOR INITIALIZING LCD
;--------------------------------------------------------------------------------
LCD_WRITE_CMD:

	MOV LCD_DATA_PORT,A
	CLR RS
	CLR RW
	SETB EN
	ACALL DELAY_LCD
	CLR EN
	RET

;--------------------------------------------------------------------------------
;		COMMAND FOR WRITING DATA INTO LCD
;--------------------------------------------------------------------------------
LCD_WRITE_DATA:

	MOV LCD_DATA_PORT,A
	SETB RS
	CLR RW
	SETB EN
	ACALL DELAY_LCD
	CLR EN
	RET

;-------------------------------------------------------------------------------
;		DELAY PROGRAM
;-------------------------------------------------------------------------------
DELAY:
	MOV  R5, #20H
	MOV	TMOD, #01h
LOOP:	MOV	TH0, #3CH ; 50000 counts on timer
	MOV	TL0, #0B1H
	SETB	TR0
HERE:	JNB	TF0, HERE
	CLR	TR0
	CLR	TF0
	DJNZ R5, LOOP
	RET


;------------------------------------------------------------------------------
;		DELAY LCD (40 micro seconds)
;------------------------------------------------------------------------------
DELAY_LCD:

	MOV R7,#20
	DJNZ R7, $
	RET

;=====================================================

	ORG 300H

CMD:	    	DB 38H,0EH,06H,81H,0H
KEEP:		DB 'KEEP WASHING!', 0h
NUM:		DB '0123456789' 
CAUTION:	DB 'YOU''RE DONE',0H
END
