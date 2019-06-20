include(`/usr/local/src/sendmail-8.15.2/cf/m4/cf.m4')dnl
DOMAIN(`generic')dnl
OSTYPE(`linux')dnl
define(`confDEF_USER_ID',``8:8'')dnl
define(`confPID_FILE', `/var/run/sendmail/sendmail.pid')dnl
FEATURE(`local_lmtp')dnl
define(`ALIAS_FILE',`/etc/mail/aliases')dnl
define(`QUEUE_DIR', `/var/spool/mqueue')dnl
define(`MSP_QUEUE_DIR', `/var/spool/clientmqueue')dnl
define(`confFORWARD_PATH', `$z/.forward.$w+$h:$z/.forward+$h:$z/.forward.$w:$z/.forward')dnl
FEATURE(`redirect')dnl
FEATURE(`access_db')dnl
FEATURE(`local_procmail', `/usr/bin/maildrop', `maildrop -d $u')dnl
LOCAL_DOMAIN(`localhost')dnl
FEATURE(`smrsh',`/usr/local/libexec/smrsh')dnl
FEATURE(`use_cw_file')dnl
GENERICS_DOMAIN_FILE(`/etc/mail/local-host-names')dnl
FEATURE(`genericstable')dnl
FEATURE(`virtusertable')dnl
FEATURE(`no_default_msa',`dnl')dnl
define(`confDOMAIN_NAME', `ec2-13-52-39-134.us-west-1.compute.amazonaws.com')dnl
dnl MASQUERADE_AS(`gturn.xyz')dnl
dnl FEATURE(`masquerade_envelope')dnl
dnl FEATURE(`always_add_domain')dnl
EXPOSED_USER(`root')dnl
define(`confPRIVACY_FLAGS', `noexpn,novrfy,noverb,noetrn')dnl
define(`confPRIVACY_FLAGS', ``goaway,authwarnings,restrictmailq,restrictqrun'')dnl
define(`confBAD_RCPT_THROTTLE', `1')dnl
define(`confTO_IDENT',`0')dnl
define(`confCACERT_PATH', `/etc/ssl/certs')dnl
define(`confCRL', `/etc/mail/ssl/revoke.crl')dnl
define(`confCACERT', `/etc/mail/ssl/bundle.pem')dnl
define(`confSERVER_CERT', `/etc/mail/ssl/sendmail.crt')dnl
define(`confSERVER_KEY', `/etc/mail/ssl/sendmail.key')dnl
define(`confCLIENT_CERT', `/etc/mail/ssl/sendmail.crt')dnl
define(`confCLIENT_KEY', `/etc/mail/ssl/sendmail.key')dnl
dnl DAEMON_OPTIONS(`Family=inet, Port=465, Name=MTA-SSL, M=s')dnl
dnl DAEMON_OPTIONS(`Port=smtp, Name=MTA')dnl
DAEMON_OPTIONS(`Family=inet,  Name=MTA-v4, Port=smtp')dnl
DAEMON_OPTIONS(`Family=inet,  Name=MSP-v4, Port=submission, Modifiers=Ea')dnl
dnl ## DAEMON_OPTIONS(`Port=smtp,Addr=127.0.0.1, Name=MTA')dnl
define(`confTLS_SRV_OPTIONS',`V')dnl
dnl ## sasl authentication
define(`confAUTH_OPTIONS', `A p')dnl
TRUST_AUTH_MECH(`LOGIN PLAIN')dnl
define(`confAUTH_MECHANISMS', `LOGIN PLAIN')dnl
define(`confLOG_LEVEL',`14')dnl
define(`confMILTER_LOG_LEVEL',`10')dnl
INPUT_MAIL_FILTER(`opendkim', `S=inet:8891@localhost')
INPUT_MAIL_FILTER(`mimedefang',`S=unix:/var/spool/MIMEDefang/mimedefang.sock,  T=S:1m;R:1m')dnl
MAILER(`local')dnl
MAILER(`smtp')dnl
MAILER(`procmail')dnl
