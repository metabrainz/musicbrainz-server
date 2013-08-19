package MusicBrainz::Server::Form::Work;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Form::Utils qw( language_options );
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
);

has_field 'attributes.type_id' => (
    type => 'Integer',
    required => 1
);

has_field 'attributes.value' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1
);

after 'validate' => sub {
    my ($self) = @_;
    return if $self->has_errors;

    my $iswcs = $self->field('iswcs');
    $iswcs->value([ uniq sort grep { $_ } @{ $iswcs->value } ]);

    my $attributes = $self->field('attributes');
    my %allowed_values = $self->ctx->model('Work')->allowed_attribute_values(
        map { $_->{type_id} } @{ $attributes->value }
    );

    for my $attribute_field ($attributes->fields) {
        my $v = $attribute_field->value;
        my $value = $v->{value};
        my $type_id = $v->{type_id};
        my $parser = $allowed_values{$v->{type_id}};

        if ($parser->{allows_value}->($type_id)) {
            # Convert the value to a format supported by Edit::Work::Edit
            $attribute_field->value({
                attribute_text => $parser->{allows_free_text} ? $value : undef,
                attribute_value_id => $parser->{allows_free_text} ? undef : $value,
                attribute_type_id => $type_id
            });
        }
        else {
            $attribute_field->field('value')->add_error(
                l('This value is not allowed for this work attribute type')
            );
        }
    }

    # We need to reset the repeatable value as we may have changed the value of
    # inner fields.
    $attributes->value([
        map { $_->value } $attributes->fields
    ]);
};

sub inflate_iswcs {
    my ($self, $value) = @_;
    return [ map { $_->iswc } @$value ];
}

sub edit_field_names { qw( type_id language_id name comment artist_credit attributes ) }

sub options_type_id           { shift->_select_all('WorkType') }
sub options_language_id       { return language_options (shift->ctx); }

1;
