package MusicBrainz::Server::Controller::Role::Profile;
use Moose::Role;

requires 'begin', 'end';

after 'begin' => sub {
    my ($self, $c) = @_;
    $c->stats->profile(begin => 'request');
};

after 'end' => sub {
    my ($self, $c) = @_;
    $c->stats->profile(end => 'request');

    for my $stat ($c->stats->report) {
        my ($depth, $name, $duration) = @$stat;
        if ($name eq 'request' && $duration > 0.01) {
            $c->log->warn('DANGER WILL ROBINSON. SLOW REQUESTS!');
            $c->log->warn("Requesting: " . $c->req->uri);
        }
    }
};

1;
