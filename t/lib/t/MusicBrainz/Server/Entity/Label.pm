package t::MusicBrainz::Server::Entity::Label;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Entity::Label;
use MusicBrainz::Server::Entity::LabelType;
use MusicBrainz::Server::Entity::LabelAlias;

use MusicBrainz::Server::Constants qw( $DLABEL_ID $NOLABEL_ID $NOLABEL_GID );

=head1 DESCRIPTION

This test checks whether label data is stored and calculated correctly.

=cut

test 'Empty label has the expected calculated data' => sub {
    my $label = MusicBrainz::Server::Entity::Label->new();
    ok(defined $label->begin_date, 'An empty label still has a begin date');
    ok($label->begin_date->is_empty, 'The begin date is empty');
    ok(defined $label->end_date, 'An empty label still has an end date');
    ok($label->end_date->is_empty, 'The end date is empty');

    is(
        $label->type_name,
        undef,
        'Undefined label type name is calculated when no type explicitly set',
    );
};

test 'Label type data is stored and returned properly' => sub {
    my $label = MusicBrainz::Server::Entity::Label->new();
    $label->type(
        MusicBrainz::Server::Entity::LabelType->new(
            id => 1,
            name => 'Production',
        )
    );
    is(
        $label->type_name,
        'Production',
        'Expected label type name is returned after setting a type',
    );
    is($label->type->id, 1, 'The type id is stored as expected');
    is(
        $label->type->name,
        'Production',
        'The type name is stored as expected',
    );
};

test 'Label code is stored and formatted properly' => sub {
    my $label = MusicBrainz::Server::Entity::Label->new();
    $label->label_code(123);
    is(
        $label->label_code,
        123,
        'The label code is returned as just the bare integer',
    );
    is(
        $label->format_label_code,
        'LC 00123',
        'The formatted label code is returned with leading zeros and a prefix',
    );
};

test 'Can store label pending edits' => sub {
    my $label = MusicBrainz::Server::Entity::Label->new();
    $label->edits_pending(2);
    is(
        $label->edits_pending,
        2,
        'The number of pending edits is stored as expected',
    );
};

test 'The right labels (and only them) are marked as special purpose' => sub {
    ok(
        MusicBrainz::Server::Entity::Label->new( id => $DLABEL_ID )->is_special_purpose,
        'A label with the row id reserved for "Deleted Label" is marked as special purpose',
    );
    ok(
        MusicBrainz::Server::Entity::Label->new( id => $NOLABEL_ID )->is_special_purpose,
        'A label with the row id of [no label] is marked as special purpose',
    );
    ok(
        MusicBrainz::Server::Entity::Label->new( gid => $NOLABEL_GID )->is_special_purpose,
        'A label with the MBID of [no label] is marked as special purpose',
    );
    ok(
        !MusicBrainz::Server::Entity::Label->new( id => 5 )->is_special_purpose,
        'A label with a bog-standard row id is not marked as special purpose',
    );
    ok(
        !MusicBrainz::Server::Entity::Label->new( gid => '7527f6c2-d762-4b88-b5e2-9244f1e34c46' )->is_special_purpose,
        'A label with a bog-standard MBID is not marked as special purpose',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
