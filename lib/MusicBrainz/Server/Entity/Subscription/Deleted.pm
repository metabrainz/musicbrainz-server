package MusicBrainz::Server::Entity::Subscription::Deleted;
use Moose::Role;
use namespace::autoclean;
use Moose::Util::TypeConstraints;

with 'MusicBrainz::Server::Entity::Subscription';

has 'last_known_name' => (
    isa => 'Str',
    is => 'ro',
    required => 1
);

has 'last_known_comment' => (
    isa => 'Str',
    is => 'ro',
    required => 1
);

has 'edit_id' => (
    isa => 'Int',
    is => 'ro',
    required => 1
);

has 'reason' => (
    isa => enum([qw( merged deleted )]),
    is => 'ro',
    required => 1
);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
