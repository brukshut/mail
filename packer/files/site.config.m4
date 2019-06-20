dnl ## $Id: site.config.m4 260 2012-11-04 15:04:49Z cgough $
define(`confOS_TYPE', `Linux')
dn ## shared objects
define(`confCCOPTS', `-fPIC')
define(`confCCOPTS_SO', `-fPIC')
APPENDDEF(`confLDOPTS_SO', `--shared')
APPENDDEF(`confLIBS', `-lssl -lcrypto -lsasl2 -lnsl -lpthread -lresolv -ldb')
APPENDDEF(`confINCDIRS', ``-I/usr/local/include/openssl'')
APPENDDEF(`confLIBDIRS', ``-L/usr/local/lib'')
APPENDDEF(`confLIBDIRS', ``-Wl,-rpath=/usr/local/lib'')
APPENDDEF(`confENVDEF', `-DSTARTTLS -DHASURANDOMDEV')
APPENDDEF(`confENVDEF', `-DSASL=20127')
dnl ## libmilter
APPENDDEF(`conf_sendmail_ENVDEF', `-DMILTER')
APPENDDEF(`conf_libmilter_ENVDEF', `-D_FFR_MILTER_ROOT_UNSAFE')
dnl ## berkeley db hash maps
APPENDDEF(`confMAPDEF', `-DNEWDB')
dnl ## no stats file
define(`confNO_STATISTICS_INSTALL')
define(`confNO_HELPFILE_INSTALL')
dnl ## disable NIS support
APPENDDEF(`confENVDEF', `-UNIS')
APPENDDEF(`confENVDEF', `-UNISPLUS')
dnl ## install locations
define(`confMBINDIR', `/usr/local/sbin/')
define(`confUBINDIR', `/usr/local/bin/')
define(`confEBINDIR', `/usr/local/libexec/')
define(`confUBINOWN', `root')
define(`confUBINGRP', `smmsp')
define(`confSBINOWN', `root')
define(`confSBINGRP', `smmsp')
define(`confMBINDIR', `/usr/local/sbin/')
define(`confUBINDIR', `/usr/local/bin/')
define(`confSBINDIR', `/usr/local/sbin')
define(`confLIBDIR', `/usr/local/lib')
define(`confSHAREDLIBDIR', `/usr/local/lib')
define(`confINCLUDEDIR', `/usr/local/include')
define(`confMANROOT', `/usr/local/share/man/man')
define(`confMANROOTMAN', `/usr/local/share/man/man')
define(`confINSTALL_RAWMAN')
define(`confMANOWN', `root')
define(`confMANGRP', `smmsp')


