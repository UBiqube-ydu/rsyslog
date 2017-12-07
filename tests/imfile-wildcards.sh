#!/bin/bash
# This is part of the rsyslog testbench, licensed under GPLv3
export IMFILEINPUTFILES="10"
echo [imfile-wildcards.sh]
. $srcdir/diag.sh check-inotify
. $srcdir/diag.sh init
# generate input files first. Note that rsyslog processes it as
# soon as it start up (so the file should exist at that point).

imfilebefore="rsyslog.input.1.log"
./inputfilegen -m 1 > $imfilebefore

# Start rsyslog now before adding more files
. $srcdir/diag.sh startup imfile-wildcards.conf
# sleep a little to give rsyslog a chance to begin processing
sleep 1

for i in `seq 2 $IMFILEINPUTFILES`;
do
	cp $imfilebefore rsyslog.input.$i.log
	imfilebefore="rsyslog.input.$i.log"
	# Wait little for correct timing
	./msleep 50
done
./inputfilegen -m 3 > rsyslog.input.$((IMFILEINPUTFILES + 1)).log
ls -l rsyslog.input.*

# sleep a little to give rsyslog a chance for processing
sleep 1

. $srcdir/diag.sh shutdown-when-empty # shut down rsyslogd when done processing messages
. $srcdir/diag.sh wait-shutdown	# we need to wait until rsyslogd is finished!

printf 'HEADER msgnum:00000000:, filename: ./rsyslog.input.1.log, fileoffset: 0
HEADER msgnum:00000000:, filename: ./rsyslog.input.2.log, fileoffset: 0
HEADER msgnum:00000000:, filename: ./rsyslog.input.3.log, fileoffset: 0
HEADER msgnum:00000000:, filename: ./rsyslog.input.4.log, fileoffset: 0
HEADER msgnum:00000000:, filename: ./rsyslog.input.5.log, fileoffset: 0
HEADER msgnum:00000000:, filename: ./rsyslog.input.6.log, fileoffset: 0
HEADER msgnum:00000000:, filename: ./rsyslog.input.7.log, fileoffset: 0
HEADER msgnum:00000000:, filename: ./rsyslog.input.8.log, fileoffset: 0
HEADER msgnum:00000000:, filename: ./rsyslog.input.9.log, fileoffset: 0
HEADER msgnum:00000000:, filename: ./rsyslog.input.10.log, fileoffset: 0
HEADER msgnum:00000000:, filename: ./rsyslog.input.11.log, fileoffset: 0
HEADER msgnum:00000001:, filename: ./rsyslog.input.11.log, fileoffset: 17
HEADER msgnum:00000002:, filename: ./rsyslog.input.11.log, fileoffset: 34\n' | cmp -b rsyslog.out.log
if [ ! $? -eq 0 ]; then
  echo "invalid output generated, rsyslog.out.log is:"
  cat rsyslog.out.log
  exit 1
fi;

. $srcdir/diag.sh exit
