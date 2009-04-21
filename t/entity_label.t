use strict;
use warnings;
use Test::More tests => 13;
use_ok 'MusicBrainz::Server::Entity::Label';
use_ok 'MusicBrainz::Server::Entity::LabelType';
use_ok 'MusicBrainz::Server::Entity::LabelAlias';

my $label = MusicBrainz::Server::Entity::Label->new();
ok( defined $label->begin_date );
ok( $label->begin_date->is_empty );
ok( defined $label->end_date );
ok( $label->end_date->is_empty );

is( $label->type_name, undef );
$label->type(MusicBrainz::Server::Entity::LabelType->new(id => 1, name => 'Production'));
is( $label->type_name, 'Production' );
is( $label->type->id, 1 );
is( $label->type->name, 'Production' );

$label->label_code(123);
is( $label->label_code, 123 );
is( $label->format_label_code, 'LC-00123' );
