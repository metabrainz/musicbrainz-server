package MusicBrainz::Server::Entity::Artwork;

use Moose;
use DBDefs;
use MusicBrainz::Server::Entity::CoverArtType;

extends 'MusicBrainz::Server::Entity';
with 'MusicBrainz::Server::Entity::Role::PendingEdits';

has comment => (
    is => 'rw',
    isa => 'Str'
);

has cover_art_types => (
    is => 'rw',
    isa => 'ArrayRef[MusicBrainz::Server::Entity::CoverArtType]',
);

sub types {
    my $self = shift;
    return [] unless $self->cover_art_types;
    return [ map { $_->name } @{ $self->cover_art_types } ];
}

sub l_types {
    my $self = shift;
    return [] unless $self->cover_art_types;
    return [ map { $_->l_name } @{ $self->cover_art_types } ];
}

has is_front => (
    is => 'rw',
    isa => 'Bool',
);

has is_back => (
    is => 'rw',
    isa => 'Bool',
);

has approved => (
    is => 'rw',
    isa => 'Bool',
);

has edit_id => (
    is => 'rw',
    isa => 'Int',
);

has mime_type => (
    is => 'rw',
    isa => 'Str',
);

has suffix => (
    is => 'rw',
    isa => 'Str',
);

has release_id => (
    is => 'rw',
    isa => 'Int',
);

has release => (
    is => 'rw',
    isa => 'Release',
);

sub _url_prefix
{
    my ($self, $suffix) = @_;

    return join(
        '/',
        DBDefs->COVER_ART_ARCHIVE_DOWNLOAD_PREFIX,
        'release',
        $self->release->gid,
        $self->id,
    ) . ($suffix // '');
}

sub _ia_url_prefix {
    my ($self, $suffix) = @_;

    $suffix //= '';

    my $download_prefix = DBDefs->COVER_ART_ARCHIVE_IA_DOWNLOAD_PREFIX;
    unless ($download_prefix) {
        $suffix =~ s/_thumb([0-9]+)\.jpg/-$1.jpg/;
        return $self->_url_prefix($suffix);
    }

    my $mbid_part = 'mbid-' . $self->release->gid;

    return join(
        '/',
        $download_prefix,
        $mbid_part,
        ($mbid_part . '-' . $self->id),
    ) . $suffix;
}

sub filename
{
    my $self = shift;

    return undef unless $self->release->gid && $self->suffix;

    return sprintf('mbid-%s-%d.%s', $self->release->gid, $self->id, $self->suffix);
}

sub image {
    my $self = shift;

    # If the file has been removed from CAA the suffix will not exist,
    # but we still call this for edit display.
    return undef unless $self->suffix;

    return $self->_url_prefix(q(.) . $self->suffix);
}

sub small_thumbnail { my $self = shift; return $self->_url_prefix('-250.jpg'); }
sub large_thumbnail { my $self = shift; return $self->_url_prefix('-500.jpg'); }
sub huge_thumbnail { my $self = shift; return $self->_url_prefix('-1200.jpg'); }

# These accessors allow for requesting thumbnails directly from the IA,
# bypassing our artwork redirect service. These are suitable for any <img>
# tags in our templates, avoiding a pointless 307 redirect and preventing
# our redirect service from becoming overloaded. The "250px"/"500px"/"1200px"
# "original" links still point to the public API at coverartarchive.org via
# small_thumbnail, large_thumbnail, etc.
#
# COVER_ART_ARCHIVE_IA_DOWNLOAD_PREFIX is required to be configured in
# DBDefs.pm; if it isn't, we fall back to using the configured redirect
# service.
sub small_ia_thumbnail { shift->_ia_url_prefix('_thumb250.jpg') }
sub large_ia_thumbnail { shift->_ia_url_prefix('_thumb500.jpg') }
sub huge_ia_thumbnail { shift->_ia_url_prefix('_thumb1200.jpg') }

sub TO_JSON {
    my ($self) = @_;

    my $json = {
        comment => $self->comment,
        filename => $self->filename,
        huge_ia_thumbnail => $self->huge_ia_thumbnail,
        huge_thumbnail => $self->huge_thumbnail,
        image => $self->image,
        id => $self->id,
        large_ia_thumbnail => $self->large_ia_thumbnail,
        large_thumbnail => $self->large_thumbnail,
        mime_type => $self->mime_type,
        small_ia_thumbnail => $self->small_ia_thumbnail,
        small_thumbnail => $self->small_thumbnail,
        suffix => $self->suffix,
        types => $self->types,
    };

    if (my $release = $self->release) {
        $json->{release} = $release->TO_JSON;
    }

    return $json;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
