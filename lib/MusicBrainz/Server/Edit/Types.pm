package MusicBrainz::Server::Edit::Types;
use strict;
use MooseX::Types -declare => [qw( ArtistCreditDefinition PartialDateHash )];
use MooseX::Types::Moose qw( ArrayRef Int Maybe );
use MooseX::Types::Structured qw( Dict Optional );
use Sub::Exporter -setup => { exports => [qw(
    ArtistCreditDefinition
    Changeset
    Nullable
    PartialDateHash
)] };

sub Nullable { (Optional[Maybe shift], @_) }
sub Changeset
{
    my %fields = @_;
    return (
        old => Dict[%fields],
        new => Dict[%fields]
    )
}

subtype PartialDateHash,
    as Dict[
        year => Nullable[Int],
        month => Nullable[Int],
        day => Nullable[Int]
    ];

subtype ArtistCreditDefinition,
    as ArrayRef;

1;
