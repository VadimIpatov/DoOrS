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

; taskman.asm
; Менеджер процессов
;
; Copyright (c) 2007 Vadim Ipatov
;
; email: Vadim Ipatov <euphoria.vi@gmail.com>

%ifndef TASKMAN_H
%define TASKMAN_H

; ---------------------------------------------- ; 
execute_program:
	pusha	
	mov 	[cs:MAINSTACK],sp			; Сохраним указатель стека
	
	xor 	ax,ax					; Так
	xor 	bx,bx					; делает
	xor 	cx,cx					; DOS,
	xor 	dx,dx					; поэтому
	xor 	si,si					; сделаем
	xor 	di,di					; аналогично
	xor 	bp,bp					; для соместимости ;)
 
	mov 	ax,progseg				; Настроим
    	mov	ds,ax					; сегментные
	mov	es,ax					; регистры
	mov	ss,ax					; и
	mov	sp,0x4C20				; указатель стека
	
create_psp: 						; Настроим PSP	
	mov 	[ds:0x0000],word 0x20CD			; int 0x20
	mov 	[ds:0x0008],word kernseg		; Адрес 
	mov 	[ds:0x000A],word return_addr		; возврата

execute:
	call	progseg+0x10:0x0000 			; Поехали!

return_addr:						; Сюда мы должны вернуться после выполнения
	mov	ax,kernseg
  	mov	ds,ax
  	mov	es,ax
  	mov	ss,ax
	mov	sp,[cs:MAINSTACK]

        popa
        
        clc
             
	write	CRLF             
                
        ret

; ---------------------------------------------- ; 	

%endif