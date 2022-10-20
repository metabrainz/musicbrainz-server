package MusicBrainz::Server::Data::Role::Relatable;

use Moose::Role;
use namespace::autoclean;

with 'MusicBrainz::Server::Data::Role::EntityModelClass';
with 'MusicBrainz::Server::Data::Role::GetByGID';
with 'MusicBrainz::Server::Data::Role::MainTable';
with 'MusicBrainz::Server::Data::Role::GID';
with 'MusicBrainz::Server::Data::Role::GIDRedirect';

no Moose::Role;
1;

=head1 NAME

MusicBrainz::Server::Data::Role::Relatable

=head1 DESCRIPTION

One role to relate them all!

Group roles associated to entity types supporting relationships,
and by extension having main table, model, GID, and GID redirect.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009,2011 Lukas Lalinsky
Copyright (C) 2010-2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
