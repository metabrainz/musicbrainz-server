package MusicBrainz::Server::Entity::WorkLanguage;

use Moose;
use MusicBrainz::Server::Entity::Types;

with 'MusicBrainz::Server::Entity::Role::LastUpdate';

has [qw( work_id language_id )] => (
    is => 'rw',
    isa => 'Int',
);

has work => (
    is => 'rw',
    isa => 'Work',
);

has language => (
    is => 'rw',
    isa => 'Language',
);

no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
