package t::MusicBrainz::Server::Controller::Search;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok test_xpath_html );
use HTML::Selector::XPath qw( selector_to_xpath );

with 't::Mechanize', 't::Context';

test '/search portal' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/search');
    html_ok($mech->content);

    my $tx = test_xpath_html($mech->content);
    $tx->ok(selector_to_xpath('.searchform form'),
            sub {
                $_->not_ok(selector_to_xpath('.error'),
                           'should not have any field errors')
            }, 'should have search form');
};

1;
