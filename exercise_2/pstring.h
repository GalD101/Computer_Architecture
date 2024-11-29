#ifndef PSTRING_H
#define PSTRING_H

typedef struct {
	unsigned char len;
	char str[255];
} Pstring;

char pstrlen(Pstring* pstr);

Pstring* swapCase(Pstring* pstr);

Pstring* pstrijcpy(Pstring* dst, Pstring* src, char i, char j);

Pstring* pstrcat(Pstring* dst, Pstring* src);

#endif
