# Sample handler.pl file.
# Start Mason and define the mod_perl handler routine.
#
package HTML::Mason;
use strict;
use HTML::Mason;    # brings in subpackages: Parser, Interp, etc.
use lib "/home/robert/musicbrainz/mb_server/cgi-bin";
use MusicBrainz;  
use UserStuff;  

{  
   package HTML::Mason::Commands;
   use vars qw(%session);
   use CGI::Cookie;
   use Apache::Session::File;
}

my $parser = new HTML::Mason::Parser;
my $interp = new HTML::Mason::Interp (parser=>$parser,
                comp_root=>'/home/robert/musicbrainz/mb_server/htdocs',
                data_dir=>'/usr/apache/mason');

my $ah = new HTML::Mason::ApacheHandler (interp=>$interp);
chown ( [getpwnam('nobody')]->[2], [getgrnam('nobody')]->[2],
        $interp->files_written );   # chown nobody

sub handler
{
    my ($r) = @_;

    return -1 if $r->content_type && $r->content_type !~ m|^text/|io;

    my %cookies = parse CGI::Cookie($r->header_in('Cookie'));

    eval { 
      tie %HTML::Mason::Commands::session, 'Apache::Session::File',
        ( $cookies{'AF_SID'} ? $cookies{'AF_SID'}->value() : undef );
    };

    if ( $@ ) {
      # If the session is invalid, create a new session.
      if ( $@ =~ m#^Object does not exist in the data store# ) {
        tie %HTML::Mason::Commands::session, 'Apache::Session::File', undef;
        undef $cookies{'AF_SID'};
      }
    }
       
    if ( !$cookies{'AF_SID'} ) 
    {
      my $cookie = new CGI::Cookie(-name=>'AF_SID', 
           -value=>$HTML::Mason::Commands::session{_session_id}, 
           -path => '/',);
      $r->header_out('Set-Cookie', => $cookie);
    }

    my $stat = $ah->handle_request($r);

    untie %HTML::Mason::Commands::session;

    return $stat;
}

1;
