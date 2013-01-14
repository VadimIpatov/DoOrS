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

; kernel.asm
; ядро
;
; Copyright (c) 2007 Vadim Ipatov
;
; email: Vadim Ipatov <euphoria.vi@gmail.com>

%include "..\include\defs.h"

bits 16

; ---------------------------------------------- ; 

__entry_point:
  	jmp short $+4
	SIGN dw 0xABCD
  	
  	cli				
  	
  	mov	ax,cs			; |
  	mov	ds,ax			; |
  	mov	es,ax			; | ”становим сегментные регистры
  	mov	ss,ax			; |
  	mov	sp,__entry_point	; |
  	  	
  	push	ds			; |
  	xor	bx,bx			; |
  	mov	ds,bx			; | ”становим вектор 
  	mov	bx,__intr21h		; | 0x21 прерывани€
  	mov	[ds:0x0084],bx		; |
  	mov	[ds:0x0086],cs		; |

  	xor	bx,bx			; |
  	mov	ds,bx			; |
  	mov	bx,__intr20h		; | ”становим вектор 
  	mov	[ds:0x0080],bx		; | 0x20 прерывани€
  	mov	[ds:0x0082],cs		; |
  	pop	ds			; |	
	
  	sti

  	setcursor 0,0
  	writeln	MSG0
	writeln MSG1
	writeln MSG2	
	
%include "tests.asm"
	
command.com:	
	jmp	__entry_interpret
	
; ---------------------------------------------- ; 	
%include "cli.asm"
%include "fat12.asm"

%include "strings.asm"
%include "taskman.asm"
%include "intr20.asm"	
%include "intr21.asm"

; ---------------------------------------------- ; 

	MSG0 		db "Kernel is successfully loaded!$"
	MSG1		db "0x20 interruption vector is successfully installed!$"
	MSG2		db "0x21 interruption vector is successfully installed!$"
	MSG3		db "File allocation table is loaded$"	
	MSG4		db "Root directory is loaded$"	
	MSG5		db "Command line interface activated$"
	
	;ERR0		db "Disk read error!$"
	
	TXTCOLOR 	db clwhite
  	CRLF 		db 0x0D,0x0A,'$'
  	BEEP 		db 0x07,'$'
  	
	MAINSTACK	dw 0 
 
	times 45536-($-$$) db 0			; ~20 кб дл€ процессов
	
__end_of_kernel:	

	times 65536-($-$$) db 0
	
; ---------------------------------------------- ;	