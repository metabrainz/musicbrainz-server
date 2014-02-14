package MusicBrainz::Server::Form::Work;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Form::Utils qw( language_options select_options );

use List::AllUtils qw( uniq );

extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';

has '+name' => ( default => 'edit-work' );

has_field 'type_id' => (
    type => 'Select',
);

has_field 'language_id' => (
    type => 'Select',
);

has_field 'name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
);

has_field 'comment' => (
    type => '+MusicBrainz::Server::Form::Field::Comment',
);

has_field 'iswcs' => (
    type => 'Repeatable',
    inflate_default_method => \&inflate_iswcs
);

has_field 'iswcs.contains' => (
    type => '+MusicBrainz::Server::Form::Field::ISWC',
);

has_field 'attributes' => (
    type => 'Repeatable',
    inflate_default_method => \&inflate_attributes,
    num_when_empty => 0
);

has_field 'attributes.type_id' => (
    type => 'Integer',
    required => 1
);

has_field 'attributes.value' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1
);

sub is_empty_attribute {
    my ($field) = @_;
    return !$field->field('type_id')->value && !$field->field('value')->value;
}

after 'validate' => sub {
    my ($self) = @_;

    my $iswcs = $self->field('iswcs');
    $iswcs->value([ uniq sort grep { $_ } @{ $iswcs->value } ]);

    my $attributes = $self->field('attributes');
    my %allowed_values = $self->ctx->model('Work')->allowed_attribute_values(
        map { $_->{type_id} } @{ $attributes->value }
    );

    for my $attribute_field ($attributes->fields) {
        next if is_empty_attribute($attribute_field);
        next if
            $attribute_field->has_errors ||
            $attribute_field->field('type_id')->has_errors ||
            $attribute_field->field('value')->has_errors;

        my $v = $attribute_field->value;
        my $value = $v->{value};
        my $type_id = $v->{type_id};
        my $parser = $allowed_values{$v->{type_id}};

        if (!defined($parser)) {
            $attribute_field->field('type_id')->add_error(
                l('Unknown work attribute type.')
            );
        }
        elsif ($parser->{allows_value}->($value)) {
            # Convert the value to a format supported by Edit::Work::Edit
            $attribute_field->value({
                attribute_text => $parser->{allows_free_text} ? $value : undef,
                attribute_value_id => $parser->{allows_free_text} ? undef : $value,
                attribute_type_id => $type_id
            });
        }
        else {
            $attribute_field->field('value')->add_error(
                l('This value is not allowed for this work attribute type.')
            );
        }
    }

    # We need to reset the repeatable value as we may have changed the value of
    # inner fields.
    my $new_values = [ grep { $_ } map { $_->value } $attributes->fields ];
    $attributes->value($new_values);
};

sub inflate_iswcs {
    my ($self, $value) = @_;
    return [ map { $_->iswc } @$value ];
}

sub inflate_attributes {
    my ($self, $value) = @_;
    return [
        map +{
            type_id => $_->type->id,
            value => $_->value_id // $_->value
        }, @$value
    ];
}

sub edit_field_names { qw( type_id language_id name comment artist_credit attributes ) }

sub options_type_id           { select_options(shift->ctx, 'WorkType') }
sub options_language_id       { return language_options (shift->ctx); }

1;
