package MusicBrainz::Server::Entity::Role::Rating;
use Moose::Role;

has 'rating' => (
    is => 'rw',
    isa => 'Int'
);

has 'user_rating' => (
    is => 'rw',
    isa => 'Int'
);

has 'rating_count' => (
    is => 'rw',
    isa => 'Int'
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;

    $json->{rating} = $self->rating;
    $json->{rating_count} = $self->rating_count // 0;
    $json->{user_rating} = $self->user_rating;

    return $json;
};

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

