package MusicBrainz::Server::Entity::Role::Art;

use Moose::Role;
use MusicBrainz::Server::Constants qw( %ENTITIES );

with 'MusicBrainz::Server::Entity::Role::PendingEdits';

requires qw( _entity _ia_entity _download_prefix _ia_download_prefix );

has types => (
    is => 'rw',
);

sub type_names {
    my $self = shift;
    return [] unless $self->types;
    return [ map { $_->name } @{ $self->types } ];
}

sub l_type_names {
    my $self = shift;
    return [] unless $self->types;
    return [ map { $_->l_name } @{ $self->types } ];
}

has comment => (
    is => 'rw',
    isa => 'Str',
);

has is_front => (
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

sub _url_prefix {
    my ($self, $suffix) = @_;

    my $entity = $self->_entity;

    return join(
        '/',
        $self->_download_prefix,
        $ENTITIES{ $entity->entity_type }{url},
        $entity->gid,
        $self->id,
    ) . ($suffix // '');
}

sub _ia_url_prefix {
    my ($self, $suffix) = @_;

    $suffix //= '';

    my $download_prefix = $self->_ia_download_prefix;
    unless ($download_prefix) {
        $suffix =~ s/_thumb([0-9]+)\.jpg/-$1.jpg/;
        return $self->_url_prefix($suffix);
    }

    my $mbid_part = 'mbid-' . $self->_ia_entity->gid;

    return join(
        '/',
        $download_prefix,
        $mbid_part,
        ($mbid_part . '-' . $self->id),
    ) . $suffix;
}

sub filename {
    my $self = shift;

    my $gid = $self->_ia_entity->gid;
    return undef unless $gid && $self->suffix;

    return sprintf('mbid-%s-%d.%s', $gid, $self->id, $self->suffix);
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
        types => $self->type_names,
    };

    if (my $entity = $self->_ia_entity) {
        $json->{ $entity->entity_type } = $entity->TO_JSON;
    }

    return $json;
}

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
