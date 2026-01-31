package MusicBrainz::Server::Entity::URL::Qobuz;

use Moose;
use utf8;

extends 'MusicBrainz::Server::Entity::URL';
with 'MusicBrainz::Server::Entity::URL::Sidebar';

sub sidebar_name { 'Qobuz' }

sub key {
    # Countries share IDs.
    return shift->url =~ s{^https://www\.qobuz\.com/(?:[a-z]{2}-[a-z]{2}/)?(?:album|interpreter|label)/([\w\d-]+)}{qobuz:$1}r;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
