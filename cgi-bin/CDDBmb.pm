# $Id$
# Documentation and Copyright exist after __END__

package CDDBmb;
require 5.001;

use strict;
use vars qw($VERSION);
use Carp;

use IO::Socket;
use Sys::Hostname;

#------------------------------------------------------------------------------
# list of known cddb servers

my @cddb_hosts =
  ( [ 'www.freedb.org'     => 8880 ],
  );

#------------------------------------------------------------------------------

my $imported_mail = 0;
eval {
  require Mail::Internet;
  require Mail::Header;
  $imported_mail = 1;
};

#------------------------------------------------------------------------------

$VERSION = '1.03';

#------------------------------------------------------------------------------
# code "adapted" from Net::Cmd, because actually using Net::Cmd hurt real bad

sub command {
  my $self = shift;
  my $str = join(' ', @_);

  unless (exists $self->{handle}) {
    $self->connect() or return 0;
  }

  $self->debug_print(0, '>>> ', $str)
    if ($self->{debug});

  my $len = length($str .= "\x0D\x0A");

  local $SIG{PIPE} = 'IGNORE' unless ($^O eq 'MacOS');
  return 0 unless(syswrite($self->{handle}, $str, $len) == $len);
  return 1;
}

#------------------------------------------------------------------------------

sub getline {
  my $self = shift;

  if (@{$self->{lines}}) {
    return shift @{$self->{lines}};
  }

  my $fd = fileno(my $socket = $self->{handle});
  return undef unless defined $fd;

  vec(my $rin = '', $fd, 1) = 1;
  my $timeout = $self->{timeout} || undef;
  my $frame = $self->{frame};

  until (@{$self->{lines}}) {

    if (select(my $rout=$rin, undef, undef, $timeout)) {
      if (sysread($socket, my $buf='', 1024)) {
        $frame .= $buf;
        my @lines = split(/\x0D?\x0A/, $frame);
        $frame = (length($buf) == 0 || substr($buf, -1, 1) eq "\x0A")
          ? ''
          : pop(@lines);
        push @{$self->{lines}}, @lines;
      }
    }
  }

  $self->{frame} = $frame;
  shift @{$self->{lines}};
}

#------------------------------------------------------------------------------

sub response {
  my $self = shift;
  my ($code, $text);

  my $str = $self->getline();

  return undef
    unless defined($str);

  $self->debug_print(0, '<<< ', $str)
    if ($self->{debug});

  ($code, $text) = ($str =~ /^(\d+)\s*(.*?)\s*$/);
  $self->{response_code} = $code;
  $self->{response_text} = $text;

  substr($code, 0, 1);
}

#------------------------------------------------------------------------------

sub message {
  my $self = shift;
  $self->{response_text};
}

#------------------------------------------------------------------------------

sub debug_print {
  my $self = shift;
  my $level = shift;
  my $text = join('', @_);
  print STDERR $text, "\n";
}

#------------------------------------------------------------------------------

sub code {
  my $self = shift;
  $self->{response_code};
}

sub text {
  my $self = shift;
  $self->{response_text};
}

#------------------------------------------------------------------------------

sub read_until_dot {
  my $self = shift;
  my @lines;

  while ('true') {
    my $line = $self->getline() or return undef;
    $self->debug_print(0, $line)
      if ($self->{debug});
    last if ($line =~ /^\.$/);
    $line =~ s/^\.\././;
    push @lines, $line;
  }

  \@lines;
}

#------------------------------------------------------------------------------
# end of "adapted" code... beginning of original stuff...
#------------------------------------------------------------------------------

