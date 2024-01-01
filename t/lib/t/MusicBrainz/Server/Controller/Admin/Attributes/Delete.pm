package t::MusicBrainz::Server::Controller::Admin::Attributes::Delete;
use utf8;
use strict;
use warnings;

use HTTP::Status qw( :constants );
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test 'Delete standard attribute (series type)' => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+attributes');

    $test->mech->get('/login');
    $test->mech->submit_form(
        with_fields => { username => 'editor', password => 'password' },
    );

    $mech->get('/admin/attributes/SeriesType/delete/1');
    is(
        $mech->status,
        HTTP_FORBIDDEN,
        'Normal user cannot access the remove script page',
    );

    $test->mech->get('/logout');
    $test->mech->get('/login');
    $test->mech->submit_form(
        with_fields => { username => 'admin', password => 'password' },
    );

    $mech->get('/admin/attributes/SeriesType/delete/1');
    html_ok($mech->content);
    $mech->text_contains(
      'because it is the parent of other attributes.',
      'Series type with children attributes cannot be deleted',
    );

    $mech->get('/admin/attributes/SeriesType/delete/2');
    html_ok($mech->content);
    $mech->text_contains(
      'You cannot remove the attribute “Release series” because it is still in use.',
      'Series type in use on a series cannot be deleted',
    );

    $mech->get_ok('/admin/attributes/SeriesType/delete/47');
    html_ok($mech->content);
    $mech->text_contains(
      'Are you sure you wish to remove the Release group award attribute?',
      'The delete series type message is shown when type not in use',
    );

    note('We actually delete the type');
    $mech->form_with_fields('confirm.submit');
    $mech->click('confirm.submit');

    $mech->get_ok('/admin/attributes/SeriesType');
    $mech->text_lacks(
      'Release group award',
      'The series type has been deleted (no longer shows on the types list)',
    );

    $mech->get('/admin/attributes/SeriesType/delete/1');
    html_ok($mech->content);
    $mech->text_contains(
      'Are you sure you wish to remove the Release group series attribute?',
      'Series type which had child can be deleted now child is deleted',
    );
};

test 'Delete language' => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+attributes');

    $test->mech->get('/login');
    $test->mech->submit_form(
        with_fields => { username => 'editor', password => 'password' },
    );

    $mech->get('/admin/attributes/Language/delete/120');
    is(
        $mech->status,
        HTTP_FORBIDDEN,
        'Normal user cannot access the remove language page',
    );

    $test->mech->get('/logout');
    $test->mech->get('/login');
    $test->mech->submit_form(
        with_fields => { username => 'admin', password => 'password' },
    );

    $mech->get_ok('/admin/attributes/Language/delete/120');
    html_ok($mech->content);
    $mech->text_contains(
      'You cannot remove the attribute “English” because it is still in use.',
      'Language in use on a release cannot be deleted',
    );

    $mech->get_ok('/admin/attributes/Language/delete/27');
    html_ok($mech->content);
    $mech->text_contains(
      'You cannot remove the attribute “Asturian” because it is still in use.',
      'Language in use on a work cannot be deleted',
    );

    $mech->get_ok('/admin/attributes/Language/delete/123');
    html_ok($mech->content);
    $mech->text_contains(
      'You cannot remove the attribute “Estonian” because it is still in use.',
      'Language in use on an editor cannot be deleted',
    );

    $mech->get_ok('/admin/attributes/Language/delete/113');
    html_ok($mech->content);
    $mech->text_contains(
      'Are you sure you wish to remove the Dutch attribute?',
      'The delete language message is shown when language not in use',
    );

    note('We actually delete the language');
    $mech->form_with_fields('confirm.submit');
    $mech->click('confirm.submit');

    $mech->get_ok('/admin/attributes/Language');
    $mech->text_lacks(
      'Dutch',
      'The language has been deleted (no longer shows on the languages list)',
    );
};

test 'Delete script' => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+attributes');

    $test->mech->get('/login');
    $test->mech->submit_form(
        with_fields => { username => 'editor', password => 'password' },
    );

    $mech->get('/admin/attributes/Script/delete/28');
    is(
        $mech->status,
        HTTP_FORBIDDEN,
        'Normal user cannot access the remove script page',
    );

    $test->mech->get('/logout');
    $test->mech->get('/login');
    $test->mech->submit_form(
        with_fields => { username => 'admin', password => 'password' },
    );

    $mech->get_ok('/admin/attributes/Script/delete/28');
    html_ok($mech->content);
    $mech->text_contains(
      'You cannot remove the attribute “Latin” because it is still in use.',
      'Script in use on a release cannot be deleted',
    );

    $mech->get_ok('/admin/attributes/Script/delete/85');
    html_ok($mech->content);
    $mech->text_contains(
      'Are you sure you wish to remove the Japanese attribute?',
      'The delete script message is shown when script not in use',
    );

    note('We actually delete the script');
    $mech->form_with_fields('confirm.submit');
    $mech->click('confirm.submit');

    $mech->get_ok('/admin/attributes/Script');
    $mech->text_lacks(
      'Japanese',
      'The script has been deleted (no longer shows on the scripts list)',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2023 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
