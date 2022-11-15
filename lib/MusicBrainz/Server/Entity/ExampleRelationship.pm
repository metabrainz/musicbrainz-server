package MusicBrainz::Server::Entity::ExampleRelationship;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );

has name => (
    isa => 'Str',
    required => 1,
    is => 'ro',
);

has published => (
    isa => 'Bool',
    is => 'ro',
    required => 1,
);

has relationship => (
    is => 'ro',
    required => 1,
);

sub TO_JSON {
    my ($self) = @_;

    return {
        name            => $self->name,
        published       => boolean_to_json($self->published),
        relationship    => to_json_object($self->relationship),
    };
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
