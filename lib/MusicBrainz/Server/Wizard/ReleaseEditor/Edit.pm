package MusicBrainz::Server::Wizard::ReleaseEditor::Edit;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw(
    $EDIT_RELEASE_EDIT
);

extends 'MusicBrainz::Server::Wizard::ReleaseEditor';

has 'release' => (
    is => 'ro',
    required => 1
);

sub cancel
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

augment 'init_object' => sub
{
    my ($self, $c) = @_;

    $self->_load_release ($c, $self->release);
    $c->model('Medium')->load_for_releases($self->release);

    $c->stash( medium_formats => [ $c->model('MediumFormat')->get_all ] );

    return $self->release;
};

sub submit {
    my ($self, $c, $release) = @_;
    $c->response->redirect($c->uri_for_action('/release/show', [ $release->gid ]));
    $c->detach;
}


1;
