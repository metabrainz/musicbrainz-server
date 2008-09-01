package MusicBrainz::Server::Facade::Artist;

use strict;
use warnings;

use base 'Class::Accessor';

use Carp;
use Class::Accessor;
use MusicBrainz::Server::Artist;

__PACKAGE__->mk_accessors( qw{
    end_date
    id
    mbid
    name
    quality
    resolution
    sort_name
    start_date
    type
});

=head1 NAME

MusicBrainz::Server::Facade::Artist

=head1 SYNOPSIS

my $artist = $c->models('Artist')->load('mb-id-here')

=head1 DESCRIPTION

MusicBrainz::Server::Artist has an interface that does not map nicely
in the Template Toolkit templates, so this facade provides a lighter
interface over the top - until the originial interface can be changed

=head1 METHODS

=head2 entity_type

A human readable string representing the type of this entity. This is
useful when creating links.

=cut

sub entity_type { 'artist' }

=head2 get_artist

Attempt to fetch the underlying artist object that this facade is covering.

Note, this may return undef.

=cut

sub get_artist { shift->{_a}; }

=head2 complete_date_range

Returns true if the artist has both a start and end date; false otherwise

=cut

sub complete_date_range
{
    my $self = shift;

    return $self->start_date && $self->end_date;
}

=head2 subscriber_count

Get's the amount of moderators subscribed to this artist

=cut

sub subscriber_count
{
    my $self = shift;

    croak "This can only be called on artists created via a database query"
        if not ref $self->{_a};

    return scalar $self->{_a}->GetSubscribers;
}

=head2 new_from_artist

Instantiate a new artist facade from an already existing artist object.

The original artist will be stored in this object and can be fetched
with L<get_artist>.

=cut

sub new_from_artist
{
    my ($class, $artist) = @_;

    $class->new({
        end_date    => $artist->end_date, 
        id          => $artist->GetId,
        mbid        => $artist->GetMBId,
        name        => $artist->GetName,
        quality     => ModDefs::GetQualityText($artist->quality),
        resolution  => $artist->resolution,
        sort_name   => $artist->sort_name,
        start_date  => $artist->begin_date,
        type        => MusicBrainz::Server::Artist::type_name($artist->type),

        _a          => $artist,
    });
}

1;
