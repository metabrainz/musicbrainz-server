package t::MusicBrainz::Server::Data::Script;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Deep qw( cmp_bag );

use MusicBrainz::Server::Data::Script;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Test::Utils qw( verify_name_and_id );

with 't::Context';

=head1 DESCRIPTION

This test checks the different getters for Script.

=cut

test 'get_by_id' => sub {
    my $test = shift;
    my $c = $test->c;

    my $script_data = MusicBrainz::Server::Data::Script->new(c => $c);

    my $script = $script_data->get_by_id(3);
    verify_name_and_id(3, 'Ugaritic', $script);
    is ($script->iso_code, 'Ugar', 'Expected ISO code Ugar found');
};

test 'get_by_ids' => sub {
    my $test = shift;
    my $c = $test->c;

    my $script_data = MusicBrainz::Server::Data::Script->new(c => $c);

    my @valid_ids = (3, 28);
    my @invalid_ids = (666);
    my @requested_ids = (@valid_ids, @invalid_ids);

    my $scripts = $script_data->get_by_ids(@requested_ids);
    cmp_bag(
        [keys %$scripts],
        \@valid_ids,
        'The keys of the returned hash are the requested *valid* row ids',
    );
    verify_name_and_id(3, 'Ugaritic', $scripts->{3});
    is ($scripts->{3}->iso_code, 'Ugar', 'Expected ISO code Ugar found');
    verify_name_and_id(28, 'Latin', $scripts->{28});
    is ($scripts->{28}->iso_code, 'Latn', 'Expected ISO code Latn found');
};

test 'get_all' => sub {
    my $test = shift;
    my $c = $test->c;

    my $script_data = MusicBrainz::Server::Data::Script->new(c => $c);

    does_ok($script_data, 'MusicBrainz::Server::Data::Role::SelectAll');
    my @scripts = sort { $a->{id} <=> $b->{id} } $script_data->get_all;
    is(@scripts, 4, 'get_all returns all 4 scripts');
    verify_name_and_id(3, 'Ugaritic', $scripts[0]);
    is ($scripts[0]->iso_code, 'Ugar', 'Expected ISO code Ugar found');
    verify_name_and_id(28, 'Latin', $scripts[1]);
    is ($scripts[1]->iso_code, 'Latn', 'Expected ISO code Latn found');
    verify_name_and_id(85, 'Japanese', $scripts[2]);
    is ($scripts[2]->iso_code, 'Jpan', 'Expected ISO code Jpan found');
    verify_name_and_id(112, 'Symbols', $scripts[3]);
    is ($scripts[3]->iso_code, 'Zsym', 'Expected ISO code Zsym found');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