sub new {
  my $type = shift;
  my %param = @_;
  my ($hostname, $login);

  if (exists $ENV{"MOD_PERL"})
  {
      $hostname = $ENV{SERVER_NAME};
      $login = $param{Login};
  }
  else
  {
      $hostname = hostname();
      $login = $param{Login} || $ENV{LOGNAME} || $ENV{USER} ||
                getpwuid($<) || croak "can't get login: $!";
  }
  my $debug = $param{Debug} || 0;
  my $host  = $param{Host} || '';
  my $port  = $param{Port} || 0;
                                        # Mac Freaks Got Spaces!
  $login =~ s/\s+/_/g;

  my $self = bless
  { hostname      => $hostname,
    login         => $login,
    libname       => 'CDDB.pm',
    libver        => $VERSION,
    cddbmail      => 'cddb-test@submit.cddb.com',
    debug         => $debug,
    host          => $host,
    port          => $port,
    lines         => [],
    frame         => '',
    response_code => '000',
    response_text => '',
  }, $type;

  $self;
}

#------------------------------------------------------------------------------

sub disconnect {
  my $self = shift;
  if (exists $self->{handle}) {
    $self->command('quit');
    $self->response();
    delete $self->{handle};
  }
  elsif ($self->{debug}) {
    carp "disconnect on unconnected handle";
  }
}

#------------------------------------------------------------------------------

sub connect {
  my $self = shift;

  unless (defined $self->{hostname}) {
    $self->{hostname} = &hostname() or croak "can't get hostname: $!";
  }
                                        # try each possible host, in order
HOST:
  while ('true') {
    # Hard disconnect here to prevent recursion.
    delete $self->{handle};
                                        # cycle to next host
    if ($self->{host} eq '') {
      my $cddb_host = shift(@cddb_hosts);
      die "ran out of CDDB hosts to query today\n"
        unless ($cddb_host);
      ($self->{host}, $self->{port}) = @$cddb_host;
    }

    $self->{handle} = new IO::Socket::INET( PeerAddr => $self->{host},
                                            PeerPort => $self->{port},
                                            Proto    => 'tcp',
                                            Timeout  => 15,
                                          );

    # The host could not connect.  Clean up after the failed attempt
    # and cycle to the next host.
    unless (defined $self->{handle}) {
      delete $self->{handle};
      $self->{host} = $self->{port} = '';
      next HOST;
    }

    # The host accepted our connection.  We'll push it back on the
    # list of known CDDB hosts so it can be tried later.  And we're
    # done with the host list cycle for now.
    push(@cddb_hosts, [ $self->{host}, $self->{port} ]);
    last HOST;
  }

  unless (defined $self->{handle}) {
    $self->{response_text} = "could not contact a server";
    $self->{response_code} = 0;
    return $self->code();
  }

  select((select($self->{handle}), $|=1)[0]);

  my $code = $self->response();
  if ($code != 2) {
    warn "bad cddb response: " . $self->message();
    return $self->code();
  }
  else {
    $self->command( 'cddb hello',
                     $self->{login}, $self->{hostname},
                     $self->{libname}, $self->{libver}
                  );
    $code = $self->response();
    if ($code != 2) {
      carp "the cddb didn't handshake: " . $self->message();
      return $self->code();
    }
  }
  $self->code();
}

#------------------------------------------------------------------------------

sub DESTROY {
  my $self = shift;
  $self->disconnect();
}

#------------------------------------------------------------------------------

sub get_genres {
  my $self = shift;
  my @genres;

  $self->command('cddb lscat');
  my $code = $self->response();
  if ($code == 2) {
    if (defined(my $genres = $self->read_until_dot())) {
      return @$genres;
    }
    return undef;
  }
  else {
    carp 'error listing categories: ' . $self->text();
    return undef;
  }
  @genres;
}

#------------------------------------------------------------------------------

