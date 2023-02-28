package MusicBrainz::Server::WebService::Escape;
use strict;
use warnings;

use base 'Exporter';
our @EXPORT_OK = qw( xml_escape );

sub xml_escape
{
    my $t = $_[0];

    return undef if (!defined $t);

    # Remove control characters as they cause XML to not be parsed
    $t =~ s/[\x00-\x08\x0A-\x0C\x0E-\x1A]//g;

    $t =~ s/\xFFFD//g;             # remove invalid characters
    $t =~ s/&/&amp;/g;             # remove XML entities
    $t =~ s/</&lt;/g;
    $t =~ s/>/&gt;/g;
    $t =~ s/"/&quot;/g;
    return $t;
}

1;
