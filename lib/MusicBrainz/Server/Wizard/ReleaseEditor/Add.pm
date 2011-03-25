package MusicBrainz::Server::Wizard::ReleaseEditor::Add;
use Moose;
use namespace::autoclean;

use CGI::Expand qw( collapse_hash );
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Edit::Utils qw( clean_submitted_artist_credits );

extends 'MusicBrainz::Server::Wizard::ReleaseEditor';

use MusicBrainz::Server::Constants qw(
    $EDIT_RELEASE_CREATE
    $EDIT_RELEASEGROUP_CREATE
);

sub prepare_duplicates
{
    my $self = shift;

    my $information = $self->load_page ('information');

    my $name = $information->value->{name};
    my $artist_credit = $information->value->{artist_credit};

    my @releases = $self->c->model('Release')->find_similar(
        name => $name,
        artist_credit => clean_submitted_artist_credits($artist_credit)
    );

    $self->c->model('Medium')->load_for_releases(@releases);
    $self->c->model('MediumFormat')->load(map { $_->all_mediums } @releases);
    $self->c->model('Country')->load(@releases);
    $self->c->model('ReleaseLabel')->load(@releases);
    $self->c->model('Label')->load(map { $_->all_labels } @releases);

    $self->c->stash(
        similar_releases => \@releases
    );
}

sub skip_duplicates
{
    my $self = shift;

    my $releases = $self->c->stash->{similar_releases};

    return ! ($releases && scalar @$releases > 0);
}

sub change_page_duplicates
{
    my ($self, $page) = @_;

    my $release_id = $self->value->{duplicate_id}
        or return;

    my $release = $self->c->model('Release')->get_by_id($release_id);
    $self->c->model('Medium')->load_for_releases($release);
    $self->_post_to_page($page, collapse_hash({
        mediums => [
            map +{
                tracklist_id => $_->tracklist_id,
                position => $_->position,
                format_id => $_->format_id,
                name => $_->name,
                deleted => 0,
                edits => '',
            }, $release->all_mediums
        ],
    }));
}

around _build_pages => sub {
    my $next = shift;
    my $self = shift;

    my @pages = @{ $self->$next };
    return [
        $pages[0],
        {
            name => 'duplicates',
            title => l('Release Duplicates'),
            template => 'release/edit/duplicates.tt',
            form => 'ReleaseEditor::Duplicates',
            prepare => sub { $self->prepare_duplicates; },
            skip => sub { $self->skip_duplicates; },
            change_page => sub { $self->change_page_duplicates (@_); }
        },
        @pages[1..$#pages]
    ];
};

augment 'create_edits' => sub
{
    my ($self, %args) = @_;
    my ($data, $create_edit, $editnote, $release, $previewing)
        = @args{qw( data create_edit edit_note release previewing )};

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

        my $edit = $create_edit->($EDIT_RELEASEGROUP_CREATE, $editnote, %args);

        # Previewing a release doesn't care about having the release group id
        $add_release_args{release_group_id} = $edit->entity->id
            unless $previewing;
    }

    # Add the release edit
    my $add_release_edit = $create_edit->(
        $EDIT_RELEASE_CREATE, $editnote, %add_release_args);
    $release = $add_release_edit->entity;

    return $release;
};

augment 'load' => sub
{
    my ($self) = @_;

    # There was no existing wizard, provide the wizard with
    # the $release to initialize the forms.

    my $rg_gid = $self->c->req->query_params->{'release-group'};
    my $label_gid = $self->c->req->query_params->{'label'};
    my $artist_gid = $self->c->req->query_params->{'artist'};

    my $release = MusicBrainz::Server::Entity::Release->new(
        mediums => [
            MusicBrainz::Server::Entity::Medium->new( position => 1 )
        ]
    );

    if ($rg_gid)
    {
        $self->c->detach () unless MusicBrainz::Server::Validation::IsGUID($rg_gid);
        my $rg = $self->c->model('ReleaseGroup')->get_by_gid($rg_gid);
        $self->c->detach () unless $rg;

        $release->release_group_id ($rg->id);
        $release->release_group ($rg);
        $release->name ($rg->name);

        $self->c->model('ArtistCredit')->load ($rg);

        $release->artist_credit ($rg->artist_credit);
    }
    elsif ($label_gid)
    {
        $self->c->detach () unless MusicBrainz::Server::Validation::IsGUID($label_gid);
        my $label = $self->c->model('Label')->get_by_gid($label_gid);

        $release->add_label(
            MusicBrainz::Server::Entity::ReleaseLabel->new(
                label => $label,
                label_id => $label->id
           ));
    }
    elsif ($artist_gid)
    {
        $self->c->detach () unless MusicBrainz::Server::Validation::IsGUID($artist_gid);
        my $artist = $self->c->model('Artist')->get_by_gid($artist_gid);
        $self->c->detach () unless $artist;

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

__PACKAGE__->meta->make_immutable;
1;
