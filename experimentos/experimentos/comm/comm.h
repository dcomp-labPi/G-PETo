#ifndef COMM_H
#define COMM_H



enum Type { SHORT, INT, LONG, LONG_LONG, UNSIGNED_CHAR, UNSIGNED_SHORT, UNSIGNED, UNSIGNED_LONG, UNSIGNED_LONG_LONG, FLOAT, DOUBLE, LONG_DOUBLE, BYTE};

extern void sendMessage(char *origem,char *destino, Type tipo, void *buffer, int size);

extern void receiveMessage(char *destino,char *origem, Type tipo, void *buffer, int size);

#endif
