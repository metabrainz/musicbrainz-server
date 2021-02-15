package MusicBrainz::Server::Entity::ReleaseLabel;

use Moose;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity';

has 'label_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'label' => (
    is => 'rw',
    isa => 'Maybe[Label]'
);

has 'catalog_number' => (
    is => 'rw',
    isa => 'Maybe[Str]'
);

has 'release_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'release' => (
    is => 'rw',
    isa => 'Release'
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    return {
        %{ $self->$orig },
        label => defined($self->label) ? $self->label->TO_JSON : undef,
        label_id => $self->label_id,
        catalogNumber => $self->catalog_number,
    };
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
