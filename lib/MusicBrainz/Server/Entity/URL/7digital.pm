package MusicBrainz::Server::Entity::URL::7digital;

use Moose;

extends 'MusicBrainz::Server::Entity::URL';
with 'MusicBrainz::Server::Entity::URL::Sidebar';

sub sidebar_name { '7digital' }

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2025 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
