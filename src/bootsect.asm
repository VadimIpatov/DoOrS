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

; bootsect.asm
; ���������
;
; Copyright (c) 2007 Vadim Ipatov
;
; email: Vadim Ipatov <euphoria.vi@gmail.com>

%define	BOOTSECT
%include "..\include\defs.h"
%undef	BOOTSECT

bits 16
org 0x7c00

; ---------------------------------------------- ;

%macro write 3				; write(buf,len,color)
	mov 	bp,%1
	mov 	cx,%2
	mov 	bx,%3
	call 	write_proc
%endmacro


; ---------------------------------------------- ;

__entry_point:
  jmp start			; [0x00] ����������� ������� �� ����������� ��� 
  OEM 		db "DoOrS 95"	; [0x03] ������������ � ����� ������ �� 
  SectSize 	dw 512 		; [0x0B] ����� ���� � �������
  ClustSize 	db 1 		; [0x0D] ����� �������� � ��������
  Ressect 	dw 1 		; [0x0E] ����� ��������� �������� � ��������� ������� �������, ������� � ������� ������� ������� 
  FatCnt 	db 2 		; [0x10] ����� ����� FAT 
  RootSize 	dw 224 		; [0x11] ���������� 32-������� ������������ ������ � �������� ��������
  TotalSect 	dw 2880 	; [0x13] ����� ����� �������� 
  Media 	db 0xF0 	; [0x15] ��� �������� ���������� (������ ����: 2 �������, 18 �������� �� �������)
  FatSize 	dw 9 		; [0x16] ���������� ��������, ���������� FAT 
  TrackSect 	dw 18 		; [0x18] ����� �������� �� ������� 
  HeadCnt 	dw 2 		; [0x1A] ����� ������� 
  HidenSect 	dd 0 		; [0x1C] ����� ������� �������� ����� ��������
  HugeSect 	dd 0 		; [0x20] ������������ FAT32 
  BootDrv 	db 0 		; [0x24] ����� ��������� 
  Reserv 	db 0 		; [0x25] ��������������� ��� Windows NT
  BootSign 	db 0x29 	; [0x26] ������� ����������� ����������� ������ 
  VolID 	dd 0 		; [0x27] ����� ����������� ����� 
  VoLabel 	db "System     "; [0x2B] ����� ����� 
  FSType 	db "FAT12   " 	; [0x36] ������������ ���� �������� �������   
  
; ---------------------------------------------- ;  
  
start:  
  	cli
  	mov	ax,cs
  	mov	ds,ax
  	mov	ss,ax
  	mov	sp,__entry_point
  	sti
    
%include "bootlogo.asm"
 
clrscr:					; ������� �����
	mov 	ax,0x03
	int 	vid
  
load_kernel:				; ������ ���� - ������ ���� � �������� ��������
	mov	ax,kernseg
	mov	es,ax			; ����� ����� - [kernseg:0] di=0
     		; 33 ������ - ����� ���������� ���� =))
    mov dx,33
	
nextsect:    
   
	push	dx
	push 	es
	push	di
	call	readsect
	pop	di
	pop	es
	pop	dx
   
	add	di,512
	inc	dx
	cmp	dx,160			; ����� (160-33+1)*512 = 128 �������� = 64 ��
	jne	nextsect
	
; --------- � ���� �� �� ���������? =) --------- ;  	

	mov	di,2
	mov	ax,kernseg
	mov	es,ax
	mov	ax, word [es:di]
	cmp	ax,word 0xABCD
	jne	readerror

	jmp	kernseg:0		; �������� ���������� �� ��������� ���
  
; ----- ������� � ������� � ��������� BIOS ----- ;   

readsect:
	push	di
	push  	es
	push  	cs
	pop   	ds
	mov   	cx,[TrackSect]	; cx=Sectors
	mov   	si,dx		; si = Sect
  
; ------------- Tmp=(Sect/Sectors) ------------- ;

	mov	ax,si		; ax = Sect
	xor	dx,dx
	div	cx		; ax = Tmp, dx=?
	mov	di,ax		; di = Tmp
  
; ----------- Sec=Sect-(Tmp*Sectors)+1 --------- ; 

	imul	cx		; ax = Tmp*Sectors
	mov	dx,si		; dx = Sect
	sub	dx,ax		; dx = Sect-(Tmp*Sectors)
	inc	dx		; dx = Sec
	mov	[ABSSECT],dx	; ABSSECT = Sec
  
; ----------------- Hea=Tmp & 1 ---------------- ;  

	mov	ax,di		; ax = Tmp
	and	ax,1		; ax = Hea
	mov	[ABSHEAD],ax	; ABSHEAD = Hea
  
;  Trk=(Sect-(Hea*Sectors)-(Sec-1))/(Sectors*2)  ;

	imul	cx		; ax = Hea*Sectors
	push	ax
	mov	ax,si		; ax = Sect
	pop	dx		; dx = Hea*Sectors
	sub	ax,dx		; ax = Sect-(Hea*Sectors)
	mov	dx,[ABSSECT]	; dx = Sec
	dec	dx		; dx = Sec-1
	sub	ax,dx		; ax = Sect-(Hea*Sectors)-(Sec-1)
	mov	dx,cx		; dx = Sectors
	shl	dx,1		; dx = Sectors*2
	push	dx
	xor	dx,dx
	pop	bx		; bx = Sectors*2
	div	bx      	; ax = Trk

	mov	cx,ax
	mov	al,cl
	shr	cx,2
	and	cl,0x00C0
	mov	ch,al
	and	cx,0xFFC0
	mov	ax,[ABSSECT]
	or	cl,al
	pop	es
	pop	bx
 
	mov	dx,[ABSHEAD]	; dh - �������
	mov	dh,dl
	mov	dl,0		; dl - ���� (0 ��� fd0)
	mov	al,1		; al - ���-�� ����������� ��������
	mov	ah,0x02		; ������ � �����
	int	disk
  
	jnc 	readdone	; ������, ���� CF=1, ah = ��� ������
  
readerror:
	mov	ax,cs		; ������� �� ��� ���� =)
	mov	es,ax
	cmp	di,2
	je	kernel_not_found
	write	MSG1,2,cllight_red
	jmp	short exit
kernel_not_found:	
	write	MSG0,5,cllight_red
exit:
	xor	ax,ax
	int 	keyb		; ��� ������� �������
	int 	0x19  
    
readdone:  
	ret
	
; ---------------------------------------------- ; 

write_proc:
	mov 	ax,0x1301
	int 	vid
	
	ret
	
; ------------------- ������ ------------------- ;

	MSG0 db "Krnl?"				; ���� �� �������
	MSG1 db "RE"				; ������ ������
	MSG2 db "Now Loading..."
	MSG3 db "*"
	MSG4 db "* DoOrS  '95 *"
	
	ABSSECT dw 0
	kern_sect dw 33
	ABSHEAD dw 0
	times 510-($-$$) db 0
    ;db 0x55,0xaa 	; � ����� ������������ ������� ������
  	SIGN dw 0xAA55		; ����������� ������ 2 �����
  	
; ---------------------------------------------- ;  	