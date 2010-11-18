package MusicBrainz::Server::Data::Role::BrowseVA;
use Moose::Role;

with 'MusicBrainz::Server::Data::Role::Browse';

use MusicBrainz::Server::Constants '$VARTIST_ID';

sub find_by_name_prefix_va
{
    my ($self, $prefix, $limit, $offset) = @_;
    return $self->find_by_name_prefix(
        $prefix, $limit, $offset,
        'artist_credit IN (SELECT artist_credit FROM artist_credit_name ' .
        'JOIN artist_credit ac ON ac.id = artist_credit ' .
        'WHERE artist = ? AND artist_count = 1)',
        $VARTIST_ID
    );
}

no Moose::Role;
1;
