package MusicBrainz::Server::Entity::Role::Alias;
use Moose::Role;

use MusicBrainz::Server::Entity::Types;

has 'aliases' => (
    is => 'rw',
    isa => 'ArrayRef[MusicBrainz::Server::Entity::Alias]',
    default => sub { [] },
);

has 'primary_alias' => (
    is => 'rw',
    isa => 'Str',
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    my $primary_alias = $self->primary_alias;

    if (defined $primary_alias) {
        $json->{primaryAlias} = $primary_alias;
    }

    return $json;
};

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2024 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

