package MusicBrainz::Server::Controller::Partners;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller' }

sub amazon : Local Args(2)
{
    my ($self, $c, $store, $asin) = @_;

    my $ass_id = DBDefs->AWS_ASSOCIATE_ID($store)
    or die 'Invalid store';

    $c->response->redirect(
    sprintf('http://%s/exec/obidos/ASIN/%s/%s?v=glance&s=music',
        $store, $asin, $ass_id));
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
