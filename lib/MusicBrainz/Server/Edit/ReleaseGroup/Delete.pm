package MusicBrainz::Server::Edit::ReleaseGroup::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_DELETE );
use MusicBrainz::Server::Translation qw( l ln );

extends 'MusicBrainz::Server::Edit::Generic::Delete';
with 'MusicBrainz::Server::Edit::ReleaseGroup::RelatedEntities';
with 'MusicBrainz::Server::Edit::ReleaseGroup';

sub edit_type { $EDIT_RELEASEGROUP_DELETE }
sub edit_name { l("Remove release group") }
sub _delete_model { 'ReleaseGroup' }
sub release_group_id { shift->entity_id }

override 'foreign_keys' => sub {
    my $self = shift;
    my $data = super();

    $data->{ReleaseGroup} = {
        $self->release_group_id => [ 'ArtistCredit' ]
    };
    return $data;
};

override 'accept' => sub
{
    my $self = shift;
    my $model = $self->c->model( $self->_delete_model );

    MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
        'This entity cannot currently be deleted due to related data.'
    ) if $model->in_use( $self->entity_id );

    $model->delete($self->entity_id);
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

