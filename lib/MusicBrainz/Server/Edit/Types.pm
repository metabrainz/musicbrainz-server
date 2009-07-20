package MusicBrainz::Server::Edit::Types;
use strict;
use MooseX::Types -declare => [qw( ArtistCreditDefinition PartialDateHash )];
use MooseX::Types::Moose qw( ArrayRef Int Maybe );
use MooseX::Types::Structured qw( Dict Optional );
use Sub::Exporter -setup => { exports => [qw( ArtistCreditDefinition Nullable PartialDateHash )] };

sub Nullable { (Optional[Maybe shift], @_) }

subtype PartialDateHash,
    as Dict[
        year => Int,
        month => Optional[Int],
        day => Optional[Int]
    ];

subtype ArtistCreditDefinition,
    as ArrayRef;

1;
