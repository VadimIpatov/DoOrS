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

; intr21.asm
; Эмуляция 21h прерывания DOS
;
; Copyright (c) 2007 Vadim Ipatov
;
; email: Vadim Ipatov <euphoria.vi@gmail.com>

%ifndef INTR21_H
%define INTR21_H

; ---------------------------------------------- ;

__intr21h:
	cmp	ah,0x00
	je	.f0
	jmp	short .nf0
.f0:
	jmp	_i21_f4Ch
.nf0:
	cmp	ah,0x01
	je	.f1
	jmp	short .nf1
.f1:
	jmp	_i21_f01h
.nf1:
	cmp	ah,0x02
	je	.f2
	jmp	short .nf2
.f2:
	jmp	_i21_f02h
.nf2:
	cmp	ah,0x08
	je	.f8
	jmp	short .nf8
.f8:
	jmp	_i21_f08h
.nf8:
	cmp	ah,0x09
	je	.f9
	jmp	short .nf9
.f9:
	jmp	_i21_f09h
.nf9:
	cmp	ah,0x0A
	je	.fA
	jmp	short .nfA
.fA:
	jmp	_i21_f0Ah
.nfA:
	cmp	ah,0x18
	je	.f18
	jmp	short .nf18
.f18:
	jmp	_i21_f18h
.nf18:	
	cmp	ah,0x25
	je	.f25
	jmp	short .nf25
.f25:
	jmp	_i21_f25h
.nf25:
	cmp	ah,0x30
	je	.f30
	jmp	short .nf30
.f30:
	jmp	_i21_f30h
.nf30:
	cmp	ah,0x35
	je	.f35
	jmp	short .nf35
.f35:
	jmp	_i21_f35h
.nf35:
	cmp	ah,0x39
	je	.f39
	cmp	ah,0x3A
	je	.f39	
	cmp	ah,0x3B
	je	.f39	
	cmp	ah,0x3C
	je	.f39	
	cmp	ah,0x3D
	je	.f39	
	cmp	ah,0x3E
	je	.f39	
	cmp	ah,0x41
	je	.f39	
	jmp	short .nf39
.f39:
	jmp	_i21_f39__41h
.nf39:
	cmp	ah,0x4C
	je	.f4C
	jmp	short .nf4C
.f4C:
	jmp	_i21_f4Ch
.nf4C:

	iret
	
; ---------------------------------------------- ;

_i21_f01h:				; -----------> Ввод с клавиатуры 
	mov	ah,0x00			; На выходе: al = символ
	int	keyb
	
	cmp	al,ASCII_CR
	je	noecho
	cmp	al,ASCII_BS
	je	noecho
	
echo:
	mov	dl,al			;
	mov	ah,0x02			; Эхо
	int	0x21			;
	
noecho:
	iret
	
; ---------------------------------------------- ; 
	
_i21_f02h:				; -----------> Вывод на дисплей
	push	ax			; dl = символ
	push	bx
	push	cx	
		
	mov	ah,0x09
	mov	bl,[cs:TXTCOLOR]
	xor	bh,bh
	mov	cx,1
	mov	al,dl
	int	vid
	
	getcursor			;
	inc	dl			; Сдвинем курсор на одну позицию вправо
	setcursor dl,dh			;
	
	pop	cx
	pop	bx
	pop	ax

	iret
	
; ---------------------------------------------- ; 
	
_i21_f08h:				; -----------> Ввод с клавиатуры без эха
					; На выходе: al = символ
	mov	ah,0x00
	int	keyb

	iret
	
; ---------------------------------------------- ; 
	
_i21_f09h:				; -----------> Выдать строку на дисплей
	pusha				; ds:dx = адрес строки, заканчивающейся символом '$'

	mov	bp,dx
	push	bp
	mov	al,'$'
	
find_term:				; Найдём символ конца строки
	cmp	[bp],al
	je	start_write
	inc	bp
	jmp	short find_term
	
