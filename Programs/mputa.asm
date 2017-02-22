DOSSEG
.MODEL SMALL
.STACK 100h
.DATA

	askme db "Enter a string: $"
	palindrome db 0Ah, 0Dh, "Palindrome: $"
	charcount db 0Ah, 0Dh, "Count: $"
	input db 100 dup ('$')
	pali db 80 dup ('$')
	wrd db 0Ah,0Dh,"Word: $"
	err1 db 0Ah,0Dh,0Ah,0Dh,"Error: null input, please try again$"
	err2 db 0Ah,0Dh,0Ah,0Dh,"Error: exceed maximum number of characters, please try again$"
	err3 db 0Ah,0Dh,0Ah,0Dh,"Error: Enter Y/N: $"
	err4 db 0Ah,0Dh,0Ah,0Dh,"Error: Wrong character terminator$" 
	cont_prompt db 0Ah,0Dh,0Ah,0Dh,"Do you still want to continue? [Y/N]$"
	chcnt dw 0
	wrdcnt dw 0
	still db ?
	
.CODE

NUMPRINTF PROC ;prints a number stored in BX
	MOV AX, BX ;move value to AX
	MOV CH, 00h ;initialize CX to 0
	MOV SI, 0Ah ;initialize SI to 10
	
	CMP AX, 00h ;if num is not 0
	JNE PARSEINT ;go to loop
	
	MOV AH, 02h ;print 0 and return
	MOV DL, 30h
	INT 21h
	RET
	
	PARSEINT: ;breaks number into digits and stores in stack
		XOR DX, DX ;clear DX
		DIV SI ;divide AX by ten
		ADD DL, 30h ;convert remainder to ASCII
		PUSH DX ;push remainder in stack
		INC CX ;add one digit to counter
		CMP AX, 0000h ;while AX != 0
		JNE PARSEINT
		
	MOV AH, 02h ;char out mode
	PRINTME:
		POP DX ;pops out a digit and prints it
		INT 21h 
	LOOP PRINTME
	RET
NUMPRINTF ENDP

CHARCNT PROC

	mov bh, 00h
	mov bl, input[0001]
	DEC BX
	call NUMPRINTF
	
	RET
CHARCNT ENDP

WORDCNT PROC
	MOV SI, 0002h ;move SI to first char
	MOV DI, 0001h ;move DI to strlen
	MOV CH, 00h ;clear upper byte of CX
	MOV CL, input[DI] ;load char count into CX
	MOV AX, 01h

	CWLOOP:
		CMP input[SI], 20h
		JE INCWRD
		
		;CMP input[SI], 20h
		JMP INCREMENT
		
		;CMP input[SI], 20h
		;JMP INCWRD
		
		INCWRD: INC AX
		INCREMENT: INC SI
	LOOP CWLOOP
	
	MOV BX, AX ; puts the number of spaces in BX
	
	CALL NUMPRINTF
	
	RET
WORDCNT ENDP
	

PRINTF PROC
	MOV AH, 09h
	INT 21h
	RET
PRINTF ENDP

YNPROMPT PROC ;gets a char from user and ensures it is Y or N
		
	LEA DX, cont_prompt
	call PRINTF

	GETCHAR:
		MOV AH, 01h ;get a character
		INT 21h
		MOV still, AL
		
		CMP still, 59h ;if input is 'Y'
		JE GOTCHAR ;check input
		
		CMP still, 79h ;if input is 'y'
		JE GOTCHAR ;check input
		
		CMP still, 4Eh ;if input is 'N'
		JE GOTCHAR ;check input
		
		CMP still, 6Eh ;if input is 'n'
		JE GOTCHAR ;check input
			
		LEA DX, err3
		call PRINTF	
		
		JMP GETCHAR ;get another char
		
		GOTCHAR:
		RET
YNPROMPT ENDP

MAIN_PROG PROC
	
	;clears the screen
	mov ax, 03h
	int 10h
	
	;prompts the user to input a string
	LEA DX, askme
	CALL PRINTF
	
	;scans for user input
	mov ah, 0Ah
	mov input, 100
	lea dx, input
	int 21h
	
	MOV SI, 0001 ;checks if name is null
	MOV AL, input[SI]
	CMP AL, 00h
	JNE CHECKEXCEED ;jump to exceed plz
	
	LEA DX, err1
	CALL PRINTF
	JMP FINISH
	
	CHECKEXCEED:
	MOV DI, 0001h ;strlen
	MOV CH, 00h ;clear upper byte of CX
	MOV CL, input[DI] ;load char count into CX
	MOV chcnt, CX ;put charcount into 'count'
	MOV DI, chcnt ; charcount to DI to be used in the loop
	
	CMP chcnt, 80
	JB PROCESS
	
	LEA DX, err2
	CALL PRINTF
	JMP FINISH
	
	PROCESS:
	MOV SI, 0001h ; strlen
	MOV BH, 00h ;clear upper byte of BH
	MOV BL, input[SI] ;store strlen in BL
	ADD SI, BX ;SI now contains index of last char
	
	CMP input[SI], '.'
	JE NORMAL
	
	CMP input[SI], '!'
	JE PALIN
	
	LEA DX, err4
	CALL PRINTF
	JMP FINISH
	
	NORMAL:
	MOV input[SI], '$'
	
	;displays the user input
	LEA DX, palindrome
	CALL PRINTF
	
	LEA DX, input[0002h]
	CALL PRINTF
	
	LEA DX, wrd
	CALL PRINTF
	CALL WORDCNT
	
	;displays the char count
	lea dx, charcount
	CALL PRINTF
		
	CALL CHARCNT ; count char and print
	
	JMP FINISH ;jump to finish
	
	PALIN:
	MOV SI, 0002h ;move SI to first char
	MOV DI, 0001h ;move DI to strlen
	MOV CH, 00h ;clear upper byte of CX
	MOV CL, input[DI] ;load char count into CX
	MOV chcnt, CX ;put charcount into 'count'
	MOV DI, chcnt ; charcount to DI to be used in the loop
		
	PALILOOP:
		MOV AL, input[SI]
		MOV pali[DI], AL
		INC SI
		DEC DI
	LOOP PALILOOP
	
	;PRINTING TIME!!!!! :)
	
	LEA DX, palindrome
	CALL PRINTF
	
	;print palindrome
	MOV SI, 0002h
	LEA DX, pali[SI]
	CALL PRINTF
	
	LEA DX, wrd
	CALL PRINTF
	CALL WORDCNT
	
	LEA DX, charcount
	CALL PRINTF
	
	CALL CHARCNT
		
	FINISH:
	CALL YNPROMPT
	
	RET
MAIN_PROG ENDP
	
BEGIN:
	mov ax, @data
	mov ds, ax
	
	START:
		CALL MAIN_PROG
		
	CHECKYN:	
		CMP still, 59h ;if input is 'Y'
		JE START ;jump to end
		CMP still, 79h ;if input is 'y'
		JE START ;jump to end
    
	;return to dos
	mov ah, 4Ch
	int 21h
		
END BEGIN	