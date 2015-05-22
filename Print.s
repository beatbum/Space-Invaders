; Print.s
; Student names: Jake Klovenski
; Last modification date: 3/29/2015
; Runs on LM4F120 or TM4C123
; EE319K lab 7 device driver for any LCD
;
; As part of Lab 7, students need to implement these LCD_OutDec and LCD_OutFix
; This driver assumes two low-level LCD functions
; ST7735_OutChar   outputs a single 8-bit ASCII character
; ST7735_OutString outputs a null-terminated string 
TOOBIG				 EQU 0x270F			;VALUE OF 9999
Asterisk	EQU		0x2A
DecimalDot	EQU		0x2E	
	
    IMPORT   ST7735_OutChar
    IMPORT   ST7735_OutString
    EXPORT   LCD_OutDec
    EXPORT   LCD_OutFix


    AREA    |.text|, CODE, READONLY, ALIGN=2
    THUMB

  

;-----------------------LCD_OutDec-----------------------
; Output a 32-bit number in unsigned decimal format
; Input: R0 (call by value) 32-bit unsigned number
; Output: none
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutDec
	PUSH{R0,LR}
	CMP R0, #10
	BLO DONERECURSING
	MOV R2,#10
	UDIV R3,R0,R2		;R3=INPUT/10
	MUL R1, R3, R2		;R2=INPUT/10 *10
	SUB R1, R0, R1		;R1=INPUT%10
	PUSH {R1,R12}		;SAVE R1
	MOV R0, R3
	BL LCD_OutDec
	POP {R0,R12}
DONERECURSING
	ADD R0, #0x30
	BL ST7735_OutChar
	POP {R0,LR}
	BX LR

;* * * * * * * * End of LCD_OutDec * * * * * * * *

; -----------------------LCD _OutFix----------------------
; Output characters to LCD display in fixed-point format
; unsigned decimal, resolution 0.001, range 0.000 to 9.999
; Inputs:  R0 is an unsigned 32-bit number
; Outputs: none
; E.g., R0=0,    then output "0.000 "
;       R0=3,    then output "0.003 "
;       R0=89,   then output "0.089 "
;       R0=123,  then output "0.123 "
;       R0=9999, then output "9.999 "
;       R0>9999, then output "*.*** "
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutFix


	
	PUSH	{R1,R2,R3,LR}
	LDR 	R1, =TOOBIG
	CMP		R0, R1
	BHI		PastRange
	
	PUSH	{R0, R1}
	MOV		R2, #1000
	UDIV	R0, R0, R2
	MOV		R1, #10
	BL		Modulus
	ADD		R0, #0x30			;ASCII Conversion
	BL 		ST7735_OutChar		;First Number
	MOV		R0, #DecimalDot
	BL 		ST7735_OutChar
	POP		{R0, R1}			;Restores R0 or a
	
	PUSH	{R0, R1}
	MOV		R2, #100
	UDIV	R0, R0, R2
	MOV		R1, #10
	BL		Modulus
	ADD		R0, #0x30			;ASCII Conversion
	BL		ST7735_OutChar		;Second Number
	POP		{R0,R1}				;Restores R0 or a
	
	PUSH	{R0,R1}		
	MOV		R2, #10
	UDIV	R0, R0, R2
	MOV		R1, #10
	BL		Modulus
	ADD		R0, #0x30			;ASCII Conversion
	BL 		ST7735_OutChar		;Third Number
	POP		{R0, R1}			;Restores R0 or a
	
	PUSH	{R0, R1}
	MOV		R1, #10
	BL		Modulus
	ADD		R0, #0x30			;ASCII Conversion
	BL		ST7735_OutChar		;Fourth Number
	POP		{R0, R1}			
	B ENDFIXED
	
PastRange					;Value higher than 9999 in R0
	MOV 	R0, #Asterisk
	BL 		ST7735_OutChar
	MOV 	R0, #DecimalDot
	BL 		ST7735_OutChar
	MOV 	R0, #Asterisk
	BL 		ST7735_OutChar
	MOV 	R0, #Asterisk
	BL 		ST7735_OutChar
	MOV 	R0, #Asterisk
	BL 		ST7735_OutChar
	
ENDFIXED
	POP		{R1,R2,R3,PC}
     BX   LR
 
     ALIGN
;* * * * * * * * End of LCD_OutFix * * * * * * * *

Modulus 	

;	a%b = e			Unsigned
;	Input: 	R0 = a,	R1 = b
;	Output:	R0 = e

	PUSH	{R1,R2,R3,LR}
	UDIV	R2, R0, R1
	MUL		R3, R1, R2
	SUB		R0, R0, R3
	
	POP		{R1,R2,R3,PC}
	BX		LR
	
	

     ALIGN                           ; make sure the end of this section is aligned
     END                             ; end of file
