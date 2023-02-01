package t::MusicBrainz::Server::Controller::WS::js::Work;
use strict;
use warnings;

use Test::More;
use Test::Routine;
use JSON;
use MusicBrainz::Server::Test;

with 't::Mechanize', 't::Context';

test all => sub {

    my $test = shift;
    my $c = $test->c;
    my $json = JSON->new;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    $c->sql->do(<<~'SQL');
        INSERT INTO work_alias (work, name, sort_name, locale, primary_for_locale)
            VALUES (4223060, 'Hello! Let''s Meet Again (7ninmatsuri version)', 'Hello! Let''s Meet Again (7ninmatsuri version)', 'en', FALSE),
                   (4223060, 'Hello! Let''s Meet Again (7ninmatsuri version)', 'Hello! Let''s Meet Again (7ninmatsuri version)', 'en_US', TRUE),
                   (4223060, 'Saluton! Ni Renkontu Denove (7nin-matsuria versio)', 'Saluton! Ni Renkontu Denove (7nin-matsuria versio)', 'eo', TRUE);
        SQL

    my $mech = MusicBrainz::WWW::Mechanize->new(catalyst_app => 'MusicBrainz::Server');
    $mech->default_header('Accept' => 'application/json');

    my $url = q(/ws/js/work?q=Let's Meet Again&direct=true);

    $mech->get_ok($url, 'fetching');

    my $data = $json->decode($mech->content);

    is($data->[0]->{id}, 4223060, 'Got the work expected');
    is($data->[0]->{primaryAlias}, q(Hello! Let's Meet Again (7ninmatsuri version)), 'Got correct primary alias (en_US)');

    $c->sql->do(<<~'SQL');
        INSERT INTO work_alias (work, name, sort_name, locale, primary_for_locale)
            VALUES (4223060, 'Hello! Let''s Meet Again (7nin Matsuri version)', 'Hello! Let''s Meet Again (7nin Matsuri version)', 'en', TRUE);
        SQL

    $mech = MusicBrainz::WWW::Mechanize->new(catalyst_app => 'MusicBrainz::Server');
    $mech->default_header('Accept' => 'application/json');
    $mech->get_ok($url, 'fetching again');

    $data = $json->decode($mech->content);

    is($data->[0]->{id}, 4223060, 'Got the work expected');
    is($data->[0]->{primaryAlias}, q(Hello! Let's Meet Again (7nin Matsuri version)), 'Got correct primary alias (en)');

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
