package MusicBrainz::Server::Form::Role::EditNote;
use strict;
use warnings;

use HTML::FormHandler::Moose::Role;

use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( is_valid_edit_note );

has 'requires_edit_note' => ( is => 'ro', default => 0 );

has_field 'edit_note' => (
    type => 'TextArea',
    label => 'Edit note:',
);

has_field 'make_votable' => (
    type => 'Checkbox',
    default => 0,
);

after validate => sub {
    my $self = shift;

    if ($self->requires_edit_note && (!defined $self->field('edit_note')->value)) {
        $self->field('edit_note')->add_error(l('You must provide an edit note'));
    }

    if ($self->requires_edit_note && (!is_valid_edit_note($self->field('edit_note')->value))) {
        $self->field('edit_note')->add_error(l('Your edit note seems to have no actual content. Please provide a note that will be helpful to your fellow editors!'));
    }
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
