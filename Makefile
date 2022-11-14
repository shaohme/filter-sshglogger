LOCALBASE?= /usr/local/

PROG=	filter-sshglogger
MAN=	filter-sshglogger.8
BINDIR=	${LOCALBASE}/libexec/smtpd/
MANDIR=	${LOCALBASE}/man/man

SRCS+=	main.c

CFLAGS+=-I${LOCALBASE}/include
CFLAGS+=-Wall -I${.CURDIR}
CFLAGS+=-Wstrict-prototypes -Wmissing-prototypes
CFLAGS+=-Wmissing-declarations
CFLAGS+=-Wshadow -Wpointer-arith -Wcast-qual
CFLAGS+=-Wsign-compare
LDFLAGS+=-L${LOCALBASE}/lib
LDADD+= -levent -lopensmtpd
DPADD=	${LIBEVENT}

bindir:
	${INSTALL} -d ${DESTDIR}${BINDIR}

.include <bsd.prog.mk>
