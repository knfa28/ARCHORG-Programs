DOSSEG
.MODEL SMALL
.STACK 100h
.DATA
	EnterString db "Enter String: $" 
	Palindrome db 0Ah, 0Dh, "Palindrome: $", 0Ah, 0Dh
	CharCount db 0Ah, 0Dh, "Character Count: $"
	WordCount db 0Ah, 0Dh, "Word Count: $"
	errwrongTerminal db 0Ah, 0Dh, "ERROR: invalid terminator, please try again. $"
	errnullinput db 0Ah, 0Dh, "ERROR: null input, please try again. $"
	errExceedlimit db 0Ah, 0Dh, "ERROR: exceed maximum number of characters, please try again.$"
	erryninput db 0Ah, 0Dh, "ERROR: Enter (Y\N) only please.$"
	contques db 0Ah, 0Dh, "Do you want to continue? (Y/N) $"
	wordCntNo dw 0
	input db 100 dup ('$')
	char db ?
	
.CODE
CLRSCRN PROC
	MOV AH, 00h
	MOV AL, 03h
	INT 10h
	RET
CLRSCRN ENDP

printNum proc 
	mov AX, BX 		;move value to AX
	mov CH, 00h 	;initialize CX to 0
	mov SI, 0Ah 	;initialize SI to 10
	
	cmp AX, 00h 	;if num is not 0
	jne parseInt	;go to loop
	
	mov AH, 02h 	;print 0 and return
	mov DL, 30h
	int  21h
	ret
	
	parseInt: 			;breaks number into digits and stores in stack
		xor DX, DX 		;clear DX
		div SI 			;divide AX by ten
		add DL, 30h 	;convert remainder to ASCII
		push DX 		;push remainder in stack
		inc CX 			;add one digit to counter
		cmp AX, 0000h 	;while AX != 0
		jne parseInt
		
	mov AH, 02h ;char out mode
	
	printDigit:
		pop DX ;pops out a digit and prints it
		int 21h 
	loop printDigit
	
	ret
printNum endp

CharCnt PROC
	XOR BX, BX
	XOR CX, CX
	MOV DI, 0001h
	MOV SI, 000Ah
	MOV BL, input[DI]
	DEC BX
	
	call printnum
	RET
CharCnt ENDP

Reverser proc
	MOV AH, 09h
	LEA DX, palindrome
	INT 21h
	XOR BX, BX
	XOR CX, CX
	MOV SI, 0001h ;SI points to strlen
	MOV BH, 00h ;clear upper byte of BH
	MOV CL, input[SI]
	DEC CX
	MOV BL, input[SI] ;store strlen in BL
	ADD SI, BX ;SI now contains index of last char
	
	CMP CX, 0
	JE immediateend
	MOV AH, 02h
	printing:
	DEC SI
	MOV DL, input[SI]
	INT 21h
	DEC CX
	JNZ printing
	immediateend:
	ret
Reverser ENDP

wordCnt PROC
	XOR BX, BX
	XOR CX, CX
	XOR AX, AX
	MOV wordCntNo, 0
	MOV DI, 0001h
	MOV SI, 0002h
	MOV CL, input[DI]
	DEC CX
	
	CMP CX, 0
	JE endit
	CMP input[SI], 20h
	JE countword
	INC wordCntNo
	countword:
	CMP input[SI], 20h
	JNE nextChar
	CMP input[SI + 1], 20h
	JE nextChar
	CMP input[SI + 1], '!'
	JE nextChar
	CMP input[SI + 1], '.'
	JE nextChar
	INC	wordCntNo
	
	nextChar:
	ADD SI, 0001h;next Char
	LOOP countword
	
	endit:
	MOV BX, wordCntNo
	CALL printnum
	ret
wordCnt ENDP

printNormal PROC
	MOV AH, 09h
	LEA DX, palindrome
	INT 21h
	;print input normally
	MOV DI, 0001h ;DI points to strlen
	MOV BH, 00h ;clear upper byte of BH
	MOV CL, input[DI]
	DEC CX
	MOV SI, 0002h
	
	CMP CX, 0
	JE stopthis
	normal:
	MOV AH, 02h
	MOV DL, input[SI]
	INC SI
	INT 21h
	loop normal
	stopthis:
	ret
printNormal ENDP

MainProg PROC
	;Print enterstring
	MOV AH, 09h
	LEA DX, EnterString
	INT 21h
	
	;get user input
	MOV AH, 0Ah
	MOV input, 100
	LEA DX, input
	INT 21h
	
	CMP input[DI], 0
	JE nullinput
	
	CMP input[DI], 80
	JG exceedlimit
	
	MOV DI, 0001h ;DI points to strlen
	MOV BH, 00h ;clear upper byte of BH
	MOV BL, input[DI] ;store strlen in BL
	ADD DI, BX ;DI now contains index of last char
	CMP input[DI], '!'
	JE printreverse
	CMP input[DI], '.'
	JNE WRONGTERMINAL
	
	;print palindrome
	CALL printnormal
	JMP toWord
	
	printreverse:
	;print palindrome
	CALL Reverser
	
	;print wordCount
	toWord:
	MOV AH, 09h
	LEA DX, wordCount
	INT 21h
	CALL wordcnt
	
	;print charCount
	toChar:
	MOV AH, 09h
	LEA DX, charCount
	INT 21h
	CALL CharCnt
	JMP endmain
	
	;print wrong terminal
	WRONGTERMINAL:
	MOV AH, 09h
	LEA DX, errwrongTerminal
	INT 21h
	JMP endmain
	
	;print nullinput
	NULLINPUT:
	MOV AH, 09h
	LEA DX, Errnullinput
	INT 21h
	JMP endmain
	
	;print exceedlimit
	exceedlimit:
	MOV AH, 09h
	LEA DX, errexceedlimit
	INT 21h
	JMP endmain
	endmain:
	ret
MainProg ENDP	

BEGIN:
	MOV AX, @data
	MOV DS, AX
	MOV SI, 0002h ;start of string
	MOV DI, 0001h ;length of input string
	
	CALL CLRSCRN
	
	CALL MAINPROG
	;print cont
	Cont:
	MOV AH, 09h
	LEA DX, contques
	INT 21h
	
	MOV AH, 01	
	INT 21h
	MOV char, AL
	
	CMP char, 'Y'
	JE BEGIN
	CMP char, 'y'
	JE BEGIN
	CMP char, 'n'
	JE stop
	CMP char, 'N'
	JE stop
	
	MOV AH, 09h
	LEA DX, erryninput
	INT 21H
	JMP Cont
	;exit routine
	stop:
	MOV AH, 4Ch
	INT 21h
END BEGIN