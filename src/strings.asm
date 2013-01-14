;+----------------------------------------------------------------------------+
;| Copyright (C) 2007  The DoOrS Team                                         |
;|                                                                            |
;| This program is free software; you can redistribute it and/or modify       |
;| it under the terms of the GNU General Public License as published by       |
;| the Free Software Foundation; either version 2 of the License, or          |
;| (at your option) any later version.                                        |
;+----------------------------------------------------------------------------+
;| This program is distributed in the hope that it will be useful,            |
;| but WITHOUT ANY WARRANTY; without even the implied warranty of             |
;| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              |
;| GNU General Public License for more details.                               |
;+----------------------------------------------------------------------------|
;| You should have received a copy of the GNU General Public License          |
;| along with this program; if not, write to the Free Software                |
;| Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA. |
;+----------------------------------------------------------------------------+

; strings.asm
; ‘ункции работы со строками стандартной библиотеки
;
; Copyright (c) 2007 Vadim Ipatov, Peter Barmin

; email: Peter Barmin <pet_gog@mail.ru>
; email: Vadim Ipatov <euphoria.vi@gmail.com>

%ifndef STRINGS_H
%define STRINGS_H


; ---------------------------------------------- ; 
chislovstr :		;  перевод числа в строку 		
 pusha
 
MOV AX,[ZNACHENIE]
 MOV BX,0FFFFH  
 
 XOR CX,CX
 MOV CL,10
 CMP AX,CX 
 JAE @LOOP5
 INC BX
 MOV [CHISLO+BX],AL   
 MOV [LEN_CHISLO],BL
 JMP @M13

@LOOP5:
 INC BX
 XOR DX,DX
 MOV CL,10
 DIV CX
 XOR CX,CX
 MOV CL,10
 CMP AX,CX
 JAE @M10
 JMP @M11
@M10:
 
 MOV [CHISLO+BX],DL
 JMP @LOOP5
@M11: 
MOV [CHISLO+BX],DL
 INC BX
 MOV [CHISLO+BX],AL
 MOV [LEN_CHISLO],BL

@M13:

 popa
 ret
	

vivodchisla:  ; вывод строки с конца
 XOR BX,BX
 MOV BL,[LEN_CHISLO]
 INC BX
@LOOP6:
 
 DEC BX
 
 MOV AH,02H
 MOV DL, [CHISLO+BX]
 CMP DL,0AH
 JAE @M14
 ADD DL,30H
 JMP @M15
@M14:
 ADD DL, 37H
@M15:
 INT 21H 
 
 CMP BX,0H
 JE @M12 
 JMP @LOOP6
@M12:

 RET

 
; /------------------------------------------------------------------------------------//
write_ch_n: 
 push si 
 push bx

 mov bx,dx
 sub bx,1
@m16:
 push ax
 mov al,[bx+si]
 mov [ZNACHENIE],al
 pop ax
 
 push bx
 push dx
 call chislovstr 
 call vivodchisla
 pop dx
 pop bx
 dec bx
 cmp bx,0
 jb @m16
 
 pop bx
 pop si
 ret

; /------------------------------------------------------------------------------------//
strcmp:					; -----------> —равненить две строки
	push	ax			; SI = указатель на первую строку
	push	bx			; DI = указатель на вторую строку
	push	si			; Ќа выходе: CF установлен, если строки одинаковые	
	push	di
.more:	
	mov 	ax,[si]
	mov 	bx,[di]

	cmp 	byte [si],'$'		;  онец первой строки?
	je 	.terminated

	cmp 	ax,bx
	jne 	.not_same

	inc 	si
	inc 	di
	jmp 	.more

.not_same:
	pop	di
	pop	si
	pop	bx
	pop	ax
	clc				; Ќе одинаковые
	ret

.terminated:
	cmp 	byte [di],'$'		;  онец второй строки?
	jne 	.not_same
	
	pop	di
	pop	si
	pop	bx
	pop	ax
	stc				; ќдинаковые
	ret
	
; ---------------------------------------------- ; 	

strlen:					; -----------> ¬ычислить длину строки
	push	si			; si = указатель на строку
					; на выходе: cx = длина
	xor	cx,cx

.more:
	cmp 	byte [si],'$'
	je 	.done
	inc 	si
	inc 	cx
	jmp 	.more

.done:
	pop	si
	
	ret

; ---------------------------------------------- ;

strupcase:				; -----------> ѕривести строку к верхнему регистру
	push	si			; si = указатель на строку

.more:
	cmp 	byte [si],'$'
	je 	.done

	cmp 	byte [si],'a'
	jl 	.noatoz
	cmp 	byte [si],'z'
	jg 	.noatoz

	sub 	byte [si],0x20

	inc 	si
	jmp 	.more

.noatoz:
	inc 	si
	jmp 	.more

.done:
	pop	si
	
	ret
	
; ---------------------------------------------- ;

strlocase:				; -----------> ѕривести строку к нижнему регистру
	push	si			; si = указатель на строку

.more:
	cmp 	byte [si],'$'
	je 	.done

	cmp 	byte [si],'A'
	jl 	.noatoz
	cmp 	byte [si],'Z'
	jg 	.noatoz

	add 	byte [si],0x20

	inc 	si
	jmp 	.more

.noatoz:
	inc 	si
	jmp 	.more

.done:
	pop	si
	
	ret	
	
; ---------------------------------------------- ;	
	
strcpy:				; ----------->  опировать одну строку в другую
	push 	si		; si = указатель на строку-источник
	push	di		; di - указатель на строку-приемник
	push	ax		; cl = количество символов (если 0 или 0xFF, тогда до конца строки)
	push	cx

	xor	ch,ch
	cmp	cl,0
	jne	.more
	
	mov	cl,0xFF
.more:
	cmp 	byte [si],'$'
	je 	.done
	cmp	cl,ch
	je	.done2
	mov 	ax,word [si]
	mov 	word [di],ax
	inc 	si
	inc 	di
	inc	ch
	jmp 	.more

.done:
	mov 	byte [di],'$'
	
.done2:
	pop	cx
	pop	ax
	pop	di
	pop	si
	
	ret		

; ---------------------------------------------- ;

strcat:					; -----------> —клеить две строки в третью
	push	si			; ax = указатель на первую строку
	push	di			; bx = указатель на вторую строку
	push	cx			; cx = указатель на третью строку
	
	mov 	si,ax
	mov 	di,cx
	call 	strcpy
	call 	strlen
	add	di,cx
	mov 	si,bx
	call 	strcpy

	pop	cx
	pop	di
	pop	si
	
	ret

; ---------------------------------------------- ;

strstrip:				; -----------> ”далить пробелы в конце
	push	cx			; si = указатель на строку
	push	si
	
	call 	strlen
	add 	si,cx
.more:
	dec 	si
	cmp 	byte [si],' '
	jne 	.done
	mov 	byte [si],'$'
	jmp 	.more

.done:
	pop	si
	pop	cx
	
	ret
	
; ---------------------------------------------- ;	

 CHISLO db 20 
 times 20 db '$'
 ZNACHENIE db 0  
 LEN_CHISLO db 0
 
%endif