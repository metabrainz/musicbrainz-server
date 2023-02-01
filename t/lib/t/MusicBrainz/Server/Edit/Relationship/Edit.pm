package t::MusicBrainz::Server::Edit::Relationship::Edit;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Relationship::Edit }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw(
    $AUTO_EDITOR_FLAG
    $EDIT_RELATIONSHIP_EDIT
    $STATUS_APPLIED
    $UNTRUSTED_FLAG
);
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_edit');
    MusicBrainz::Server::Test->prepare_raw_test_database($c);

    my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    is($rel->edits_pending, 0, 'no edit pending on the relationship');
    $c->model('Link')->load($rel);
    $c->model('LinkType')->load($rel->link);
    is($rel->link->type->id, 103, 'link type id = 103');
    is($rel->link->begin_date->year, undef, 'no begin date');
    is($rel->link->end_date->year, undef, 'no end date');

    my $edit = _create_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Edit');

    my ($edits, $hits) = $c->model('Edit')->find({ artist => 3 }, 10, 0);
    is($hits, 1, 'Found 1 edit for artist 1');
    is($edits->[0]->id, $edit->id, '... which has the same id as the edit just created');

    ($edits, $hits) = $c->model('Edit')->find({ artist => 4 }, 10, 0);
    is($hits, 1, 'Found 1 edit for artist 2');
    is($edits->[0]->id, $edit->id, '... which has the same id as the edit just created');

    $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    is($rel->edits_pending, 1, 'The relationship has 1 edit pending.');

    # Test rejecting the edit
    reject_edit($c, $edit);
    $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    ok(defined $rel);
    is($rel->edits_pending, 0, 'After rejecting the edit, no edit pending on the relationship');

    # Test accepting the edit
    $edit = _create_edit($c);
    accept_edit($c, $edit);
    $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    ok(defined $rel, 'After accepting the edit, the relationship has...');
    $c->model('Link')->load($rel);
    $c->model('LinkType')->load($rel->link);
    is($rel->link->type->id, 102, '... type id 102');
    is($rel->link->begin_date->year, 1994, '... begin year 1994');
    is($rel->link->end_date->year, 1995, '... end year 1995');
    is($rel->entity0_id, 3, '... entity 0 is artist 3');
    is($rel->entity1_id, 5, '... entity 1 is artist 5');
};

test 'The display data works even if and endpoint or link type is deleted' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_edit');

    my $edit = _create_edit($c);
    $edit->accept;

    $c->sql->do('SET CONSTRAINTS ALL IMMEDIATE');
    $c->sql->do('SET CONSTRAINTS ALL DEFERRED');
    $c->sql->do('TRUNCATE artist CASCADE');
    $c->sql->do('TRUNCATE link_type CASCADE');
    $c->model('Edit')->load_all($edit);

    ok(defined $edit->display_data->{old});
    is($edit->display_data->{old}{target}{name}, 'Artist 2');
    is($edit->display_data->{old}{verbosePhrase}, 'is/was an additional member of');
    is($edit->display_data->{new}{target}{name}, 'Artist 3');
    is($edit->display_data->{new}{verbosePhrase}, 'collaborated additionally on');
};

test 'Editing a relationship more than once fails subsequent edits' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_edit');

    my $edit_1 = _create_edit($c);
    my $edit_2 = _create_edit($c);

    accept_edit($c, $edit_1);

    isa_ok exception { $edit_2->accept },
        'MusicBrainz::Server::Edit::Exceptions::FailedDependency';
};

test 'Editing a relationship fails if the relationship has been deleted' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_edit');

    my $edit_1 = _create_edit($c);

    $c->model('Relationship')->delete('artist', 'artist', 1);

    isa_ok exception { $edit_1->accept },
        'MusicBrainz::Server::Edit::Exceptions::FailedDependency';
};

test 'Editing a relationship fails if one of the old endpoints has been deleted' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_edit');

    my $edit = _create_edit($c);
    $c->model('Artist')->delete(4);

    isa_ok exception { $edit->accept },
        'MusicBrainz::Server::Edit::Exceptions::FailedDependency';
};

test 'Editing a relationship fails if one of the new endpoints has been deleted' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_edit');

    my $edit = _create_edit($c);
    $c->model('Artist')->delete(5);

    isa_ok exception { $edit->accept },
        'MusicBrainz::Server::Edit::Exceptions::FailedDependency';
};

test 'Editing a relationship succeeds despite an entity being merged' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_edit');

    my $r = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    $c->model('Link')->load($r);
    $c->model('LinkType')->load($r->link);

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_EDIT,
        editor_id => 1,
        link_type => $c->model('LinkType')->get_by_id(102),
        privileges => $UNTRUSTED_FLAG,
        relationship => $r,
    );

    ok($edit->is_open);
    $c->model('Artist')->merge(5, [4]);
    ok !exception { $edit->accept };
};

