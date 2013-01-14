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

; fat12.asm
; ���������� �������� ������� FAT12
;
; Copyright (c) 2007 Vadim Ipatov, Peter Barmin
;
; email: Peter Barmin <pet_gog@mail.ru>
; email: Vadim Ipatov <euphoria.vi@gmail.com>

%ifndef FAT_H
%define FAT_H

  VVOD_DIR DB 'Where we are going: $' ; 
def_temp_dir:  
  defbuf TEMP_DIR,8  ; ����������
  
  VVOD_FILE DB 'Filename:$'  ; ��� �����
def_temp_name_file:

  defbuf TEMP_NAME_FILE,12
 
 ERROR_NAME_FILE  db 'Filename error!$'
 FILE_NOT_FOUND	db 'File not found!$'
 OPEN_NAME_FILE db '$$$$$$$$$$'
 OPEN_MASKA_FILE db '$$$$$'
 
 OPEN_FILE_KLASTER dw 0 ;  ��������� ������� �����
; ---------------------------------------------- ;; ---------------------------------------------- ;
openfile:             ;��������� ������ ����� � ������
 write VVOD_FILE
 readln TEMP_NAME_FILE 
 %if DEBUG
 write TEMP_NAME_FILE 
 %endif
 push dx
 call proverka_name_file
 
 %if DEBUG
 push dx

 mov [ZNACHENIE],dx
 call chislovstr
 call vivodchisla 
 pop dx
 
  %endif
 
 cmp dx,0
 je @read_files 
 pop dx
 jmp @exit_openfile
 
@read_files:
  push si
  mov si,OPEN_NAME_FILE
  call strupcase
  
  mov si,OPEN_MASKA_FILE
  call strupcase
  pop si
pop dx
 ; ---------------------------------------------- ;
 ; ������ �������
 
 push dx
 mov dx,[DIR_SECTOR]
 mov [TEMP_SECTOR],dx
 pop dx
 
@read_files_start:  
  
 push di

 disk_read BUF_SECT,[TEMP_SECTOR],[TEMP_SECTOR]   ; ������ ������ TEMP_SECTOR � ���������� BUF_SECT

 pop di
 

 push si
 mov si,0
@read_files_next:
 cmp byte [BUF_SECT+si], 0x00
 jne short @no_end_readfiles
 jmp end_readfiles
@no_end_readfiles:
 
 cmp byte [BUF_SECT+si], 0xE5
 jne short @not_next_files
 jmp @next_files
@not_next_files: 
 
; write_n BUF_SECT+si,8
 push dx
 mov dl,byte [BUF_SECT+si+11]
 and dl,00010000b
 cmp dl,00010000b
 pop dx 
 jne @met11
 jmp @next_files
    
@met11:
	
	push dx
    cmp_name_files BUF_SECT+si,OPEN_NAME_FILE,OPEN_MASKA_FILE ; ��������� ����� �����
    cmp dx,0
	pop dx
	jne @next_files
	
	jmp @run_open_file
	
     ;;;;=======================================
 
@next_files: 
 add si,32
 cmp si,512
 je short @not_read_files_next 
 jmp @read_files_next
; readln TEMP_CHISLO
@not_read_files_next
 ; ���� ��������� � �������� ��������
 
 cmp word [TEMP_SECTOR],32
 ja @read_fat_files ; ���� ���, �� �������� ��������� ����� ��������
 pop si 
 push dx
 
 ;���� � �������� �������� �� ������ ����������� ����� ��������
 mov dx,[TEMP_SECTOR]
 inc dx
 mov [TEMP_SECTOR],dx
 pop dx
 jmp @read_files_start
  
@read_fat_files:  
  
 ;push dx
 
 call read_next_cluster ;��� ���� ���������� � �������� ��������� �������


 cmp word [TEMP_SECTOR],0x0FFF
 je @vostonovim_dx_files ; ���� ������� ���������, �� ������� ��������� FILE_NOT_FOUND
 ;mov [TEMP_SECTOR],dx
 ;pop dx
 pop si 

 jmp @read_files_start
 
@vostonovim_dx_files:
 ;pop dx
 
end_readfiles: 
 writeln FILE_NOT_FOUND
 %if DEBUG

 writeln NULL_BUF
 %endif
 pop si
 ret

