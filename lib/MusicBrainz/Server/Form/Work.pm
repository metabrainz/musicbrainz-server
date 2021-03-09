package MusicBrainz::Server::Form::Work;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( l N_l );
use MusicBrainz::Server::Form::Utils qw( language_options select_options_tree );
use JSON;
use List::AllUtils qw( uniq );

extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';
with 'MusicBrainz::Server::Form::Role::Relationships';

# MBS-11428: When making changes to this module, please make sure to
# keep MusicBrainz::Server::Controller::WS::js::Edit in sync with it

has '+name' => ( default => 'edit-work' );

has_field 'type_id' => (
    type => 'Select',
);

has_field 'languages' => (
    type => 'Repeatable',
    inflate_default_method => \&inflate_languages,
);

has_field 'languages.contains' => (
    type => 'Select',
    options_method => \&options_languages,
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
);

has_field 'attributes.type_id' => (
    type => 'Integer',
    required => 1,
    required_message => N_l('Please select a work attribute type.'),
    localize_meth => sub { my ($self, @message) = @_; return l(@message); }
);

has_field 'attributes.value' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
    required_message => N_l('Please enter a work attribute value.'),
    localize_meth => sub { my ($self, @message) = @_; return l(@message); }
);

sub is_empty_attribute {
    my ($field) = @_;
    return !$field->field('type_id')->value && !$field->field('value')->value;
}

sub validate_languages {
    my $self = shift;

    my @languages = $self->field('languages')->fields;

    my $is_valid = 1;

    # If we have only one language, then it can be whatever
    # If we have two or more, we check it's not mul (248) nor zxx (486)
    # because combining those with anything else doesn't make sense,
    # and we check the same language hasn't been selected multiple times
    if (scalar @languages > 1) {
        my %used_languages;
        for my $language_field (@languages) {
            my $language_id = $language_field->value;

            if ($language_id == 284) {
                $language_field->push_errors(
                    l('You cannot select “[Multiple languages]” and specific languages at the same time.')
                );
                $is_valid = 0;
            } elsif ($language_id == 486) {
                $language_field->push_errors(
                    l('You cannot select “[No lyrics]” and a lyrics language at the same time.')
                );
                $is_valid = 0;
            } elsif ($used_languages{$language_id}) {
                $language_field->add_error(
                    l('You cannot select the same language more than once.')
                );
                $is_valid = 0;
            }
            $used_languages{$language_id} = 1;
        }
    }

    return $is_valid;
}

after 'validate' => sub {
    my ($self) = @_;

    my $iswcs = $self->field('iswcs');
    $iswcs->value([ uniq sort grep { $_ } @{ $iswcs->value } ]);

    my $attributes = $self->field('attributes');

    my $attribute_types = $self->ctx->model('WorkAttributeType')->get_by_ids(
        map { $_->{type_id} } @{ $attributes->value }
    );

    $self->ctx->model('WorkAttributeTypeAllowedValue')->load_for_work_attribute_types(
        values %$attribute_types
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
        my $attribute_type = $attribute_types->{$type_id};

        if (!defined($attribute_type)) {
            $attribute_field->field('type_id')->add_error(
                l('Unknown work attribute type.')
            );
            next;
        }

        unless ($attribute_type->allows_value($value)) {
            $attribute_field->field('value')->add_error(
                l('This value is not allowed for this work attribute type.')
            );
        }
    }

    unless ($self->has_errors) {
        for my $attribute_field ($attributes->fields) {
            next if is_empty_attribute($attribute_field);

            my $v = $attribute_field->value;
            my $value = $v->{value};
            my $type_id = $v->{type_id};
            my $attribute_type = $attribute_types->{$type_id};

            # Convert the value to a format supported by Edit::Work::Edit
            $attribute_field->value({
                attribute_text => $attribute_type->free_text ? $value : undef,
                attribute_value_id => $attribute_type->free_text ? undef : $value,
                attribute_type_id => $type_id
            });
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

sub inflate_languages {
    my ($self, $value) = @_;

    return [map { $_->language_id } @$value];
}

sub edit_field_names { qw( type_id languages name comment artist_credit attributes ) }

sub options_type_id           { select_options_tree(shift->ctx, 'WorkType') }

sub options_languages {
    language_options(shift->form->ctx, 'work');
}

1;
