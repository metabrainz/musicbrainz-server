package MusicBrainz::Server::Form::Alias;
use HTML::FormHandler::Moose;

use Locale::Language;

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';

has '+name' => ( default => 'edit-alias' );

has_field 'name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1
);

has_field 'locale' => (
    type     => 'Select',
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

sub edit_field_names { qw(name locale) }

sub validate_locale {
    my ($self, $field) = @_;
    $field->add_error('An alias for this locale has already been added')
        if $self->alias_model->has_locale( $self->parent_id, $field->value, $self->id );
}

sub options_locale {
    my ($self, $field) = @_;
    return [
        map {
            language2code($_) => $_
        } sort { $a cmp $b } all_language_names()
    ];
}

1;
