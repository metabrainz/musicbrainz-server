package MusicBrainz::Server::Entity::Subscription;
use Moose::Role;
use namespace::autoclean;

has 'id' => (
    isa => 'Int',
    is => 'ro'
);

has 'editor_id' => (
    isa => 'Int',
    is => 'ro'
);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
