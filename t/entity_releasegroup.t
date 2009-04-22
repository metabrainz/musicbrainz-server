use strict;
use warnings;
use Test::More tests => 8;
use_ok 'MusicBrainz::Server::Entity::ReleaseGroup';
use_ok 'MusicBrainz::Server::Entity::ReleaseGroupType';

my $rg = MusicBrainz::Server::Entity::ReleaseGroup->new();
ok( !defined $rg->first_release_date );

is( $rg->type_name, undef );
$rg->type(MusicBrainz::Server::Entity::ReleaseGroupType->new(id => 1, name => 'Album'));
is( $rg->type_name, 'Album' );
is( $rg->type->id, 1 );
is( $rg->type->name, 'Album' );

$rg->edits_pending(2);
is( $rg->edits_pending, 2 );
