package t::MusicBrainz::Server::Data::CoverArtArchive;
use Test::Routine;
use Test::More;

with 't::Context';

use FindBin '$Bin';
use LWP::UserAgent::Mockable;

test 'Test delete_releases' => sub {
    my $test = shift;
    my $c = $test->c;

    LWP::UserAgent::Mockable->reset('playback', $Bin.'/lwp-sessions/cover-art-archive-delete.lwp');
    LWP::UserAgent::Mockable->set_playback_validation_callback(\&basic_validation);

    $c->model('CoverArtArchive')->delete_releases('f34c079d-374e-4436-9448-da92dedef3ce');

    LWP::UserAgent::Mockable->finished;
};

test 'merge_releases when the target does not have images (union)' => sub {
    my $test = shift;
    my $c = $test->c;

    LWP::UserAgent::Mockable->reset('playback', $Bin.'/lwp-sessions/cover-art-archive-merge-union.lwp');
    LWP::UserAgent::Mockable->set_playback_validation_callback(\&basic_validation);

    $c->model('CoverArtArchive')->merge_releases(
        'a34c079d-374e-4436-9448-da92dedef3ce',
        'b34c079d-374e-4436-9448-da92dedef3ce'
    );

    LWP::UserAgent::Mockable->finished;
};

test 'merge_releases when the target does have images (delete)' => sub {
    my $test = shift;
    my $c = $test->c;

    LWP::UserAgent::Mockable->reset('record', $Bin.'/lwp-sessions/cover-art-archive-merge-delete.lwp');
    LWP::UserAgent::Mockable->set_playback_validation_callback(\&basic_validation);

    $c->model('CoverArtArchive')->merge_releases(
        'a34c079d-374e-4436-9448-da92dedef3ce',
        'b34c079d-374e-4436-9448-da92dedef3ce'
    );

    LWP::UserAgent::Mockable->finished;
};

sub basic_validation {
    my ($actual, $expected) = @_;
    is($actual->uri, $expected->uri, 'called ' . $expected->uri);
    is($actual->method, $expected->method, 'method is ' . $expected->method);
}

1;