start_write:
	mov	cx,bp	
	pop	bp
	sub	cx,bp
	push	cx			; cx = длина буфера для вывода
	
	xor	bh,bh   		;
	mov	ah,0x03 		; Получим текущую позицию курсора в dh;dl
	int	vid			;
	
	pop	cx

	mov	bl,[cs:TXTCOLOR]	; bh = номер видеостраницы (0), bl = атрибут
	mov	ax,0x1301		; al = 1 - курсор в конец строки
	int	vid
	
	popa
	
	iret

; ---------------------------------------------- ;

_i21_f0Ah:				; -----------> Ввод строки в буфер
	pusha				; ds:dx = адрес буфера
	
	xor	cx,cx
	xor	ax,ax
	mov	bx,dx
	mov	ch,[ds:bx]
	inc	bx
	push	bx
	
read_next_char:	
	cmp	cl,ch
	je	maxlen_beep
	mov	ah,0x01
	int	0x21
	cmp	al,ASCII_CR
	je	read_end
	cmp	al,ASCII_BS
	je	backsp
	inc	bx
	mov	dl,[ds:bx]
	mov	[ds:bx],al
	inc	cl
	jmp	short read_next_char
	
backsp:
	mov	[ds:bx],dl
	cmp	cl,0
	je	read_next_char
	dec	cl	
	dec	bx
	
	pusha
		
	getcursor
	dec	dl
	push	dx
	setcursor dl,dh
	mov	dl,0
	mov	ah,0x02
	int	0x21
	pop	dx
	setcursor dl,dh	
	
	popa

	jmp	short read_next_char		; [20:34] Вот в этом месте мне подумалось, что я не кушал 
						; 	  ничего с самого утра..... :-D
maxlen_beep:
	write	BELL
	mov	ah,0x08
	int	0x21
	cmp	al,ASCII_BS
	je	backsp
	cmp	al,ASCII_CR
	jne	maxlen_beep
	
read_end:	
	pop	bx
;	inc	cl
	mov	[ds:bx],byte cl
	mov	bl,cl
	inc	bl
	mov	[ds:bx],byte ASCII_CR
	
	popa
	
	iret		
	
	BELL	db ASCII_BEL,'$'
; ---------------------------------------------- ;

_i21_f18h:				; -----------> DOS Null-function для совместимости
	xor 	al,al
	
	iret
	
; ---------------------------------------------- ;	

_i21_f25h:				; -----------> Установить вектор прерывания	
	push	bx			; al = номер прерывания
  	push	es			; ds:dx = адрес обработчика прерывания
 
  	xor	bx,bx
  	mov	es,bx
  	mov	bl,4
  	mul	bl
	mov	bl,al
  	mov	[es:bx],dx
  	add	bx,2
  	mov	[es:bx],ds
  	
  	pop	es
  	pop	bx
  	
	iret  	

; ---------------------------------------------- ;

_i21_f30h:				; -----------> Получить версию ОС
	mov 	al,VERSION_MAJOR	; al = старший номер версии
	mov 	ah,VERSION_MINOR	; ah = младший номер версии
	xor	bx,bx			; bx = 0
	xor	cx,cx			; cx = 0
		
	iret
	
; ---------------------------------------------- ; 

_i21_f35h:				; -----------> Получить вектор прерывания	
	push	dx			; al = номер прерывания		
  	push	ds			; На выходе: es:bx = адрес обработчика прерывания
  	
  	xor	bx,bx
  	mov	ds,bx
  	mov	bl,4
  	mul	bl
	mov	bl,al
  	mov	dx,[ds:bx]
  	add	bx,2
  	mov	es,[ds:bx]
  	mov	bx,dx
  	
  	pop	ds
  	pop	dx

	iret  	
	
; ---------------------------------------------- ;

_i21_f39__41h:				; -----------> Заглушки для файловых функиций (для совместимости)
	mov 	ax,0x03			; На выходе: ax = 0x03
	stc				; Carry flag = fail
	iret

; ---------------------------------------------- ;

_i21_f4Ch:				; -----------> Завершить программу	
	jmp	__intr20h		; al = код завершения					 	

; ---------------------------------------------- ;

__intr21h_end:
	iret
   
; ---------------------------------------------- ;   
	
%endif