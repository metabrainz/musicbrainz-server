package t::MusicBrainz::Server::Entity::ArtistCredit;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use aliased 'MusicBrainz::Server::Entity::ArtistCredit';
use aliased 'MusicBrainz::Server::Entity::ArtistCreditName';

test all => sub {

my $artist_credit = MusicBrainz::Server::Entity::ArtistCredit->new();
ok( defined $artist_credit );

$artist_credit->add_name(MusicBrainz::Server::Entity::ArtistCreditName->new(name => 'Artist 1', join_phrase => ' & '));
$artist_credit->add_name(MusicBrainz::Server::Entity::ArtistCreditName->new(name => 'Artist 2'));
is( $artist_credit->name, 'Artist 1 & Artist 2' );

$artist_credit->clear_names();
$artist_credit->add_name(MusicBrainz::Server::Entity::ArtistCreditName->new(name => 'Artist 1', join_phrase => ', '));
$artist_credit->add_name(MusicBrainz::Server::Entity::ArtistCreditName->new(name => 'Artist 2', join_phrase => ' and '));
$artist_credit->add_name(MusicBrainz::Server::Entity::ArtistCreditName->new(name => 'Artist 3'));
is( $artist_credit->name, 'Artist 1, Artist 2 and Artist 3' );

ok(
    ArtistCredit->new(
        names => [
            ArtistCreditName->new(
                name => 'Breakage',
                artist_id => 1
            )])
        ==
    ArtistCredit->new(
        names => [
            ArtistCreditName->new(
                name => 'Breakage',
                artist_id => 1
            )]),
    'Identical artist credits are =='
);

ok(
    ArtistCredit->new(
        names => [
            ArtistCreditName->new(
                name => 'Breakage',
                artist_id => 1
            )])
        !=
    ArtistCredit->new(
        names => [
            ArtistCreditName->new(
                name => 'Break',
                artist_id => 1
            )]),
    'Artist credits with differing names are !=',
);

ok(
    ArtistCredit->new(
        names => [
            ArtistCreditName->new(
                name => 'Breakage',
                artist_id => 1
            )])
        !=
    ArtistCredit->new(
        names => [
            ArtistCreditName->new(
                name => 'Breakage',
                artist_id => 2
            )]),
    'Artist credits with differing artists are !='
);

ok(
    ArtistCredit->new(
        names => [
            ArtistCreditName->new( name => 'Breakage', artist_id => 1, join_phrase => ' & ' ),
            ArtistCreditName->new( name => 'Noisia', artist_id => 5 ),
        ])
        !=
    ArtistCredit->new(
        names => [
            ArtistCreditName->new(
                name => 'Breakage',
                artist_id => 2
            )]),
    'Artist credits with differing name counts are !='
);

ok(
    ArtistCredit->new(
        names => [
            ArtistCreditName->new( name => 'Breakage', artist_id => 1, join_phrase => ' & ' ),
            ArtistCreditName->new( name => 'Noisia', artist_id => 5 ),
        ]),
    'can test artist credits for truth'
);

my $zero_ac = ArtistCredit->from_array([
    { name => '0', artist_id => 1, join_phrase => '0' },
]);

my @zero_ac_names = $zero_ac->all_names;

is($zero_ac_names[0]->name, '0', 'from_array accepts 0 as credited name');
is($zero_ac_names[0]->join_phrase, '0', 'from_array accepts 0 as join phrase');

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
