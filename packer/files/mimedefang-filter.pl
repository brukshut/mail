##
## /etc/mail/mimedefang-filter.pl
##

## Enable spamassassin
$SALocalTestsOnly = 0;

## Enable clamav
#$Features{'Virus:CLAMAV'} = ('/usr/bin/clamscan' ne '/bin/false' ? '/usr/bin/clamscan' : 0);
#$Features{'Virus:CLAMD'}  = ('/usr/sbin/clamd' ne '/bin/false' ? '/usr/sbin/clamd' : 0);

$AdminAddress = 'abuse@bitpusher.org';
$AdminName = "abuse@bitpusher.org";
$DaemonAddress = 'mimedefang@localhost';
$AddWarningsInline = 0;
md_graphdefang_log_enable('mail', 1);
$MaxMIMEParts = 50;
$Stupidity{"NoMultipleInlines"} = 0;
detect_and_load_perl_modules();

## This procedure returns true for entities with bad filenames.
sub filter_bad_filename  {
  my($entity) = @_;
  my($bad_exts, $re);

  ## bad extensions
  $bad_exts = '(ade|adp|app|asd|asf|asx|bas|bat|chm|cmd|com|cpl|crt|dll|exe|fxp|hlp|hta|hto|inf|ini|ins|isp|jse?|lib|lnk|mdb|mde|msc|msi|msp|mst|ocx|pcd|pif|prg|reg|scr|sct|sh|shb|shs|sys|url|vb|vbe|vbs|vcs|vxd|wmd|wms|wmz|wsc|wsf|wsh|\{[^\}]+\})';

  ## Do not allow:
  ## - CLSIDs  {foobarbaz}
  ## - bad extensions (possibly with trailing dots) at end
  $re = '\.' . $bad_exts . '\.*$';

  return 1 if (re_match($entity, $re));

  ## look inside zip files
  if (re_match($entity, '\.zip$') and $Features{"Archive::Zip"}) {
    my $bh = $entity->bodyhandle();
    if (defined($bh)) {
      my $path = $bh->path();
      if (defined($path)) {
        return re_match_in_zip_directory($path, $re);
      }
    }
  }
  return 0;
}

##
## %PROCEDURE: filter_begin
## %ARGUMENTS:
##  $entity -- the parsed MIME::Entity
## %RETURNS:
##  Nothing
## %DESCRIPTION:
##  Called just before e-mail parts are processed
##

sub filter_begin {
  my($entity) = @_;
  ## ALWAYS drop messages with suspicious chars in headers
  if ($SuspiciousCharsInHeaders) {
    md_graphdefang_log('suspicious_chars');
    ## action_quarantine_entire_message("Message quarantined because of suspicious characters in headers");
    ## Do NOT allow message to reach recipient(s)
    return action_discard();
  }

  ## don't scan outgoing mail
  return if (defined($SendmailMacros{"auth_type"}));
  return if ($RelayAddr eq "127.0.0.1");

  ## Copy original message into work directory as an "mbox" file for scanning
  ## needed for clamav
  #md_copy_orig_msg_to_work_dir_as_mbox_file();

  ## Scan for viruses if any virus-scanners are installed
  #my($code, $category, $action) = message_contains_virus();

  ## Lower level of paranoia - only looks for actual viruses
  #$FoundVirus = ($category eq "virus");

  ## Higher level of paranoia - takes care of "suspicious" objects
  #$FoundVirus = ($action eq "quarantine");
  
  #if ($FoundVirus) {
    ## Log and add custom header if virus is found.
    #md_graphdefang_log('virus found:', $VirusName, $RelayAddr);
    #action_add_header("X-VIRUS-FOUND", "YES");
    #return;
  #}

  #if ($action eq "tempfail") {
  #  action_tempfail("Problem running virus-scanner");
  #  md_syslog('warning', "Problem running virus scanner: code=$code, category=$category, action=$action");

  #} else {
    ## let us know we virus scanned
  #  action_add_header("X-VIRUS-SCANNED", "YES");
  #}
}

##
## %PROCEDURE: filter
## %ARGUMENTS:
##  entity -- a Mime::Entity object (see MIME-tools documentation for details)
##  fname -- the suggested filename, taken from the MIME Content-Disposition:
##           header.  If no filename was suggested, then fname is ""
##  ext -- the file extension (everything from the last period in the name
##         to the end of the name, including the period.)
##  type -- the MIME type, taken from the Content-Type: header.
##
##  NOTE: There are two likely and one unlikely place for a filename to
##  appear in a MIME message:  In Content-Disposition: filename, in
##  Content-Type: name, and in Content-Description.  If you are paranoid,
##  you will use the re_match and re_match_ext functions, which return true
##  if ANY of these possibilities match.  re_match checks the whole name;
##  re_match_ext checks the extension.  See the sample filter below for usage.
## %RETURNS:
##  Nothing
## %DESCRIPTION:
##  This function is called once for each part of a MIME message.
##  There are many action_*() routines which can decide the fate
##  of each part; see the mimedefang-filter man page.
##
sub filter {
  my($entity, $fname, $ext, $type) = @_;
  ## avoid unnecessary work
  return if message_rejected();

  ## don't scan outgoing mail
  return if (defined($SendmailMacros{"auth_type"}));
  return if ($RelayAddr eq "127.0.0.1");
  
  ## block message/partial parts
  if (lc($type) eq "message/partial") {
    md_graphdefang_log('message/partial');
    action_bounce("MIME type message/partial not accepted here");
    return action_discard();
  }

  if (filter_bad_filename($entity)) {
    md_graphdefang_log('bad_filename', $fname, $type);
    action_add_header("X-VIRUS-FOUND", "YES");
    return action_drop_with_warning("filter bad filename.\n");
  }

  return action_accept();
}