sub calculate_id {
  my $self = shift;
  my @toc = @_;

  my ($seconds_previous, $seconds_first, $seconds_last, $cddb_sum,
      @track_numbers, @track_lengths, @track_offsets,
     );

  foreach my $line (@toc) {
    my ($track, $mm_begin, $ss_begin, $ff_begin) = split(/\s+/, $line, 4);
    my $seconds_begin = ($mm_begin * 60) + $ss_begin;

    if (defined $seconds_previous) {
      my $elapsed = $seconds_begin - $seconds_previous;
      push( @track_lengths,
            sprintf("%02d:%02d", int($elapsed / 60), $elapsed % 60)
          );
    }
    else {
      $seconds_first = $seconds_begin;
    }
                                        # virtual track: lead-out information
    if ($track == 999) {
      $seconds_last = $seconds_begin;
      last;
    }
                                        # virtual track: get-toc error code
    if ($track == 1000) {
      carp "error in TOC: $ff_begin";
      return undef;
    }

    map { $cddb_sum += $_; } split(//, $seconds_begin);
    push @track_offsets, ($mm_begin * 60 + $ss_begin) * 75 + $ff_begin;
    push @track_numbers, sprintf("%03d", $track);
    $seconds_previous = $seconds_begin;
  }

  my $total_seconds = $seconds_last - $seconds_first;
  my $id = sprintf
    ( "%08x",
      (($cddb_sum % 255) << 24)
      | ($total_seconds << 8)
      | scalar(@track_offsets)
    );
                                        # return things cddb needs
  if (wantarray()) {
    ($id, \@track_numbers, \@track_lengths, \@track_offsets, $total_seconds);
  }
  else {
    $id;
  }
}

#------------------------------------------------------------------------------

sub get_discs {
  my $self = shift;
  my ($id, $offsets, $total_seconds) = @_;
                                        # accept CDDB.pm TOC format...
  my ($track_count, $offsets_string);
  if (ref($offsets) eq 'ARRAY') {
    $track_count = scalar(@$offsets);
    $offsets_string = join ' ', @$offsets;
  }
                                        # ... or MP3 format, for pudge
  else {
    $offsets =~ /^(\d+?)\s+(.*)$/;
    $track_count = $1;
    $offsets_string = $2;
  }

  my ($code, $flag, @matches);
                                        # attempt to query over and over
ATTEMPT:
  while ('true') {
    #print STDERR "Query: $id $track_count $offsets_string $total_seconds\n";
    $self->command( 'cddb query', $id, $track_count,
                    $offsets_string, $total_seconds
                  );
    $code = $self->response();
    if ($self->code() == 417) {
      next ATTEMPT;
    }
    last ATTEMPT;
  }

  if ($code != 2) {
    return undef;
  }

  if ($self->code() == 200) {
    my ($genre, $cddb_id, $title) =
      ($self->text() =~ /^(\S+)\s*(\S+)\s*(.*?)\s*$/);
    push(@matches, [ $genre, $cddb_id, $title ]);
  }
  elsif ($self->code() == 202) {
    @matches = ();
  }
  elsif ($self->code() == 211) {
    my $discs = $self->read_until_dot();
    if (defined $discs) {
      foreach my $disc (@$discs) {
        my ($genre, $cddb_id, $title) =
          ($disc =~ /^(\S+)\s*(\S+)\s*(.*?)\s*$/);
        push(@matches, [ $genre, $cddb_id, $title ]);
      }
    }
  }
  else {
    warn "unknown cddb response: " . $self->text();
  }

  @matches;
}

#------------------------------------------------------------------------------

sub get_discs_by_toc {
  my $self = shift;
  my (@info, @discs);
  if (@info = $self->calculate_id(@_)) {
    @discs = $self->get_discs(@info[0, 3, 4]);
  }
  @discs;
}

#------------------------------------------------------------------------------

sub get_disc_details {
  my $self = shift;
  my ($genre, $id) = @_;
                                        # becasue CDDB only allows one per
  if (exists $self->{'got tracks before'}) {
    $self->disconnect();
    $self->connect() or return undef;
  }
  $self->{'got tracks before'} = 'yes';

  $self->command('cddb read', $genre, $id);
  my $code = $self->response();
  if ($code != 2) {
    carp 'CDDB could not read the disc file: ' . $self->text();
    return undef;
  }

  my $track_file;
  unless (defined($track_file = $self->read_until_dot())) {
    warn 'error reading track file';
    return undef;
  }

  my @track_file = @$track_file;
  my %details = ( offsets => [ ] );
  my $state = 'beginning';
  foreach my $line (@track_file) {
    #print STDERR "line: $line\n";
    if ($state eq 'beginning') {
      if ($line =~ /track\s*frame\s*off/i) {
        $state = 'offsets';
      }
      next;
    }

    if ($state eq 'offsets') {
      if ($line =~ /^\#\s*(\d+)/) {
        push @{$details{offsets}}, $1;
        next;
      }
      $state = 'headers';
      next;
    }

    if ($state eq 'headers') {
      if ($line =~ /^\#/) {
        $line =~ s/\s+/ /g;
        if (my ($header, $value) = ($line =~ /^\#\s*(.*?)\:\s*(.*?)\s*$/)) {
          $details{lc($header)} = $value;
        }
        next;
      }
      $state = 'data';
      # passes through on purpose
    }

    if ($state eq 'data') {
      next unless (my ($tag, $idx, $val) =
                   ($line =~ /^\s*(.+?)(\d*)\s*\=\s*(.+?)\s*$/)
                  );
      $tag = lc($tag);

      if ($idx ne '') {
        $tag .= 's';
        $details{$tag} = [ ] unless (exists $details{$tag});
        $details{$tag}->[$idx] .= $val;
        $details{$tag}->[$idx] =~ s/^\s+//;
        $details{$tag}->[$idx] =~ s/\s+$//;
        $details{$tag}->[$idx] =~ s/\s+/ /g;
      }
      else {
        $details{$tag} .= $val;
        $details{$tag} =~ s/^\s+//;
        $details{$tag} =~ s/\s+$//;
        $details{$tag} =~ s/\s+/ /g;
      }
    }
  }

  \%details;
}

#------------------------------------------------------------------------------

sub can_submit_disc {
  my $self = shift;
  $imported_mail;
}

sub submit_disc {
  my $self = shift;
  my %params = @_;

  if (!$imported_mail) {
    croak "submit_disc needs Mail::Internet and Mail::Header, which appear " .
          "not to be installed";
  }

  unless (defined $self->{hostname}) {
    $self->{hostname} = &hostname() or croak "can't get hostname: $!";
  }

  (exists $params{Genre})       or croak "submit_disc needs a Genre";
  (exists $params{Id})          or croak "submit_disc needs an Id";
  (exists $params{Artist})      or croak "submit_disc needs an Artist";
  (exists $params{DiscTitle})   or croak "submit_disc needs a DiscTitle";
  (exists $params{TrackTitles}) or croak "submit_disc needs TrackTitles";
  (exists $params{Offsets})     or croak "submit_disc needs Offsets";

  my $host;
  if (exists $params{Host}) {
    $host = $params{Host};
  }
  elsif (exists $ENV{SMTPHOSTS}) {
    $host = $ENV{SMTPHOSTS};
  }
  else {
    $host = 'mail';
  }
                                        # optional... override bad choice
  my $from =  (exists $params{From})
    ? $params{From}
    : ($self->{login} . '@' . $self->{hostname});

  my $header = new Mail::Header;
  $header->add( From    => $from );
  $header->add( To      => $self->{cddbmail} );
  $header->add( Subject => 'cddb ' . $params{Genre} . ' ' . $params{Id});

  my @message_body =
    ( '# xmcd',
      '#',
      '# Track frame offsets:',
      map({ "#\t" . $_; } @{$params{Offsets}}),
      '#',
      '# Disc length: ' . (hex(substr($params{Id},2,4))+2) . ' seconds',
      '#',
      '# Revision: 1',
      '# Submitted via: ' . $self->{libname} . ' ' . $self->{libver},
      '#',
      'DISCID=' . $params{Id},
      'DTITLE=' . $params{Artist} . ' / ' . $params{DiscTitle},
    );

  my $number = 0;
  foreach my $title (@{$params{TrackTitles}}) {
    my $copy = $title;
    while ($copy ne '') {
      push(@message_body, 'TTITLE' . $number . '=' . substr($copy, 0, 69));
      substr($copy, 0, 69) = '';
    }
    $number++;
  }

  push @message_body, 'EXTD=';
  push @message_body, map { "EXTT$_="; } (0..--$number);
  push @message_body, 'PLAYORDER=';

  map { $_ .= "\n"; } @message_body;

  my $mail = new Mail::Internet
    ( undef,
      Header => $header,
      Body   => \@message_body,
    );
  $mail->smtpsend
    ( Host => $host,
    ) or croak "could not send CDDB record (bad SMTP host '$host'?)";
}

###############################################################################
1;
__END__

=head1 NAME

CDDB.pm - a high-level interface to the Internet Compact Disc Database

=head1 SYNOPSIS

  use CDDB;

  ### connect to the CDDB server
  my $cddb = new CDDB( Host  => 'www.cddb.com',         # default
                       Port  => 8880,                   # default
                       Login => $login_id,              # defaults to %ENV's
                     ) or die $!;

  ### retrieve known genres
  my @genres = $cddb->get_genres();

  ### calculate CDDB ID based on MSF info
  my @toc = ( '1    0  2 37',           # track, CD-i MSF (space-delimited)
              '999  1 38 17',           # lead-out track MSF
              '1000 0  0 Error!',       # error track (don't include if ok)
            );
  my ($cddb_id,       # used for further CDDB queries
      $track_numbers, # padded with 0's provided as a convenience
      $track_lengths, # length of each track, in MM:SS format
      $track_offsets, # absolute offsets (used for further CDDB queries)
      $total_seconds  # total play time, in MM:SS format
     ) = $cddb->calculate_id(@toc);

  ### query discs based on CDDB ID and other information
  my @discs = $cddb->get_discs($cddb_id, $track_offsets, $total_seconds);
  foreach my $disc (@discs) {
    my ($genre, $cddb_id, $title) = @$disc;
  }

  ### query disc details (usually done with get_discs() information)
  my $disc_info     = $cddb->get_disc_details($genre, $cddb_id);
  my $disc_time     = $disc_info->{'disc length'};
  my $disc_id       = $disc_info->{discid};
  my $disc_title    = $disc_info->{dtitle};
  my @track_offsets = @{$disc_info->{offsets}};
  my @track_titles  = @{$disc_info->{ttitles}};
  # other information may be returned... explore!

  ### submit a disc (via e-mail, requires MailTools)
  $cddb->submit_disc
    ( Genre       => 'classical',
      Id          => 'b811a20c',
      Artist      => 'Various',
      DiscTitle   => 'Cartoon Classics',
      Offsets     => $disc_info->{offsets},   # array reference
      TrackTitles => $disc_info->{ttitles},   # array reference
      From        => 'login@host.domain.etc', # will try to determine
    );

=head1 DESCRIPTION

The CDDB serves compact disc information for programs that need it.
CDDB.pm provides a Perl interface to the CDDB server protocols.  With
it, a Perl program can identify a CD based on its "table of contents"
(CD-i MSF information), list its track titles, and manage track times.

This information could be useful for generating CD catalogs, naming
MP3 files, or even playing CDs in an automated jukebox.

=head1 PUBLIC METHODS

=over 4

=item C<new(...)>

Creates a CDDB server interface, returning a handle to it.  This
interface does not connect to the server until needed, and the CDDB
protocol may require several separate connections (sometimes one per
query).

C<new> accepts these parameters: Host (defaults to www.cddb.com), Port
(defaults to 8880), Login (defaults to your login ID), and Debug
(defaults to boolean false) parameters.

=item C<get_genres()>

Takes no parameters.  Returns a list of genres known by the CDDB
server, or undef if there is an error.

=item C<calculate_id(...)>

The CDDB protocol defines an ID as a hash of track lengths and the
number of tracks, with an added checksum. The most basic information
required to calculate this is the CD table of contents (the CD-i track
offsets, in MSF [Minutes, Seconds, Frames] format).

C<calculate_id(...)> accepts TOC information as a list of strings.
Each string contains four fields, separated by whitespace:

=over 2

=item 1. The track number, starting with 1.

Special track numbers are 999, for the CD lead-out information; and
1000, to indicate that an error has occurred while acquiring the CD
information (error tracks modify the meaning of the other fields; look
below).

=item 2. The track start, in minutes (the M in MSF).

If a track starts at 01:23 and 5 frames, then this field is 1.  In an
error track, this field is ignored (but is expected to contain
something; usually 0).

=item 3. The track start, in seconds (the S in MSF).

If a track starts at 01:23 and 5 frames, then this field is 23.  In an
error track, this field is ignored (but is expected to contain
something; usually 0).

=item 4. The track start, in frames (the F in MSF).

If a track starts at 01:23 and 5 frames, then this field is 5.  In an
error track, this field contains an error message (which may contain
spaces).

=back

C<calculate_id(...)> returns just the ID in scalar context.  In array
context, it returns an array containing the following values (in the
order listed here):

=over 2

=item C<$cddb_id>

This is the hashed CDDB ID, required for any queries involving this
CD, as well as C<submit_disc(...)>.

=item C<$track_numbers>

This is a reference to an array containing the track numbers, padded
to three characters with leading zeroes.  It is provided for
convenience and is not required by the CDDB.

=item C<$track_lengths>

The MSF information provided to C<calculate_id(...)> refers to track
offsets.  This is a reference to an array containing the track lengths
in MM:SS format, as computed from the MSF offsets.  This information
is provided for convenience and is not required by the CDDB.

=item C<$track_offsets>

These are absolute frame offsets as calculated by the MSF information.
They are required by C<get_discs(...)> and C<submit_disc(...)>.

=item C<$total_seconds>

This is the calculated total playing time for the CD.  It is required
by C<get_discs(...)>.

=back

=item C<get_discs(...)>

C<get_discs(...)> asks the CDDB server for all its CDs that match the
given ID, track offsets list, and total seconds (combined).  The CDDB
performs "fuzzy" matching and may return more than one disc.

C<get_discs(...)> takes three parameters:

=over 2

=item C<$cddb_id>

This is the CDDB ID, as generated by C<calculate_id(...)>.

=item C<$track_offsets>

This may be in two formats.

The first format is a reference to an array of absolute track offsets,
similar to ones generated by C<calculate_id(...)>.

The second format is a string containing the track count and the
absolute offsets, separated by whitespace.

=item C<$total_seconds>

The total playing time for the CD, as generated by
C<calculate_id(...)>.

=back

C<get_discs(...)> returns an array of matching discs, each of which is
represented by an array reference.  It returns an empty array if the
query succeeded but did not match.  It returns undef on error.

Each disc record contains three elements, two of which can be used
later on:

=over 2

=item C<$genre>

The genre this disc falls into, as determined by whoever submitted the
disc in the first place (see C<get_genres()>).

=item C<$cddb_id>

The actual CDDB ID, which may be different than the one supplied to
C<get_discs(...)> due to fuzzy matching.

=item C<$title>

The title of this disc.

=back

=item C<get_discs_by_toc(...)>

This function combines C<calculate_id(...)> and C<get_discs(...)> into
one step.  It takes the same parameters as C<calculate_id(...)>, and
it returns the same information as C<get_discs(...)>.

=item C<get_disc_details(...)>

This function fetches the detailed information for a CD.  It takes two
parameters: the disc C<$genre> and the C<$cddb_id>.

It returns a hash reference containing as much information as it can.
The information includes data normally stored in comments.  The most
common entries this function returns include:

=over 2

=item C<'disc length'>

This is the total playing time for the disc, as recorded in the CDDB.
Commonly it is in the form "somenumber seconds", but since the CDDB
stores it in a comment, it could say just about anything.

=item C<'discid'>

This is a rehash (get it?) of the CDDB ID, and should match the
C<$cddb_id> parameter to C<get_disc_details(...)>.

=item C<'dtitle'>

This is the disc title, again.

=item C<'offsets'>

This is a reference to an array of absolute disc track offsets, in CD
frames.

=item C<'ttitles'>

This is a reference to an array of track titles.  These are the droids
you are looking for.

=item C<'processed by'>

This is a comment field, identifying the CDDB server name and version.

=item C<'revision'>

This is the version number for the CD record.  Revisions start at 1
and are incremented for every correction.  It is the responsibility of
the submitter to provide a correct revision number, as sort of a
sanity check.

=item C<'submitted via'> is the name and version of the software that
submitted this CDDB record.  The main intention is to identify records
that are submitted by broken software so they can be purged or
corrected.

=back

=item C<can_submit_disc()>

Returns boolean true or false.  If true, CDDB.pm was able to import
the MailTools it needs to send submissions.  If false, it didn't, and
you'll need to install at least Mail::Internet and Mail::Header (and
the underlying Net::SMTP, etc.).

=item C<submit_disc(...)>

C<submit_disc(...)> submits a disc record to the CDDB.  The CDDB
accepts disc submissions through e-mail, so this function requires
MailTools to operate.  The rest of CDDB.pm will operate without
MailTools being installed (since CDDB submissions are relatively
rare), but C<submit_disc(...)> will croak if MailTools are not
installed.

C<submit_disc(...)> takes six required parameters and two optional
parameters.  The parameters are in pairs, like C<Parameter => $value>,
and can appear in any order.  Here goes:

=over 2

=item 'Genre'

This is the disc genre.  It must be one of the genres that the server
knows (see C<get_genres()>).

=item 'Id'

This is the CDDB ID, as calculated from C<calculate_id(...)>.

=item 'Artist'

This is the disc artist, gleaned from the CD liner, and entered by a
human.

=item 'DiscTitle'

This is the disc title, gleaned from the CD liner, and entered by a
human.

=item 'Offsets'

This is a reference to an array of absolute track offsets, as provided
by C<calculate_id(...)>.

=item 'TrackTitles'

This is a reference to an array of track titles, gleaned from the CD
liner, and entered by a human.

=item 'From'

This is the disc submitter's e-mail address.  It is not required, and
will default to the current user's login ID at the current machine.
The CDDB will send this person a return receipt, including the full
headers and body of the submitted e-mail.

The default return address may not be a deliverable address,
especially if CDDB.pm is being used on a dial-up machine that isn't
running its own MTA.  If the current machine has its own MTA, problems
still may occur if the machine's Internet address changes.

=item 'Host'

This is the SMTP host to contact when sending mail.  It is not
required, and if omitted will default to the C<SMTPHOSTS> environment
variable.  If C<SMTPHOSTS> is not defined, it will fall back to
'mail'.  If 'mail' is not a machine running an SMTP daemon, then
C<submit_disc(...)> will C<croak>.

=back

=head1 PRIVATE METHODS

Documented as being not documented.

=head1 EXAMPLES

Please see the cddb.t program in the t (tests) directory.  It
exercises every aspect of CDDB.pm.

=head1 BUGS

There are no known bugs, but see the README for things that need to be
done.

=head1 CONTACT AND COPYRIGHT

Copyright 1998 Rocco Caputo E<lt>troc@netrus.netE<gt>.  All rights
reserved.  This program is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=cut
