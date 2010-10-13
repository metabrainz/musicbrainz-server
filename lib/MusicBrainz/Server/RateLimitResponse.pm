package MusicBrainz::Server::RateLimitResponse;
use Moose;
use namespace::autoclean;

use overload 'bool' => '_bool';

has 'is_over_limit' => (
    isa => 'Bool',
    is => 'ro',
);

has [qw( rate limit period )] => (
    is => 'ro'
);

sub msg {
    sprintf "%.1f, limit is %.1f per %d seconds",
        $_[0]->rate,
        $_[0]->limit,
        $_[0]->period;
}

sub _bool { warn $_[0]->is_over_limit; shift->is_over_limit }

1;
