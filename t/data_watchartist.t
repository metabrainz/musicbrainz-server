use strict;
use warnings;
use Test::More;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context;
MusicBrainz::Server::Test->prepare_test_database($c, '+watch');

subtest 'Find watched artists for editors watching artists' => sub {
    my @watching = $c->model('WatchArtist')->find_watched_artists(1);
    is(@watching => 2, 'watching 2 artists');
    is_watching('Spor', 1, 1, @watching);
    is_watching('Break', 2, 1, @watching);
};

subtest 'Find watched artists where an editor is not watching anyone' => sub {
    my @watching = $c->model('WatchArtist')->find_watched_artists(2);
    is(@watching => 0, 'Editor #2 is not watching any artists');
};

done_testing;

sub is_watching {
    my ($name, $artist_id, $editor_id, @watching) = @_;
    subtest "Is watching $name" => sub {
        ok((grep { $_->artist->name eq $name } @watching),
            '...artist.name');
        ok((grep { $_->artist_id == $artist_id } @watching),
            '...artist_id');
        ok((grep { $_->editor_id == $editor_id } @watching),
            '...editor_id');
    };
}
