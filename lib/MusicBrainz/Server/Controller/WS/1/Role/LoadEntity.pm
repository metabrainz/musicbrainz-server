package MusicBrainz::Server::Controller::WS::1::Role::LoadEntity;
use Moose::Role;

use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::Validation;

sub load
{
    my ($self, $c, $type, $id) = @_;

    unless (MusicBrainz::Server::Validation::IsGUID($id)) {
        $self->bad_req($c, "$id is not a valid MBID");
    }

    my ($model, $entity);

    if ($type eq 'artist' || $type eq 'label') {
        $model  = $c->model( type_to_model($type) );
        $entity = $model->get_by_gid($id);
    }
    elsif ($type eq 'release') {
        $model      = $c->model('ReleaseGroup');
        my $release = $c->model('Release')->get_by_gid($id);
        $entity     = $model->get_by_id($release->release_group_id);
    }
    elsif ($type eq 'track') {
        $model  = $c->model('Recording');
        $entity = $model->get_by_gid($id);
    }
    else {
        $self->bad_req($c, "$type is not a valid type");
    }

    unless (defined $entity) {
        $self->bad_req($c, "Could not load MBID $id");
    }

    return ($model, $entity);
}

1;


