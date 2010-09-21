package MusicBrainz::Server::Edit::Historic::AddTrack;
use Moose;
use MooseX::Types::Structured qw( Dict Optional );
use MooseX::Types::Moose qw( ArrayRef Int Str );
use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_ADD_TRACK );
use Scalar::Util qw( looks_like_number );

extends 'MusicBrainz::Server::Edit::Historic';

sub edit_name     { 'Add track' }
sub historic_type { 7 }
sub edit_type     { $EDIT_HISTORIC_ADD_TRACK }
sub edit_template { 'historic/add_track_old' }

sub related_entities
{
    my $self = shift;
    return {
        release => $self->data->{release_ids}
    }
}

has '+data' => (
    isa => Dict[
        release_ids => ArrayRef[Int],
        name        => Str,
        position    => Int,
        artist_name => Optional[Str],
    ]
);

sub release_ids { @{ shift->data->{release_ids} } }

sub foreign_keys
{
    my $self = shift;
    return {
        Release => {
            map { $_ => [ 'ArtistCredit' ] } $self->release_ids
        }
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    my @release_ids = @{ $self->data->{release_ids} };
    return {
        releases => [
            map {
                $loaded->{Release}->{ $_ }
            } $self->release_ids
        ],
        position    => $self->data->{position},
        name        => $self->data->{name},
        artist_name => $self->data->{artist_name}
    }
}

sub upgrade
{
    my $self = shift;
    $self->data({
        release_ids => $self->album_release_ids($self->row_id),
        %{ $self->new_value },
    });

    return $self;
}

sub deserialize_new_value
{
    my ($self, $new) = @_;
    my @lines = split /\n/, $new;

    # Some edits (see #650 seem to have position and name swapped round...)
    my ($name, $position) = @lines;
    if (looks_like_number($name) && !looks_like_number($position)) {
        ($name, $position) = ($position, $name);
    }

    my %deserialized = (
        name     => $name,
        position => $position
    );

    $deserialized{artist_name} = $lines[3] if $lines[3];

    return \%deserialized;
}


__PACKAGE__->meta->make_immutable;
no Moose;
1;
