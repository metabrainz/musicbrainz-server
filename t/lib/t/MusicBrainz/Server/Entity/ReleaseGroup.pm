package t::MusicBrainz::Server::Entity::ReleaseGroup;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Entity::ReleaseGroup;
use MusicBrainz::Server::Entity::ReleaseGroupType;

test all => sub {

my $rg = MusicBrainz::Server::Entity::ReleaseGroup->new();
ok( !defined $rg->first_release_date );

is( $rg->type_name, undef );
$rg->primary_type(MusicBrainz::Server::Entity::ReleaseGroupType->new(id => 1, name => 'Album'));
is( $rg->type_name, 'Album' );
is( $rg->primary_type->id, 1 );
is( $rg->primary_type->name, 'Album' );

$rg->edits_pending(2);
is( $rg->edits_pending, 2 );

};

1;
