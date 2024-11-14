package MusicBrainz::Server::Edit::Release::RelatedEntities;
use Moose::Role;
use namespace::autoclean;

requires 'c';

around '_build_related_entities' => sub
{
    my $orig = shift;
    my $self = shift;

    my @releases = values %{ $self->c->model('Release')->get_by_ids($self->release_ids) };
    my @recordings = $self->related_recordings(\@releases);
    $self->c->model('ReleaseGroup')->load(@releases);
    $self->c->model('ArtistCredit')->load(
        @releases, @recordings, map { $_->release_group } @releases);

    return {
        artist => [
            map { $_->artist_id } map { @{ $_->artist_credit->names } }
                @releases, @recordings,
                map { $_->release_group } @releases,
        ],
        recording => [ map { $_->id } @recordings ],
        release => [ map { $_->id } @releases ],
        release_group => [ map { $_->release_group_id } @releases ],
    };
};

sub release_ids { shift->release_id }

sub related_recordings { () }

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
