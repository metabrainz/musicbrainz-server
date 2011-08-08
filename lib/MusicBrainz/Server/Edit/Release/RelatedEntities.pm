package MusicBrainz::Server::Edit::Release::RelatedEntities;
use Moose::Role;
use namespace::autoclean;

requires 'c';

around '_build_related_entities' => sub
{
    my $orig = shift;
    my $self = shift;

    my @releases = values %{ $self->c->model('Release')->get_by_ids($self->release_ids) };
    $self->c->model('ReleaseGroup')->load(@releases);
    $self->c->model('ArtistCredit')->load(
        @releases, map { $_->release_group } @releases);
 
    return {
        artist => [
            map { $_->artist_id } map { @{ $_->artist_credit->names } }
                @releases,
                map { $_->release_group } @releases
        ],
        release => [ map { $_->id } @releases ],
        release_group => [ map { $_->release_group_id } @releases ],
    }
};

sub release_ids { shift->release_id }

1;