@run_open_file: 
 ;���� ������ ������ ��� ����� ��������� � ������! 
 ; ��� ����� ������� ������� ������ ����� OPEN_FILE_KLASTER
 push dx
 mov dx,word [BUF_SECT+si+26]
 mov [OPEN_FILE_KLASTER],dx
 
 push dx
 mov [ZNACHENIE],dx
 call chislovstr

 %if DEBUG
 call vivodchisla 
 %endif
 pop dx
 
 pop dx
 
  
 
 pop si
 
 push di
 mov 	di,__end_of_kernel;  ������ ��������� �����
 add di,100h ; ������� ����� ��� PSP

 ;mov di,5D50h

 mov  dx,word [OPEN_FILE_KLASTER] 		

 

 ;push ds
 ;pop	es
 
  push ax
  push bx
  push cx
 open_next_cluster: 
    
	push dx
    add dx,31

	; ����������� � ����� ������� 
	
    call	readsect
    pop dx	
	
	push 	di		; ������� ��������� ������ ����� DX 
	mov 	di,FAT
    mov 	ax,dx
	mov 	bx,ax
	mov 	cx,3
	mul 	cx 		; FAT12 ��� 12-��������� ������� - ��� ������������� ������ �-�� 3 �����
	shr 	ax,1 		; ����� �� 2 - �.�. ������ ������� ������� ����� ����� 1,5 �����
	add 	di,ax 
	mov 	dx,word [di] ; ������ ����� �� FAT �� �������� � ax
	and 	bx,1
	je 	even_1 		; ���� ����� �������� ������ 
	shr 	dx,4 		; ������� ������� 12 ���
	jmp 	short odd_1 	; ���� ����� �������� �������� 
even_1: 
	and 	dx,0x0FFF	; ������� ������� 12 ���
	
odd_1: 
	pop 	di 
	
	cmp 	dx,0x0FFF
	je 	open_end_read_cluster; 0x0FFF - ��������� ������� 
	add 	di,512 
	
	jmp 	short open_next_cluster 
	
open_end_read_cluster:
   pop cx
   pop bx
   pop ax
   pop di

   ;mov ax,5555
   ;push ax
   
 ;  writeln NULL_BUF

   call	execute_program

   writeln NULL_BUF
   ret

@exit_openfile:
 
 ; write_n __end_of_kernel+100,100
 ;writeln NULL_BUF
 
	ret

; ---------------------------------------------- ;; ---------------------------------------------- ;
 
proverka_name_file: ; �������� �� ��������� ���� ����� �����
                    ; �����
					; dx=1  �������
					; dx=0 ��� ������������!!!!
                    ; OPEN_NAME_FILE ��� �����
                    ; OPEN_MASKA_FILE ���������� �����					
 push cx
 push dx
 push bx

 ;jmp short @yes_tochka 
 xor cx,cx
 mov cl,byte [TEMP_NAME_FILE+1]
 cmp cl,0
 jne @proverka_name
 jmp @exit_proverkafile
@proverka_name 
 mov dx,cx
 cmp dx,3
 jbe @korotkoe_name
 jmp @dlinnoe_name
@korotkoe_name:
 mov dx,0
 jmp @poisk_tochki
@dlinnoe_name 
 sub dx,4
@poisk_tochki:
 
 mov bx,cx
 ;add bx,2
 cmp byte [TEMP_NAME_FILE+BX+1],'.'
 je @yes_tochka
 
 dec cx
 cmp cx,dx
 ja @poisk_tochki
 
 ;jmp @error_tochka
@error_tochka:
; writeln NULL_BUF
 writeln ERROR_NAME_FILE
 ;writeln NULL_BUF
 jmp @exit_proverkafile 
 
@yes_tochka :
 cmp cx,1
 ja @met13
 jmp @error_tochka
 
@met13: 
 cmp cx,10
 jb @met14
 jmp @error_tochka
@met14:
 
 push cx
 dec cx
@loop_namefile :
 mov bx,cx
 mov dl,byte [TEMP_NAME_FILE+BX+1]
 dec bx
 dec cx
 mov byte [OPEN_NAME_FILE+BX],dl
 cmp bx,0
 jne @loop_namefile
 
 pop cx 
 mov bx,cx
 dec bx
 mov byte [OPEN_NAME_FILE+BX],'$'
  
%if DEBUG
 writeln NULL_BUF

 writeln OPEN_NAME_FILE 
%endif
 cmp cl,byte [TEMP_NAME_FILE+1]
 jae @met15
 jmp @met16
@met15:
  mov byte [OPEN_MASKA_FILE],'$'
 
 jmp @ok_proverkafile
@met16: 
 push ax
 mov ax,0xFFFF
 
@loop_maskfile :
 inc cx
 mov bx,cx
 mov dl,byte [TEMP_NAME_FILE+BX+1]
 inc ax 
 mov bx,ax
 mov byte [OPEN_MASKA_FILE+BX],dl
 cmp cl, byte [TEMP_NAME_FILE+1]
 jb @loop_maskfile
 
 inc bx
 mov byte [OPEN_MASKA_FILE+BX],'$'
 pop ax
