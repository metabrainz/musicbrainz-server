package MusicBrainz::Server::Entity::Role::ArtistCredit;
use Moose::Role;
use MusicBrainz::Server::Entity::Types;

has 'artist_credit_id' => (
    is => 'rw',
    isa => 'Int',
);

has 'artist_credit' => (
    is => 'rw',
    isa => 'ArtistCredit',
    predicate => 'artist_credit_loaded',
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    my $artist_credit = $self->artist_credit;

    if ($artist_credit) {
        $json->{artist} = $artist_credit->name;
        $json->{artistCredit} = $artist_credit->TO_JSON;
    }

    return $json;
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
