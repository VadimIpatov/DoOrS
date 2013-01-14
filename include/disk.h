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

; disk.h
; Макросы для работы с диском
;
; Copyright (c) 2007 Vadim Ipatov
; email: Peter Barmin <pet_gog@mail.ru>
; email: Vadim Ipatov <euphoria.vi@gmail.com>

%ifndef DISK_H
%define DISK_H

; ---------------------------------------------- ;
				; diskread(buf,first_sect,end_sect)
				
				 ; макрос чтения с first_sect до end_sect секторов в buf
%macro disk_read 3
	push dx
	push di
	
	mov 	dx,%2 		; Начальный сектор
	mov 	di,%1		; Буфер
	
%%label:
	call 	readsect 
	add 	di,512 
	inc 	dx 
	cmp 	dx,%3 		; Конечный сектор
	jb %%label
	
	pop di
	pop dx
	
%endmacro 	

; ---------------------------------------------- ;

				; cmp_name_file(buf,NAME_FILE,MASKA_FILE)
				
				; макрос сравнения NAME_FILE и buf
				;                  MASKA_FILE и buf+8 
%macro cmp_name_files 3
	push bx

    ;write_n %1,8
	;writeln %2
	;writeln %3
	;readln NULL_BUF
	mov bx,0
%%loop_name_file:
    mov dl,byte [%1+bx]
	cmp dl,' '
	je %%proverka_name_files
    cmp dl,byte [%2+bx]
    jne %%no_file
	inc bx
	cmp bx,8
	jb %%loop_name_file
	mov bx,0
	jmp %%loop_maska_file
	
	

%%proverka_name_files
   cmp byte[%2+bx],'$'
   jne %%no_file   
   mov bx,0
   jmp %%loop_maska_file

%%proverka_maska_files
   cmp byte[%3+bx],'$'
   jne %%no_file   
   jmp %%yes_file

   
    
%%loop_maska_file:
    mov dl,byte [%1+bx+8]
	cmp dl,' '
	je %%proverka_maska_files
    cmp dl,byte [%3+bx]
    jne %%no_file
	inc bx
	cmp bx,3
	jb %%loop_maska_file
	jmp %%yes_file
	
   
	
	
	
%%yes_file:
	;dx=0
	mov dx,0
	jmp %%exit_cmp_files
	
%%no_file:	
   ;dx=1
   mov dx,1

%%exit_cmp_files:	

	pop bx
%endmacro 	

; ---------------------------------------------- ;

				; cmp_name_dir(buf1,buf2)  
				; макрос сравнения названия двух директорий
%macro cmp_name_dir 2
   ; buf1 di буфер ввода
   ; buf2 si буфер директории фат   
push di
push si
push bx
   
	mov 	di,%1		; buf1
	
	mov bx,0
%%loop:
 
 
	mov dh,byte [di+bx+2]
 	mov dl,byte [%2+bx]
 
	cmp dl,' '
	je %%prov_1
	cmp dh,dl
	jne %%no_eqv
	jmp %%cmp_next
	
	
	

%%prov_1:
   cmp bl,byte [di+1]
   jne %%no_eqv
   jmp %%yes_eqv

%%yes_eqv:
  mov dx,1
  jmp %%cmp_exit

%%no_eqv:
   mov dx,0
   jmp %%cmp_exit   


%%cmp_next	
	inc 	bx 	
	cmp 	bx,8 		; Конечный сектор
	jb %%loop
	
	cmp byte [di+1],8
	je %%yes_eqv
	jmp %%no_eqv
%%cmp_exit:	
  
   pop bx
   pop si
   pop di
	
%endmacro 	


; ---------------------------------------------- ;
				; set_path(buf) 
				;  установка пути в командной строке
%macro set_path 1
    
	push di
	push bx
	push cx
    push dx
	
	mov 	di,%1		; Буфер
	mov bx,0
	mov cx,[INDEX_PATH]
%%loop_str:
    mov dl,byte [di+bx+2] 
    push bx
    mov bx,cx
    mov byte [PATH+bx],dl
    pop bx
    
    inc cx
    inc bx    
	
	cmp bl,byte [di+1]
	jb %%loop_str
	
	mov bx,cx
    mov byte [PATH+bx],'\'
	inc bx
	mov byte [PATH+bx],'$'

	mov [INDEX_PATH],bx
	
	pop dx
	pop cx
	pop bx
	pop di
	

%endmacro 	
; ---------------------------------------------- ;
				; last_path   
				; изменение пути, когда перход вверх ("..")
%macro last_path 0
	push bx

	mov bx,[INDEX_PATH]
	sub bx,1
%%find_slesh:
    dec bx
	cmp byte [PATH+bx],'\'
	jne %%find_slesh
	mov byte [PATH+bx+1],'$'
	inc bx
	mov [INDEX_PATH],bx
	
	pop bx
	
%endmacro 	

%endif