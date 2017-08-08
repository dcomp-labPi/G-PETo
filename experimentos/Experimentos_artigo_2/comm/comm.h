#include "funcs.h"
#ifndef COMM_H
#define COMM_H

extern void sendMessage(char *origem,char *destino, Type tipo, void *buffer, int size);

extern void receiveMessage(char *destino,char *origem, Type tipo, void *buffer, int size);

#endif
