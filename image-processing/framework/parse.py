import xml.etree.ElementTree as ET
from os import sys

#Return *.c for 1, *.o for 2
#tipo = sys.argv[1]
#names_files = []
names_files = []
names_functions = []
hosts_ips = []
names = ""

root = ET.parse('startup.xml').getroot()

arquivo = open("Makefile","w")

functions_file = open("functions_names","w")

hosts = open("comm/hosts.cfg","w")
config = open("comm/config","w")
rank = 0
cont_rank = 0

cont = 0

for neighbor in root.iter('ipmachine'):
	cont_rank = 0
	hosts.write(neighbor.get('ip')+" slots="+neighbor.get('ngpus')+"\n")
	while(cont_rank < int(neighbor.get('ngpus'))):
		config.write(str(rank)+"\t"+str(cont_rank)+"\n")
		cont_rank = cont_rank + 1
		rank = rank + 1


for neighbor in root.iter('file'):
	names_files.append(neighbor.get('name'))

for neighbor in root.iter('func'):
	cont +=1
	names_functions.append(neighbor.get('funcName'))


for neighbor in root.iter('file'):
	names = names +" "+ neighbor.get('name')

functions_file.write(str(cont)+"\n")
for i in names_functions:
	functions_file.write(i+"\n")


#for i in hosts_ips:
#	hosts.write(i+"\n");

cudacc = "/usr/local/cuda-8.0/bin/nvcc"
mkcuda = "$(CUDACC)"
objs = ""
for i in names_files:
	objs = objs+i.strip(".cu")+".o"+" "


arquivo.write("CUFILES= "+names+"\n")
arquivo.write("OBJS= funcoes.o "+objs+"\n")
arquivo.write("TARGET= $(OBJS) link.o libfw.so"+"\n")
arquivo.write("CUDACC= "+cudacc+"\n")
arquivo.write("\n")
arquivo.write("all: framework file\n")
arquivo.write("\n")
arquivo.write("framework:\n")
arquivo.write("\t$(MAKE) -C ./comm/\n")
arquivo.write("\n")
arquivo.write("file: $(TARGET)"+"\n")
arquivo.write("\n")
arquivo.write("\n")
arquivo.write("libfw.so: link.o \n")
arquivo.write("\tg++  -shared -Wl,-soname,libfw.so -o libfw.so $(OBJS) comm/comm.o link.o -L/usr/local/cuda-8.0/lib64  -lcudart -lpng\n")
arquivo.write("\n")
arquivo.write("\n")
arquivo.write("link.o: "+names+"\n")
arquivo.write("\t"+ mkcuda +"  -m64   -arch=sm_20 -lpng16 -dlink -Xcompiler  -fPIC  comm/comm.o $(OBJS) -o link.o\n")
arquivo.write("\n")
arquivo.write("funcoes.o: funcoes.h funcoes.cu\n")
arquivo.write("\t"+ mkcuda +" -m64 -arch=sm_20 -dc  -Xcompiler -fPIC -c funcoes.cu\n")
arquivo.write("\n")
arquivo.write("\n")
for i in names_files:
	arquivo.write(i.strip(".cu")+".o: "+i+" "+i.strip(".cu")+".h comm/comm.h\n")
	arquivo.write("\t"+mkcuda+" -m64 -arch=sm_20 -dc  -Xcompiler -fPIC -c "+i+" \n")
	arquivo.write("\n")
	arquivo.write("\n")

arquivo.write("clean: \n")
arquivo.write("\trm -f link.o libfw.so "+ objs +" \n")
arquivo.write("\t$(MAKE) -C ./comm/ clean\n")


