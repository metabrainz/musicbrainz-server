package MusicBrainz::Server::Entity::EditorSubscription;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Entity::Types;

with 'MusicBrainz::Server::Entity::Subscription::Active';

has 'subscribed_editor' => (
    isa => 'Editor',
    is => 'rw'
);

has 'subscribed_editor_id' => (
    isa => 'Int',
    is => 'ro',
);

sub type { 'editor' }

sub target_id { shift->subscribed_editor_id }

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
