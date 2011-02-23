package MusicBrainz::Server::Edit::Work::RelatedEntities;
use Moose::Role;
use namespace::autoclean;

requires 'c';

around 'related_entities' => sub
{
    my $orig = shift;
    my $self = shift;

    my @works = values %{
        $self->c->model('Work')->get_by_ids($self->work_ids)
    };

    $self->c->model('Relationship')->load_subset([ 'artist' ], @works);

    return {
        artist => [
            map { $_->entity0_id } map { $_->all_relationships } @works
        ],
        work => [
            $self->work_ids
        ]
    }
};

sub work_ids { shift->work_id }

1;
