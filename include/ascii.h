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

; ascii.h
; ���������� ������� ������� ASCII
;
; Copyright (c) 2007 Vadim Ipatov
;
; email: Vadim Ipatov <euphoria.vi@gmail.com>

%ifndef ASCII_H
%define ASCII_H

; ---------------------------------------------- ;

  ASCII_NUL	equ 0x00	; ����� (����� ������)
  ASCII_SOH	equ 0x01	; ������ ���������
  ASCII_STX	equ 0x02	; ������ ������
  ASCII_ETX	equ 0x03	; ����� ������
  ASCII_EOT	equ 0x04	; ����� ��������
  ASCII_ENQ	equ 0x05	; ������
  ASCII_ACK	equ 0x06	; �������������
  ASCII_BEL	equ 0x07	; ������
  ASCII_BS	equ 0x08	; ��� �����
  ASCII_HT	equ 0x09	; �������������� ���������
  ASCII_LF	equ 0x0A	; ������� ������
  ASCII_VT	equ 0x0B	; ������������ ���������
  ASCII_FF  	equ 0x0C	; ������ �����
  ASCII_CR	equ 0x0D	; ������� �������
  ASCII_SO	equ 0x0E	; Shift out
  ASCII_SI	equ 0x0F	; Shift in
  ASCII_DLE	equ 0x10	; Data line escape
  ASCII_DC1	equ 0x11	; Device ctrl 1 (X-ON)
  ASCII_DC2	equ 0x12	; Device ctrl 2
  ASCII_DC3	equ 0x13	; Device ctrl 3 (X-OFF)
  ASCII_DC4	equ 0x14	; Device ctrl 4
  ASCII_NAK	equ 0x15	; �����. �������������
  ASCII_SYN	equ 0x16	; �������������
  ASCII_ETB	equ 0x17	; ����� ����� ��������
  ASCII_CAN	equ 0x18	; �����
  ASCII_EM	equ 0x19	; ����� ��������
  ASCII_SUB	equ 0x1A	; �����������
  ASCII_ESC	equ 0x1B	; Escape
  ASCII_FS	equ 0x1C	; ����������� ������
  ASCII_GS	equ 0x1D	; ����������� �����
  ASCII_RS	equ 0x1E	; ����������� �������
  ASCII_US	equ 0x1F	; ����������� �����
    
; ---------------------------------------------- ;

%endif