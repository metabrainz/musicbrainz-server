package MusicBrainz::Server::Form::Filter::Recording;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'filter' );

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
        map { $_->id => $_->name }
        @{ $self->artist_credits }
    ];
}

1;

