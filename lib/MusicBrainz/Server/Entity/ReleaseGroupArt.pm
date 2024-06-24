package MusicBrainz::Server::Entity::ReleaseGroupArt;

use Moose;
use DBDefs;

extends 'MusicBrainz::Server::Entity::ReleaseArt';

has release_group_id => (
    is => 'rw',
    isa => 'Int',
);

has release_group => (
    is => 'rw',
    isa => 'ReleaseGroup',
);

sub _entity { shift->release_group }

sub _url_prefix
{
    my $self = shift;

    # Release Groups only support front cover art.
    return join('/', DBDefs->COVER_ART_ARCHIVE_DOWNLOAD_PREFIX, 'release-group', $self->release_group->gid, 'front');
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
