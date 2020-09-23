package MusicBrainz::Server::Form::Filter::ReleaseGroup;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form::Filter::Generic';

has 'artist_credits' => (
    isa => 'ArrayRef[ArtistCredit]',
    is => 'ro',
    required => 1,
);

has 'secondary_types' => (
    isa => 'ArrayRef[ReleaseGroupSecondaryType]',
    is => 'ro',
    required => 1,
);

has 'types' => (
    isa => 'ArrayRef[ReleaseGroupType]',
    is => 'ro',
    required => 1,
);

has_field 'artist_credit_id' => (
    type => 'Select',
);

has_field 'type_id' => (
    type => 'Select',
);

has_field 'secondary_type_id' => (
    type => 'Select',
);

sub filter_field_names {
    return qw/ name artist_credit_id secondary_type_id type_id /;
}

sub options_artist_credit_id {
    my ($self, $field) = @_;
    return [
        map +{ value => $_->id, label => $_->name },
        @{ $self->artist_credits }
    ];
}

sub options_secondary_type_id {
    my ($self, $field) = @_;
    return [
        map +{ value => $_->id, label => $_->l_name },
        @{ $self->secondary_types }
    ];
}

sub options_type_id {
    my ($self, $field) = @_;
    return [
        map +{ value => $_->id, label => $_->l_name },
        @{ $self->types }
    ];
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{options_artist_credit_id} = $self->options_artist_credit_id;
    $json->{options_secondary_type_id} = $self->options_secondary_type_id;
    $json->{options_type_id} = $self->options_type_id;
    return $json;
};

1;

