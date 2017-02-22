DOSSEG
.MODEL SMALL
.STACK 100h
.DATA
	UNAME db 24 DUP(24h)
	CURR db 8 DUP(24h)
	BIRTH db 8 DUP(24h)
	YEARC dw 0
	YEARB dw 0
	NAME_PROMPT db "Name: $"
	CURR_PROMPT db 0Ah,0Dh,"Current Year: $"
	BIRTH_PROMPT db 0Ah,0Dh,"Birth Year: $"
	HELLO db 0Ah,0Dh,0Ah,0Dh,"Hello, $"
	YOU_ARE db "!",20h,"You are $"
	YEARS db " years old right now.$"
	CONT_PROMPT db 0Ah,0Dh,0Ah,0Dh,"Do you want to Continue (Y/N)? $"
	NULL_NAME db 0Ah,0Dh,0Ah,0Dh,"Error: Name Input is Empty$"
	NULLC db 0Ah,0Dh,0Ah,0Dh,"Error: Current Year Input is Empty$"
	NULLB db 0Ah,0Dh,0Ah,0Dh,"Error: Birth Year Input is Empty$"
	CINV_ERR db 0Ah,0Dh,0Ah,0Dh,"Error: Current Year has Invalid Numerical Input$"
	BINV_ERR db 0Ah,0Dh,0Ah,0Dh,"Error: Birth Year has Invalid Numerical Input$"
	YEAR_ERR db 0Ah,0Dh,0Ah,0Dh,"Error: Current Year is less than Birth Year$"
	YN_ERR db 0AH,0Dh,0Ah,0Dh,"Error: Enter Y/N: $"
	CONT db ?
.CODE
CLRSCR PROC ;clears screen
	MOV AH, 00h
	MOV AL, 03h
	INT 10h
	RET
CLRSCR ENDP

PRINTNUM PROC ;prints a number stored in BX
	MOV AX, BX ;move value to AX
	XOR CX, CX ;initialize CX to 0
	MOV SI, 000Ah ;initialize SI to 10
	
	CMP AX, 0000h ;if num is not 0
	JNE BREAKING ;go to loop
	
	MOV AH, 02h ;print 0 and return
	MOV DL, 30h
	INT 21h
	RET
	
	BREAKING: ;breaks number into digits and stores in stack
		XOR DX, DX ;clear DX
		DIV SI ;divide AX by ten
		ADD DL, 30h ;convert remainder to ASCII
		PUSH DX ;push remainder in stack
		INC CX ;add one digit to counter
		CMP AX, 0000h ;while AX != 0
		JNE BREAKING
		
	MOV AH, 02h ;char out mode
	PRINTING:
		POP DX ;pops out a digit and prints it
		INT 21h 
	LOOP PRINTING
	RET
PRINTNUM ENDP

