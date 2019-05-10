package MusicBrainz::Server::Entity::CollectionItem;
use Moose;
use namespace::autoclean;

use DateTime::Format::Pg;

use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Types qw( PgDateStr );

has 'entity' => (
    is => 'rw',
    isa => 'Entity',
    required => 1,
);

has 'added' => (
    is => 'rw',
    isa => 'PgDateStr',
);

sub TO_JSON {
    my $self = shift;

    my $json = $self->entity->TO_JSON;
    $json->{collection_item} = {
        added => undef,
    };

    my $added = $self->added;
    if (defined $added) {
        $added = DateTime::Format::Pg->parse_datetime($self->added);
        $added->set_time_zone('UTC');
        $json->{collection_item}->{added} = $added->iso8601 . 'Z';
    }

    return $json;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
