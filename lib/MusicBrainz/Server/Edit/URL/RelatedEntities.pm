package MusicBrainz::Server::Edit::URL::RelatedEntities;
use Moose::Role;
use MusicBrainz::Server::Constants qw( :direction );
use namespace::autoclean;

requires 'c';

around '_build_related_entities' => sub
{
    my $orig = shift;
    my $self = shift;

    my @urls = values %{
        $self->c->model('URL')->get_by_ids($self->url_ids)
    };

    $self->c->model('Relationship')->load(@urls);

    my @relationships = map { $_->all_relationships } @urls;

    my $related_entities;

    for my $rel (@relationships) {
        my $target_type = $rel->target_type;
        my $target_id = $rel->direction == $DIRECTION_FORWARD
            ? $rel->entity1_id
            : $rel->entity0_id;
        push @{ $related_entities->{$target_type} //= [] }, $target_id;
    }

    push @{ $related_entities->{url} //= [] }, $self->url_ids;

    return $related_entities;
};

sub url_ids { shift->url_id }

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
