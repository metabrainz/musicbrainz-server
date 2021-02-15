package MusicBrainz::Server::Entity::Role::Comment;
use Moose::Role;

has comment => (
    is => 'rw',
    isa => 'Str'
);

around TO_JSON => sub {
    my ($orig, $self) = @_;
    return {%{ $self->$orig }, comment => $self->comment};
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
