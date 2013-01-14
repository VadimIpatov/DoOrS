/*
 *  Copyright (C) 2007  The DoOrS Team
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */
 
/*
* bootwrite.c
* Запись загрузчика в образ дискеты
*
* Copyright (c) 2007 Vadim Ipatov
*
* email: Vadim Ipatov <euphoria.vi@gmail.com>
*/

#pragma hdrstop
#pragma argsused
#include <stdio.h>

int main(int argc, char* argv[])
{
  char *buf[512];
  FILE *img,*boot;

  if (argc<3) {
    printf("Usage: bootwrite.exe floppyimage bootsect\n");
    return 3;
  }

  if (boot=fopen(argv[2],"rb")) {
    if (!fread(buf,512,1,boot)) {
        printf("'%s' ReadError!\n",argv[1]);
        return 2;
    }
    fclose(boot);

    if (img=fopen(argv[1],"r+b+")) {
      if (!fwrite(buf,512,1,img)) {
        printf("'%s' WriteError!\n",argv[2]);
        return 2;
      }

      fclose(img);
    } else {
        printf("'%s' WriteError!\n",argv[2]);
        return 1;
      }

  } else {
      printf("'%s' ReadError!\n",argv[1]);
      return 1;
    }

  printf("Boot sector is successfully written!\n");
  return 0;
}
