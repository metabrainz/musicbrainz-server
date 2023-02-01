package t::MusicBrainz::Server::Entity::ArtistCredit;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use aliased 'MusicBrainz::Server::Entity::ArtistCredit';
use aliased 'MusicBrainz::Server::Entity::ArtistCreditName';

=head1 DESCRIPTION

This test checks that artist credit names are calculated correctly,
artist credit comparison works as expected, and using 0 does not confuse Perl.

=cut

test 'Artist credit name calculation' => sub {
    my $artist_credit = MusicBrainz::Server::Entity::ArtistCredit->new();
    ok(defined $artist_credit, 'An artist credit was created');

    is(
        $artist_credit->name,
        '',
        'AC name is listed as empty before any names are added',
    );

    $artist_credit->add_name(
        MusicBrainz::Server::Entity::ArtistCreditName->new(
            name => 'Artist 1',
        ));
    is(
        $artist_credit->name,
        'Artist 1',
        'AC names with one artist are listed as expected',
    );

    $artist_credit->clear_names();

    is(
        $artist_credit->name,
        '',
        'AC name is listed as empty after clearing the names data',
    );

    $artist_credit->add_name(
        MusicBrainz::Server::Entity::ArtistCreditName->new(
            name => 'Artist 1',
            join_phrase => ' & ',
        ));
    $artist_credit->add_name(
        MusicBrainz::Server::Entity::ArtistCreditName->new(
            name => 'Artist 2',
        ));
    is(
        $artist_credit->name,
        'Artist 1 & Artist 2',
        'AC names with multiple artists are listed as expected',
    );

    $artist_credit->clear_names();

    $artist_credit->add_name(
        MusicBrainz::Server::Entity::ArtistCreditName->new(
            name => 'Artist 1',
            join_phrase => ', ',
        ));
    $artist_credit->add_name(
        MusicBrainz::Server::Entity::ArtistCreditName->new(
            name => 'Artist 2',
            join_phrase => ' and ',
        ));
    $artist_credit->add_name(
        MusicBrainz::Server::Entity::ArtistCreditName->new(
            name => 'Artist 3',
        ));
    is(
        $artist_credit->name,
        'Artist 1, Artist 2 and Artist 3',
        'AC names with multiple join phrases are listed as expected',
    );
};

test 'Artist credit comparison' => sub {
    ok(
        ArtistCredit->new(
            names => [
                ArtistCreditName->new(
                    name => 'Breakage',
                    artist_id => 1,
                )])
            ==
        ArtistCredit->new(
            names => [
                ArtistCreditName->new(
                    name => 'Breakage',
                    artist_id => 1,
                )]),
        'Identical artist credits are ==',
    );

    ok(
        ArtistCredit->new(
            names => [
                ArtistCreditName->new(
                    name => 'Breakage',
                    artist_id => 1,
                )])
            !=
        ArtistCredit->new(
            names => [
                ArtistCreditName->new(
                    name => 'Break',
                    artist_id => 1,
                )]),
        'Artist credits with differing names for the same artist are !=',
    );

    ok(
        ArtistCredit->new(
            names => [
                ArtistCreditName->new(
                    name => 'Breakage',
                    artist_id => 1,
                )])
            !=
        ArtistCredit->new(
            names => [
                ArtistCreditName->new(
                    name => 'Breakage',
                    artist_id => 2,
                )]),
        'Artist credits with differing artists of the same name are !='
    );

    ok(
        ArtistCredit->new(
            names => [
                ArtistCreditName->new(
                    name => 'Breakage',
                    artist_id => 1,
                    join_phrase => ' & ',
                ),
                ArtistCreditName->new(
                    name => 'Noisia',
                    artist_id => 5,
                ),
            ])
            !=
        ArtistCredit->new(
            names => [
                ArtistCreditName->new(
                    name => 'Breakage',
                    artist_id => 2,
                )]),
        'Artist credits with differing name counts are !=',
    );

    ok(
        ArtistCredit->new(
            names => [
                ArtistCreditName->new(
                    name => 'Breakage',
                    artist_id => 1,
                    join_phrase => ' & ',
                ),
                ArtistCreditName->new(
                    name => 'Noisia',
                    artist_id => 5,
                ),
            ]),
        'Can test artist credits for truth',
    );
};

test 'from_array method accepts 0 as name and/or join phrase' => sub {
    my $zero_ac = ArtistCredit->from_array([
        { name => '0', artist_id => 1, join_phrase => '0' },
    ]);

    my @zero_ac_names = $zero_ac->all_names;
    my $name = $zero_ac_names[0];

    is($name->name, '0', 'from_array accepts 0 as credited name');
    is($name->join_phrase, '0', 'from_array accepts 0 as join phrase');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
