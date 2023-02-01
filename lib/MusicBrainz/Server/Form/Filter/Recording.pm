package MusicBrainz::Server::Form::Filter::Recording;
use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form::Filter::Generic';

has 'artist_credits' => (
    isa => 'ArrayRef[ArtistCredit]',
    is => 'ro',
    required => 1,
);

has_field 'artist_credit_id' => (
    type => 'Select',
);

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
    $json->{options_artist_credit_id} = $self->options_artist_credit_id;
    return $json;
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
