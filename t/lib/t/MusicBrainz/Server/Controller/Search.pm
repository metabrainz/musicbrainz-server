package t::MusicBrainz::Server::Controller::Search;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok test_xpath_html );
use HTML::Selector::XPath 'selector_to_xpath';

with 't::Mechanize', 't::Context';

test "/search portal" => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    $mech->get_ok('/search');
    html_ok($mech->content);

    my $tx = test_xpath_html ($mech->content);
    $tx->ok(selector_to_xpath('.searchform form', prefix => "html"),
            sub {
                $_->not_ok(selector_to_xpath('.error', prefix => "html"),
                           'should not have any field errors')
            }, 'should have search form');
};

1;
