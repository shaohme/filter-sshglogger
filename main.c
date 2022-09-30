/*
 * Copyright (c) 2022 Martin Kjær Jørgensen <me@lagy.org>
 *
 * Permission to use, copy, modify, and distribute this software for
 * any purpose with or without fee is hereby granted, provided that
 * the above copyright notice and this permission notice appear in all
 * copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
 * WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
 * AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
 * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
 * OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
 * NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
 * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#include <syslog.h>
#include <errno.h>
#include <string.h>
#include <sys/time.h>
#include <opensmtpd.h>
#include <netdb.h>
#include <unistd.h>

void on_auth (struct osmtpd_ctx *ctx,
    const char *username,
    enum osmtpd_auth_result result);

int main (int argc, char *argv[])
{
#ifdef __OpenBSD__
	int rc = pledge ("unix flock stdio", NULL);
	if (rc != 0) {
		int errnum = errno;
		osmtpd_errx (1, "pledge error: rc=%d, err=%d, errstr=%s", rc, errnum,
		    strerror (errnum));
	}
#endif
	openlog ("filter-sshglogger", LOG_NDELAY, LOG_USER);
	syslog (LOG_INFO, "starting");
	osmtpd_register_report_auth (1, on_auth);
	osmtpd_need(OSMTPD_NEED_SRC);
	syslog (LOG_INFO, "running");
	osmtpd_run ();

	syslog (LOG_INFO, "stopping");
	closelog ();
	return 0;
}

void on_auth (struct osmtpd_ctx *ctx,
    const char *username,
    enum osmtpd_auth_result result)
{
	char hoststr[NI_MAXHOST];
	char portstr[NI_MAXSERV];
	socklen_t client_len = sizeof (struct sockaddr_storage);

	int rc = getnameinfo ((struct sockaddr *) &ctx->src, client_len, hoststr,
	    sizeof (hoststr), portstr, sizeof (portstr),
	    NI_NUMERICHOST | NI_NUMERICSERV);

	if (rc != 0) {
		int errnum = errno;
		osmtpd_errx (1, "getnameinfo rc '%d' of ss_family '%d' err '%d' '%s'", rc, ctx->src.ss_family, errnum,
		    strerror (errnum));
	}
	if(result == OSMTPD_AUTH_FAIL) {
		syslog (LOG_INFO, "Invalid user %s from %s port %s", username, hoststr, portstr);
	}
}
