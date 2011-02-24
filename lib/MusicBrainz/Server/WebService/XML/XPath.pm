package MusicBrainz::Server::WebService::XML::XPath;
use strict;
use warnings;

use XML::XPath;

sub new {
    my $class = shift;
    my $xp = XML::XPath->new(@_);
    $xp->set_namespace( mb => 'http://musicbrainz.org/ns/mmd-2.0#' );
    return $xp;
}

1;
