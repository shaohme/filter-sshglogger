# filter-sshglogger

One day I noticed something brute forcing authentication attempts on
my `opensmtpd` server which already runs `sshguard` protecting sshd, so
I wondered if I could protect `opensmtpd` the same way ...

## Description
This filter listens on `opensmtpd` authentication attempts and checks
if they fail because of incorrect username or password combination. If
so, it logs the attempt to `syslog` in a format `sshguard` parses
correctly, and let it and `pf` decide what to do.

## Dependencies
It requires OpenSMTPD 6.6.0 or higher and needs an extended version of
`libopensmtpd` not yet merged. See changes here
[libopensmtpd](<https://github.com/shaohme/libopensmtpd>)

## How to install
Install the modified `libopensmtpd` library metioned in dependencies by
cloning it at running:

```
$ doas make install
```

This should install or overwrite existing `libopensmtpd` library with a
modified version allowing filters to subscribe to authentication
events.

Afterwards close this repository and run the usual install command:

```
$ doas make install
```

The filter should now be installed in default `opensmtpd` filters
directory `/usr/local/libexec/smtpd`

## How to configure
The filter itself requires no configuration.

It must be declared in smtpd.conf and attached to a listener for sessions to go through filter-sshglogger:
```
# smtpd.conf
...
filter sshguard proc-exec "filter-sshglogger"

...
listen on all port smtp tls pki "default" filter { "rdns", "sshguard" }
```

`filter-sshglogger` will open a syslog interface and log failed
authentication attempts using its own application name. This should
probably be written to its own logfile, like so:

```
# /etc/syslog.conf
...
!!filter-sshglogger
*.*                                                     /var/log/smtpd-sshg
```

`sshguard` should be configured to pickup these events and act
accordingly, like so:

```
# /etc/sshguard.conf

BACKEND="/usr/local/libexec/sshg-fw-pf"
...
FILES="/var/log/authlog /var/log/maillog /var/log/smtpd-sshg"
```

`syslog` omits repeated entries in logs. `sshguard` might need these
repeated entires to form a judgement. To make `syslog` stop omitting
these entries, simply add:

```
# /etc/rc.conf.local
...
syslogd_flags=-rr
```

From now on `sshguard` should recognize failed authentication attempts
and block the peer temporarily using the same rules as with SSH, etc.
