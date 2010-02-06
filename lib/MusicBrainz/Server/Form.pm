package MusicBrainz::Server::Form;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has '+name' => ( required => 1 );
has '+html_prefix' => ( default => 1 );

sub submitted_and_valid
{
    my ($self, $params) = @_;
    return $self->process( params => $params) && $self->has_params if values %$params;
}

sub _select_all
{
    my ($self, $model, $accessor) = @_;
    $accessor ||= 'name';
    return [ map {
        $_->id => $_->$accessor
    } $self->ctx->model($model)->get_all ];
}

# Modified copy from HTML/FormHandler.pm (including a bug fix for
# Repeatable initialization)
sub _init_from_object
{
   my ( $self, $node, $item ) = @_;

   $node ||= $self;
   return unless $item;
   warn "HFH: init_from_object ", $self->name, "\n" if $self->verbose;
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

1;
