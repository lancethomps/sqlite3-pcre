VERSION=0.1.1
CC=gcc
INSTALL=install
DEBUG?=#-D_DEBUG
VERBOSE?=-v -Wp,-v
CFLAGS=$(shell pkg-config --cflags sqlite3 libpcre)
LIBS=$(shell pkg-config --libs libpcre)
prefix=$(shell brew --prefix)

.PHONY: build install dist clean debug

pcre.dylib: pcre.c
	@# ${CC} -g -fPIC -dynamiclib ${CFLAGS} -L${prefix}/lib -W -Werror ${LIBS} -lsqlite3 -I${prefix}/include pcre.c -o $@
	@############################################# original upstream install #############################################
	@# ${CC} -shared -o $@ ${CFLAGS} -W -Werror pcre.c ${LIBS} -Wl,-z,defs
	@############################################# modified custom install #############################################
	@# gcc -g -fPIC -dynamiclib -o $@ -L"${prefix}/lib" -lsqlite3 -lpcre -Werror pcre.c -I"${prefix}/include"
	@############################################# original custom install #############################################
	@# gcc -shared -o pcre.so -L/usr/local/lib -lsqlite3 -lpcre -Werror pcre.c -I/usr/local/include
	${CC} -g -fPIC -dynamiclib -o $@ -L"${prefix}/opt/sqlite/lib" -L"${prefix}/lib" -lsqlite3 -lpcre -W -Werror -Wno-unused-parameter pcre.c -I"${prefix}/opt/sqlite/include" -I"${prefix}/include" $(DEBUG) $(VERBOSE)

build: pcre.dylib

install: build
	#rm -v ${DESTDIR}${prefix}/lib/sqlite3/pcre.dylib
	${INSTALL} -pv -m755 pcre.dylib ${DESTDIR}${prefix}/lib/sqlite3/pcre.dylib

dist: clean
	mkdir sqlite3-pcre-${VERSION}
	cp -f pcre.c Makefile readme.txt sqlite3-pcre-${VERSION}
	tar -czf sqlite3-pcre-${VERSION}.tar.gz sqlite3-pcre-${VERSION}

clean:
	rm -f pcre.so pcre.dylib

debug:
	@echo "CFLAGS=$(CFLAGS)"
	@echo "LIBS=$(LIBS)"
