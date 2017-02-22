;*******************************************************************************
TITLE Hex String Insertion
;Created By: Austin Fernandez
;Last Edited on: October 8, 2014
;
;This program inserts D of the hexadecimal system 
;
;(D = { '0', '1', ..., 'E', 'F' };
;
;iteratively in between characters in an input string.
;
;sample input: ABCDEFH
;sample output: A1B2C3D4E5F6H7
;*******************************************************************************

DOSSEG
.MODEL SMALL
.STACK 100h
.DATA
	PROMPT db "Enter String: $"
	RESULT db 0Ah,0Dh,"Output: $"
	PAUSE_MSG db 0AH, 0Dh,"Press Any Key to Continue...$"
	INPUT db 164 DUP(24h) ;size is double the max length (80-chars max) + 4
	
.CODE

BEGIN:
	;initialize DS
	MOV AX, @data
	MOV DS, AX
	
	;clear screen
	MOV AX, 0003h
	INT 10h
	
	;display prompt
	LEA DX, PROMPT
	MOV AH, 09h
	INT 21h
	
	MOV byte ptr INPUT, 81 ;initialize input string length to 80
	
	;gets input
	LEA DX, INPUT
	MOV AH, 0Ah
	INT 21h
	
	MOV SI, 0001h ;goes to index of actual length
	MOV CH, 00h ;clears upper byte of counter
	MOV CL, INPUT[SI] ;puts string length in CX
	MOV DI, CX ;stores string length in DI
	ADD DI, 0002h ;shifts DI to index of carriage return
	INC SI ;shifts SI to first char's index
	
	;shifts n-char input n indices to the right
	SHIFT:
		MOV AL, INPUT[SI] ;store byte at source in AL
		MOV INPUT[DI], AL ;move it to desitination
		INC SI ;increment both indices
		INC DI
	LOOP SHIFT ;loop for entire length of string
	
	MOV DI, 0001h ;goes to index of actual length
	MOV CH, 00h ;clears upper byte of counter
	MOV CL, INPUT[DI] ;puts string length in CX
	MOV SI, CX ;stores string length in SI
	ADD SI, 0002h ;SI now points to first char of copy
	INC DI ;DI now points to first char index
	MOV BL, 30h ;move '0' to BL
	
	;generates the altered string
	GENSTRING:
		MOV AL, INPUT[SI] ;move source char to AL
		MOV INPUT[DI], AL ;move to destination
		INC DI ;go to next index
		MOV INPUT[DI], BL ;move BL
		INC SI ;increment indices and BL
		INC DI
		INC BL
		
		CMP BL, 3Ah ;if BL is past '9'
		JE UP ;go to 'A'
		JMP NXTCHK ;check next
		
		;converts BL to 'A'
		UP: 
			MOV BL, 41h
		NXTCHK:
			CMP BL, 47h ;if BL is not past 'F'
			JL NXT ;go to next iteration
			MOV BL, 30h ;converts BL to '0'
		NXT:
	LOOP GENSTRING
	
	;displays result message
	MOV AH, 09h
	LEA DX, RESULT
	INT 21h
	
	;displays result
	MOV SI, 0002h
	LEA DX, INPUT[SI]
	INT 21h
	
	;displays pause prompt
	LEA DX, PAUSE_MSG
	INT 21h
	
	;gets a character
	MOV AH, 07h
	INT 21h
	
	;clears screen
	MOV AX, 0003h
	INT 10h
	
	;exit routine
	MOV AH, 4Ch
	INT 21h
END BEGIN