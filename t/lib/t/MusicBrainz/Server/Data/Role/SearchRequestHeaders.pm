package t::MusicBrainz::Server::Data::Role::SearchRequestHeaders;
use strict;
use warnings;

use Test::Routine;
use Test::More;

use DBDefs;
use MusicBrainz::Server::Data::Role::SearchRequestHeaders;

# A minimal consumer of the role under test.
{
    package t::MusicBrainz::Server::Data::Role::SearchRequestHeaders::Consumer;
    use Moose;
    use namespace::autoclean;
    with 'MusicBrainz::Server::Data::Role::SearchRequestHeaders';
    __PACKAGE__->meta->make_immutable;
}

sub build_headers {
    my %tags = @_;
    my $consumer =
        t::MusicBrainz::Server::Data::Role::SearchRequestHeaders::Consumer->new;
    return { $consumer->build_search_request_headers(%tags) };
}

test 'X-MB-Version reflects DBDefs->GIT_SHA and GIT_BRANCH' => sub {
    my $headers = build_headers();
    is($headers->{'X-MB-Version'}, DBDefs->GIT_SHA . '@' . DBDefs->GIT_BRANCH,
        'X-MB-Version comes from GIT_SHA and GIT_BRANCH');
};

1;
