package t::MusicBrainz::Server::Data::Community;
use strict;
use warnings;

use Test::Routine;
use Test::More;

with 't::Context';

test 'Community data model can be instantiated' => sub {
    my $test = shift;

    isa_ok(
        $test->c->model('Community'),
        'MusicBrainz::Server::Data::Community',
    );
};

1;
