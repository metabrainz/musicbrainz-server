package MusicBrainz::Server::Form::Filter::Release;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Data::Utils qw( non_empty );
use MusicBrainz::Server::Translation qw( l );
use aliased 'MusicBrainz::Server::Entity::PartialDate';

extends 'MusicBrainz::Server::Form::Filter::Generic';

has 'countries' => (
    isa => 'ArrayRef[Area]',
    is => 'ro',
    required => 1,
);

has_field 'country_id' => (
    type => 'Select',
);

has_field 'date' => (
    type => 'Text',
);

sub filter_field_names {
    return qw/ name artist_credit_id country_id date /;
}

sub options_country_id {
    my ($self, $field) = @_;
    return [
        map +{ value => $_->id, label => $_->name },
        @{ $self->countries }
    ];
}

sub validate_date {
    my ($self, $field) = @_;
    return unless non_empty($field->value);
    $field->push_errors(l('Must be a valid date or partial date. Examples: 2006-05-25, 1990-01, ????-01, ...'))
        if PartialDate->new($field->value)->is_empty;
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{options_country_id} = $self->options_country_id;
    return $json;
};

1;
