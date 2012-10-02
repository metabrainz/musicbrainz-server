package MusicBrainz::Server::ControllerUtils::CDTOC;

use base 'Exporter';

our @EXPORT_OK = qw(
    add_dash
);

sub add_dash
{
   my ($c, $discid) = @_;

   if (substr($discid,length($discid)-1,1) ne '-') {
       my $redir = $c->relative_uri;
       $redir =~ s/$discid/$discid-/;
       $c->response->redirect($redir);
       $c->detach;
   }
}
