package MusicBrainz::Server::Form::Alias;
use HTML::FormHandler::Moose;

use DateTime::Locale;
use List::UtilsBy 'sort_by';

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';
with 'MusicBrainz::Server::Form::Role::DatePeriod';

has '+name' => ( default => 'edit-alias' );

has_field 'name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1
);

has_field 'sort_name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1
);

has_field 'locale' => (
    type     => 'Select',
    required => 0
);

has_field 'type_id' => (
    type => 'Select',
    required => 0
);

has 'id' => (
    isa => 'Int',
    is  => 'rw',
);

has 'parent_id' => (
    isa => 'Int',
    is  => 'ro',
    required => 1,
);

has 'alias_model' => (
    isa => 'MusicBrainz::Server::Data::Alias',
    is  => 'ro',
    required => 1
);

sub edit_field_names { qw( name locale sort_name begin_date end_date type_id ) }

sub validate_locale {
    my ($self, $field) = @_;
    $field->add_error('An alias for this locale has already been added')
        if $self->alias_model->has_locale( $self->parent_id, $field->value, $self->id );
}

sub options_locale {
    my ($self, $field) = @_;
    return [
        map {
            $_->id => ($_->id =~ /_/ ? "&nbsp;&nbsp;&nbsp;" : '') . $_->name
        }
            sort_by { $_->name }
                map { DateTime::Locale->load($_) } DateTime::Locale->ids
    ];
}

sub options_type_id {
    my $self = shift;
    $self->_select_all($self->alias_model->parent->alias_type);
}

1;
