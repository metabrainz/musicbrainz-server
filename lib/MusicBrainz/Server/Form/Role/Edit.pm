package MusicBrainz::Server::Form::Role::Edit;
use strict;
use warnings;

use HTML::FormHandler::Moose::Role;

with 'MusicBrainz::Server::Form::Role::EditNote';

requires 'edit_field_names';

sub edit_fields
{
    my ($self) = @_;
    return grep {
        $_->has_input || $_->has_value
    } map {
        $self->field($_)
    } $self->edit_field_names;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