CENTRAL PROC ;main logic
	CALL CLRSCR ;clear screen
	
	MOV AH, 09h ;prints name prompt
	LEA DX, NAME_PROMPT
	INT 21h
	
	MOV byte ptr UNAME, 22 ;gets name
	MOV AH, 0Ah
	LEA DX, UNAME
	INT 21h
	
	MOV AH, 09h ;prints curr year prompt
	LEA DX, CURR_PROMPT
	INT 21h
	
	MOV byte ptr CURR, 5 ;gets current year
	MOV AH, 0Ah
	LEA DX, CURR
	INT 21h
	
	MOV AH, 09h ;prints birth year prompt
	LEA DX, BIRTH_PROMPT
	INT 21h
	
	MOV byte ptr BIRTH, 5 ;print birth year
	MOV AH, 0Ah
	LEA DX, BIRTH
	INT 21h
	
	MOV SI, 0001 ;checks if name is null
	MOV AL, UNAME[SI]
	CMP AL, 00h
	JNE CHECK2
	
	MOV AH, 09h ;prints null name error
	LEA DX, NULL_NAME
	INT 21h
	JMP YNCALL
	
	CHECK2:
		MOV AX, SI ;replaces carriage return with $
		ADD AL, UNAME[SI]
		MOV SI, AX
		INC SI
		MOV byte ptr UNAME[SI], 24h
		
		MOV SI, 0001 ;checks if curr year input is null
		MOV AL, CURR[SI]
		CMP AL, 00h
		JNE CHECK3
		
		MOV AH, 09h ;prints null curr year error
		LEA DX, NULLC
		INT 21h
		JMP YNCALL
		
	CHECK3: ;checks if curr year input is numeric
		INC SI
		CMP CURR[SI],0Dh
		JE CHECK4
		CMP CURR[SI],30h
		JB ERR1
		CMP CURR[SI], 39h
		JA ERR1
		JMP CHECK3
	ERR1: ;prints curr year is not numeric error
		MOV AH, 09h
		LEA DX, CINV_ERR
		INT 21h
		JMP YNCALL
	CHECK4: ;checks if birth year input is null
		MOV SI, 0001
		MOV AL, BIRTH[SI]
		CMP AL, 00h
		JNE CHECK5
		
		MOV AH, 09h ;prints null birth year error
		LEA DX, NULLB
		INT 21h
		JMP YNCALL
	CHECK5: ;checks if birth year input is numeric
		INC SI
		CMP BIRTH[SI],0Dh
		JE PROCEED
		CMP BIRTH[SI],30h
		JB ERR2
		CMP BIRTH[SI], 39h
		JA ERR2
		JMP CHECK5
	ERR2: ;prints birth year is not numeric error
		MOV AH, 09h
		LEA DX, BINV_ERR
		INT 21h
		JMP YNCALL
	PROCEED: ;does processing
		MOV AX, 0000h ;initializes accumulator
		MOV BL, 0Ah ;sets BL to 10 for binary conversion
		MOV SI, 0001h ;set SI to index before first char
		MOV CH, 00h ;clear upper byte of CX
		MOV CL, CURR[SI] ;initialize to length of current year
		
		CONV1: ;converts current year
			INC SI ;next char
			MUL BL ;multiply AX by 10
			SUB byte ptr CURR[SI], 30h ;convert ASCII to digit
			ADD AL, CURR[SI] ;add digit value to AL
			ADC AH, 00h ;add remaining to AH
		LOOP CONV1
		MOV YEARC, AX ;move to YEARC
		
		MOV AX, 0000h ;initializes accumulator
		MOV SI, 0001h ;set SI to index before first char
		MOV CH, 00h ;clear upper byte of CX
		MOV CL, BIRTH[SI] ;initialize to length of birth year
		
		CONV2:
			INC SI ;next char
			MUL BL ;multiply AX by 10
			SUB byte ptr BIRTH[SI], 30h ;convert ASCII to digit
			ADD AL, BIRTH[SI] ;add digit value to AL
			ADC AH, 00h ;add remaining to AH
		LOOP CONV2
	
		MOV YEARB, AX ;move to YEARB
		MOV DX, YEARB ;move to DX
		
		CMP DX, YEARC ;if birth year is <= current year, go to final printing
		JBE FINAL
		
	ERR3: ;prints curr year less than birth year error
		MOV AH, 09h
		LEA DX, YEAR_ERR
		INT 21h
		JMP YNCALL	
		
	FINAL: ;printing data
		SUB YEARC, DX ;subtracts current year by birth year
		MOV BX, YEARC ;move age to BX

		MOV AH, 09h ;print hello
		LEA DX, HELLO
		INT 21h
		
		MOV SI, 0002h ;print name
		LEA DX, UNAME[SI]
		INT 21h
		
		LEA DX, YOU_ARE ;print message
		INT 21h

		CALL PRINTNUM ;print age
		
		MOV AH, 09h ;print last part of message
		LEA DX, YEARS
		INT 21h
	
	YNCALL:
		CALL GETYN ;ask user if they wish to continue
	RET
CENTRAL ENDP

GETYN PROC ;gets a char from user and ensures it is Y or N
	MOV AH, 09H ;display prompt
	LEA DX, CONT_PROMPT
	INT 21h

	GETCHAR:
		MOV AH, 01h ;get a character
		INT 21h
		MOV CONT, AL
		
		CMP CONT, 59h ;if input is 'Y'
		JE GOTCHAR ;check input
		
		CMP CONT, 79h ;if input is 'y'
		JE GOTCHAR ;check input
		
		CMP CONT, 4Eh ;if input is 'N'
		JE GOTCHAR ;check input
		
		CMP CONT, 6Eh ;if input is 'n'
		JE GOTCHAR ;check input
		
		MOV AH, 09h ;display error
		LEA DX, YN_ERR
		INT 21h
		
		JMP GETCHAR ;get another char
		
		GOTCHAR:
		RET
GETYN ENDP

BEGIN:
	MOV AX, @data ;initialize DS and ES
	MOV DS, AX
	MOV ES, AX
		
	START:
		CALL CENTRAL ;call main logic
		
	CHECKYN:	
		CMP CONT, 59h ;if input is 'Y'
		JE START ;jump to end
		CMP CONT, 79h ;if input is 'y'
		JE START ;jump to end
	
	CALL CLRSCR ;clear screen	
	
	MOV AH,	4Ch
	INT 21h
END BEGIN