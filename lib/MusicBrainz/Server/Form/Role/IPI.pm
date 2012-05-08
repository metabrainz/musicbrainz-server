package MusicBrainz::Server::Form::Role::IPI;
use HTML::FormHandler::Moose::Role;

has_field 'ipi_codes'          => ( type => 'Repeatable', num_when_empty => 1 );
has_field 'ipi_codes.code'     => ( type => '+MusicBrainz::Server::Form::Field::IPI' );
has_field 'ipi_codes.deleted'  => ( type => 'Checkbox' );

around edit_fields => sub {
    my $orig = shift;
    my $self = shift;

    my @ret = $self->$orig (@_);

    for my $field (@ret)
    {
        if ($field->name eq 'ipi_codes')
        {
            # FIXME: this is an evil dirty hack, the ipi_codes field
            # wouldn't take this value if HTML::FormHandler did any
            # kind of validation on the ->value() accessor.
            #
            # what would be a better place to perform this mapping?
            my @new_value = map { $_->{code} } grep { $_->{deleted} == 0 } @{ $field->value };
            $field->value(\@new_value);
        }
    };

    return @ret;
};

after 'BUILD' => sub {
    my ($self) = @_;

    if (defined $self->init_object)
    {
        my $ipi_codes = $self->dupe_model->ipi->find_by_entity_id ($self->init_object->id);

        my $max = @$ipi_codes - 1;
        for (0..$max)
        {
            my $ipi_field = $self->field ('ipi_codes')->fields->[$_];

            unless (defined $ipi_field)
            {
                $self->field ('ipi_codes')->add_extra (1);
                $ipi_field = $self->field ('ipi_codes')->fields->[$_];
            }

            $ipi_field->field ('code')->value ($ipi_codes->[$_]->ipi);
        }

    }
};

1;

=head1 COPYRIGHT

Copyright (C) 2012 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
