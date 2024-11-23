package MusicBrainz::Server::Translation::History;
use Moose;
use namespace::autoclean;

extends 'MusicBrainz::Server::Translation';
with 'MusicBrainz::Server::Role::Translation' => { domain => 'history' };

sub l { __PACKAGE__->instance->gettext(@_) }

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2024 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