test q(Editing a relationship fails if one of the entities is merged, and the
       edited relationship already exists on the merge target) => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_edit');

    my $r = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    $c->model('Link')->load($r);
    $c->model('LinkType')->load($r->link);

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_EDIT,
        editor_id => 1,
        link_type => $c->model('LinkType')->get_by_id(102),
        privileges => $UNTRUSTED_FLAG,
        relationship => $r,
    );

    ok($edit->is_open);
    $c->model('Artist')->merge(5, [4]);
    $c->model('Relationship')->insert('artist', 'artist', {
        entity0_id      => 3,
        entity1_id      => 5,
        link_type_id    => 102,
        attributes      => [{ type => { id => 1 } }],
    });
    isa_ok exception { $edit->accept },
        'MusicBrainz::Server::Edit::Exceptions::FailedDependency';
};

test 'Editing relationships fails if the underlying link type changes' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_edit');

    my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    $c->model('Link')->load($rel);
    $c->model('LinkType')->load($rel->link);

    my $edit1 = $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_EDIT,
        editor_id => 1,
        relationship => $rel,
        begin_date => { year => 1994 },
        privileges => $UNTRUSTED_FLAG,
    );

    my $edit2 = $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_EDIT,
        editor_id => 1,
        relationship => $rel,
        link_type => $c->model('LinkType')->get_by_id(102),
        privileges => $UNTRUSTED_FLAG,
    );

    is(exception { $edit2->accept }, undef);
    is(exception { $edit1->accept },
        'This relationship has changed type since this edit was entered');
};

test 'Relationship link_order values are ignored' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_edit');

    my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    $c->model('Link')->load($rel);
    $c->model('LinkType')->load($rel->link);

    $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_EDIT,
        editor_id => 1,
        relationship => $rel,
        attributes => [{ type => { gid => '4fd3b255-a7d7-4424-9a63-40fa543b601c' } }],
        link_order => 5,
    );

    $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    is($rel->link_order, 0);
};

test 'Text attributes with undef values raise exceptions' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_edit');

    my $rel = $c->model('Relationship')->get_by_id('artist', 'event', 1);
    $c->model('Link')->load($rel);
    $c->model('LinkType')->load($rel->link);

    like(exception {
        $c->model('Edit')->create(
            edit_type => $EDIT_RELATIONSHIP_EDIT,
            editor_id => 1,
            relationship => $rel,
            attributes => [
                {
                    type => { gid => 'ebd303c3-7f57-452a-aa3b-d780ebad868d' },
                    text_value => undef
                }
            ],
        );
    }, qr/Attribute ebd303c3-7f57-452a-aa3b-d780ebad868d requires a text value/);
};

test 'Attributes are validated against the new link type, not old one (MBS-7614)' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_edit');

    my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    $c->model('Link')->load($rel);
    $c->model('LinkType')->load($rel->link);

    $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_EDIT,
        editor_id => 1,
        relationship => $rel,
        link_type => $c->model('LinkType')->get_by_id(102),
        attributes => [{ type => { gid => '5b66c85d-6963-4d4b-86e5-18d2caccb349' } }],
    );

    $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    $c->model('Link')->load($rel);
    $c->model('LinkType')->load($rel->link);

    is($rel->link->type_id, 102);
    is_deeply([ map { $_->type_id } $rel->link->all_attributes ], [2]);

    # Make sure unchanged attributes are also validated against the new link type.
    like exception {
        $c->model('Edit')->create(
            edit_type => $EDIT_RELATIONSHIP_EDIT,
            editor_id => 1,
            relationship => $rel,
            link_type => $c->model('LinkType')->get_by_id(104),
        );
    }, qr/Attribute 2 is unsupported for link type 104/;
};

test 'Instrument credits can be added to an existing relationship' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_edit');

    my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    $c->model('Link')->load($rel);
    $c->model('LinkType')->load($rel->link);

    $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_EDIT,
        editor_id => 1,
        relationship => $rel,
        link_type => $c->model('LinkType')->get_by_id(103),
        attributes => [
            {
                type => {
                    gid => '63021302-86cd-4aee-80df-2270d54f4978'
                },
                credited_as => 'crazy guitar'
            }
        ],
    );

    $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    $c->model('Link')->load($rel);
    $c->model('LinkType')->load($rel->link);

    is($rel->link->attributes->[0]->credited_as, 'crazy guitar');
};

test 'Edits that change endpoints are auto-editable by auto-editors' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_edit');

    my $edit = _create_edit($c, privileges => $AUTO_EDITOR_FLAG);
    ok(!$edit->is_open, 'edit changing an endpoint was applied immediately by an auto-editor');
};

