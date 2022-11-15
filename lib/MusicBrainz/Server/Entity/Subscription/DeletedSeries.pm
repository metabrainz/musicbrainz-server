package MusicBrainz::Server::Entity::Subscription::DeletedSeries;
use Moose;
use namespace::autoclean;

with 'MusicBrainz::Server::Entity::Subscription::Deleted';

__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
