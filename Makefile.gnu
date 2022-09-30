LOCALBASE?=	/usr/

PROG=		filter-sshglogger
MAN=		filter-sshglogger.8
BINDIR=		${LOCALBASE}/libexec/opensmtpd/
MANDIR=		${LOCALBASE}/share/man/man8

SRCS+=		main.c

CFLAGS+=	-I${LOCALBASE}/include
CFLAGS+=	-DPROG=${PROG}
CFLAGS+=	-Wall -I${.CURDIR}
CFLAGS+=	-Wstrict-prototypes -Wmissing-prototypes
CFLAGS+=	-Wmissing-declarations
CFLAGS+=	-Wshadow -Wpointer-arith -Wcast-qual
CFLAGS+=	-Wsign-compare
CFLAGS+=	${CRYPT_CFLAGS}
CFLAGS+=	-I${CURDIR}

LDFLAGS+=	-L${LOCALBASE}/lib
LDFLAGS+=	${CRYPT_LDFLAGS}
LDADD+=		${CRYPT_LDADD} -lopensmtpd

INSTALL?=	install

MANFORMAT?=		mangz

BINOWN?=	root
BINGRP?=	root
BINPERM?=	755
MANOWN?=	root
MANGRP?=	root
MANPERM?=	644

ifeq (${MANFORMAT}, mangz)
TARGET_MAN=		${MAN}.gz
CLEANFILES+=		${TARGET_MAN}
${TARGET_MAN}: ${MAN}
	mandoc -Tman ${MAN} | gzip > $@
else
TARGET_MAN=		${MAN}
endif

${SRCS:.c=.d}:%.d:%.c
	 ${CC} ${CFLAGS} -MM $< >$@
CLEANFILES+=	${SRCS:.c=.d}

OBJS=		${notdir ${SRCS:.c=.o}}
CLEANFILES+=	${OBJS}

${PROG}: ${OBJS}
	${CC} ${LDFLAGS} -o $@ ${OBJS} ${LDADD}

.DEFAULT_GOAL=		all
.PHONY: all
all: ${PROG} ${TARGET_MAN}
CLEANFILES+=	${PROG}

.PHONY: clean
clean:
	rm -f ${CLEANFILES}

.PHONY: install
install: ${PROG}
	${INSTALL} -D -o ${BINOWN} -g ${BINGRP} -m ${BINPERM} ${PROG} ${DESTDIR}${BINDIR}/${PROG}
	${INSTALL} -D -o ${MANOWN} -g ${MANGRP} -m ${MANPERM} ${TARGET_MAN} ${DESTDIR}${MANDIR}/${TARGET_MAN}
