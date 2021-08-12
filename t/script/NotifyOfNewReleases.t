use strict;
use warnings;
use Test::More;
use Test::Magpie::ArgumentMatcher qw( hash anything );
use Test::Magpie qw( mock when inspect verify );
use Test::Routine;
use Test::Routine::Util;
use MusicBrainz::Server::Test;

use aliased 'MusicBrainz::Server::Entity::Editor';
use aliased 'MusicBrainz::Server::Entity::Release';
use aliased 'MusicBrainz::Script::NotifyOfNewReleases' => 'Script';

my $c = MusicBrainz::Server::Test->create_test_context(
    models => {
        map { $_ => mock } qw( WatchArtist )
    }
);

has emailer => (
    is => 'ro',
    default => sub { mock },
    lazy => 1,
    clearer => 'clear_emailer'
);

has script => (
    is => 'ro',
    default => sub {
        my $test = shift;
        Script->new(
            c => $c, emailer => $test->emailer, verbose => 0
        );
    },
    lazy => 1,
    clearer => 'clear_script',
);

before run_test => sub {
    my $test = shift;
    $test->clear_emailer;
    $test->clear_script;
};

my $acid2 = Editor->new(id => 1);

test 'Send with releases' => sub {
    my $test = shift;

    my @new_releases = (Release->new);

    when($c->model('WatchArtist'))->find_editors_to_notify
        ->then_return($acid2);
    when($c->model('WatchArtist'))->find_new_releases($acid2->id)
        ->then_return(@new_releases);

    $test->script->run;

    my %args = inspect($test->emailer)
        ->send_new_releases(hash(editor => $acid2), anything)
            ->arguments;

    ok(%args, 'sends an email to aCiD2');
    delete $args{editor};
    is_deeply(\%args, {
        releases => \@new_releases
    }, 'notifies about 1 new release');

    TODO: {
        local $TODO = 'Update last checked';
        verify($c->model('WatchArtist'))
            ->update_last_checked;
    }
};

test 'Doesnt notify on no releases' => sub {
    my $test = shift;

    my @new_releases = (Release->new);

    when($c->model('WatchArtist'))->find_editors_to_notify
        ->then_return($acid2);
    when($c->model('WatchArtist'))->find_new_releases($acid2->id)
        ->then_return();

    $test->script->run;

    verify($test->emailer, times => 0)
        ->send_new_releases(anything)
};

run_me;
done_testing;

