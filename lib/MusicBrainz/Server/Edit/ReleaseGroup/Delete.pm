package MusicBrainz::Server::Edit::ReleaseGroup::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_DELETE );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Generic::Delete';
with 'MusicBrainz::Server::Edit::ReleaseGroup::RelatedEntities',
     'MusicBrainz::Server::Edit::ReleaseGroup';

sub edit_type { $EDIT_RELEASEGROUP_DELETE }
sub edit_name { N_l('Remove release group') }
sub _delete_model { 'ReleaseGroup' }
sub release_group_id { shift->entity_id }

override 'foreign_keys' => sub {
    my $self = shift;
    my $data = super();

    $data->{ReleaseGroup} = {
        $self->release_group_id => [ 'ArtistCredit' ],
    };
    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

