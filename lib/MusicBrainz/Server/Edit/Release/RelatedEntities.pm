package MusicBrainz::Server::Edit::Release::RelatedEntities;
use Moose::Role;
use namespace::autoclean;

requires 'c', 'release_id';

around 'related_entities' => sub
{
    my $orig = shift;
    my $self = shift;

    my $release = $self->c->model('Release')->get_by_id($self->release_id);
    $self->c->model('ReleaseGroup')->load($release);
    $self->c->model('ArtistCredit')->load($release, $release->release_group);
 
    return {
        artist => [
            map { $_->artist_id } map { @{ $_->artist_credit->names } }
                $release, $release->release_group
        ],
        release => [ $release ],
        release_group => [ $release->release_group_id ],
    }
};

1;
