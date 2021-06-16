package MusicBrainz::Server::Edit::URL::RelatedEntities;
use Moose::Role;
use MusicBrainz::Server::Constants qw( $DIRECTION_FORWARD );
use namespace::autoclean;

requires 'c';

around '_build_related_entities' => sub {
    my ($orig, $self) = @_;

    my @urls = values %{
        $self->c->model('URL')->get_by_ids($self->url_ids)
    };

    $self->c->model('Relationship')->load(@urls);

    my $related_entities = {};
    for my $rel (map { $_->all_relationships } @urls) {
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
