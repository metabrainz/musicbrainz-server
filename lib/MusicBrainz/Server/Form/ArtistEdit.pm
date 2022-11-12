package MusicBrainz::Server::Form::ArtistEdit;
use strict;
use warnings;

use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form::Artist';

has 'artist_credits' => (
    isa => 'ArrayRef[ArtistCredit]',
    is => 'ro',
    required => 1,
);

has_field 'rename_artist_credit' => (
    type => 'Multiple'
);

sub options_rename_artist_credit {
    my ($self, $field) = @_;
    return [
        map { $_->id => $_->name }
        @{ $self->artist_credits }
    ];
}

sub rename_artist_credit_set {
    my $self = shift;
    my %set = map { $_ => 1 } @{ $self->field('rename_artist_credit')->value || [] };
    return \%set;
}

1;
