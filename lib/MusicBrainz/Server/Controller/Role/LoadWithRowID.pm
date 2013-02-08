package MusicBrainz::Server::Controller::Role::LoadWithRowID;
use Moose::Role;
use Scalar::Util qw( looks_like_number );

around _load => sub
{
    my $orig = shift;
    my $self = shift;
    my ($c, $id) = @_;

    if (looks_like_number($id)) {
        my $gid = $self->_row_id_to_gid($c, $id) or $c->detach('/error_404');
        $c->response->redirect($c->uri_for_action($c->action, [ $gid ]));
        $c->detach;
    }
    else {
        $self->$orig($c, $id);
    }
};

sub _row_id_to_gid {
    my ($self, $c, $row_id) = @_;
    # Max size for an int in postgresql:
    # http://www.postgresql.org/docs/current/static/datatype-numeric.html
    return if $row_id > 2147483647;

    my $entity = $c->model($self->{model})->get_by_id($row_id) or return;
    return $entity->gid;
}

1;
