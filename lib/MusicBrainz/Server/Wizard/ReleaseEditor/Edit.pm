package MusicBrainz::Server::Wizard::ReleaseEditor::Edit;
use Moose;
use Data::Compare;
use namespace::autoclean;
use MusicBrainz::Server::Data::Utils qw( artist_credit_to_ref trim );
use MusicBrainz::Server::Form::Utils qw( expand_param expand_all_params collapse_param );
use MusicBrainz::Server::Track qw( format_track_length );

extends 'MusicBrainz::Server::Wizard::ReleaseEditor';

use MusicBrainz::Server::Constants qw(
    $EDIT_RECORDING_EDIT
    $EDIT_RELEASE_EDIT
    $EDIT_RELEASE_ARTIST
);

sub add_medium_position {
    my ($self, $idx, $new) = @_;

    return $idx + 1;
};

augment 'create_edits' => sub
{
    my ($self, %opts) = @_;
    my ($data, $create_edit, $editnote, $previewing)
        = @opts{qw( data create_edit edit_note previewing )};

    $self->_load_release;
    $self->c->stash( medium_formats => [ $self->c->model('MediumFormat')->get_all ] );

    # release edit
    # ----------------------------------------

    my @fields = qw( packaging_id status_id script_id language_id country_id
                     date as_auto_editor release_group_id artist_credit );
    my %args = map { $_ => $data->{$_} } grep { exists $data->{$_} } @fields;

    $args{name} = trim ($data->{name});
    $args{comment} = trim ($data->{comment} // '');
    $args{barcode} = trim ($data->{barcode});

    if ($data->{no_barcode})
    {
        $args{barcode} =  '';
    }
    else
    {
        $args{barcode} = undef unless $data->{barcode};
    }

    $args{'to_edit'} = $self->release;
    $self->c->stash->{changes} = 0;

    $create_edit->($EDIT_RELEASE_EDIT, $editnote, %args);

    # recording edits
    # ----------------------------------------

    my $medium_index = -1;
    for my $medium (@{ $data->{rec_mediums} }) {
        $medium_index++;
        my $track_index = -1;
        for my $track_association (@{ $medium->{associations} }) {
            $track_index++;
            next if $track_association->{gid} eq 'new';
            if ($track_association->{update_recording}) {
                my $track = $data->{mediums}[ $medium_index ]{tracks}[ $track_index ];
                $create_edit->(
                    $EDIT_RECORDING_EDIT, $editnote,
                    to_edit => $self->c->model('Recording')->get_by_gid( $track_association->{gid} ),
                    name => $track->name,
                    artist_credit => artist_credit_to_ref($track->artist_credit, [ "gid" ]),
                    length => $track->length,
                    as_auto_editor => $data->{as_auto_editor},
                );
            }
        }
    }

    return $self->release;
};

after 'prepare_tracklist' => sub {
    my ($self, $release) = @_;

    my $json = JSON::Any->new( utf8 => 1 );

    $self->c->model('Medium')->load_for_releases($self->release);
    my @medium_cdtocs = $self->c->model('MediumCDTOC')->load_for_mediums(
        $self->release->all_mediums);

    $self->c->model('CDTOC')->load(@medium_cdtocs);

    my $database_artist = artist_credit_to_ref ($release->artist_credit, [ "gid" ]);
    my $submitted_artist = $self->c->stash->{release_artist};

    if ($self->_is_same_artist ($database_artist, $submitted_artist))
    {
        # Just use "null" here to indicate the release artist wasn't edited.
        $self->c->stash->{release_artist_json} = "null";
    }
    else
    {
        $self->c->stash->{release_artist_json} = $json->encode ($database_artist);

        # The release artist was changed, create or update medium edits.
        for my $medium ($self->release->all_mediums)
        {
            $self->_update_medium_edits ($medium, $database_artist, $submitted_artist);
        }
    }
};

augment 'load' => sub
{
    my ($self) = @_;

    $self->_load_release;
    $self->c->model('Medium')->load_for_releases($self->release);

    $self->c->stash->{edit_release} = 1;

    return $self->release;
};

# this just loads the remaining bits of a release, not yet loaded by 'load'
sub _load_release
{
    my ($self) = @_;

    $self->c->model('ReleaseLabel')->load($self->release);
    $self->c->model('Label')->load(@{ $self->release->labels });
    $self->c->model('ReleaseGroupType')->load($self->release->release_group);
    $self->c->model('Release')->annotation->load_latest ($self->release);
}

sub _edits_from_tracklist
{
    my ($self, $tracklist_id) = @_;

    my $tracklist = $self->c->model('Tracklist')->get_by_id($tracklist_id);
    $self->c->model('Track')->load_for_tracklists($tracklist);
    $self->c->model('ArtistCredit')->load($tracklist->all_tracks);
    $self->c->model('Artist')->load(map { @{ $_->artist_credit->names } } $tracklist->all_tracks);

    return [ map { $self->track_edit_from_track ($_) } $tracklist->all_tracks ];
}


=method _is_same_artist

_is_same_artist compares two artist credits and decides if they are identical
or not. This method makes the following assumptions:

    $a  is an artist credit loaded from the database, it has both row ids and
        gids for each artist in the artist credit.

    $b  is an artist credit either loaded from the database, seeded to the
        release editor, or entered by the user.  It may lack row ids and gids.

=cut

sub _is_same_artist
{
    my ($self, $a, $b) = @_;

    my @names_a = @{ $a->{names } };
    my @names_b = @{ $b->{names } };

    return 0 if scalar @names_a != scalar @names_b;

    for my $i (0..$#names_a)
    {
        $a = $names_a[$i];
        $b = $names_b[$i];

        if ($b->{artist}->{gid})
        {
            return 0 if $a->{artist}->{gid} ne $b->{artist}->{gid};
        }
        elsif ($b->{artist}->{id})
        {
            return 0 if $a->{artist}->{id} != $b->{artist}->{id};
        }
        else
        {
            return 0;    # new artist
        }

        return 0 if ($a->{join_phrase} // '') ne ($b->{join_phrase} // '');
        return 0 if ($a->{name} // '') ne ($b->{name} // '');
    }

    return 1;
}


sub _update_medium_edits
{
    my ($self, $medium, $database_artist, $submitted_artist) = @_;

    my $json = JSON::Any->new( utf8 => 1 );

    my $mediums = $self->get_value ('tracklist', 'mediums') // [];

    for my $disc_idx (0..$#$mediums)
    {
        my $disc = $mediums->[$disc_idx];
        my $edits;

        if (!$disc->{edits} && $disc->{tracklist_id})
        {
            $edits = $self->_edits_from_tracklist ($disc->{tracklist_id});
        }
        elsif ($disc->{edits})
        {
            $edits = $json->decode ($disc->{edits});
        }

        next unless $edits;

        my $changes = 0;

        for my $trk_idx (0..$#$edits)
        {
            my $trk = $edits->[$trk_idx];

            if ($self->_is_same_artist ($trk->{artist_credit}, $database_artist))
            {
                $trk->{artist_credit} = $submitted_artist;
                $edits->[$trk_idx] = $self->update_track_edit_hash ($trk);
                $changes = 1;
            }
        }

        if ($changes)
        {
            $mediums->[$disc_idx]->{edits} = $json->encode ($edits);
        }
    };

    $self->set_value ('tracklist', 'mediums', $mediums);
}

__PACKAGE__->meta->make_immutable;
1;
