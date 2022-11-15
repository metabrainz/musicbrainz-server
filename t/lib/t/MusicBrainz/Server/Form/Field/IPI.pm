package t::MusicBrainz::Server::Form::Field::IPI;
use strict;
use warnings;

use Test::Routine;
use Test::More;

{
    package t::MusicBrainz::Server::Form::Field::IPI::TestForm;
    use HTML::FormHandler::Moose;

    extends 'MusicBrainz::Server::Form';

    has '+name' => ( default => 'test-edit' );

    has_field 'ipi_9digit' => (
        type => '+MusicBrainz::Server::Form::Field::IPI',
    );

    has_field 'ipi_11digit' => (
        type => '+MusicBrainz::Server::Form::Field::IPI',
    );
}

test 'IPI field validation and transformation' => sub {
    my $form = t::MusicBrainz::Server::Form::Field::IPI::TestForm->new();
    ok(!$form->ran_validation, 'new form, not yet has_errors');

    $form->process({ 'test-edit' => {
        'ipi_9digit' => '123456789',
        'ipi_11digit' => '66123456789'
    }});

    ok($form->ran_validation, 'processed form, validation run');
    ok($form->is_valid, 'validation passed');

    is($form->field('ipi_9digit')->value, '00123456789', '9 digit IPI is padded out to 11 digits');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
