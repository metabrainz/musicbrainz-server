package MusicBrainz::Server::Edit::Historic::MACToSAC;
use Moose;
use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( ArrayRef Int Str );
use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_MAC_TO_SAC );

use aliased 'MusicBrainz::Server::Entity::Artist';

extends 'MusicBrainz::Server::Edit::Historic';

sub edit_name     { 'Convert release to single artist' }
sub edit_template { 'historic/mac_to_sac' }
sub edit_type     { $EDIT_HISTORIC_MAC_TO_SAC }
sub historic_type { 13 }

has '+data' => (
    isa => Dict[
        artist_name   => Str,
        old_artist_id => Int,
        new_artist_id => Int,
        release_ids   => ArrayRef[Int],
    ]
);

sub _release_ids
{
    my $self = shift;
    return @{ $self->data->{release_ids} };
}

sub foreign_keys
{
    my $self = shift;
    return {
        Artist  => [ $self->data->{old_artist_id}, $self->data->{new_artist_id} ],
        Release => [ $self->_release_ids ]
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    my $new_artist = $loaded->{Artist}->{ $self->data->{new_artist_id} } ||
        Artist->new();

    $new_artist = $new_artist->meta->clone_instance(
        $new_artist,
        name => $self->data->{artist_name}
    );

    return {
        releases => [ map { $loaded->{Release}->{ $_ } } $self->_release_ids ],
        artist => {
            old => $loaded->{Artist}->{ $self->data->{old_artist_id} },
            new => $new_artist
        }
    }
}

sub upgrade
{
    my ($self) = @_;

    my $target = $self->artist_id == 1 ? $self->new_value->{artist_id} :
                                         $self->artist_id;

    $self->data({
        release_ids   => $self->album_release_ids($self->row_id),
        artist_name   => $self->new_value->{name},
        new_artist_id => $target || 0,
        old_artist_id => 1
    });

    return $self;
}

sub deserialize_new_value
{
    my ($self, $value) = @_;

    my %deserialized;
    if ($value =~ /\n/) {
        @deserialized{qw( sort_name name artist_id move_tracks)} =
            split /\n/, $value;

        if ($deserialized{'name'} =~ /\A\d+\z/ && !defined $deserialized{'artist_id'})
        {
            $deserialized{'move_tracks'} = $deserialized{'artist_id'};
            $deserialized{'artist_id'}   = $deserialized{'name'};
        }

        $deserialized{'name'} = delete $deserialized{sort_name};
    }
    else {
        $deserialized{move_tracks} = 0;
        $deserialized{artist_id} = 0;
        $deserialized{name} = $value;
    }

    return \%deserialized;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
