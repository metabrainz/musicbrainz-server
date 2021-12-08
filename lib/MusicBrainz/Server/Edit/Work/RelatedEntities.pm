package MusicBrainz::Server::Edit::Work::RelatedEntities;
use Moose::Role;
use namespace::autoclean;

requires 'c';

around '_build_related_entities' => sub
{
    my $orig = shift;
    my $self = shift;

    my @works = values %{
        $self->c->model('Work')->get_by_ids($self->work_ids)
    };

    my ($recordings, undef) = $self->c->model('Recording')->find_by_works([$self->work_ids]);

    my @recording_ids = map { $_->id } @$recordings;

    my ($releases, undef) = $self->c->model('Release')->find_by_recording(\@recording_ids);

    $self->c->model('Relationship')->load_subset([ 'artist' ], @works);

    return {
        artist => [
            map { $_->entity0_id } map { $_->all_relationships } @works
        ],
        recording => [
            @recording_ids
        ],
        release => [
            map { $_->id } @$releases
        ],
        work => [
            $self->work_ids
        ]
    }
};

sub work_ids { shift->work_id }

1;
