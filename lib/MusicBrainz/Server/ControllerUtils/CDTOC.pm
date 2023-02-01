package MusicBrainz::Server::ControllerUtils::CDTOC;
use strict;
use warnings;

use base 'Exporter';

our @EXPORT_OK = qw(
    add_dash
);

sub add_dash
{
   my ($c, $discid) = @_;

   if (substr($discid,length($discid)-1,1) ne '-') {
       my $redir = $c->relative_uri =~ s/\Q$discid\E/$discid-/r;
       $c->response->redirect($redir);
       $c->detach;
   }
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
