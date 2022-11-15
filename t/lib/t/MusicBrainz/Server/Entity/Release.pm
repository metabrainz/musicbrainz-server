package t::MusicBrainz::Server::Entity::Release;
use utf8;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use aliased 'MusicBrainz::Server::Entity::Release';
use aliased 'MusicBrainz::Server::Entity::ReleasePackaging';
use aliased 'MusicBrainz::Server::Entity::ReleaseStatus';
use aliased 'MusicBrainz::Server::Entity::Medium';
use aliased 'MusicBrainz::Server::Entity::MediumFormat';

test all => sub {

my $release = Release->new();
does_ok( $release, 'MusicBrainz::Server::Entity::Role::Quality' );

$release->edits_pending(2);
is( $release->edits_pending, 2 );

is( $release->status_name, undef );
$release->status(ReleaseStatus->new(id => 1, name => 'Official'));
is( $release->status_name, 'Official', 'Release status is Official' );
is( $release->status->id, 1 );
is( $release->status->name, 'Official', 'Release status is Official' );

is( $release->packaging_name, undef );
$release->packaging(ReleasePackaging->new(id => 1, name => 'Jewel Case'));
is( $release->packaging_name, 'Jewel Case', 'Release packaging is Jewel Case' );
is( $release->packaging->id, 1 );
is( $release->packaging->name, 'Jewel Case', 'Release packaging is Jewel Case' );

ok( @{$release->labels} == 0 );
ok( @{$release->mediums} == 0 );

is( $release->combined_format_name, '' );
is( $release->combined_track_count, '' );

my $medium1 = Medium->new(track_count => 10, position => 1);
$medium1->format(MediumFormat->new(id => 1, name => 'CD'));
$release->add_medium($medium1);
is( $release->combined_format_name, 'CD', 'Release format is CD' );
is( $release->combined_track_count, '10', 'Release has 10 tracks' );

my $medium2 = Medium->new(track_count => 22, position => 2);
$medium2->format(MediumFormat->new(id => 2, name => 'DVD'));
$release->add_medium($medium2);
is( $release->combined_format_name, 'CD + DVD', 'Release format is CD + DVD' );
is( $release->combined_track_count, '10 + 22', 'Release has 10 + 22 tracks' );

my $medium3 = Medium->new(track_count => 10, position => 3);
$medium3->format(MediumFormat->new(id => 1, name => 'CD'));
$release->add_medium($medium3);
is( $release->combined_format_name, '2×CD + DVD', 'Release format is 2xCD + DVD' );
is( $release->combined_track_count, '10 + 22 + 10', 'Release has 10 + 22 + 10 tracks' );

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
