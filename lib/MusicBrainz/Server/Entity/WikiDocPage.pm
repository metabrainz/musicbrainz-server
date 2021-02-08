package MusicBrainz::Server::Entity::WikiDocPage;

use Moose;

has 'version' => (
    is => 'rw',
    isa => 'Int'
);

has 'title' => (
    is => 'rw',
    isa => 'Str',
);

has 'hierarchy' => (
    is => 'rw',
    isa => 'ArrayRef',
);

has 'content' => (
    is => 'rw',
    isa => 'Str'
);

has 'canonical' => (
    is => 'rw',
    isa => 'Str',
);

sub TO_JSON {
    my ($self) = @_;

    return {
        content     => $self->content,
        hierarchy   => $self->hierarchy,
        title       => $self->title,
        version     => $self->version,
    };
}


__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Robert Kaye

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