%if DEBUG
 writeln NULL_BUF
 writeln OPEN_MASKA_FILE 
%endif
 jmp @ok_proverkafile
@exit_proverkafile: 
 pop bx
 pop dx
 pop cx
 
 ; dx=1
 mov dx,1
 %if DEBUG
 writeln NULL_BUF
 %endif
 ret
 
@ok_proverkafile:
 pop bx
 pop dx
 pop cx
 
 mov dx, 0
 %if DEBUG
 writeln NULL_BUF
 %endif
 ret


; ---------------------------------------------- ;; ---------------------------------------------- ;; ---------------------------------------------- ;
readMBRsect:        ;  ������ ������ �� ������������ �������

 disk_read BUF_SECT,0,0
 
 write_n BUF_SECT+3,8 ;����� ����� ������������ ��
 writeln NULL_BUF
 
 write_n BUF_SECT+43,11 ;����� ����� ����
 writeln NULL_BUF
 
 write_n BUF_SECT+54,8 ; ����� FAT12
 writeln NULL_BUF

 ret
 
 
 ; ---------------------------------------------- ;
 
 
readdir:               ; ������ ������ ����� � ����������
 ; ---------------------------------------------- ;
 push dx
 mov dx,[DIR_SECTOR]
 mov [TEMP_SECTOR],dx
 pop dx
 
@read_start:  
  
 push di

 disk_read BUF_SECT,[TEMP_SECTOR],[TEMP_SECTOR]

 pop di
 push si
 mov si,0
@read_next:
 cmp byte [BUF_SECT+si], 0x00
 jne short @no_end_readdir
 jmp end_readdir
@no_end_readdir:
 
 cmp byte [BUF_SECT+si], 0xE5
 jne short @not_next
 jmp @next
@not_next: 
 
 
 call read_data
 write TAB_BUF
 call read_time
 write TAB_BUF
  
 push dx
 mov dl,byte [BUF_SECT+si+11]
 and dl,00010000b
 cmp dl,00010000b 
 je short @katalog ; ���� �������, �� ������� <DIR>
 write TAB_BUF
 write TAB_BUF
 write_n BUF_SECT+si,8 ;
 write TOCHKA 
 write_n BUF_SECT+si+8,3 ;
 writeln NULL_BUF
 pop dx
 jmp @next
@katalog: 
 write DIR_BUF
 write_n BUF_SECT+si,8 ;
 writeln NULL_BUF
 pop dx
 
 
@next: 
 add si,32
 cmp si,512
 je short @not_read_next 
 jmp @read_next
; readln TEMP_CHISLO
@not_read_next
 cmp word [TEMP_SECTOR],32
 ja @read_fat
 pop si 
 push dx
 mov dx,[TEMP_SECTOR]
 inc dx
 mov [TEMP_SECTOR],dx
 pop dx
 jmp @read_start
  
@read_fat:  
  
 ;push dx
 call read_next_cluster


 cmp word [TEMP_SECTOR],0x0FFF
 je @vostonovim_dx
 ;mov [TEMP_SECTOR],dx
 ;pop dx
 pop si 

 jmp @read_start
 
@vostonovim_dx:
 ;pop dx
 
end_readdir:

 pop si
 ;write_n BUF_SECT+32,8 ;����� ����� ����
 ;write TOCHKA
 ;write_n BUF_SECT+8+32,3 ;
 writeln NULL_BUF
 
; write_n BUF_SECT+64,8 ;����� ����� ����
;  write TOCHKA
; write_n BUF_SECT+8+64,3 ;
; writeln NULL_BUF
 
 
 ret
  ; ---------------------------------------------- ;
  
  
read_time:   ;   ������ ������� �������� �����

;������� 
 ;(0-30) ������ 
 ;(0-59) ���� 
 ;(0-23) 

 mov ax,word [BUF_SECT+si+22] 
 And AX, 0xF800
 Shr AX, 11  
 ; AX = ����
 mov [ZNACHENIE],ax 
 call chislovstr
 cmp byte [LEN_CHISLO],1
 je @norm_chas
 write NOL
@norm_chas 
 call vivodchisla
 

 write DVOITOCHIE
 mov ax,word [BUF_SECT+si+22]
 And AX, 0x07E0
 Shr AX, 5 
 ;AX = ������ 
 mov [ZNACHENIE],ax ;AX = ���� 
 call chislovstr
 cmp byte [LEN_CHISLO],1
 je @norm_min
 write NOL
