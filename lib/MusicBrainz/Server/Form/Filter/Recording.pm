package MusicBrainz::Server::Form::Filter::Recording;
use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form::Filter::Generic';

use MusicBrainz::Server::Translation qw( l );

has 'artist_credits' => (
    isa => 'ArrayRef[ArtistCredit]',
    is => 'ro',
    required => 1,
);

has_field 'artist_credit_id' => (
    type => 'Select',
);

has_field 'video' => (
    type => 'Select',
);

has_field 'hide_bootlegs' => (
    type => 'Checkbox',
);

sub filter_field_names {
    return qw/ disambiguation name artist_credit_id hide_bootlegs video /;
}

sub options_artist_credit_id {
    my ($self, $field) = @_;
    return [
        map +{ value => $_->id, label => $_->name },
        @{ $self->artist_credits },
    ];
}

sub options_video {
    return [
        { value => 1, label => l('Videos only') },
        { value => 2, label => l('Non-videos only') },
    ];
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{options_artist_credit_id} = $self->options_artist_credit_id;
    $json->{options_video} = $self->options_video;
    return $json;
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
