package t::MusicBrainz::Server::Entity::Language;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Entity::Language;

=head1 DESCRIPTION

This test ensures that language code accessors return the right code.

=cut

test 'Language codes are returned correctly' => sub {
    my $language = MusicBrainz::Server::Entity::Language->new();
    $language->iso_code_2t('alg');
    is(
        $language->alpha_3_code,
        'alg',
        'alpha_3_code returns iso_code_2t if iso_code_3 is missing',
    );

    $language->iso_code_3('arp');
    is(
        $language->alpha_3_code,
        'arp',
        'alpha_3_code returns iso_code_3 if present',
    );
    is(
        $language->bcp47,
        'arp',
        'bcp47 returns iso_code_3 if iso_code_1 is missing',
    );

    $language->iso_code_1('eu');
    is(
        $language->bcp47,
        'eu',
        'bcp47 returns iso_code_1 if present',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
