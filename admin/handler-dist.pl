# Sample handler.pl file.
# Start Mason and define the mod_perl handler routine.
#
package HTML::Mason;
use strict;
use HTML::Mason;    # brings in subpackages: Parser, Interp, etc.

# TODO: Check to make sure this path points to where the cgi-bin stuff is
use lib "/home/robert/musicbrainz/mb_server/cgi-bin";
use MusicBrainz;  
use UserStuff;  
use Album;
use Diskid;
use TableBase;
use Artist;
use Genre;
use Pending;
use Track;
use Lyrics;
use UserStuff;
use Moderation;
use GUID;
use Sql;

{  
   package HTML::Mason::Commands;
   use vars qw(%session);
   use CGI::Cookie;
   use Apache::Session::File;
}

my $parser = new HTML::Mason::Parser(default_escape_flags=>'h');
my $interp = new HTML::Mason::Interp (parser=>$parser,
            # TODO: This needs to point to the installed htdocs
            comp_root=>'/home/robert/musicbrainz/mb_server/htdocs',
            # TODO: This directory needs to be created for mason's internal 
            # use. Its best to create a mason dir in the main apache dir.
            data_dir=>'/usr/apache/mason',
            allow_recursive_autohandlers=>undef);
my $ah = new HTML::Mason::ApacheHandler (interp=>$interp);
chown ( [getpwnam('nobody')]->[2], [getgrnam('nobody')]->[2],
        $interp->files_written );   # chown nobody

sub handler
{
    my ($r) = @_;

    return -1 if $r->content_type && $r->content_type !~ m|^text/|io;

    my %cookies = parse CGI::Cookie($r->header_in('Cookie'));
    if (exists $cookies{'AF_SID'})
    {
        eval { 
           tie %HTML::Mason::Commands::session, 
              'Apache::Session::File',
              $cookies{'AF_SID'}->value(),
              {
                 Directory => '/tmp/sessions',
                 LockDirectory   => '/tmp/locks',
              }; 
        };

        my $err = $@;
        $ah->handle_request($r);
        if (! $err) 
        {   
             # only untie if you've managed to create a tie in the first place
             untie %HTML::Mason::Commands::session;
        }
    }
    else
    {
        $ah->handle_request($r);
    }
}

1;
