package MusicBrainz::Server::Entity::Types;

use Moose::Util::TypeConstraints;

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

subtype 'Label'
    => as class_type 'MusicBrainz::Server::Entity::Label';

subtype 'LabelAlias'
    => as class_type 'MusicBrainz::Server::Entity::LabelAlias';

subtype 'LabelType'
    => as class_type 'MusicBrainz::Server::Entity::LabelType';

subtype 'Country'
    => as class_type 'MusicBrainz::Server::Entity::Country';

subtype 'Gender'
    => as class_type 'MusicBrainz::Server::Entity::Gender';

subtype 'PartialDate'
    => as class_type 'MusicBrainz::Server::Entity::PartialDate';

subtype 'Work'
    => as class_type 'MusicBrainz::Server::Entity::Work';

subtype 'WorkAlias'
    => as class_type 'MusicBrainz::Server::Entity::WorkAlias';

subtype 'WorkType'
    => as class_type 'MusicBrainz::Server::Entity::WorkType';

1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

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
