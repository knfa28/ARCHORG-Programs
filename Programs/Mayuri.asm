DOSSEG
.MODEL SMALL
.STACK 100h
.DATA
	prompt db "Enter your name: $" ;input prompt
	
	;censorec ASCII values
	response db 0Ah,0Dh,54h,75h,54h,75h,52h,75h,7Eh,2Ch,20h,24h
	input db 83 ;user input
.CODE
BEGIN:
	;initialize DS
	MOV AX, @data
	MOV DS, AX
	
	;display prompt
	MOV AH, 09h
	LEA DX, prompt
	INT 21h
	
	;get user input
	MOV AH, 0Ah
	MOV input, 81
	LEA DX, input
	INT 21h
	
	MOV SI, 0002h ;move SI to first char
	MOV DI, 0001h ;move DI to strlen
	MOV CH, 00h ;clear upper byte of CX
	MOV CL, input[DI] ;load char count into CS
	
	;capitalizes string
	STRMAN:
		TEST SI,0001h ;checks LSB
		JPE CAP ;if even index
		JMP LOWE
		
		CAP:
			CMP input[SI],61h ;compares with lowercase 'a'
			JL NXT 
			;if greater than equal to
			CMP input[SI], 7AH ;compares with lowercase 'z'
			JG  NXT
			SUB input[SI], 20h ;if lowercase, subtracts value to make it uppercase
			JMP NXT
		LOWE:
			CMP input[SI],41h ;compares with uppercase 'a'
			JL NXT
			;if greater than equal to
			CMP input[SI], 5AH ;compares with uppercase 'z'
			JG  NXT
			ADD input[SI], 20h ;if uppercase, adds value to make it uppercase
		NXT: INC SI ;goes to next char
	LOOP STRMAN ;loop for entire string
	
	MOV SI, 0001h ;SI points to strlen
	MOV BH, 00h ;clear upper byte of BH
	MOV BL, input[SI] ;store strlen in BL
	ADD SI, BX ;SI now contains index of last char
	INC SI ;SI now contains index of \r
	MOV input[SI], '!' ;makes \r into an exclamation point
	INC SI ;next index
	MOV input[SI], '$' ;adds terminating character
	
	;displays response
	MOV AH, 09h
	LEA DX, response
	INT 21h
	
	;display capitalizes user input
	MOV AH, 09h
	MOV SI, 0002h
	LEA DX, input[SI]
	INT 21h
	
	;exit routine
	MOV AH, 4Ch
	INT 21h
END BEGIN