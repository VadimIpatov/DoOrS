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

; cli.asm
; Интерфейс командной строки
;
; Copyright (c) 2007 Vadim Ipatov
;
; email: Vadim Ipatov <euphoria.vi@gmail.com>

%ifndef CLI_H
%define CLI_H
; ---------------------------------------------- ;	
	CMD_0		db "help$"
	CMD_1		db "ver$"			
	CMD_2		db "pwd$"
	CMD_3		db "color$"
	CMD_4		db "cls$"
	CMD_5		db "shutdown$"
	CMD_6		db "dinfo$"
	CMD_7		db "dir$"
	CMD_8		db "cd$"
	CMD_9		db "exec$"
	CMD_BLANK	db "$"
; ---------------------------------------------- ;
__entry_interpret:
	writeln	INFO_MSG
	call loadfat
	writeln MSG3
	call loadroot
	writeln MSG4
	writeln MSG5
interpret:
	write	PATH
	write	CMD_PROMPT	
	readln	CMD
	xor	bx,bx
	mov	bl,byte [CMD+1]
	add	bl,2
	mov	ax,CMD
	add	bx,ax
	mov	[ds:bx],byte '$'
	mov	si,CMD+2
	call	strlocase
	call	strstrip
%if DEBUG	
	write	DEBUG_MSG0
	writeln	CMD+2
%endif
	call 	getcmd
	
	jmp	short interpret
	
; ---------------------------------------------- ;	
	
getcmd:

;;--- help ----
	mov	di,CMD_0
	call	strcmp
	jc	@lab_9
	jmp 	@lab_10
@lab_9:	
	jmp 	cmd_help
@lab_10:	


; - ---- ver -----
	mov	di,CMD_1
	call	strcmp
	jc	@lab_11
	jmp 	@lab_12
@lab_11:	
	jmp 	cmd_ver
@lab_12:

;------- pwd ------	
	mov	di,CMD_2
	call	strcmp
	jc 	@lab_7	
	jmp 	@lab_8
@lab_7:	
	jmp 	cmd_pwd
@lab_8:	

;------ color ---------
	mov	di,CMD_3
	call	strcmp
	jc 	@lab_5
    	jmp 	@lab_6	
@lab_5:	
	jmp 	cmd_color
@lab_6:	


;-------- cls ----
	mov	di,CMD_4
	call	strcmp
	jc	@lab_1
    	jmp 	@lab_2
@lab_1:
   	jmp 	cmd_cls
@lab_2:	

;------ shutdown -----
	mov	di,CMD_5
	call	strcmp
	jc 	@lab_3
    	jmp 	@lab_4	
@lab_3:    
	jmp 	cmd_shutdown
@lab_4:	


; ----- dinfo ---------
	mov	di,CMD_6
	call	strcmp
	jc	@lab_13
	jmp 	@lab_14
@lab_13:	
	jmp 	cmd_dinfo
@lab_14:

;--------dir-----------
	
	mov	di,CMD_7
	call	strcmp
	jc	@lab_15
	jmp 	@lab_16
@lab_15:	
	jmp 	cmd_dir
@lab_16:

;;---------cd -----------	
	mov	di,CMD_8
	call	strcmp
	jc	@lab_17
	jmp 	@lab_18
@lab_17:	
	jmp 	cmd_cd
	
@lab_18:	
	
;;---------exec-----------	
	mov	di,CMD_9
	call	strcmp
	jc	@lab_19
	jmp 	@lab_20
@lab_19:	
	jmp 	cmd_exec
	
@lab_20:	
;---------blank-----------    
    	mov	di,CMD_BLANK
	call	strcmp
	jc	@lab_21
	jmp	@lab_22
@lab_21:
	ret
@lab_22:
;-------------------------  
   
cmd_unknown:
	writeln	UNKNOWNCMD
	ret	
	
;---------------------------------------------- ;

cmd_exec:
    	call openfile
	ret

;---------------------------------------------- ;

cmd_cd:
    	call setdir
	ret
	
; ---------------------------------------------- ;

cmd_dir:
	call readdir
	ret	
		
; ---------------------------------------------- ;

cmd_dinfo:
	call readMBRsect
	ret
		
; ---------------------------------------------- ;
cmd_help:
	writeln	USAGE
	ret

; ---------------------------------------------- ;	

cmd_ver:
	writeln	VERSION
	ret
	
; ---------------------------------------------- ;

cmd_pwd:
	writeln PATH
	ret	

; ---------------------------------------------- ;

cmd_color:
	cmp byte [cs:TXTCOLOR],clwhite
	jb	chcol
	jmp	short retcol
chcol:
	inc byte [cs:TXTCOLOR]
	jmp	short end_color
retcol:
	textcolor clblue
end_color:	
	ret
	
; ---------------------------------------------- ;

cmd_cls:
	clrscr
	ret	

; ---------------------------------------------- ;	
	
cmd_shutdown:
	write	CRLF
	write	ROH
oncemore:	
	mov	ah,0x01
	int	0x21
	
	cmp	al,'r'
	je	__reboot
	cmp	al,'R'
	je	__reboot
	cmp	al,'h'
	je	__halt
	cmp	al,'H'
	je	__halt	
	cmp	al,'l'
	je	__reload	
	cmp	al,'L'
	je	__reload
	cmp	al,'c'
	je	__cancel
	cmp	al,'C'
	je	__cancel
	
	
	getcursor
	dec	dl
	setcursor dl,dh
	jmp	short oncemore
	
__reboot:
	write	PLW
	xor	ax,ax
	mov	ds,ax
	mov	bx,0x0472
	mov	[bx],word 0x1234
	jmp	0xF000:0xFFF0
	
__reload:
	int	0x19

__halt:
	write	CRLF
	writeln	SYSHLT
	
	hlt
	jmp short $

__cancel:
	writeln	CRLF
	ret

; ---------------------------------------------- ;

	CMD_PROMPT	db ">$"
	UNKNOWNCMD	db "No such command$"
	
	defbuf CMD,78
	
	USAGE		db "                               +----------------+",			  0x0D,0x0A
			db "            -------------------|BUILTIN COMMANDS|-------------------",0x0D,0x0A
			db "                               +----------------+",			  0x0D,0x0A	
			db "                CD              Change directory",			  0x0D,0x0A
			db "                CLS             Clear screen",			  0x0D,0x0A	
			db "                COLOR           Set text color",			  0x0D,0x0A					
			db "                DINFO           Print disk info",			  0x0D,0x0A
			db "                DIR             Directory view",			  0x0D,0x0A						
			db "                EXEC            Execute program",			  0x0D,0x0A			
			db "                HELP            Print this help",			  0x0D,0x0A
			db "                PWD             Print current path",		  0x0D,0x0A
			db "                SHUTDOWN        Reboot, Reload or halt",		  0x0D,0x0A
			db "                VER             Print information about version",	  0x0D,0x0A
			db "            --------------------------------------------------------",'$'

	VERSION		db "Nanosoft DoOrS 95$"
	
	DEBUG_MSG0 	db "Cmd=$"
	INFO_MSG	db 0x0D,0x0A,"Please, type 'help' if u need help$"
	PLW		db 0x0D,0x0A,"Reboot in progress. Please, wait...$"
	
	ROH 		db "[R]eboot/Re[L]oad/[H]alt or [C]ancel? $"	
	SYSHLT 		db "System halted!$"	
	
	

%endif
	