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
; Загрузчик
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
  jmp start			; [0x00] Безусловный переход на загрузочный код 
  OEM 		db "DoOrS 95"	; [0x03] Аббревиатура и номер версии ОС 
  SectSize 	dw 512 		; [0x0B] Число байт в секторе
  ClustSize 	db 1 		; [0x0D] Число секторов в кластере
  Ressect 	dw 1 		; [0x0E] Число резервных секторов в резервной области раздела, начиная с первого сектора раздела 
  FatCnt 	db 2 		; [0x10] Число копий FAT 
  RootSize 	dw 224 		; [0x11] Количество 32-байтных дескрипторов файлов в корневом каталоге
  TotalSect 	dw 2880 	; [0x13] Общее число секторов 
  Media 	db 0xF0 	; [0x15] Тип носителя информации (Гибкий диск: 2 стороны, 18 секторов на дорожке)
  FatSize 	dw 9 		; [0x16] Количество секторов, занимаемых FAT 
  TrackSect 	dw 18 		; [0x18] Число секторов на дорожке 
  HeadCnt 	dw 2 		; [0x1A] Число головок 
  HidenSect 	dd 0 		; [0x1C] Число скрытых секторов перед разделом
  HugeSect 	dd 0 		; [0x20] Используется FAT32 
  BootDrv 	db 0 		; [0x24] Номер дисковода 
  Reserv 	db 0 		; [0x25] Зарезервировано для Windows NT
  BootSign 	db 0x29 	; [0x26] Признак расширенной загрузочной записи 
  VolID 	dd 0 		; [0x27] Номер логического диска 
  VoLabel 	db "System     "; [0x2B] Метка диска 
  FSType 	db "FAT12   " 	; [0x36] Аббревиатура типа файловой системы   
  
; ---------------------------------------------- ;  
  
start:  
  	cli
  	mov	ax,cs
  	mov	ds,ax
  	mov	ss,ax
  	mov	sp,__entry_point
  	sti
    
%include "bootlogo.asm"
 
clrscr:					; Очистим экран
	mov 	ax,0x03
	int 	vid
  
load_kernel:				; Грузим ядро - первый файл в корневом каталоге
	mov	ax,kernseg
	mov	es,ax			; Точка входа - [kernseg:0] di=0
     		; 33 сектор - здесь начинается ядро =))
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
	cmp	dx,160			; Всего (160-33+1)*512 = 128 секторов = 64 кб
	jne	nextsect
	
; --------- А ядро ли мы загрузили? =) --------- ;  	

	mov	di,2
	mov	ax,kernseg
	mov	es,ax
	mov	ax, word [es:di]
	cmp	ax,word 0xABCD
	jne	readerror

	jmp	kernseg:0		; Передаем управление на считанный код
  
; ----- Перевод № сектора в параметры BIOS ----- ;   

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
 
	mov	dx,[ABSHEAD]	; dh - головка
	mov	dh,dl
	mov	dl,0		; dl - диск (0 для fd0)
	mov	al,1		; al - кол-во считываемых секторов
	mov	ah,0x02		; Чтение с диска
	int	disk
  
	jnc 	readdone	; Ошибка, если CF=1, ah = код ошибки
  
readerror:
	mov	ax,cs		; Сделаем всё как было =)
	mov	es,ax
	cmp	di,2
	je	kernel_not_found
	write	MSG1,2,cllight_red
	jmp	short exit
kernel_not_found:	
	write	MSG0,5,cllight_red
exit:
	xor	ax,ax
	int 	keyb		; Ждём нажатия клавиши
	int 	0x19  
    
readdone:  
	ret
	
; ---------------------------------------------- ; 

write_proc:
	mov 	ax,0x1301
	int 	vid
	
	ret
	
; ------------------- ДАННЫЕ ------------------- ;

	MSG0 db "Krnl?"				; Ядро не найдено
	MSG1 db "RE"				; Ошибка чтения
	MSG2 db "Now Loading..."
	MSG3 db "*"
	MSG4 db "* DoOrS  '95 *"
	
	ABSSECT dw 0
	kern_sect dw 33
	ABSHEAD dw 0
	times 510-($-$$) db 0
    ;db 0x55,0xaa 	; В конце загрузочного сектора должны
  	SIGN dw 0xAA55		; содержаться данные 2 байта
  	
; ---------------------------------------------- ;  	