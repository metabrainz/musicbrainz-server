package t::MusicBrainz::Server::Data::Language;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Deep qw( cmp_bag );

use MusicBrainz::Server::Data::Language;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Test::Utils qw( verify_name_and_id );

with 't::Context';

=head1 DESCRIPTION

This test checks the different getters for Language.

=cut

test 'get_by_id' => sub {
    my $test = shift;
    my $c = $test->c;

    my $language_data = MusicBrainz::Server::Data::Language->new(c => $c);

    my $language = $language_data->get_by_id(145);
    verify_name_and_id(145, 'German', $language);
    is ($language->iso_code_3, 'deu', 'Expected ISO code 3 deu found');
    is ($language->iso_code_2t, 'deu', 'Expected ISO code 2t deu found');
    is ($language->iso_code_2b, 'ger', 'Expected ISO code 2b ger found');
    is ($language->iso_code_1, 'de', 'Expected ISO code 1 de found');
};

test 'get_by_ids' => sub {
    my $test = shift;
    my $c = $test->c;

    my $language_data = MusicBrainz::Server::Data::Language->new(c => $c);

    my @requested_ids = (27, 145);

    my $languages = $language_data->get_by_ids(@requested_ids);
    cmp_bag(
        [keys %$languages],
        \@requested_ids,
        'The keys of the returned hash are the requested row ids',
    );
    verify_name_and_id(27, 'Asturian', $languages->{27});
    is (
        $languages->{27}->iso_code_3,
        'ast',
        'Expected ISO code 3 ast found',
    );
    is (
        $languages->{27}->iso_code_2t,
        'ast',
        'Expected ISO code 2t ast found',
    );
    is (
        $languages->{27}->iso_code_2b,
        'ast',
        'Expected ISO code 2b ast found',
    );
    is (
        $languages->{27}->iso_code_1,
        undef,
        'ISO code 1 is undefined as expected',
    );
    verify_name_and_id(145, 'German', $languages->{145});
    is (
        $languages->{145}->iso_code_3,
        'deu',
        'Expected ISO code 3 deu found',
    );
    is (
        $languages->{145}->iso_code_2t,
        'deu',
        'Expected ISO code 2t deu found',
    );
    is (
        $languages->{145}->iso_code_2b,
        'ger',
        'Expected ISO code 2b ger found',
    );
    is (
        $languages->{145}->iso_code_1,
        'de',
        'Expected ISO code 1 de found',
    );
};

test 'get_all' => sub {
    my $test = shift;
    my $c = $test->c;

    my $language_data = MusicBrainz::Server::Data::Language->new(c => $c);

    does_ok($language_data, 'MusicBrainz::Server::Data::Role::SelectAll');
    my @languages = sort { $a->{id} <=> $b->{id} } $language_data->get_all;
    is(@languages, 13, 'get_all returns all 13 languages');
    verify_name_and_id(27, 'Asturian', $languages[0]);
    is (
        $languages[0]->iso_code_3,
        'ast',
        'Expected ISO code 3 ast found',
    );
    is (
        $languages[0]->iso_code_2t,
        'ast',
        'Expected ISO code 2t ast found',
    );
    is (
        $languages[0]->iso_code_2b,
        'ast',
        'Expected ISO code 2b ast found',
    );
    is (
        $languages[0]->iso_code_1,
        undef,
        'ISO code 1 is undefined as expected',
    );
    verify_name_and_id(113, 'Dutch', $languages[1]);
    is (
        $languages[1]->iso_code_3,
        'nld',
        'Expected ISO code 3 nld found',
    );
    is (
        $languages[1]->iso_code_2t,
        'nld',
        'Expected ISO code 2t nld found',
    );
    is (
        $languages[1]->iso_code_2b,
        'dut',
        'Expected ISO code 2b dut found',
    );
    is (
        $languages[1]->iso_code_1,
        'nl',
        'Expected ISO code 1 nl found',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
