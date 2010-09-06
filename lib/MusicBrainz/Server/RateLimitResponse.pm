package MusicBrainz::Search::RateLimitResponse;
use Moose;
use namespace::autoclean;

has 'is_over_limit' => (
    isa => 'Boolean',
    is => 'ro',
);

has [qw( rate limit period )] => (
    is => 'ro'
);

1;
