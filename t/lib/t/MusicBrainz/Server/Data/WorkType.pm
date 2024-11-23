package t::MusicBrainz::Server::Data::WorkType;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Moose;

use MusicBrainz::Server::Data::WorkType;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {
    my $test = shift;

    my $wt_data = MusicBrainz::Server::Data::WorkType->new(c => $test->c);

    my $wt = $wt_data->get_by_id(1);
    is ($wt->id, 1);
    is ($wt->name, 'Aria');

    $wt = $wt_data->get_by_id(2);
    is ($wt->id, 2);
    is ($wt->name, 'Ballet');

    my $wts = $wt_data->get_by_ids(1, 2);
    is ($wts->{1}->id, 1);
    is ($wts->{1}->name, 'Aria');

    is ($wts->{2}->id, 2);
    is ($wts->{2}->name, 'Ballet');

    does_ok($wt_data, 'MusicBrainz::Server::Data::Role::SelectAll');
    my @types = $wt_data->get_all;
    is(@types, 29);
    is($types[0]->id, 1);
    is($types[1]->id, 2);
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
