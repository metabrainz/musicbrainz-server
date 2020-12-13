package MusicBrainz::Server::Data::CoverArtType;

use Moose;
use namespace::autoclean;

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::ArtType';

sub _type { 'cover_art_type' }

sub art_schema { 'cover_art_archive' }

sub art_type_table { 'cover_art_archive.cover_art_type' }

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::CoverArtType';
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
