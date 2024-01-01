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

    my $empty_fields = $form->field('empty_fields');
    ok($empty_fields->has_errors, 'empty fields are invalid');

    my $missing_artist_ids = $form->field('missing_artist_ids');
    ok($missing_artist_ids->has_errors, 'missing artist ids are invalid');

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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
