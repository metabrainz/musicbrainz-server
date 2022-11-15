package t::MusicBrainz::Server::Edit::URL::Edit;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Fatal;
use Test::Deep qw( cmp_set );

around run_test => sub {
    my ($orig, $test) = splice(@_, 0, 2);
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+url');
    $test->_clear_edit;
    $test->edit;
    $test->$orig(@_);
};

with 't::Edit';
with 't::Context';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_URL_EDIT );
use MusicBrainz::Server::Constants qw( $STATUS_APPLIED $STATUS_OPEN );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

has edit => (
    is => 'ro',
    lazy => 1,
    clearer => '_clear_edit',
    builder => '_build_edit'
);

test 'Entering makes no changes' => sub {
    my $test = shift;
    my $url = $test->c->model('URL')->get_by_id(2);
    is($url->url, 'http://microsoft.com');
    is($url->edits_pending, 1);
};

test 'Can accept' => sub {
    my $test = shift;
    accept_edit($test->c, $test->edit);
    is($test->edit->status, $STATUS_APPLIED);

    my $url = $test->c->model('URL')->get_by_id(2);
    is($url->url, 'http://apple.com/');
    is($url->edits_pending, 0);
};

test 'Can reject' => sub {
    my $test = shift;
    reject_edit($test->c, $test->edit);

    my $url = $test->c->model('URL')->get_by_id(2);
    is($url->url, 'http://microsoft.com');
    is($url->edits_pending, 0);
};

test 'Entering the same edit twice is OK' => sub {
    my $test = shift;
    my $original_edit = $test->edit;

    my $second_edit = $test->_build_edit;
    accept_edit($test->c, $second_edit);

    accept_edit($test->c, $original_edit);
    is($original_edit->status, $STATUS_APPLIED);

    my $url = $test->c->model('URL')->get_by_id(2);
    is($url->url, 'http://apple.com/');
    is($url->edits_pending, 0);
};

test 'Editing a URL that no longer exists fails' => sub {
    my $test = shift;

    my $edit_1 = _build_edit($test, 'http://musicbrainz.org/');
    my $edit_2 = _build_edit($test, 'http://musicbrainz.org/');

    accept_edit($test->c, $edit_1);

    isa_ok exception { $edit_2->accept },
        'MusicBrainz::Server::Edit::Exceptions::FailedDependency';
};

test 'Can edit 2 URLs into a common URL' => sub {
    my $test = shift;

    my $builder = sub {
        my ($url_to_edit) = @_;
        $test->c->model('Edit')->create(
            edit_type => $EDIT_URL_EDIT,
            editor_id => 1,
            privileges => 1,
            to_edit => $test->c->model('URL')->get_by_id($url_to_edit),
            url => 'http://lalalalala.horse/'
        );
    };

    my $edit_1 = $builder->(2);
    my $edit_2 = $builder->(3);

    is $edit_1->status, $STATUS_APPLIED;
    is $edit_2->status, $STATUS_OPEN, 'Merging URLs is not an auto edit';

    accept_edit($test->c, $edit_2);
    is $edit_2->status, $STATUS_APPLIED;
};

test 'Check conflicts (conflicting edits)' => sub {
    my $test = shift;
    my $c = $test->c;

    my $edit_1 = $c->model('Edit')->create(
        edit_type   => $EDIT_URL_EDIT,
        editor_id   => 1,
        to_edit     => $c->model('URL')->get_by_id(1),
        url         => 'http://musicbrainz.org/rocks',
    );

    my $edit_2 = $c->model('Edit')->create(
        edit_type   => $EDIT_URL_EDIT,
        editor_id   => 1,
        to_edit     => $c->model('URL')->get_by_id(1),
        url         => 'http://musicbrainz.org/super',
    );

    ok !exception { $edit_1->accept }, 'accepted edit 1';
    ok  exception { $edit_2->accept }, 'could not accept edit 2';

    my $url = $c->model('URL')->get_by_id(1);
    is($url->url, 'http://musicbrainz.org/rocks', 'url renamed');
};

test 'Changing URL scheme from HTTP to HTTPS is an auto-edit (MBS-9439)' => sub {
    my $test = shift;

    my $edit_1 = _build_edit($test, 'https://musicbrainz.org/', 1);
    is $edit_1->status, $STATUS_APPLIED;

    my $edit_2 = _build_edit($test, 'http://musicbrainz.org/', 1);
    is $edit_2->status, $STATUS_OPEN, 'Moving from HTTPS to HTTP is not an auto edit';
};

test 'Related entities get linked to the edit' => sub {
    my $test = shift;
    my $c = $test->c;

    my $edit = $c->model('Edit')->create(
        edit_type   => $EDIT_URL_EDIT,
        editor_id   => 1,
        to_edit     => $c->model('URL')->get_by_id(3),
        url         => 'http://musicbrainz.org/super',
    );

    cmp_set($edit->related_entities->{artist},
            [ 100 ],
            'is related to the artist that uses the URL');

    cmp_set($edit->related_entities->{url},
            [ 3 ],
            'is related to the URL itself');
};

test 'Editing an Amazon URL updates the release ASIN' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, <<~'SQL');
        TRUNCATE link CASCADE;
        SQL
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+edit_relationship_edit');

    my $relationship = $c->model('Relationship')->get_by_id('release', 'url', 1);
    $c->model('Link')->load($relationship);
    $c->model('LinkType')->load($relationship->link);

    my $release;
    my $load_release = sub {
        $release = $c->model('Release')->get_by_id(2);
        $c->model('Release')->load_meta($release);
    };

    $load_release->();

    is(
        $release->amazon_asin,
        'B00005CDNG',
        'Release ASIN is set to start',
    );

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_URL_EDIT,
        editor_id => 1,
        to_edit => $c->model('URL')->get_by_id(263685),
        url => 'https://www.amazon.com/gp/product/B000000000',
    );
    accept_edit($c, $edit);

    $load_release->();

    is(
        $release->amazon_asin,
        'B000000000',
        'Release ASIN is updated after editing URL',
    );

    $edit = $c->model('Edit')->create(
        edit_type => $EDIT_URL_EDIT,
        editor_id => 1,
        to_edit => $c->model('URL')->get_by_id(263685),
        url => 'https://www.amazon.com/gp/product/',
    );
    accept_edit($c, $edit);

    $load_release->();

    is(
        $release->amazon_asin,
        undef,
        'Release ASIN is unset after editing to an invalid URL',
    );
};

sub _build_edit {
    my ($test, $url, $url_to_edit) = @_;
    $test->c->model('Edit')->create(
        edit_type => $EDIT_URL_EDIT,
        editor_id => 1,
        to_edit => $test->c->model('URL')->get_by_id($url_to_edit || 2),
        url => $url || 'http://apple.com/',
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
