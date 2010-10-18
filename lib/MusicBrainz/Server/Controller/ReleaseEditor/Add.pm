package MusicBrainz::Server::Controller::ReleaseEditor::Add;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::ReleaseEditor' };

use MusicBrainz::Server::Constants qw(
    $EDIT_RELEASE_CREATE
    $EDIT_RELEASEGROUP_CREATE
);

sub add : Path('/release/add') Edit RequireAuth
{
    my ($self, $c) = @_;
    $self->run($c);
}

sub cancelled {
    my ($self, $c) = @_;
    # FIXME: detach to artist, label or release group page if started from there
    $c->detach ();
}

augment 'create_edits' => sub
{ 
    my ($self, $c, $data, $previewing, $editnote, $release) = @_;

    my $edit_action = $previewing ? '_preview_edit' : '_create_edit';

    # add release (and release group if necessary)
    # ----------------------------------------

    my @fields = qw( name comment packaging_id status_id script_id language_id
                     country_id barcode artist_credit date as_auto_editor );
    my %add_release_args = map { $_ => $data->{$_} } grep { defined $data->{$_} } @fields;

    if ($data->{release_group_id}){
        $add_release_args{release_group_id} = $data->{release_group_id};
    }
    else {
        my @fields = qw( name artist_credit type_id as_auto_editor );
        my %args = map { $_ => $data->{$_} } grep { defined $data->{$_} } @fields;

        my $edit = $self->$edit_action($c, $EDIT_RELEASEGROUP_CREATE, $editnote, %args);

        # Previewing a release doesn't care about having the release group id
        $add_release_args{release_group_id} = $edit->entity->id
            unless $previewing;
    }

    # Add the release edit
    my $add_release_edit = $self->$edit_action($c,
        $EDIT_RELEASE_CREATE, $editnote, %add_release_args);
    $release = $add_release_edit->entity;

    return $release;
};

augment 'load' => sub
{
    my ($self, $c, $wizard) = @_;

    # There was no existing wizard, provide the wizard with
    # the $release to initialize the forms.

    my $rg_gid = $c->req->query_params->{'release-group'};
    my $label_gid = $c->req->query_params->{'label'};
    my $artist_gid = $c->req->query_params->{'artist'};

    my $release = MusicBrainz::Server::Entity::Release->new(
        mediums => [
            MusicBrainz::Server::Entity::Medium->new( position => 1 )
        ]
    );

    if ($rg_gid)
    {
        $c->detach () unless MusicBrainz::Server::Validation::IsGUID($rg_gid);
        my $rg = $c->model('ReleaseGroup')->get_by_gid($rg_gid);
        $c->detach () unless $rg;

        $release->release_group_id ($rg->id);
        $release->release_group ($rg);
        $release->name ($rg->name);

        $c->model('ArtistCredit')->load ($rg);

        $release->artist_credit ($rg->artist_credit);
    }
    elsif ($label_gid)
    {
        $c->detach () unless MusicBrainz::Server::Validation::IsGUID($label_gid);
        my $label = $c->model('Label')->get_by_gid($label_gid);

        $release->add_label(
            MusicBrainz::Server::Entity::ReleaseLabel->new(
                label => $label,
                label_id => $label->id
           ));
    }
    elsif ($artist_gid)
    {
        $c->detach () unless MusicBrainz::Server::Validation::IsGUID($artist_gid);
        my $artist = $c->model('Artist')->get_by_gid($artist_gid);
        $c->detach () unless $artist;

        $release->artist_credit (
            MusicBrainz::Server::Entity::ArtistCredit->from_artist ($artist));
    }

    unless(defined $release->artist_credit) {
        $release->artist_credit (MusicBrainz::Server::Entity::ArtistCredit->new);
        $release->artist_credit->add_name (MusicBrainz::Server::Entity::ArtistCreditName->new);
        $release->artist_credit->names->[0]->artist (MusicBrainz::Server::Entity::Artist->new);
    }

    return $release;
};

sub submitted
{
    my ($self, $c, $release) = @_;

    # Not previewing, we've added a release.
    $c->response->redirect(
        $c->uri_for_action('/release/show', [ $release->gid ])
    );
    $c->detach;
}

1;
