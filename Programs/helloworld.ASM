DOSSEG
.MODEL SMALL
.STACK 100h
message db "hello world$"
.CODE
BEGIN:

mov ah,09h
mov dx, offset message
int 21h

mov, 4ch
mov al,00
int 21h


END BEGIN