##
## %PROCEDURE: filter_multipart
## %ARGUMENTS:
##  entity -- a Mime::Entity object (see MIME-tools documentation for details)
##  fname -- the suggested filename, taken from the MIME Content-Disposition:
##           header.  If no filename was suggested, then fname is ""
##  ext -- the file extension (everything from the last period in the name
##         to the end of the name, including the period.)
##  type -- the MIME type, taken from the Content-Type: header.
## %RETURNS:
##  Nothing
## %DESCRIPTION:
##  This is called for multipart "container" parts such as message/rfc822.
##  You cannot replace the body (because multipart parts have no body),
##  but you should check for bad filenames.
##
sub filter_multipart {
  my($entity, $fname, $ext, $type) = @_;
  ## avoid unnecessary work
  return if message_rejected();

  ## don't scan outgoing mail
  return if (defined($SendmailMacros{"auth_type"}));
  return if ($RelayAddr eq "127.0.0.1");
  
  if (filter_bad_filename($entity)) {
    md_graphdefang_log('bad_filename', $fname, $type);
    action_notify_administrator("A MULTIPART attachment of type $type, named $fname was dropped.\n");
    action_add_header("X-VIRUS-FOUND", "YES");
    return action_drop_with_warning("filter multipart\n");
  }
  ## Block message/partial parts
  if (lc($type) eq "message/partial") {
    md_graphdefang_log('message/partial');
    action_bounce("MIME type message/partial not accepted here");
    return;
  }
  return action_accept();
}

##
## %PROCEDURE: defang_warning
## %ARGUMENTS:
##  oldfname -- the old file name of an attachment
##  fname -- the new "defanged" name
## %RETURNS:
##  A warning message
## %DESCRIPTION:
##  This function customizes the warning message when an attachment
##  is defanged.
##
sub defang_warning {
  my($oldfname, $fname) = @_;
  return
    "An attachment named '$oldfname' was converted to '$fname'.\n" .
    "To recover the file, right-click on the attachment and Save As\n" .
    "'$oldfname'\n";
}

## If SpamAssassin found SPAM, append report.  We do it as a separate
## attachment of type text/plain
sub filter_end {
  my($entity) = @_;

  ## If you want quarantine reports, uncomment next line
  ## send_quarantine_notifications();

  ## IMPORTANT NOTE:  YOU MUST CALL send_quarantine_notifications() AFTER
  ## ANY PARTS HAVE BEEN QUARANTINED.  SO IF YOU MODIFY THIS FILTER TO
  ## QUARANTINE SPAM, REWORK THE LOGIC TO CALL send_quarantine_notifications()
  ## AT THE END!!!

  ## No sense doing any extra work
  return if message_rejected();

  ## don't scan outgoing mail
  return if (defined($SendmailMacros{"auth_type"}));
  return if ($RelayAddr eq "127.0.0.1");
  
  ## Spam checks if SpamAssassin is installed
  if ($Features{"SpamAssassin"}) {
    if (-s "./INPUTMSG" < 100*1024) {
      ## Only scan messages smaller than 100kB.  Larger messages
      ## are extremely unlikely to be spam, and SpamAssassin is
      ## dreadfully slow on very large messages.
      my($hits, $req, $names, $report) = spam_assassin_check();
      my($score);
      if ($hits < 40) {
        $score = "*" x int($hits);
      } else {
        $score = "*" x 40;
      }

      ## What we do with SPAM
      if ($hits >= $req) {
        ## Log this bad boy.
        md_graphdefang_log('spam', $hits, $RelayAddr);

        ## We mark-up anything less than 20.0
        if ($hits <= 20.0) {
          action_add_header("X-MD-SPAM", "YES");
          action_add_header("X-MD-SPAM-Level", "$score");
          ##action_add_header("X-MD-SPAM-Score", "$hits ($score) $names");
          action_add_header("X-MD-SPAM-Score", "$hits");
          action_add_part($entity, "text/plain", "-suggest", "$report\n",
                         "SpamAssassinReport.txt", "inline");
        }
        ## We discard anything greater than 10.0
        if ($hits > 10.0) {
          action_bounce("WARNING: Your email is being returned as SPAM.");
        }

      } else {
        ## We use this header to verify that the first SA check has passed.
        action_add_header("X-MILTER-SA-CHECKED", "YES");
      }
    }
  }

  ## I HATE HTML MAIL!  If there's a multipart/alternative with both
  ## text/plain and text/html parts, nuke the text/html.  Thanks for
  ## wasting our disk space and bandwidth...
  ## If you want to strip out HTML parts if there is a corresponding
  ## plain-text part, uncomment the next line.
  ## remove_redundant_html_parts($entity);
  md_graphdefang_log('mail_in');

  ## Deal with malformed MIME.
  ## Some viruses produce malformed MIME messages that are misinterpreted
  ## by mail clients.  They also might slip under the radar of MIMEDefang.
  ## If you are worried about this, you should canonicalize all
  ## e-mail by uncommenting the action_rebuild() line.  This will
  ## force _all_ messages to be reconstructed as valid MIME.  It will
  ## increase the load on your server, and might break messages produced
  ## by marginal software.  Your call.

  #action_rebuild();
}

# DO NOT delete the next line, or Perl will complain.
1;

