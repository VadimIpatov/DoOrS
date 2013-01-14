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

; bootlogo.asm
; Заставка при загрузке
;
; Copyright (c) 2007 Vadim Ipatov
;
; email: Vadim Ipatov <euphoria.vi@gmail.com>
 
%ifndef LOGO_H
%define LOGO_H
 
NOVMWARE equ 0
 
draw_logo:
	mov	ah,0
	mov 	al,GRAPHMODE
	int 	vid
	
; -------- Здесь рисуем 3 цветных линии -------- ;

	mov 	cx,65
	mov 	bx,255
	mov	dx,8
	mov 	al,cllight_green
	call 	draw_hline
	
	mov 	cx,96
	mov 	bx,224
	mov 	dx,16
	mov 	al,cllight_red
	call 	draw_hline
	
	mov 	cx,128
	mov 	bx,192
	mov 	dx,24
	mov 	al,clyellow
	call 	draw_hline
	
; ------------ Выводим текст в рамке ----------- ;

	mov 	al,1
	mov 	bl,clwhite
	mov 	dl,13
	mov 	ah,0x13
	mov 	dh,4
	call 	ll
	jmp 	ff
	
ll:
	mov 	cx,1
	mov 	bp,MSG3
	
.yy:
	cmp 	dl,27
	je 	.ok
	int 	vid
	add 	dl,1
	jmp 	.yy
	
.ok:
	ret
	
ff:
	mov 	dl,13
	mov 	cx,14
	mov 	dh,5
	mov 	bp,MSG4
	int 	vid
	mov 	dh,6
	mov 	bp,MSG2
	int 	vid
	mov 	dh,7
	call 	ll
	
; ------------ Рисуем бегущую линию ------------ ;

	mov 	cx,65
	mov 	bx,80
	mov 	al,cllight_red
	
_line:
	cmp 	cx,255
	je 	set_text
	add 	cx,1
	mov 	dx,72
	push 	cx
	push 	dx
	mov 	cx,NOVMWARE
	mov 	dx,0
	mov 	ah,0x86
	int 	0x15
	pop 	dx
	pop 	cx
	call 	draw_vline
	jmp 	_line
	
; ---------------------------------------------- ; Рисует горизонтальную линию
						 ; cx = X1, bx = X2, dx = Y, al = цвет
draw_hline:					 
_looph:
	cmp 	cx,bx
	je 	.hback
	add 	cx,1
	call 	draw_pixel
	jmp 	_looph
.hback:
	ret
	
; ---------------------------------------------- ; Рисует вертикальную линию
						 ; dx = Y1, bx = Y2, cx = X, al = цвет
draw_vline:					
_loopv:
	cmp 	dx,bx
	je 	.vback
	add 	dx,1
	call 	draw_pixel
	jmp 	_loopv
.vback:
	ret 
	
; ---------------------------------------------- ; Рисует пиксел
						 ; dx = строка, cx = колонка, al = цвет
draw_pixel:		 				 
	mov 	ah,0x0c
	int 	vid
	ret
	
; ---------------------------------------------- ;

set_text:
	mov 	ah,0
	mov	al,TEXTMODE
	int 	vid
		
%endif		
