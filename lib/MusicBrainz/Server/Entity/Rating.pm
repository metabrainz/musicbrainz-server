package MusicBrainz::Server::Entity::Rating;

use Moose;
use MusicBrainz::Server::Entity::Types;

has 'editor_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'editor' => (
    is => 'rw',
    isa => 'Editor'
);

has 'rating' => (
    is => 'rw',
    isa => 'Int'
);

sub TO_JSON {
    my $self = shift;

    my $editor = $self->editor;
    my $rating = 0 + $self->rating;
    return {
        editor => (defined $editor ? $editor->TO_JSON : undef),
        rating => $rating,
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 NAME

MusicBrainz::Server::Entity::Rating

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
