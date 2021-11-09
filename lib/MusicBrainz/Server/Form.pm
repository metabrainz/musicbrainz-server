package MusicBrainz::Server::Form;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

use List::AllUtils qw( sort_by );
use MusicBrainz::Server::Translation qw( l );

with 'MusicBrainz::Server::Form::Role::ToJSON';

has '+name' => ( required => 1 );
has '+html_prefix' => ( default => 1 );

# Modified copy from HTML/FormHandler.pm (including a bug fix for
# Repeatable initialization)
sub _init_from_object
{
   my ( $self, $node, $item ) = @_;

   $node ||= $self;
   return unless $item;
   warn 'HFH: init_from_object ', $self->name, "\n" if $self->verbose;
   my $my_value;
   for my $field ( $node->fields ) {
      next if $field->parent && $field->parent != $node;
      next if $field->writeonly;
      my $value = $self->_get_value( $field, $item );
      if (!defined $value) {
         if ( $field->isa('HTML::FormHandler::Field::Repeatable') ) {
            $field->_init;
         }
         next;
      }
      if ( $field->isa('HTML::FormHandler::Field::Repeatable') ) {
         $field->_init_from_object($value);
      }
      elsif ( $field->isa('HTML::FormHandler::Field::Compound') ) {
         $self->_init_from_object( $field, $value );
      }
      else {
         if ( my @values = $field->get_init_value ) {
            my $values_ref = @values > 1 ? \@values : shift @values;
            $field->init_value($values_ref) if defined $values_ref;
            $field->value($values_ref)      if defined $values_ref;
         }
         else {
            $self->init_value( $field, $value );
         }
         $field->_load_options if $field->can('_load_options');
      }
      $my_value->{ $field->name } = $field->value;
   }
   $node->value($my_value);
   $self->did_init_obj(1);
}


sub serialize
{
    my ($self, $previous) = @_;

    # to serialize a form we save both the values and attributes of each field.
    # ->fif provides convenient access to all values.
    my $fif = $self->_fix_fif($self->fif);

    my @attribute_names = qw/ label title style id disabled readonly order /;
    my $name = $self->name;
    my $attributes = {};

    # ->fif should have dumped all field names, so we can use that to simply
    # iterate over all fields instead of walking the tree.
    for my $full_name (keys %$fif)
    {
        my $field = $full_name =~ s/^\Q$name.\E//r;

        $attributes->{$full_name} = { map {
            $_ => $self->field($field)->$_
        } @attribute_names };
    }

    return {
         'values' => $fif,
         'attributes' => $attributes,
    };
}

sub unserialize
{
    my ($self, $data, $params) = @_;

    $params ||= $data->{'values'};

    my $name = $self->name;

    $self->process( params => $params );

    for my $full_name (keys %{ $data->{'attributes'} })
    {
        my $field = $full_name =~ s/^\Q$name.\E//r;

        next unless $self->field($field);

        my $value = $data->{'attributes'}->{$full_name};
        for (keys %$value)
        {
            $self->field($field)->$_( $value->{$_} ) if $value->{$_};
        }

        # disabled inputs are never submitted with the form, so we have to
        # copy the values previously rendered.
        if ($self->field($field)->disabled)
        {
            $self->field($field)->value($data->{'values'}->{$full_name});
        }
    }
}

# FIXME: remove this. just temporary, until gshank's fixes are available on CPAN.
sub _fix_fif
{
    my ($self, $fif) = @_;

    # getting a list of prefixes which are used for repeatables.
    my %repeatables;
    for my $key (keys %$fif)
    {
        my @segments = split(/\./, $key);
        next if scalar @segments == 1;

        my $fieldname = '';
        my $sep = '';
        while (scalar @segments)
        {
            $fieldname .= $sep . shift @segments;

            my $f = $self->field($fieldname);
            $repeatables{$fieldname} = 1 if ($f && $f->is_repeatable);

            $sep = q(.);
        }
    }

    # comparing all keys against the list of repeatables, and removing
    # any values which shouldn't be in the ->fif.
    for (keys %$fif)
    {
        for my $prefix (keys %repeatables)
        {
            delete($fif->{$_}) if (m/^\Q$prefix\E\.[^0-9]+/);
        }
    }

    return $fif;
}

sub clear_errors {
    my ($self, $field) = @_;

    if (!$field)
    {
        map { $self->clear_errors($_) } $self->fields;
        return;
    }

    $field->clear_errors;

    if ($field->is_repeatable)
    {
        map { $self->clear_errors($_) } $field->fields;
    }

    if ($field->can('is_compound') && $field->is_compound)
    {
        map { $self->clear_errors($_) } $field->fields;
    }
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
