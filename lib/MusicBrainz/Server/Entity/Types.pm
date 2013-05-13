package MusicBrainz::Server::Entity::Types;

use Moose::Util::TypeConstraints;

subtype 'AggregatedTag'
    => as class_type 'MusicBrainz::Server::Entity::AggregatedTag';

subtype 'Annotation'
    => as class_type 'MusicBrainz::Server::Entity::Annotation';

subtype 'Application'
    => as class_type 'MusicBrainz::Server::Entity::Application';

subtype 'Area'
    => as class_type 'MusicBrainz::Server::Entity::Area';

subtype 'AreaAlias'
    => as class_type 'MusicBrainz::Server::Entity::AreaAlias';

subtype 'AreaType'
    => as class_type 'MusicBrainz::Server::Entity::AreaType';

subtype 'Artist'
    => as class_type 'MusicBrainz::Server::Entity::Artist';

subtype 'ArtistAlias'
    => as class_type 'MusicBrainz::Server::Entity::ArtistAlias';

subtype 'ArtistCredit'
    => as class_type 'MusicBrainz::Server::Entity::ArtistCredit';

subtype 'ArtistCreditName'
    => as class_type 'MusicBrainz::Server::Entity::ArtistCreditName';

subtype 'ArtistType'
    => as class_type 'MusicBrainz::Server::Entity::ArtistType';

subtype 'AutoEditorElection'
    => as class_type 'MusicBrainz::Server::Entity::AutoEditorElection';

subtype 'AutoEditorElectionVote'
    => as class_type 'MusicBrainz::Server::Entity::AutoEditorElectionVote';

subtype 'Barcode'
    => as class_type 'MusicBrainz::Server::Entity::Barcode';

subtype 'CDTOC'
    => as class_type 'MusicBrainz::Server::Entity::CDTOC';

subtype 'CDStub'
    => as class_type 'MusicBrainz::Server::Entity::CDStub';

subtype 'Collection'
    => as class_type 'MusicBrainz::Server::Entity::Collection';

subtype 'Edit'
    => as class_type 'MusicBrainz::Server::Edit';

subtype 'Editor'
    => as class_type 'MusicBrainz::Server::Entity::Editor';

subtype 'EditorOAuthToken'
    => as class_type 'MusicBrainz::Server::Entity::EditorOAuthToken';

subtype 'Entity'
    => as class_type 'MusicBrainz::Server::Entity';

subtype 'Label'
    => as class_type 'MusicBrainz::Server::Entity::Label';

subtype 'LabelAlias'
    => as class_type 'MusicBrainz::Server::Entity::LabelAlias';

subtype 'LabelType'
    => as class_type 'MusicBrainz::Server::Entity::LabelType';

subtype 'Link'
    => as class_type 'MusicBrainz::Server::Entity::Link';

subtype 'Linkable'
    => as role_type 'MusicBrainz::Server::Entity::Role::Linkable';

subtype 'LinkAttribute'
    => as class_type 'MusicBrainz::Server::Entity::LinkAttribute';

subtype 'LinkAttributeType'
    => as class_type 'MusicBrainz::Server::Entity::LinkAttributeType';

subtype 'LinkType'
    => as class_type 'MusicBrainz::Server::Entity::LinkType';

subtype 'LinkTypeAttribute'
    => as class_type 'MusicBrainz::Server::Entity::LinkTypeAttribute';

subtype 'Gender'
    => as class_type 'MusicBrainz::Server::Entity::Gender';

subtype 'Language'
    => as class_type 'MusicBrainz::Server::Entity::Language';

subtype 'Medium'
    => as class_type 'MusicBrainz::Server::Entity::Medium';

subtype 'MediumCDTOC'
    => as class_type 'MusicBrainz::Server::Entity::MediumCDTOC';

subtype 'MediumFormat'
    => as class_type 'MusicBrainz::Server::Entity::MediumFormat';

subtype 'PartialDate'
    => as class_type 'MusicBrainz::Server::Entity::PartialDate';

subtype 'PUID'
    => as class_type 'MusicBrainz::Server::Entity::PUID';

subtype 'Recording'
    => as class_type 'MusicBrainz::Server::Entity::Recording';

subtype 'Relationship'
    => as class_type 'MusicBrainz::Server::Entity::Relationship';

subtype 'ReleaseGroup'
    => as class_type 'MusicBrainz::Server::Entity::ReleaseGroup';

subtype 'ReleaseGroupType'
    => as class_type 'MusicBrainz::Server::Entity::ReleaseGroupType';

subtype 'Release'
    => as class_type 'MusicBrainz::Server::Entity::Release';

subtype 'ReleaseEvent'
    => as class_type 'MusicBrainz::Server::Entity::ReleaseEvent';

subtype 'ReleaseStatus'
    => as class_type 'MusicBrainz::Server::Entity::ReleaseStatus';

subtype 'ReleasePackaging'
    => as class_type 'MusicBrainz::Server::Entity::ReleasePackaging';

subtype 'ReleaseLabel'
    => as class_type 'MusicBrainz::Server::Entity::ReleaseLabel';

subtype 'Script'
    => as class_type 'MusicBrainz::Server::Entity::Script';

subtype 'Tag'
    => as class_type 'MusicBrainz::Server::Entity::Tag';

subtype 'Tracklist'
    => as class_type 'MusicBrainz::Server::Entity::Tracklist';

subtype 'Track'
    => as class_type 'MusicBrainz::Server::Entity::Track';

subtype 'UserTag'
    => as class_type 'MusicBrainz::Server::Entity::UserTag';

subtype 'Work'
    => as class_type 'MusicBrainz::Server::Entity::Work';

subtype 'WorkAlias'
    => as class_type 'MusicBrainz::Server::Entity::WorkAlias';

subtype 'WorkType'
    => as class_type 'MusicBrainz::Server::Entity::WorkType';

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
