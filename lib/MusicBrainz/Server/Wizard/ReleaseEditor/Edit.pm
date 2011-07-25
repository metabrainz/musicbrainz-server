package MusicBrainz::Server::Wizard::ReleaseEditor::Edit;
use Moose;
use Data::Compare;
use namespace::autoclean;
use MusicBrainz::Server::Data::Utils qw( artist_credit_to_ref );

extends 'MusicBrainz::Server::Wizard::ReleaseEditor';

use MusicBrainz::Server::Constants qw(
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

    my @fields = qw( name comment packaging_id status_id script_id language_id
                     country_id barcode date as_auto_editor release_group_id );
    my %args = map { $_ => $data->{$_} } grep { exists $data->{$_} } @fields;

    $args{'to_edit'} = $self->release;
    $self->c->stash->{changes} = 0;

    $create_edit->($EDIT_RELEASE_EDIT, $editnote, %args);

    # release artist edit
    # ----------------------------------------

    $create_edit->(
        $EDIT_RELEASE_ARTIST, $editnote, release => $self->release,
        update_tracklists => 1, artist_credit => $data->{artist_credit},
        as_auto_editor => $data->{as_auto_editor}
        );

    return $self->release;
};

override 'prepare_tracklist' => sub {
    my ($self, $release) = @_;

    my $json = JSON::Any->new( utf8 => 1 );

    my $database_artist = artist_credit_to_ref ($release->artist_credit);
    my $submitted_artist = $self->get_value ("information", "artist_credit");

    if (Compare ($database_artist, $submitted_artist))
    {
        # Just use "null" here to indicate the release artist wasn't edited.
        $self->c->stash->{release_artist_json} = "null";
    }
    else
    {
        # The release artist was changed, provide javascript with the original
        # release artist, so it knows which track artists to update.
        $self->c->stash->{release_artist_json} = $json->encode (
            artist_credit_to_ref ($release->artist_credit));
    }

    $self->c->model('Medium')->load_for_releases($self->release);
    my @medium_cdtocs = $self->c->model('MediumCDTOC')->load_for_mediums(
        $self->release->all_mediums);

    $self->c->model('CDTOC')->load(@medium_cdtocs);


    my @medium_cdtocs_json;
    my $number = 0;
    for my $medium ($self->release->all_mediums)
    {
        $medium_cdtocs_json[$number++] =
            $medium->cdtocs ? $medium->cdtocs->[0]->cdtoc->track_count : undef;
    }

    $self->c->stash->{medium_cdtocs_json} = $json->encode (\@medium_cdtocs_json);
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

__PACKAGE__->meta->make_immutable;
1;
