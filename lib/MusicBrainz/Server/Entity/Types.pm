package MusicBrainz::Server::Entity::Types;

use Moose::Util::TypeConstraints;

for my $cls (qw(AggregatedTag AliasType Annotation Application
                Area AreaAlias AreaType
                Artist ArtistAlias ArtistCredit ArtistCreditName ArtistType
                AutoEditorElection AutoEditorElectionVote
                Barcode CDTOC CDStub Collection CollectionType Coordinates
                CoverArtType
                Editor EditorOAuthToken
                Instrument InstrumentType
                Label LabelAlias LabelType
                Link LinkAttribute LinkAttributeType LinkType LinkTypeAttribute
                Gender Language
                Medium MediumCDTOC MediumFormat
                PartialDate
                Place PlaceAlias PlaceType
                Recording
                Relationship
                ReleaseGroup ReleaseGroupSecondaryType ReleaseGroupType
                Release ReleaseEvent ReleaseStatus ReleasePackaging ReleaseLabel
                Script Tag Track UserTag
                Series SeriesOrderingType SeriesType
                Work WorkAlias WorkType
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

=head1 COPYRIGHT

Copyright (C) 2009-2013 Lukas Lalinsky, MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
