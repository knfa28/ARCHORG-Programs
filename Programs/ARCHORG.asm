dosseg
.model small
.stack 100h
.data
	
	;display prompts
	inputPrompt db "Enter string: $"
	palDisplay db 0Ah, 0Dh, "Palindrome: $"
	wordDisplay db 0Ah,0Dh,"Word: $"
	charDisplay db 0Ah, 0Dh, "Count: $"
	continuePrompt db 0Ah,0Dh,0Ah,0Dh,"Do you still want to continue? [Y/N] $"
	
	;string addresses
	input db 100 dup('$')
	palindrome db 84 dup('$')
	
	;error prompts
	nullError db 0Ah,0Dh,0Ah,0Dh,"Error: null input, please try again$"
	maxError db 0Ah,0Dh,0Ah,0Dh,"Error: exceed maximum number of characters, please try again$"
	terminatorError db 0Ah,0Dh,0Ah,0Dh,"Error: invalid terminator, please try again$"
	ynError db 0Ah,0Dh,0Ah,0Dh,"Error: Enter Y/N: $"
	
	;integer storage
	charCount dw 0
	wordCount dw 0
	
	;character storage
	continue db ?
	
.code

;clears screen
clearScreen proc
	mov AH, 00h
	mov AL, 03h
	int 10h
	ret
clearScreen endp

;prints a String
printString proc
	mov AH, 09h
	int 21h
	ret
printString endp

;prints an integer stored in bx
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

;counts the number of words in a String
countWord proc
	mov SI, 0002h     ;move SI to first char
	mov DI, 0001h     ;move DI to strlen
	mov CH, 00h       ;clear upper byte of CX
	mov CL, input[DI] ;load char count into CX
	mov AX, 01h

	wordLoop:
		;checks if the scanned char is a space
		cmp input[SI], 20h
		je nextSpace
		
		jmp nextChar
		
		nextSpace:
			cmp input[SI + 1], 20h
			jne addWord
			jmp nextChar
		
	addWord: inc AX
	nextChar:inc SI
	loop wordLoop
	
	mov BX, AX ; puts the number of spaces in BX
	call printNum
	
	ret
countWord endp

;counts the number of characters in a String
countChar proc
	mov bh, 00h
	mov bl, input[0001]
	dec BX
	call printNum
	ret
countChar endp

;gets a char from user and ensures it is Y or N
checkYN proc
		
	LEA DX, continuePrompt
	call printString

	getChar:
		mov AH, 01h ;get a character
		int 21h
		mov continue, AL
		
		cmp continue, 59h 	;if input is 'Y'
		je done 			;check input
		
		cmp continue, 79h 	;if input is 'y'
		je done 			;check input
		
		cmp continue, 4Eh 	;if input is 'N'
		je done 			;check input
		
		cmp continue, 6Eh 	;if input is 'n'
		je done 			;check input
		
		;displays error message
		lea DX, ynError
		call printString	
		
		jmp getChar ;gets another char
		
		done: ret
checkYN endp

;prints input String as is
printNormal proc
	mov input[SI], '$'
		
	;prints the user input
	lea DX, palDisplay
	call printString	
	lea DX, input[0002h]
	call printString
	
	;prints the word count
	lea DX, wordDisplay
	call printString
	call countWord
		
	;prints the char count
	lea dx, charDisplay
	call printString
	call countChar
 	
	jmp final
	ret
printNormal endp

;prints input String as a palindrome
printPalindrome proc
	mov SI, 0002h 		;move SI to first char
	mov DI, 0001h 		;move DI to strlen
	mov CH, 00h 		;clear upper byte of CX
	mov CL, input[DI] 	;load char count into CX
	mov charCount, CX 	;put charcount into 'count'
	mov DI, charCount 	;charcount to DI to be used in the loop
		
	toPalindrome:
		mov AL, input[SI]
		mov palindrome[DI], AL
		inc SI
		dec DI
	loop toPalindrome
	
	;prints the palindrome
	lea DX, palDisplay
	call printString
	mov SI, 0002h
	lea DX, palindrome[SI]
	call printString
	
	;prints the word count
	lea DX, wordDisplay
	call printString
	call countWord
	
	;prints the char count
	lea DX, charDisplay
	call printString
	call countChar
	
	jmp final
	ret
printPalindrome endp

;checks the terminator being used
checkTerminator proc
	mov SI, 0001h 		;strlen
	mov BH, 00h 		;clear upper byte of BH
	mov BL, input[SI] 	;store strlen in BL
	add SI, BX 			;SI now contains index of last char
	
	;if (.), print String as is
	cmp input[SI], '.'
	je printNormal
	
	;if (!), print String as a palindrome
	cmp input[SI], '!'
	je printPalindrome
	
	;otherwise, display error message
	lea DX, terminatorError
	call printString
	
	jmp final
	ret
checkTerminator endp

;checks if the String exceeds 80 char
checkExceed proc
	mov DI, 0001h 		;strlen
	mov CH, 00h 		;clear upper byte of CX
	mov CL, input[DI] 	;load char count into CX
	mov charCount, CX 	;put charcount into 'count'
	mov DI, charCount 	;charcount to DI to be used in the loop
	
	;if String is below 80 char, check the terminator
	cmp charCount, 80
	jb checkTerminator
	
	;otherwise, display error message
	lea DX, maxError
	call printString
	
	jmp final
	ret
checkExceed endp

main proc
	call clearScreen
	
	;prompts the user to input a string
	lea DX, inputPrompt
	call printString
	
	;scans for user input
	mov ah, 0Ah
	mov input, 100
	lea dx, input
	int 21h
	
	;checks if input is null
	mov SI, 0001 
	mov AL, input[SI]
	cmp AL, 00h
	jmp checkExceed ;checks if the String exceeds 80 char
	
	;loop call
	final:
		call checkYN
	
	ret
main endp

begin:
	mov ax, @data
	mov ds, ax
	
	start:
		call main
		
	again:	
		cmp continue, 59h  	;if input is 'Y'
		je start        	;jump to start
		cmp continue, 79h  	;if input is 'y'
		je start        	;jump to start
    
	;return to dos
	mov ah, 4Ch
	int 21h		
end begin