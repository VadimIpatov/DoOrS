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

; routine.h
; Функции ввода/вывода, работа с дисплеем, работа с системным динамиком
;
; Copyright (c) 2007 Vadim Ipatov
;
; email: Vadim Ipatov <euphoria.vi@gmail.com>


%ifndef CONSOLE_H
%define CONSOLE_H

%include "..\include\colors.h"
%include "..\include\ascii.h"

; ---------------------------------------------- ;
					; setcursor(x,y)
%macro setcursor 2
	push	bx
	push	dx
	
	xor	bx,bx
	mov	dl,%1
	mov	dh,%2
	mov 	ah,0x02
	int 	vid
	
 	pop	dx
 	pop	bx
%endmacro

; ---------------------------------------------- ;

%macro getcursor 0			; getcursor(): dl=x,dh=y
	push	ax
	push	bx
	push	cx
	
	xor	bx,bx
	mov	ah,0x03
	int	vid	
	
	pop	cx
	pop	bx
	pop	ax
%endmacro

; ---------------------------------------------- ;

%macro hidecur 0			; hidecur()
	push	ax
	push	cx
	
	mov 	ah,0x01
	mov 	cx,0x2000
	int 	vid
	
	pop	cx
	pop	ax
%endmacro	
	
; ---------------------------------------------- ;	

%macro clrscr 0				; clrscr()
	push	ax
	
	mov 	ax,0x03
	int 	vid
	
	pop	ax
%endmacro
	
; ---------------------------------------------- ;
					; textcolor(color)
%macro textcolor 1
	mov	[TXTCOLOR], byte %1
%endmacro

; ---------------------------------------------- ; 

%macro delay 2				; delay(time_p1,time_p2)
	push	ax
	push	cx
	push	dx
	
	mov	cx,%1
	mov	dx,%2
	mov 	ah,0x86
	int 	ext_at

	pop	dx
	pop	cx
	pop	ax
%endmacro
		
; ---------------------------------------------- ;	

%macro sound 1				; sound(freq)
	push	ax
	push	cx
	
	mov	ax,%1
	mov 	cx,ax

	mov 	al,182
	out 	0x43,al
	mov	ax,cx
	out 	0x42,al
	mov 	al,ah
	out 	0x42,al

	in 	al,0x61
	or 	al,0x03
	out 	0x61,al

	pop	cx
	pop	ax
%endmacro

; ---------------------------------------------- ;

%macro nosound 0			; nosound()
	push	ax

	in 	al,0x61h
	and 	al,0xFC
	out 	0x61,al

	pop	ax
%endmacro

; ---------------------------------------------- ;
					; write(buf)
%macro write 1
	push	ax
	push	dx
	
	mov	ah,0x09
	mov	dx,%1	
	int	0x21
	
	pop	dx
	pop	ax
%endmacro

; ---------------------------------------------- ;

					; write_n(buf,n)
%macro write_n 2   ; вывод из строки n байт
	
	push	ax
	push	dx
	push	bx
	push 	cx
	
	mov cx,0
	
%%1_continue:
	

	mov bx,cx
	mov dl,[bx+%1]
;	cmp dl,0x20;
;   je %%@met1
	mov	ah,0x02
	int	0x21
; %%@met1:	
	inc cx
	cmp cx,%2
	jb %%1_continue

	pop cx
	pop bx
	pop	dx
	pop	ax
	
%endmacro



; ---------------------------------------------- ;

					; writeln(buf)
%macro writeln 1
	push	ax
	push	dx
	
	mov	ah,0x09
	mov	dx,%1
	int	0x21
	mov	dx,CRLF
	int	0x21	
	
	pop	dx
	pop	ax
%endmacro

; ---------------------------------------------- ;
					; read(buf)
%macro read 1
	push	ax
	push	dx
	
	mov	ah,0x0A
	mov	dx,%1
	int	0x21
	
	pop	dx
	pop	ax
%endmacro

; ---------------------------------------------- ;
					; readln(buf)
%macro readln 1
	push	ax
	push	dx
	
	mov	ah,0x0A
	mov	dx,%1
	int	0x21	
	
	mov	ah,0x09	
	mov	dx,CRLF
	int	0x21	
	 
	pop	dx
	pop	ax		
%endmacro

; ---------------------------------------------- ;
					; defbuf(name,len)
%macro defbuf 2		
	%1		db %2,0
	times %2+1 db '$'
%endmacro

; ---------------------------------------------- ;

  TEXTMODE	equ 0x02
  GRAPHMODE 	equ 0x13
    
; ---------------------------------------------- ;

%endif