package MusicBrainz::Server::Form::Filter::Recording;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'filter' );

has 'entity_type' => (
    isa => 'Str',
    is => 'ro',
    required => 1,
);

has 'artist_credits' => (
    isa => 'ArrayRef[ArtistCredit]',
    is => 'ro',
    required => 1,
);

has_field 'name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
);

has_field 'artist_credit_id' => (
    type => 'Select',
);

has_field 'cancel' => ( type => 'Submit' );
has_field 'submit' => ( type => 'Submit' );

sub filter_field_names {
    return qw/ name artist_credit_id /;
}

sub options_artist_credit_id {
    my ($self, $field) = @_;
    return [
        map +{ value => $_->id, label => $_->name },
        @{ $self->artist_credits }
    ];
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{entity_type} = $self->entity_type;
    $json->{options_artist_credit_id} = $self->options_artist_credit_id;
    return $json;
};

1;

