package MusicBrainz::Server::Entity::Subscription::Active;
use Moose::Role;
use namespace::autoclean;

with 'MusicBrainz::Server::Entity::Subscription';

requires 'target_id', 'type';

has 'last_edit_sent' => (
    isa => 'Int',
    is => 'ro'
);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
