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

; tests.asm
; Набор загрузочных тестов
;
; Copyright (c) 2007 Vadim Ipatov
;
; email: Vadim Ipatov <euphoria.vi@gmail.com>

%ifndef TESTS_H
%define TESTS_H

; ---------------------------------------------- ; 

get_biosdate:
	write	BIOSDATE
	getcursor
	mov	dl,15
	setcursor dl,dh
	mov	cx,8
	push	es
	mov	ax,0xf000
	mov	es,ax
	mov	bp,0xfff5
	xor	bx,bx
	mov	bl,[TXTCOLOR]
	mov	ax,0x1301
	int	vid
	pop	es
	write	CRLF
end_get_biosdate:

get_comptype:
	push	ds
	mov	ax,0xf000
	mov	ds,ax
	mov	bx,0xfffe
	mov	al,[ds:bx]
	pop	ds
	write	COMPTYPE
	cmp	al,0x0ff
	je	.pc
	cmp	al,0x0fe
	je	.xt	
	cmp	al,0x0fd
	je	.pcjr	
	cmp	al,0x0fc
	je	.at
	cmp	al,0x0f9
	je	.cpc
	jmp	short .unkn	
.pc:
	writeln	COMPTYPE_PC
	jmp	short end_get_comptype
.xt:
	writeln	COMPTYPE_XT
	jmp	short end_get_comptype	
.pcjr:
	writeln	COMPTYPE_PCjr
	jmp	short end_get_comptype	
.at:
	writeln	COMPTYPE_AT
	jmp	short end_get_comptype	
.cpc:
	writeln	COMPTYPE_CPC
	jmp	short end_get_comptype	
.unkn:
	writeln	COMPTYPE_UNKN
end_get_comptype:

; ---------------------------------------------- ; 

tests_dataseg:
	jmp	tests_dataseg_end
	
	BIOSDATE	db 0x0D,0x0A,"ROM-BIOS Date: $"
	
	COMPTYPE	db "Computer Type: $"
	COMPTYPE_PC	db "Original PC$"
	COMPTYPE_XT	db "XT or Portable PC$"
	COMPTYPE_PCjr	db "PCjr$"
	COMPTYPE_AT	db "AT$"
	COMPTYPE_CPC	db "Convertible PC$"	
	COMPTYPE_UNKN	db "Unknown$"	
	
tests_dataseg_end:	

; ---------------------------------------------- ; 	

%endif