@norm_min
 call vivodchisla 
 
 write DVOITOCHIE
 mov ax,word [BUF_SECT+si+22]
 And AX, 0x001F
 Imul AX, 2 
 ;AX = �������
 mov [ZNACHENIE],ax ;
 call chislovstr
 cmp byte [LEN_CHISLO],1
 je @norm_sec
 write NOL
@norm_sec
 call vivodchisla
 
 ret  
; ---------------------------------------------- 


read_data:  ; ������ ���� �������� �����
 
 ;(0-31) ����� 
;(1-31) ��� 
;(0-119) 
 mov ax,word [BUF_SECT+si+24]
 And AX, 0x001F
 mov [ZNACHENIE],ax ;AX = ���� 
 call chislovstr
 cmp byte [LEN_CHISLO],1
 je @norm_den
 write NOL
@norm_den
 call vivodchisla
 
 write TOCHKA
 mov ax,word [BUF_SECT+si+24]
 And AX, 0x01E0  
 Shr AX, 5 
 mov [ZNACHENIE],ax
 call chislovstr
 cmp byte [LEN_CHISLO],1
 je @norm_mecyc
 write NOL
@norm_mecyc 
 call vivodchisla
 ;AX = ����� 
 
 write TOCHKA
 mov ax,word [BUF_SECT+si+24]
 ;And AX, 0xFC00 
 Shr AX, 9 
 Add AX, 0x07BC
 mov [ZNACHENIE],ax
 call chislovstr
 call vivodchisla

 write TAB_BUF
 
ret 
; ---------------------------------------------- ;





setdir:                               ;;  ����� ����������
 write VVOD_DIR
 readln TEMP_DIR 
 push si
 mov si,TEMP_DIR
 call strupcase
 pop si
 ;defbuf TEMP_DIR,8 ; �������������� ����� ����� ����������
 ;writeln TEMP_DIR
; write TEMP_DIR
 
 push dx
 mov dx,[DIR_SECTOR]
 mov [TEMP_SECTOR],dx
 pop dx
 
set_dir_start:
 push di
 disk_read BUF_SECT,[TEMP_SECTOR],[TEMP_SECTOR]
 pop di

 push si
 mov si,0
@set_read_next:
 cmp byte [BUF_SECT+si], 0x00
 jne short @set_no_end_dir
 jmp set_dir_error
@set_no_end_dir:
 cmp byte [BUF_SECT+si], 0xE5
 jne short @set_not_next
 jmp @set_next
@set_not_next: 
 
 push dx
 mov dl,byte [BUF_SECT+si+11]
 and dl,00010000b
 cmp dl,00010000b
 je short @set_katalog

; write_n BUF_SECT+si,8 ;

 pop dx
 jmp @set_next
@set_katalog: 
 pop dx


 cmp_name_dir TEMP_DIR,BUF_SECT+si
 
 mov [ZNACHENIE],dx
 cmp word [ZNACHENIE],0x0001
 jne @set_next
 jmp @dir_ustanovlen
 
 
 
 
@set_next: 
 add si,32
 cmp si,512
 je short @set_not_read_next 
 jmp @set_read_next
; readln TEMP_CHISLO
@set_not_read_next
 cmp word [TEMP_SECTOR],32
 ja @set_read_fat
 pop si 
 push dx
 mov dx,[TEMP_SECTOR]
 inc dx
 mov [TEMP_SECTOR],dx
 pop dx
 jmp set_dir_start
  
@set_read_fat:  
  
 ;push dx
 call read_next_cluster


 cmp word [TEMP_SECTOR],0x0FFF
 jne not_set_end_readdir
 jmp set_dir_error
not_set_end_readdir: 
 pop si 

 jmp set_dir_start
 
@set_vostonovim_dx:
 ;pop dx

@dir_ustanovlen:

 ;writeln TEMP_DIR
 push dx
 mov dx,word [BUF_SECT+si+26]
 cmp dx,0
 je @korn_katalog
 add dx,31
 jmp @not_korn_katalog  
@korn_katalog:
 mov dx,19

@not_korn_katalog: 
 mov [DIR_SECTOR],dx
 pop dx

 ;/////////////////
 cmp byte [TEMP_DIR+2],'.' 
 je @dir_
 jmp @dir_8

@dir_: 
 cmp byte [TEMP_DIR+1],1
 je set_end_readdir
 
 cmp byte [TEMP_DIR+3],'.' 
 je @dir__
 jmp @dir_8
 

@dir__:
 cmp byte [TEMP_DIR+1],2
 jne @dir_8
 last_path
 jmp set_end_readdir
