package MusicBrainz::Server::Form::Alias;
use HTML::FormHandler::Moose;

use DateTime::Locale;
use List::UtilsBy 'sort_by';
use MusicBrainz::Server::Translation qw( l ln );

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

has_field 'primary_for_locale' => (
    type => 'Checkbox'
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

sub edit_field_names { qw( name locale sort_name begin_date end_date type_id primary_for_locale ) }

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

sub validate_primary_for_locale {
    my $self = shift;
    if ($self->field('primary_for_locale')->value && !$self->field('locale')->value) {
        return $self->field('primary_for_locale')->add_error(
            l('This alias can only be a primary alias if a locale is selected'));
    }
}

1;
