package MusicBrainz::Server::Entity::Role::Review;
use Moose::Role;

has 'review_count' => (
    is => 'rw',
    isa => 'Int'
);

has 'most_recent_review' => (
    is => 'rw',
    isa => 'Maybe[CritiqueBrainz::Review]'
);

has 'most_popular_review' => (
    is => 'rw',
    isa => 'Maybe[CritiqueBrainz::Review]'
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;

    if (defined $self->review_count) {
        $json->{review_count} = $self->review_count;
    }

    return $json;
};

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut


