package MusicBrainz::Server::Edit::Types;
use strict;
use warnings;

use MooseX::Types -declare => [qw(
    ArtistCreditDefinition
    CoordinateHash
    LinkAttributesArray
    PartialDateHash
    RecordingMergesArray
)];
use MooseX::Types::Moose qw( ArrayRef Int Maybe Num Str );
use MooseX::Types::Structured qw( Dict Optional );
use Sub::Exporter -setup => { exports => [qw(
    ArtistCreditDefinition
    Changeset
    CoordinateHash
    LinkAttributesArray
    Nullable
    NullableOnPreview
    PartialDateHash
    RecordingMergesArray
)] };

sub Nullable { (Optional[Maybe shift], @_) }

# This isn't (currently) any different from Nullable.  It only serves to document
# the intent.  For now, these still need to be validated elsewhere when setting the
# attribute.
sub NullableOnPreview { (Optional[Maybe shift], @_) }

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

subtype CoordinateHash,
    as Dict[
        latitude => Num,
        longitude => Num,
    ];

subtype ArtistCreditDefinition,
    as Dict[
        names => ArrayRef[
            Dict[
                artist => Dict[
                    name => Nullable[Str],
                    id => Nullable[Str],
                    gid => Optional[Str],
                ],
                name => Nullable[Str],
                join_phrase => Nullable[Str],
            ]],
        preview => Optional[Str],
    ];

subtype LinkAttributesArray,
    as ArrayRef[Dict[
        type => Dict[
            root => Optional[Dict[
                name => Optional[Str],
                id => Optional[Int],
                gid => Optional[Str],
            ]],
            name => Optional[Str],
            id => Int,
            gid => Optional[Str],
        ],
        credited_as => Optional[Str],
        text_value => Optional[Str],
    ]];

subtype RecordingMergesArray,
    as ArrayRef[Dict[
        medium => Int,
        track => Str,
        sources => ArrayRef[Dict[
            id => Int,
            gid => Optional[Str],
            name => Str,
            length => Nullable[Int],
            artist_credit_id => Optional[Int],
        ]],
        destination => Dict[
            id => Int,
            gid => Optional[Str],
            name => Str,
            length => Nullable[Int],
            artist_credit_id => Optional[Int],
        ]
    ]];

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
