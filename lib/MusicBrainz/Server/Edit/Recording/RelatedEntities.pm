package MusicBrainz::Server::Edit::Recording::RelatedEntities;
use Moose::Role;
use namespace::autoclean;

requires 'c';

around '_build_related_entities' => sub
{
    my $orig = shift;
    my $self = shift;

    my @recordings = values %{
        $self->c->model('Recording')->get_by_ids($self->recording_ids)
    };

    my ($releases, undef) = $self->c->model('Release')->find_by_recording(
        [ $self->recording_ids ]
    );
    my @releases = @$releases;

    $self->c->model('ReleaseGroup')->load(@releases);
    $self->c->model('ArtistCredit')->load(@recordings, @releases,
                                          map { $_->release_group } @releases);
    return {
        artist => [
            map { $_->artist_id } map { @{ $_->artist_credit->names } }
                @recordings, @releases, map { $_->release_group } @releases
        ],
        release => [ map { $_->id } @releases ],
        release_group => [ map { $_->release_group_id } @releases ],
        recording => [ map { $_->id } @recordings ]
    }
};

sub recording_ids { shift->recording_id }

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