test 'Entity credits can be added to an existing relationship' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_edit');

    my $relationship = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    $c->model('Link')->load($relationship);
    $c->model('LinkType')->load($relationship->link);

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_EDIT,
        editor_id => 1,
        relationship => $relationship,
        entity0_credit => 'Foo Credit',
        entity1_credit => 'Bar Credit',
    );

    is($edit->status, $STATUS_APPLIED);

    is_deeply($edit->data, {
      edit_version => 2,
      link => {
            attributes => [
                {
                    type => {
                        id => 1,
                        gid => '0a5341f8-3b1d-4f99-a0c6-26b7f4e42c7f',
                        name => 'additional',
                        root => {
                            gid => '0a5341f8-3b1d-4f99-a0c6-26b7f4e42c7f',
                            id => 1,
                            name => 'additional'
                        }
                    }
                }
            ],
            begin_date => { month => undef, day => undef, year => undef },
            end_date => { year => undef, month => undef, day => undef },
            ended => '0',
            entity0 => {
               name => 'Artist 1',
               gid => '945c079d-374e-4436-9448-da92dedef3cf',
               id => 3
            },
            entity1 => {
               gid => '75a40343-ff6e-45d6-a5d2-110388d34858',
               id => 4,
               name => 'Artist 2'
            },
           link_type => {
                id => 103,
                link_phrase => '{additional} {founder:founding} member of',
                long_link_phrase => 'is/was {additional:an additional|a} member of {founder:and founded|}',
                name => 'member of band',
                reverse_link_phrase => '{additional} {founder:founding} members',
            },
        },
        new => {
            entity1_credit => 'Bar Credit',
            entity0_credit => 'Foo Credit'
        },
        old => {
            entity1_credit => '',
            entity0_credit => ''
        },
        relationship_id => 1,
        type1 => 'artist',
        type0 => 'artist',
        entity1_credit => '',
        entity0_credit => ''
    });
};

test 'Editing an Amazon relationship updates the release ASIN' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_edit');

    my ($relationship, $release1, $release2);

    my $load_data = sub {
        $release1 = $c->model('Release')->get_by_id(1);
        $release2 = $c->model('Release')->get_by_id(2);
        $c->model('Release')->load_meta($release1, $release2);

        $relationship = $c->model('Relationship')->get_by_id('release', 'url', 1);
        $c->model('Link')->load($relationship);
        $c->model('LinkType')->load($relationship->link);
    };

    $load_data->();

    is($release1->amazon_asin, undef, 'Release 1 ASIN is empty to start');
    is(
        $release2->amazon_asin,
        'B00005CDNG',
        'Release 2 ASIN is set to start',
    );

    # Change the release to $release1, which should move the ASIN to
    # that release.
    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_EDIT,
        editor_id => 1,
        relationship => $relationship,
        entity0 => $release1,
    );
    accept_edit($c, $edit);

    $load_data->();

    is(
        $release1->amazon_asin,
        'B00005CDNG',
        'Release 1 ASIN is set after changing relationship endpoint',
    );
    is(
        $release2->amazon_asin,
        undef,
        'Release 2 ASIN is unset after changing relationship endpoint',
    );

    # Change the link type, which should remove the ASIN from $release1.
    $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_EDIT,
        editor_id => 1,
        relationship => $relationship,
        link_type => $c->model('LinkType')->get_by_id(288),
    );

    $load_data->();

    is(
        $release1->amazon_asin,
        undef,
        'Release 1 ASIN is unset after changing relationship link type',
    );
    is(
        $release2->amazon_asin,
        undef,
        'Release 2 ASIN is still unset after changing relationship link type',
    );

    # Change the link type back, which should restore the ASIN on $release1.
    $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_EDIT,
        editor_id => 1,
        relationship => $relationship,
        link_type => $c->model('LinkType')->get_by_id(77),
    );

    $load_data->();

    is(
        $release1->amazon_asin,
        'B00005CDNG',
        'Release 1 ASIN is set after changing relationship link type back',
    );
    is(
        $release2->amazon_asin,
        undef,
        'Release 2 ASIN is still unset after changing relationship link type back',
    );
};

sub _create_edit {
    my ($c, %args) = @_;

    my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    $c->model('Link')->load($rel);
    $c->model('LinkType')->load($rel->link);

    return $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_EDIT,
        editor_id => 1,
        relationship => $rel,
        link_type => $c->model('LinkType')->get_by_id(102),
        begin_date => { year => 1994 },
        end_date => { year => 1995 },
        entity1 => $c->model('Artist')->get_by_id(5),
        %args
    );
}

sub _create_edit_change_direction {
    my $c = shift;

    my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    $c->model('Link')->load($rel);
    $c->model('LinkType')->load($rel->link);

    return $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_EDIT,
        editor_id => 1,
        change_direction => 1,
        relationship => $rel,
        link_type => $c->model('LinkType')->get_by_id(103),
        begin_date => undef,
        end_date => undef,
        attributes => [],
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
