package MusicBrainz::Server::Form::Filter::Work;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( l lp );
extends 'MusicBrainz::Server::Form::Filter::Generic';

has 'types' => (
    isa => 'ArrayRef[WorkType]',
    is => 'ro',
    required => 1,
);

has_field 'role_type' => (
    type => 'Select',
);

has_field 'type_id' => (
    type => 'Select',
);

sub filter_field_names {
    return qw/ name role_type type_id /;
}

sub options_role_type {
    return [
        { value => 1, label => l('As performer') },
        { value => 2, label => l('As writer') },
    ];
}

sub options_type_id {
    my ($self, $field) = @_;
    return [
        { value => '[none]', label => lp('[none]', 'work type') },
        map +{ value => $_->id, label => $_->l_name },
        @{ $self->types }
    ];
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{options_role_type} = $self->options_role_type;
    $json->{options_type_id} = $self->options_type_id;
    return $json;
};

1;

