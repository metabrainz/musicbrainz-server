package t::MusicBrainz::Server::Edit::Series::Edit;
use strict;
use warnings;

use Test::Fatal;
use Test::More;
use Test::Routine;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Series::Edit }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_SERIES_EDIT );
use MusicBrainz::Server::Test qw( accept_edit );

test 'Can edit a series without changing the type' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+series');

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_SERIES_EDIT,
        editor_id => 1,
        to_edit => $c->model('Series')->get_by_id(2),
        name => 'Renamed Series',
    );

    isa_ok($edit, 'MusicBrainz::Server::Edit::Series::Edit');

    ok !exception { accept_edit($c, $edit) };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
