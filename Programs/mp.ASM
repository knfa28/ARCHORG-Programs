DOSSEG
.MODEL SMALL
.STACK 100h
.DATA
	continueString db "do you want to try again? <y/n>"
	commandString db "Enter string: $" 
	userInput db 84 dup("$"); maximum of 80 characters in the string 
	newline	db 0dh, 0ah, "$"
	testString db "tester$"
	null_input db "Error: Null input $"
	charCnt dw 0
	errorInvalid db "Invalid input!$"
	reversed db 82 dup('$')
	continue db ?
.CODE
clearscreen macro

	mov ah, 00h
	mov al, 03h
	int 10h

endm
palindrome macro string
			
		mov di, 0001h ;index of the length of string
		mov si, 0002h ;index of start of string
		xor cx,cx
		mov cl, string[di] ;cx now contains the length of the string
		mov charCnt, cx ;charCnt now contains length of string
		mov di,charCnt ; di contains length of string

		palindromeLoop:

			mov al,string[si] ;reverse 
			mov reversed[di],al
			inc si
			dec di

		loop palindromeLoop

		xor bx,bx
		mov si,0001h
		mov bl,reversed[si]
		add si,bx
		inc si
		mov reversed[si],'$'

		printString reversed[0002h]
	endm

	normal macro string

		mov si, 0001h
		xor bx,bx
		mov bl, string[si]
		add si,bx

		mov string[si],'$'
		printString string[0002h]
			
	endm

	;function to print a variable
	printString macro string
		mov ah, 09h
		lea dx, string
		int 21h
	endm

	;function to scan a string
	scanString macro input 
		mov byte ptr input,81
		lea dx, input
		mov ah,0Ah
		int 21h
	endm

	printChar macro char
		mov ah,02h
		lea dx, char 
		int 21h
	endm

	printDxStack macro
		mov ah, 02h ; we are now printing a character
		printLoop:

			pop dx
			int 21h

		loop printLoop

	endm


	printNumBx macro

		mov ax,bx
		xor cx,cx ;makes value of cx 0
		mov si, 000Ah ;si is 10!

		cmp ax, 0000h 
		jne breakdown ;if zero then its an invalid input

		printString null_input
		jmp endbreakdown

		breakdown:
		
			xor dx,dx ;make sure dx contains nothing or 0
			div si ; div results in AX so its whatever in AX divided by si which si 10
			add dl,30h ;gets number as ascii
			push dx ;pushes the number (currently in ascii)
			inc cx ; will be used to know how many decimal places the number has.
			cmp ax, 0000h ; while the number in ax is not 0 meaning that it still has something to breakdown
			jne breakdown ; jne means != to the above breakdown again

		printDxStack

		endbreakdown:
	endm

	printLength macro input

		xor bx,bx ;set 0
		mov si,0001h
		mov bl,input[si]
		dec bx
		printNumBx

	endm

	printNumWords macro sentence

		mov di, 0001h ; di now points to length
		mov si, 0002h ; si points to start of string
		xor cx,cx
		mov cl, sentence[di]
		mov ax, 01h ;ask later

		startCnt:

			cmp sentence[si],20h
			je addWordCnt
			jmp nextLetter
			addWordCnt:
				inc ax ;it had encountered a space so its 1 word
			nextLetter:
				inc si

		loop startCnt

		mov bx,ax ;moves number of words to bx

		printNumBx


	endm

	restart proc
		
		printString continueString

		getChar:
			mov ah, 01h 
			int 21h
			mov continue, al
		
			cmp continue, 59h 	
			je done 			
			
			cmp continue, 79h 	
			je done 			
		
			cmp continue, 4Eh 	
			je done 			
			
			cmp continue, 6Eh 	
			je done 			
		
		
			printString errorInvalid
		
		jmp getChar ;gets another char
		
		done:
			 ret
	restart endp

	run macro

	printString commandString
	scanString userInput
	printString newline
		mov si, 0001h
		xor bx,bx
		mov bl,userInput[si]
		add si,bx
		cmp userInput[si],'!'
		je reverse
		cmp userInput[si],'.'
		je same
		reverse:
			palindrome userInput
			jmp finished
		same:
			normal userInput
	finished:
		printString newline
		printNumWords userInput
		printString newline

		call restart

	endm
	
BEGIN:
	;so we can use the things in data
	MOV ax, @data 
	MOV ds,ax
	
	again:
		run
		cmp continue, 59h  	
		je again      	
		cmp continue, 79h  	
		je again
		    	

	;end of code
	mov ah, 4ch
	int 21h
END BEGIN