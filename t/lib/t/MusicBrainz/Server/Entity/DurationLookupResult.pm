package t::MusicBrainz::Server::Entity::DurationLookupResult;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;

BEGIN { use MusicBrainz::Server::Entity::DurationLookupResult; }

test all => sub {

my $artist = MusicBrainz::Server::Entity::DurationLookupResult->new();
has_attribute_ok($artist, $_) for qw( distance medium_id medium );

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
