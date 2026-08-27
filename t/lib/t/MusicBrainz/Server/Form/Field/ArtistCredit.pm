package t::MusicBrainz::Server::Form::Field::ArtistCredit;
use utf8;
use strict;
use warnings;

use Test::Routine;
use Test::More;

{
    package t::MusicBrainz::Server::Form::Field::ArtistCredit::TestForm;
    use HTML::FormHandler::Moose;

    extends 'MusicBrainz::Server::Form';

    has '+name' => ( default => 'test-edit' );

    has_field $_ => (
        type => '+MusicBrainz::Server::Form::Field::ArtistCredit',
    ) for qw( missing_fields empty_fields missing_artist_ids );
}

test 'Artist credit field validation' => sub {
    my $form = t::MusicBrainz::Server::Form::Field::ArtistCredit::TestForm->new();
    ok(!$form->ran_validation, 'new form has not yet been validated');

    $form->process({ 'test-edit' => {
        missing_fields => undef,
        empty_fields => { names => [ { name => '', artist => { name => '', id => undef } }, { name => '' } ] },
        missing_artist_ids => { names => [ { name => 'α', artist => { name => 'β' } } ] },
    }});

    ok($form->ran_validation, 'processed form, validation run');
    ok(!$form->is_valid, 'processed form, with invalid fields');

    my $missing_fields = $form->field('missing_fields');
    ok($missing_fields->has_errors, 'missing fields are invalid');
    is(
        $missing_fields->errors->[0],
        'Artist credit field is required',
        'the top level field has a "required" error message',
    );

    my $empty_fields = $form->field('empty_fields');
    ok($empty_fields->has_error_fields, 'empty fields are invalid');
    my @names = $empty_fields->field('names')->fields;
    is(
        $names[0]->errors->[0],
        'Please add an artist name for each credit.',
        'the first empty field has an error',
    );
    is(
        $names[1]->errors->[0],
        'Please add an artist name for each credit.',
        'the second empty field has an error',
    );
    ok(!$empty_fields->has_errors, 'the top level field has no error');

    my $missing_artist_ids = $form->field('missing_artist_ids');
    ok($missing_artist_ids->has_error_fields, 'missing artist ids are invalid');
    @names = $missing_artist_ids->field('names')->fields;
    is(
        $names[0]->errors->[0],
        'Artist "α" is unlinked, please select an existing artist. ' .
        'You may need to add a new artist to MusicBrainz first.',
        'the field with an unlinked artist has an error',
    );
    ok(!$missing_artist_ids->has_errors, 'the top level field has no error');

    $form = t::MusicBrainz::Server::Form::Field::ArtistCredit::TestForm->new( init_object => {} );
    ok(!$form->ran_validation, 'new form with init_object has not yet been validated');

    $form->process({ 'test-edit' => {
        missing_fields => undef,
        empty_fields => undef,
        missing_artist_ids => undef,
    }});

    ok($form->ran_validation, 'processed empty form with init_object, validation run');
    ok($form->is_valid, 'empty form with init_object is valid');
};

1;
