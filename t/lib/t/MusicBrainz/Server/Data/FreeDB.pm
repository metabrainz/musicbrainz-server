package t::MusicBrainz::Server::Data::FreeDB;
use Test::Routine;
use Test::More;
use LWP::UserAgent::Mockable;

use FindBin '$Bin';

with 't::Context';

test "Correctly handle the 200 OK failed to process the response error" => sub {
    my $test = shift;
    my $c    = $test->c;

    LWP::UserAgent::Mockable->reset(playback => $Bin . '/lwp-sessions/mbs-3622-freedb-import.lwp');
    LWP::UserAgent::Mockable->set_playback_validation_callback(\&basic_validation);

    my $entry = $c->model('FreeDB')->lookup('rock', '24116e15');
    is(scalar(@{ $entry->tracks }), 21);
    is($entry->title, 'Sunshine Live Vol. 39 CD 1');
    is($entry->artist, 'Sunshine Live Vol. 39 CD 1');

    LWP::UserAgent::Mockable->finished;
};

sub basic_validation {
    my ($actual, $expected) = @_;
    is($actual->uri, $expected->uri, 'called ' . $expected->uri);
    is($actual->method, $expected->method, 'method is ' . $expected->method);
}

1;
