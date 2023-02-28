package t::MusicBrainz::Server::Form::Field::URL;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use URI;

{
    package t::MusicBrainz::Server::Form::Field::URL::TestForm;
    use HTML::FormHandler::Moose;

    extends 'MusicBrainz::Server::Form';

    has '+name' => ( default => 'test-edit' );

    has_field 'url' => (
        type => '+MusicBrainz::Server::Form::Field::URL'
    );
}

test 'URL field validation' => sub {
    my $form = t::MusicBrainz::Server::Form::Field::URL::TestForm->new;
    ok(!$form->ran_validation, 'new form has not yet been validated');

    $form->process({
        'test-edit' => {
            url => 'http://musicbrainz.org/'
        }
    });

    ok($form->is_valid, 'processed without errors');

    $form->process({
        'test-edit' => {
            url => 'not a url'
        }
    });

    ok(!$form->is_valid, 'did not process with invalid URLs');
};

test 'URL FIF' => sub {
    my $form = t::MusicBrainz::Server::Form::Field::URL::TestForm->new(
        init_object => { url => URI->new('http://musicbrainz.org/') }
    );

    is($form->field('url')->fif, 'http://musicbrainz.org/');
};
