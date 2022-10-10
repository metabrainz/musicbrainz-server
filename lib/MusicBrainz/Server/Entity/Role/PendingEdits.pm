package MusicBrainz::Server::Entity::Role::PendingEdits;

use Moose::Role;
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );

has 'edits_pending' => (
    is => 'rw',
    isa => 'Int'
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    return {
        %{ $self->$orig },
        editsPending => boolean_to_json($self->edits_pending),
    };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
