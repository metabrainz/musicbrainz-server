package t::MusicBrainz::Server::Entity::Label;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Entity::Label;
use MusicBrainz::Server::Entity::LabelType;
use MusicBrainz::Server::Entity::LabelAlias;

use MusicBrainz::Server::Constants qw( $DLABEL_ID $NOLABEL_ID $NOLABEL_GID );

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

ok(MusicBrainz::Server::Entity::Label->new( id => $DLABEL_ID )->is_special_purpose);
ok(MusicBrainz::Server::Entity::Label->new( id => $NOLABEL_ID )->is_special_purpose);
ok(MusicBrainz::Server::Entity::Label->new( gid => $NOLABEL_GID )->is_special_purpose);
ok(!MusicBrainz::Server::Entity::Label->new( id => 5 )->is_special_purpose);
ok(!MusicBrainz::Server::Entity::Label->new( gid => '7527f6c2-d762-4b88-b5e2-9244f1e34c46' )->is_special_purpose);

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
