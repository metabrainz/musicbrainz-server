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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
