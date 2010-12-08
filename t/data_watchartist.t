use strict;
use warnings;
use Test::Fatal;
use Test::More;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context;
MusicBrainz::Server::Test->prepare_test_database($c, '+watch');

subtest 'Find watched artists for editors watching artists' => sub {
    my @watching = $c->model('WatchArtist')->find_watched_artists(1);
    is(@watching => 2, 'watching 2 artists');
    is_watching('Spor', 1, @watching);
    is_watching('Break', 2, @watching);
};

subtest 'Find watched artists where an editor is not watching anyone' => sub {
    my @watching = $c->model('WatchArtist')->find_watched_artists(2);
    is(@watching => 0, 'Editor #2 is not watching any artists');
};

subtest 'Can add new artists to the watch list' => sub {
    $c->model('WatchArtist')->watch_artist(
        artist_id => 3, editor_id => 2
    );

    my @watching = $c->model('WatchArtist')->find_watched_artists(2);
    is(@watching => 1, 'Editor #2 is now watching 1 artist');
    is_watching('Tosca', 3, @watching);
};

subtest 'Watching a watched artist does not crash' => sub {
    ok !exception {
        $c->model('WatchArtist')->watch_artist(
            artist_id => 3, editor_id => 2
        );
    }, 'editor #2 watched artist #3 without an exception';
};

subtest 'is_watching' => sub {
    ok($c->model('WatchArtist')->is_watching(
        artist_id => 3, editor_id => 2),
        'editor #2 is watching artist #3');
    ok(!$c->model('WatchArtist')->is_watching(
        artist_id => 1, editor_id => 2),
        'editor #2 is not watching artist #1');
};

subtest 'stop_watching' => sub {
    $c->model('WatchArtist')->stop_watching_artist(
        artist_id => 3, editor_id => 2
    );

    ok(!$c->model('WatchArtist')->is_watching(
        artist_id => 3, editor_id => 2),
        'editor #2 is no longer watching artist #3');
};

subtest 'find_new_releases' => sub {
    my $sql = Sql->new($c->dbh);

    subtest 'Find releases in the future' => sub {
        $sql->begin;
        $sql->do('UPDATE editor_watch_preferences SET last_checked = NOW()');
        $sql->do("UPDATE release_meta SET date_added = NOW() + '@ 1 week'::INTERVAL");

        my @releases = $c->model('WatchArtist')->find_new_releases(1);
        is(@releases => 1, 'found one release');
        $sql->rollback;
    };

    subtest 'Find releases after last_checked' => sub {
        $sql->begin;
        $sql->do("UPDATE release_meta SET date_added = NOW() - '@ 1 week'::INTERVAL");

        my @releases = $c->model('WatchArtist')->find_new_releases(1);
        is(@releases => 0, 'found no releases');
        $sql->rollback;
    };

    subtest 'Do not notify of newly added releases released in the past' => sub {
        $sql->begin;
        $sql->do('UPDATE release SET date_year = 2009');
        $sql->do("UPDATE release_meta SET date_added = NOW() + '@ 1 week'::INTERVAL");
        my @releases = $c->model('WatchArtist')->find_new_releases(1);
        is(@releases => 0, 'found no releases');
        $sql->rollback;
    };
};

done_testing;

sub is_watching {
    my ($name, $artist_id, @watching) = @_;
    subtest "Is watching $name" => sub {
        ok((grep { $_->name eq $name } @watching),
            '...artist.name');
        ok((grep { $_->id == $artist_id } @watching),
            '...artist_id');
    };
}
