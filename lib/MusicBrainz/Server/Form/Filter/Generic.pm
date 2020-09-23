package MusicBrainz::Server::Form::Filter::Generic;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'filter' );

has 'entity_type' => (
    isa => 'Str',
    is => 'ro',
    required => 1,
);

has_field 'name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
);

has_field 'cancel' => ( type => 'Submit' );
has_field 'submit' => ( type => 'Submit' );

sub filter_field_names {
    return qw/ name /;
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{entity_type} = $self->entity_type;
    return $json;
};

1;

