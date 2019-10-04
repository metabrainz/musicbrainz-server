package MusicBrainz::Server::Form::Filter::ReleaseGroup;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form::Filter::Generic';

has 'types' => (
    isa => 'ArrayRef[ReleaseGroupType]',
    is => 'ro',
    required => 1,
);

has_field 'type_id' => (
    type => 'Select',
);

sub filter_field_names {
    return qw/ name artist_credit_id type_id /;
}

sub options_type_id {
    my ($self, $field) = @_;
    return [
        map +{ value => $_->id, label => $_->name },
        @{ $self->types }
    ];
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{options_type_id} = $self->options_type_id;
    return $json;
};

1;

