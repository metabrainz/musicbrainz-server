package MusicBrainz::Server::Wizard::ReleaseEditor::Add;
use Moose;
use namespace::autoclean;

use Encode qw( encode );
use JSON qw( decode_json );
use MusicBrainz::Server::CGI::Expand qw( collapse_hash );
use MusicBrainz::Server::ControllerUtils::Release qw( load_release_events );
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Data::Utils qw( object_to_ids artist_credit_to_ref trim );
use MusicBrainz::Server::Validation qw( is_guid );
use MusicBrainz::Server::Edit::Utils qw( clean_submitted_artist_credits );
use MusicBrainz::Server::Entity::ArtistCredit;
use List::UtilsBy qw( uniq_by );

extends 'MusicBrainz::Server::Wizard::ReleaseEditor';

use MusicBrainz::Server::Constants qw(
    $EDIT_RELEASE_CREATE
    $EDIT_RELEASEGROUP_CREATE
    $EDIT_MEDIUM_CREATE
    $EDIT_RELEASE_REORDER_MEDIUMS
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
    load_release_events($self->c, @releases);
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

    my $seeded = $self->get_value('tracklist', 'seeded');
    my $mediums = $self->get_value('tracklist', 'mediums');
    my $has_tracks =
        $mediums && @$mediums
            && @{decode_json(encode('utf-8', $mediums->[0]{edits} || '[]'))};

    return ($seeded && $has_tracks)
        || !($releases && scalar @$releases > 0);
}

sub change_page_duplicates
{
    my ($self) = @_;
    my $json = JSON::Any->new( utf8 => 1 );

    my $release_id = $self->get_value ('duplicates', 'duplicate_id')
        or return;

    my $release = $self->c->model('Release')->get_by_id($release_id);
    $self->c->model('Medium')->load_for_releases($release);

    my @media = map +{
        medium_id_for_recordings => $_->id,
        position => $_->position,
        format_id => $_->format_id,
        name => $_->name,
        deleted => 0,
        edits => $json->encode ([ $self->track_edits_from_medium ($_) ]),
    }, $release->all_mediums;

    # Any existing edits on the tracklist page were probably seeded,
    # or they came in through /cdtoc/attach?toc=, or the user edited
    # the tracklist and then navigated back to the duplicates tab.
    #
    # We only care about the TOC scenario:
    #
    # If a TOC is present we need to preserve it and make sure the
    # track count + track lengths match it, everything else can be
    # replaced with data from the existing (duplicate) tracklist.

    my @seededmedia = @{ $self->get_value ('tracklist', 'mediums') // [] };

    # "Add a new release" on /cdtoc/attach can only seed one toc at a time,
    # and only to the first disc.  So we can safely ignore subsequent discs.
    if (defined $seededmedia[0] && $seededmedia[0]->{toc})
    {
        my $medium = $self->c->model('Medium')->get_by_id($media[0]->{medium_id_for_recordings});
        $self->c->model('Track')->load_for_mediums ($medium);

        my @tracks = $self->track_edits_from_medium ($medium);
        my @edits = @{ $json->decode ($seededmedia[0]->{edits}) };

        my @new_edits = map {
            $tracks[$_]->{length} = $edits[$_]->{length};
            $tracks[$_]->{position} = $_ + 1;
            $self->update_track_edit_hash ($tracks[$_]);
        } 0..$#edits;

        $media[0]->{edits} = $json->encode (\@new_edits);
    }

    $self->_post_to_page ($self->page_number->{'tracklist'},
        collapse_hash({ mediums => \@media }));

    # When an existing release is selected, clear out any seeded recordings.
    $self->_post_to_page($self->page_number->{'recordings'},
          collapse_hash({ rec_mediums => [ ] }));
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

    my @fields = qw( packaging_id status_id script_id language_id
                     artist_credit as_auto_editor events );
    my %add_release_args = map { $_ => $data->{$_} } grep { defined $data->{$_} } @fields;

    $add_release_args{name} = trim ($data->{name});
    $add_release_args{comment} = trim ($data->{comment} // '');
    $add_release_args{barcode} = trim ($data->{barcode});

    if ($data->{release_group_id}){
        $add_release_args{release_group_id} = $data->{release_group_id};
    }
    else {
        my @fields = qw( artist_credit primary_type_id as_auto_editor secondary_type_ids );
        my %args = map { $_ => $data->{$_} } grep { defined $data->{$_} } @fields;
        $args{name} = trim( $data->{release_group}{name} // $data->{name} );

        my $edit = $create_edit->($EDIT_RELEASEGROUP_CREATE, $editnote, %args);

        # Previewing a release doesn't care about having the release group id
        $add_release_args{release_group_id} = $edit->entity_id
            unless $previewing;
    }

    if ($data->{no_barcode})
    {
        $add_release_args{barcode} =  '';
    }
    else
    {
        $add_release_args{barcode} = undef unless $data->{barcode};
    }

    if ($add_release_args{events}) {
        $add_release_args{events} =
            $self->_filter_release_events($add_release_args{events});
    }

    # Add the release edit
    my $add_release_edit = $create_edit->(
        $EDIT_RELEASE_CREATE, $editnote, %add_release_args);

    $release = $self->c->model('Release')->get_by_id($add_release_edit->entity_id)
        unless $previewing;

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
    my $release_artist = MusicBrainz::Server::Entity::ArtistCredit->from_array(
        clean_submitted_artist_credits($self->value->{artist_credit})->{names});

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

            $trk->{artist_credit} = artist_credit_to_ref ($release_artist, [ "gid" ]);

            $edits[$trk_idx] = $self->update_track_edit_hash ($trk);
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

    if ($rg_gid && is_guid($rg_gid))
    {
        my $rg = $self->c->model('ReleaseGroup')->get_by_gid($rg_gid);

        if ($rg) {
            $release->release_group_id ($rg->id);
            $release->release_group ($rg);
            $release->name ($rg->name);

            $self->c->model('ArtistCredit')->load ($rg);

            $release->artist_credit ($rg->artist_credit);
        }
    }
    elsif ($artist_gid && is_guid($artist_gid))
    {
        my $artist = $self->c->model('Artist')->get_by_gid($artist_gid);

        if ($artist) {
            $release->artist_credit (
                MusicBrainz::Server::Entity::ArtistCredit->from_artist ($artist));
        }
    }

    if ($label_gid && is_guid($label_gid))
    {
        my $label = $self->c->model('Label')->get_by_gid($label_gid);

        if ($label) {
            $release->add_label(
                MusicBrainz::Server::Entity::ReleaseLabel->new(
                    label => $label,
                    label_id => $label->id
               ));
        }
    }

    unless(defined $release->artist_credit) {
        $release->artist_credit (MusicBrainz::Server::Entity::ArtistCredit->new);
        $release->artist_credit->add_name (
            MusicBrainz::Server::Entity::ArtistCreditName->new(
                name => ''
            )
        );
        $release->artist_credit->names->[0]->artist (MusicBrainz::Server::Entity::Artist->new);
    }

    return $release;
};

sub should_approve {
    my ($self, $type) = @_;
    return $type == $EDIT_MEDIUM_CREATE || $type == $EDIT_RELEASE_REORDER_MEDIUMS;
}

__PACKAGE__->meta->make_immutable;
1;
