package MusicBrainz::Server::Edit::Historic::RemoveReleases;
use Moose;
use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( ArrayRef Int Str );
use MusicBrainz::Server::Data::Release;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_REMOVE_RELEASES );

extends 'MusicBrainz::Server::Edit::Historic';
with 'MusicBrainz::Server::Edit::Historic::NoSerialization';

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

sub build_display_data
{
    my ($self, $loaded) = @_;

    my @releases = map {
        MusicBrainz::Server::Data::Release->new( id => $_->id, name => $_->name );
    } @{ $self->data->{releases} }

    return { releases => \@releases }
}

sub upgrade
{
    my $self = shift;

    my @albums = split( /\n/, $self->new_value );
    map { s/^Album.*=// } @albums;

    my @releases = map { { 
            id => $albums[$_], 
            name => $albums[$_+1] 
        } } grep { ($_ + 1)  % 2 } (0..$#albums);

    $self->data({ releases => \@releases });

    return $self;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
