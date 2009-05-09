use strict;
use warnings;
use Test::More tests => 16;
use_ok 'MusicBrainz::Server::Data::Label';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

my $label_data = MusicBrainz::Server::Data::Label->new(c => $c);

my $label = $label_data->get_by_id(1);
is ( $label->id, 1 );
is ( $label->gid, "f45c079d-374e-4436-9448-da92dedef3ce" );
is ( $label->name, "Mute" );
is ( $label->sort_name, "Mute" );
is ( $label->begin_date->year, 2008 );
is ( $label->begin_date->month, 1 );
is ( $label->begin_date->day, 2 );
is ( $label->end_date->year, 2009 );
is ( $label->end_date->month, 3 );
is ( $label->end_date->day, 4 );
is ( $label->edits_pending, 0 );
is ( $label->type_id, 1 );
is ( $label->label_code, 1234 );
is ( $label->format_label_code, 'LC-01234' );
is ( $label->comment, undef );
