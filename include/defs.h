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

; defs.h
; Определения
;
; Copyright (c) 2007 Vadim Ipatov
;
; email: Vadim Ipatov <euphoria.vi@gmail.com>

%ifndef DEFS_H 
%define DEFS_H 

%include "..\include\routine.h"
%include "..\include\disk.h"

DEBUG		equ 0

vid  		equ 0x10
disk 		equ 0x13
ext_at		equ 0x15
keyb 		equ 0x16

kernseg 	equ 0x1000
progseg		equ 0x1B1E
vidtseg 	equ 0xb800

VERSION_MAJOR	equ 1
VERSION_MINOR	equ 0

%endif