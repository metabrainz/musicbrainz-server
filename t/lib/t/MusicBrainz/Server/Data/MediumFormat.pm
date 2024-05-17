package t::MusicBrainz::Server::Data::MediumFormat;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::MediumFormat;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {

my $test = shift;

my $mf_data = MusicBrainz::Server::Data::MediumFormat->new(c => $test->c);

my $mf = $mf_data->get_by_id(1);
is ( $mf->id, 1 );
is ( $mf->name, 'CD' );
is ( $mf->year, 1982 );


$mf = $mf_data->get_by_id(2);
is ( $mf->id, 2 );
is ( $mf->name, 'DVD' );
is ( $mf->year, 1995 );

my $mfs = $mf_data->get_by_ids(1, 2);
is ( $mfs->{1}->id, 1 );
is ( $mfs->{1}->name, 'CD' );

is ( $mfs->{2}->id, 2 );
is ( $mfs->{2}->name, 'DVD' );


does_ok($mf_data, 'MusicBrainz::Server::Data::Role::SelectAll');
my @formats = $mf_data->get_all;
is(@formats, 60);
is($formats[0]->id, 1);
is($formats[1]->id, 2);


};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
