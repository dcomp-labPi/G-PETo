#include "funcoes.h"
#include "comm/comm.h"

#ifdef _FUNC_1_
#define _FUNC_1_

///Operação estática feita pelas funções que processam
void processa_vetor_pixel(RGBA *buffer, int size);

///Envia mensagem para as outras funções e recebe o resultado
extern "C" void funcaoEnv1();

extern "C" void funcaoProc1(); ///Processa dados

extern "C" void funcaoProc2(); ///Processa dados

//extern "C" void funcaoProc3(); ///Processa dados

#endif /*_FUNC_1_*/