package t::MusicBrainz::Server::Data::Role::SearchRequestHeaders;
use strict;
use warnings;

use Test::Routine;
use Test::More;

use DBDefs;
use Sys::Hostname qw( hostname );
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

test 'X-MB-Container is always emitted from the hostname' => sub {
    my $headers = build_headers();
    ok(exists $headers->{'X-MB-Container'},
        'X-MB-Container is present');
    is($headers->{'X-MB-Container'}, hostname(),
        'X-MB-Container comes from the current hostname');
};

test 'X-MB-Node is emitted from MUSICBRAINZ_NODE_NAME when set' => sub {
    local $ENV{MUSICBRAINZ_NODE_NAME} = 'foccacia';

    my $headers = build_headers();
    is($headers->{'X-MB-Node'}, 'foccacia',
        'X-MB-Node comes from MUSICBRAINZ_NODE_NAME when set');
};

test 'X-MB-Node is skipped when MUSICBRAINZ_NODE_NAME is unset' => sub {
    local %ENV = %ENV;
    delete $ENV{MUSICBRAINZ_NODE_NAME};

    my $headers = build_headers();
    ok(!exists $headers->{'X-MB-Node'},
        'X-MB-Node is skipped when MUSICBRAINZ_NODE_NAME is unset');
};

1;
