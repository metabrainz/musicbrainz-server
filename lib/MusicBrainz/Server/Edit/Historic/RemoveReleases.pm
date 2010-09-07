package MusicBrainz::Server::Edit::Historic::RemoveReleases;
use Moose;
use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( ArrayRef Int Str );
use MusicBrainz::Server::Data::Release;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_REMOVE_RELEASES );

extends 'MusicBrainz::Server::Edit::Historic';

sub edit_name     { 'Remove releases' }
sub historic_type { 24 }
sub edit_type     { $EDIT_HISTORIC_REMOVE_RELEASES }

has '+data' => (
    isa => Dict[
        releases => ArrayRef[
            Dict[
                id => Int,
                name => Str
            ],
        ],
    ]
);

sub foreign_keys
{
    my $self = shift;

    return {
        Release => { map { $_->{id} => [ 'ArtistCredit' ] } @{ $self->data->{releases} } },
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        releases => [ 
            map {
                $loaded->{Release}{$_->{id}} ||
                    MusicBrainz::Server::Data::Release->new(
                        id => $_->{id}, name => $_->{name}
                    );
            } @{ $self->data->{releases} }
        ]
    };
}

sub upgrade
{
    my $self = shift;

    my @releases;
    for (my $i = 0; ; $i++) {
        my $id = $self->new_value->{"AlbumId$i"} or last;
        my $name = $self->new_value->{"AlbumName$i"} or last;
 
        if (my @ids = @{ $self->album_release_ids($id) }) {
            push @releases, map +{
                id => $_, name => $name
            }, @ids;
        }
        else {
            # If the release has been removed, we won't be able to resolve the IDs
            push @releases, {
                id => 0, name => $name
            }
        }
    }


    $self->data({ releases => \@releases });

    return $self;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
