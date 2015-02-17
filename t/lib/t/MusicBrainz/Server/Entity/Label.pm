package t::MusicBrainz::Server::Entity::Label;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Entity::Label;
use MusicBrainz::Server::Entity::LabelType;
use MusicBrainz::Server::Entity::LabelAlias;

test all => sub {

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
is( $label->format_label_code, 'LC 00123' );

$label->edits_pending(2);
is( $label->edits_pending, 2 );

ok( !$label->has_age );
$label->begin_date->year  (1976);
$label->end_date->year  (2009);
my @got = $label->age;
is_deeply( \@got, [33, 0, 0], "Label age 33 years" );

};

1;
