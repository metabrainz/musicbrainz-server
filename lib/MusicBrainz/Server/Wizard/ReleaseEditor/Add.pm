package MusicBrainz::Server::Wizard::ReleaseEditor::Add;
use Moose;
use namespace::autoclean;

use CGI::Expand qw( collapse_hash );
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Data::Utils qw( object_to_ids );
use MusicBrainz::Server::Edit::Utils qw( clean_submitted_artist_credits );
use MusicBrainz::Server::Entity::ArtistCredit;
use List::UtilsBy qw( uniq_by );

extends 'MusicBrainz::Server::Wizard::ReleaseEditor';

use MusicBrainz::Server::Constants qw(
    $EDIT_RELEASE_CREATE
    $EDIT_RELEASEGROUP_CREATE
);


around render => sub {
    my $orig = shift;
    my $self = shift;
    my $page = $_[0];

    my $page_shown = $self->shown ($self->_current);

    $self->$orig (@_);

    # hide errors if this is the first time (in this wizard session) that this
    # page is shown to the user.
    if (! $page_shown)
    {
        $page->clear_errors;

        # clear_errors doesn't clear everything, error_fields on the form still
        # contains the error fields -- so let's set an extra flag so the template
        # knows wether to show errors or not.
        $self->c->stash->{hide_errors} = 1;
    }
};


sub prepare_duplicates
{
    my $self = shift;

    my $name = $self->get_value ('information', 'name');
    my $artist_credit = $self->get_value ('information', 'artist_credit');
    my $rg_id = $self->get_value ('information', 'release_group_id');

    my @releases = $self->c->model('Release')->find_similar(
        name => $name,
        artist_credit => clean_submitted_artist_credits($artist_credit)
    );

    if ($rg_id)
    {
        my ($more_releases, $hits) = $self->c->model('Release')->find_by_release_group ($rg_id);

        @releases = uniq_by { $_->id } @$more_releases, @releases;
    }

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
    my ($self) = @_;

    my $release_id = $self->value->{duplicate_id}
        or return;

    my $release = $self->c->model('Release')->get_by_id($release_id);
    $self->c->model('Medium')->load_for_releases($release);

    my $TRACKLIST_PAGE = 2;
    $self->_post_to_page($TRACKLIST_PAGE, collapse_hash({
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
            submit => sub { $self->change_page_duplicates (@_); }
        },
        @pages[1..$#pages]
    ];
};

sub add_medium_position {
    my ($self, $idx, $new) = @_;

    return $new->{position};
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
        my @fields = qw( artist_credit type_id as_auto_editor );
        my %args = map { $_ => $data->{$_} } grep { defined $data->{$_} } @fields;
        $args{name} = $data->{release_group}{name} || $data->{name};

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

after 'prepare_tracklist' => sub {
    my ($self, $release) = @_;

    $self->c->stash->{release_artist_json} = "null";

    my $json = JSON::Any->new( utf8 => 1 );

    return unless $self->value->{seeded};

    my @tracklist_edits = @{ $self->value->{mediums} };

    # If the release editor was seeded with a regular (single artist)
    # release, a lookup for that artist may have been required on the
    # information tab.  In that case the artist id/gid should be applied
    # to all track artists with the same name.
    my $release_artist = MusicBrainz::Server::Entity::ArtistCredit->from_array (
        $self->value->{artist_credit}->{names});

    for my $medium (@tracklist_edits)
    {
        next unless defined $medium->{edits};

        my @edits = @{ $json->decode ($medium->{edits}) };
        for my $trk_idx (0..$#edits)
        {
            my $trk = $edits[$trk_idx];

            # If the track artist is not set, or identical to the release artist,
            # use the identified release artist for all tracks.
            next unless $trk->{artist_credit}->{preview} eq $release_artist->name
                || $trk->{artist_credit}->{preview} eq '';

            $trk->{artist_credit} = $release_artist;

            $edits[$trk_idx] = hash_structure ($trk);
        }
        $medium->{edits} = $json->encode (\@edits);
    }

    $self->load_page('tracklist', {
        'seeded' => 0,
        'mediums' => \@tracklist_edits,
    });
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

# Approve edits edits that should never fail
after create_edits => sub {
    my ($self, %args) = @_;
    my ($data, $create_edit, $editnote, $release, $previewing)
        = @args{qw( data create_edit edit_note release previewing )};
    return if $previewing;

    my $c = $self->c->model('MB')->context;

    $c->sql->begin;
    my @edits = @{ $self->c->stash->{edits} };
    for my $edit (@edits) {
        if (should_approve($edit)) {
            $c->model('Edit')->accept($edit);
        }
    }
    $c->sql->commit;
};

sub should_approve {
    my $edit = shift;
    return unless $edit->is_open;
    return $edit->meta->name eq 'MusicBrainz::Server::Edit::Medium::Create' ||
           $edit->meta->name eq 'MusicBrainz::Server::Edit::Release::ReorderMediums';
}

__PACKAGE__->meta->make_immutable;
1;
