package t::MusicBrainz::Server::Data::WebService;
use strict;
use warnings;

use Test::Routine;
use Test::More;

use HTTP::Response;
use HTTP::Status qw( :constants );
use LWP::UserAgent::Mockable;
use DBDefs;
use MusicBrainz::Server::Data::WebService;

with 't::Context';

test 'xml_search issues the direct Solr request' => sub {
    my $test = shift;
    my $c = $test->c;

    no warnings 'redefine';
    # Ensure the direct-call branch (not X-Accel-Redirect) is exercised.
    local *DBDefs::SEARCH_X_ACCEL_REDIRECT = sub { 0 };

    my $requested = 0;
    LWP::UserAgent::Mockable->set_record_pre_callback(sub {
        $requested = 1;
        my $response = HTTP::Response->new;
        $response->code(HTTP_OK);
        $response->content('<metadata/>');
        return $response;
    });

    my $ws = MusicBrainz::Server::Data::WebService->new(c => $c);
    my $result = $ws->xml_search('artist', { query => 'love', fmt => 'xml' });

    LWP::UserAgent::Mockable->finished;

    ok(exists $result->{xml}, 'xml_search returned an XML document');
    ok($requested, 'a Solr request was made');
};

test 'xml_search returns tag_headers on the X-Accel-Redirect path' => sub {
    my $test = shift;
    my $c = $test->c;

    no warnings 'redefine';
    local *DBDefs::SEARCH_X_ACCEL_REDIRECT = sub { 1 };

    my $ws = MusicBrainz::Server::Data::WebService->new(c => $c);
    my $result = $ws->xml_search('artist', { query => 'love', fmt => 'xml' });

    ok(exists $result->{redirect_url}, 'redirect path returns a redirect_url');
    ok(exists $result->{tag_headers}, 'redirect path returns tag_headers');

    my %headers = @{ $result->{tag_headers} };
    is($headers{'X-MB-Version'},
        DBDefs->GIT_SHA . '@' . DBDefs->GIT_BRANCH,
        'tag_headers include X-MB-Version');
};

1;
