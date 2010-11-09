package MusicBrainz::Server::Controller::ReleaseEditor::Edit;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::ReleaseEditor' }

use MusicBrainz::Server::Constants qw(
    $EDIT_RELEASE_EDIT
);

sub edit : Chained('/release/load') Edit RequireAuth
{
    my ($self, $c) = @_;
    my $release = $c->stash->{release};
    $self->_load_tracklist ($c, $release);
    $self->run($c, $release);
}

sub cancelled
{
    my ($self, $c) = @_;

    my $release = $c->stash->{release};

    $c->response->redirect($c->uri_for_action('/release/show', [ $release->gid ]))
}

augment 'create_edits' => sub
{
    my ($self, $c, $data, $previewing, $editnote, $release) = @_;

    $self->_load_release ($c, $release);
    $c->stash( medium_formats => [ $c->model('MediumFormat')->get_all ] );

    # FIXME Do we need this? -- acid
    # we're on the changes preview page, load recordings so that the user can
    # confirm track <-> recording associations.
    my @tracks = $release->all_tracks;
    $c->model('Recording')->load (@tracks);

    my $edit_action = $previewing ? '_preview_edit' : '_create_edit';

    # release edit
    # ----------------------------------------

    my @fields = qw( name comment packaging_id status_id script_id language_id
                     country_id barcode artist_credit date as_auto_editor );
    my %args = map { $_ => $data->{$_} } grep { defined $data->{$_} } @fields;

    $args{'to_edit'} = $release;
    $c->stash->{changes} = 0;

    $self->$edit_action($c, $EDIT_RELEASE_EDIT, $editnote, %args);

    return $release;
};

augment 'load' => sub
{
    my ($self, $c, $wizard, $release) = @_;

    $self->_load_release ($c, $release);
    $c->stash( medium_formats => [ $c->model('MediumFormat')->get_all ] );

    return $release;
};

sub submitted {
    my ($self, $c, $release) = @_;
    $c->response->redirect($c->uri_for_action('/release/show', [ $release->gid ]));
    $c->detach;
}

1;