@dir_8:

 set_path TEMP_DIR
 jmp set_end_readdir
set_dir_error:

 writeln DIR_NOT_FOUND 
 
set_end_readdir:

 pop si 
 writeln NULL_BUF
 

 ret


; ---------------------------------------------- ;
  
readsect:         
; ������ ������� (DX=����� �������) 
; ES:DI � ����� ��� ����� ������
	pusha
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
	;writeln	ERR0
  
readdone:
	popa
	ret
	
; ---------------------------------------------- ;	
	
read_next_cluster:             ;   ��������� ������ ���������� �������� � ������� �����
  ;�������� ��������� ���������� �������� ��  ������� 

 ;  1. ������ FAT � ������
 ;  2. �������� ����� ���������� �������� �� 3 (��� ��� FAT12 ��� 12-��������� �������, �.�. ��� ������������� ������ ��� ������������ 3 �����)
 ;  3. ��������� ��������� �� 2 (��� ��� ������ ������� ������� ����� ����� 1,5 �����)
 ;  4. ��������� 16-������� ����� �� FAT , ��������� � �������� �������� ��������, ���������� ����� ������� �� 2
 ;  5. ���� ����� ���������� �������� ������, �� ��������� �� FAT ����� ���� �������� ����� 0FFFh, ������� ������� 12 ���, ���� �� ����� ���������� �������� ��������, ��������� �� FAT �������� ���������� �������� ������ �� 4 ����, ������� ������� 12 ���
 ;  6. ���������� ��������� - ��� ����� ���������� �������� � �������, ��� ���� �������� 0FFFh ( ��� ������ � ��������� �� 0FF8h �� 0FFFh) ������������� ����� ������� ���������


 

    push ax
	push bx
	
	mov  	dx,[TEMP_SECTOR] 		; ����������� � ����� ������� 
	sub     dx,31
    ;call	readsect
	push 	di		; ������� ��������� ������ ����� DX 
	mov 	di,FAT
    mov 	ax,dx
	mov 	bx,ax
	mov 	cx,3
	mul 	cx 		; FAT12 ��� 12-��������� ������� - ��� ������������� ������ �-�� 3 �����
	shr 	ax,1 		; ����� �� 2 - �.�. ������ ������� ������� ����� ����� 1,5 �����
	add 	di,ax 
	mov 	dx,word [di] ; ������ ����� �� FAT �� �������� � ax
	and 	bx,1
	je 	even 		; ���� ����� �������� ������ 
	shr 	dx,4 		; ������� ������� 12 ���
	jmp 	short odd 	; ���� ����� �������� �������� 
even: 
	and 	dx,0x0FFF	; ������� ������� 12 ���
odd: 
	pop 	di 
	cmp 	dx,0x0FFF
	je 	end_read_cluster; 0x0FFF - ��������� ������� 
	
	;add 	di,512 
	add dx,31
	
	jmp 	short end_read_cluster 
end_read_cluster:
   pop bx
   pop ax
   mov [TEMP_SECTOR],dx

   ret
; ---------------------------------------------- ;	
	
loadfat:                                ; ��������� ������ FAT ������� 9 ���������!!!!!
	disk_read FAT,1,10
	ret

; ---------------------------------------------- ;	

loadroot:
	disk_read ROOTDIR,19,33
	ret

; ---------------------------------------------- ;
	
fat_data_section:
	jmp	end_fat_data_section
    
	
	ABSSECT 	dw 0 		; ���������� ������
	ABSHEAD 	dw 0 		; ���������� �������
	TrackSect 	dw 18		; ����� �������� �� ������� 
	BUF_SECT db 0                ;  ���� ������ � ������
	times 512 db 0
	FAT		db 0		; ������� ������������� ������
	times 9*512-1 	db 0		; 9 ��������
	ROOTDIR		db 0		; �������� �������
	times 15*512-1  db 0		; 15 ��������
	PATH		db 'A:\$'	; ������� �������
	times 252	db 0	
    	DIR_SECTOR dw  19;0x00A1 ;0x00B0 
	TEMP_SECTOR dw 0
	
 
	
end_fat_data_section:	
 

  
	;  ��������� ���������� ��� ����� ����������
    
   

   
  INDEX_PATH dw 3


   DIR_NOT_FOUND db 'Path not found!$'
   NULL_BUF DB '$'
   TAB_BUF DB '    $'
   DIR_BUF DB '<DIR>   $'
   TOCHKA DB '.$'
   DVOITOCHIE DB ':$'
   
   NOL DB '0$'
   TEMP_CHISLO DB '           $' 

; ---------------------------------------------- ;	
%endif
	