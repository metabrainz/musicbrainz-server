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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
