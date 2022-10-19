package t::MusicBrainz::Server::Form::Field::Text;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use URI;

{
    package t::MusicBrainz::Server::Form::Field::Text::TestForm;
    use HTML::FormHandler::Moose;

    extends 'MusicBrainz::Server::Form';

    has '+name' => ( default => 'test-edit' );

    has_field 't' => (
        type => '+MusicBrainz::Server::Form::Field::Text'
    );
}

test 'URL field validation' => sub {
    my $expected = 'All good';
    t_field_ok($expected, $expected);
    t_field_ok(' All good', $expected);
    t_field_ok(' All good ', $expected);
    t_field_ok('All good ', $expected);
    t_field_ok('All    good ', $expected);
};

sub t_field_ok {
    my ($input, $expected) = @_;
    my $form = t::MusicBrainz::Server::Form::Field::Text::TestForm->new;
    $form->process({
        'test-edit' => {
            t => $input
        }
    });
    ok($form->is_valid, 'processed without errors');
    is($form->field('t')->value, $expected);
}
