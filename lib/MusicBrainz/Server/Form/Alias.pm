package MusicBrainz::Server::Form::Alias;
use HTML::FormHandler::Moose;

use DateTime::Locale;
use List::UtilsBy 'sort_by';
use MusicBrainz::Server::Translation qw( l ln );

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';

has '+name' => ( default => 'edit-alias' );

has_field 'name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1
);

has_field 'sort_name' => (
    type => '+MusicBrainz::Server::Form::Field::Text'
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

has_field 'period' => (
    type => '+MusicBrainz::Server::Form::Field::DatePeriod',
    not_nullable => 1
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

has search_hint_type_id => (
    isa => 'Int',
    is => 'ro',
    required => 1
);

sub edit_field_names {
    qw( name locale sort_name period.begin_date period.end_date
        type_id primary_for_locale )
}

sub _locale_name_special_cases {
    my $locale = shift;
    if ($locale->id eq 'el_POLYTON') {
        return 'Greek Polytonic';
    } elsif ($locale->id eq 'sr_Cyrl_YU') {
	return 'Serbian Cyrillic Yugoslavia';
    } elsif ($locale->id eq 'sr_Latn_YU') {
	return 'Serbian Latin Yugoslavia';
    } else {
	return $locale->name;
    }
}

sub options_locale {
    my ($self, $field) = @_;
    return [
        map {
            # Special-case el_POLYTON, because it has a stupid non-descriptive name
            $_->id => ($_->id =~ /_/ ? "&nbsp;&nbsp;&nbsp;" : '') . _locale_name_special_cases($_)
        }
            sort_by { $_->name }
            sort_by { $_->id }
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

after validate => sub {
    my $self = shift;
    my $type_id = $self->field('type_id')->value;

    if (!$type_id || $type_id != $self->search_hint_type_id) {
        my $sort_name_field = $self->field('sort_name');
        $sort_name_field->required(1);
        $sort_name_field->validate_field;
    }

    if ($self->alias_model->exists({ name => $self->field('name')->value,
                                     locale => $self->field('locale')->value,
                                     type_id => $self->field('type_id')->value,
                                     not_id => $self->init_object ? $self->init_object->{id} : undef,
                                 })) {
        $self->field('name')->add_error('This alias already exists');
    }
};

1;
