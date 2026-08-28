package t::MusicBrainz::Server::Form::Utils;
use strict;
use warnings;

use Test::Routine;
use Test::More;

use MusicBrainz::Server::Form::Utils qw( form_or_field_to_json );

{
    package t::MusicBrainz::Server::Form::Utils::TestForm;
    use HTML::FormHandler::Moose;

    extends 'MusicBrainz::Server::Form';

    has '+name' => ( default => 'test-form' );

    has_field 'names' => ( type => 'Repeatable' );
    has_field 'names.text' => ( type => 'Text' );
}

test 'form_or_field_to_json on a test form' => sub {
    my $form = t::MusicBrainz::Server::Form::Utils::TestForm->new;
    my $json = form_or_field_to_json($form);

    is_deeply(
        form_or_field_to_json($form),
        {
            field => {
                names => {
                    errors => [],
                    field => [
                        {
                            errors => [],
                            field => {
                                text => {
                                    errors => [],
                                    has_errors => \0,
                                    html_name => 'test-form.names.0.text',
                                    id => 3,
                                    type => 'field',
                                    value => '',
                                },
                            },
                            has_errors => \0,
                            html_name => 'test-form.names.0',
                            id => 2,
                            type => 'compound_field',
                        },
                    ],
                    has_errors => \0,
                    html_name => 'test-form.names',
                    id => 1,
                    last_index => 0,
                    type => 'repeatable_field',
                },
            },
            has_errors => \0,
            name => 'test-form',
            type => 'form',
        },
    );
};

1;
