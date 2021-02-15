package MusicBrainz::Server::Entity::Role::Area;
use Moose::Role;
use MusicBrainz::Server::Types;

has area_id => (
    is => 'rw',
    isa => 'Int'
);

has area => (
    is => 'rw',
    isa => 'Area'
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    return {
        %{ $self->$orig },
        area => ($self->area ? $self->area->TO_JSON : undef),
    };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
