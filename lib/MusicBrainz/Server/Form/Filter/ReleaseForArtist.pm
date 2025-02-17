package MusicBrainz::Server::Form::Filter::ReleaseForArtist;
use strict;
use warnings;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( lp );

extends 'MusicBrainz::Server::Form::Filter::Release';

sub options_label_id {
    my ($self, $field) = @_;
    return [
        { value => '-1', label => lp('[none]', 'release label') },
        map +{ value => $_->id, label => $_->name },
        @{ $self->labels },
    ];
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{options_label_id} = $self->options_label_id;
    return $json;
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2025 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut