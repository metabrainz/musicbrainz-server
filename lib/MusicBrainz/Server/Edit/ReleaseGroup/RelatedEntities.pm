package MusicBrainz::Server::Edit::ReleaseGroup::RelatedEntities;
use Moose::Role;
use namespace::autoclean;

requires 'c';

around '_build_related_entities' => sub
{
    my $orig = shift;
    my $self = shift;

    my @release_groups = values %{
        $self->c->model('ReleaseGroup')->get_by_ids($self->release_group_ids)
    };
    $self->c->model('ArtistCredit')->load(@release_groups);

    return {
        artist => [
            map { $_->artist_id } map { @{ $_->artist_credit->names } }
                @release_groups
        ],
        release_group => [ map { $_->id } @release_groups ],
    }
};

sub release_group_ids { shift->release_group_id }

1;
