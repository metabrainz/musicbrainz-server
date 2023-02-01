package MusicBrainz::Server::Edit::Medium::RelatedEntities;
use Moose::Role;
use namespace::autoclean;

requires 'c', 'medium_id';

around '_build_related_entities' => sub
{
    my $orig = shift;
    my ($self) = shift;
    my $medium = $self->c->model('Medium')->get_by_id($self->medium_id);
    $self->c->model('Release')->load($medium);
    $self->c->model('ReleaseGroup')->load($medium->release);

    my $release = $medium->release;
    my $release_group = $release->release_group;

    $self->c->model('ArtistCredit')->load($release, $release_group);
    return {
        artist => [
            map { $_->artist_id } map { @{ $_->artist_credit->names } }
                $release, $release_group
        ],
        release_group => [ $release_group->id ],
        release => [ $release->id ]
    }
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
