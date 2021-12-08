package t::MusicBrainz::Server::Data::Blog;
use Test::Routine;
use Test::More;

use FindBin qw($Bin);
use LWP::UserAgent::Mockable;

with 't::Context';

test 'Accessing the blog when its up does not die' => sub {
    my $test = shift;

    LWP::UserAgent::Mockable->reset(
        playback => $Bin.'/lwp-sessions/data_blog.up.lwp-mock'
    );

    my $entries = $test->c->model('Blog')->get_latest_entries;
    ok(defined $entries);
    ok(@$entries > 0);

    LWP::UserAgent::Mockable->finished;
};

test 'Accessing the blog when its down returns undef' => sub {
    my $test = shift;

    LWP::UserAgent::Mockable->reset(
        playback => $Bin.'/lwp-sessions/data_blog.down.lwp-mock'
    );

    my $entries = $test->c->model('Blog')->get_latest_entries;
    ok(!defined $entries);

    LWP::UserAgent::Mockable->finished;
};

1;
