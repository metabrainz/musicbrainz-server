package MusicBrainz::Server::Entity::Types;

use Moose::Util::TypeConstraints;
use namespace::autoclean;

for my $cls (qw(AggregatedTag AggregatedGenre Annotation Application
                Area AreaAlias AreaAliasType AreaType
                Artist ArtistAlias ArtistAliasType ArtistCredit ArtistCreditName ArtistType
                AutoEditorElection AutoEditorElectionVote
                Barcode CDTOC CDStub Collection CollectionType Coordinates
                CoverArtType
                CritiqueBrainz::Review CritiqueBrainz::User
                EditNoteChange
                Editor EditorOAuthToken
                Event EventAlias EventAliasType EventType
                Gender Genre GenreAlias GenreAliasType
                Instrument InstrumentAlias InstrumentAliasType InstrumentType
                Label LabelAlias LabelAliasType LabelType
                Link LinkAttribute LinkAttributeType LinkType LinkTypeAttribute
                Language
                Medium MediumCDTOC MediumFormat
                PartialDate
                Place PlaceAlias PlaceAliasType PlaceType
                Recording RecordingAlias RecordingAliasType
                Relationship RelationshipTargetTypeGroup RelationshipLinkTypeGroup
                ReleaseGroup ReleaseGroupAlias ReleaseGroupAliasType ReleaseGroupSecondaryType ReleaseGroupType
                Release ReleaseAlias ReleaseAliasType ReleaseEvent ReleaseStatus ReleasePackaging ReleaseLabel
                Script Tag Track UserTag
                Series SeriesAlias SeriesAliasType SeriesOrderingType SeriesType
                Work WorkAlias WorkAliasType WorkType WorkLanguage
                WorkAttribute WorkAttributeType WorkAttributeTypeAllowedValue)) {
    subtype $cls => as class_type "MusicBrainz::Server::Entity::$cls";
}

subtype 'Edit'
    => as class_type 'MusicBrainz::Server::Edit';

subtype 'Entity'
    => as class_type 'MusicBrainz::Server::Entity';

subtype 'Relatable'
    => as role_type 'MusicBrainz::Server::Entity::Role::Relatable';

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2013 Lukas Lalinsky, MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
