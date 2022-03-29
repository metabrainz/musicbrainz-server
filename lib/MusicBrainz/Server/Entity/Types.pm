package MusicBrainz::Server::Entity::Types;

use Moose::Util::TypeConstraints;

for my $cls (qw(AggregatedTag AggregatedGenre AliasType Annotation Application
                Area AreaAlias AreaType
                Artist ArtistAlias ArtistCredit ArtistCreditName ArtistType
                AutoEditorElection AutoEditorElectionVote
                Barcode CDTOC CDStub Collection CollectionType Coordinates
                CoverArtType
                CritiqueBrainz::Review CritiqueBrainz::User
                Editor EditorOAuthToken
                Event EventAlias EventType
                Gender Genre
                Instrument InstrumentType
                Label LabelAlias LabelType
                Link LinkAttribute LinkAttributeType LinkType LinkTypeAttribute
                Language
                Medium MediumCDTOC MediumFormat
                PartialDate
                Place PlaceAlias PlaceType
                Recording RecordingAlias
                Relationship RelationshipTargetTypeGroup RelationshipLinkTypeGroup
                ReleaseGroup ReleaseGroupAlias ReleaseGroupSecondaryType ReleaseGroupType
                Release ReleaseAlias ReleaseEvent ReleaseStatus ReleasePackaging ReleaseLabel
                Script Tag Track UserTag
                Series SeriesOrderingType SeriesType
                Work WorkAlias WorkType WorkLanguage
                WorkAttribute WorkAttributeType WorkAttributeTypeAllowedValue)) {
    subtype $cls => as class_type "MusicBrainz::Server::Entity::$cls";
}

subtype 'Edit'
    => as class_type 'MusicBrainz::Server::Edit';

subtype 'Entity'
    => as class_type 'MusicBrainz::Server::Entity';

subtype 'Linkable'
    => as role_type 'MusicBrainz::Server::Entity::Role::Linkable';

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2013 Lukas Lalinsky, MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
