package MusicBrainz::Server::Edit::Historic::MoveDiscID;
use strict;
use warnings;

use aliased 'MusicBrainz::Server::Entity::CDTOC';
use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_MOVE_DISCID );
use MusicBrainz::Server::Edit::Constants qw( %EDIT_KIND_LABELS );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_lp );

use MusicBrainz::Server::Edit::Historic::Base;

sub edit_name     { N_lp('Move disc ID', 'edit type') }
sub edit_kind     { $EDIT_KIND_LABELS{'other'} }
sub historic_type { 21 }
sub edit_type     { $EDIT_HISTORIC_MOVE_DISCID }
sub edit_template { 'historic/MoveDiscId' }

sub _build_related_entities
{
    my $self = shift;
    return {
        release => [
            @{ $self->data->{release_ids} },
            @{ $self->data->{new_release_ids} },
        ],
    };
}

sub foreign_keys
{
    my $self = shift;
    return {
        Release => {
            map { $_ => [ 'ArtistCredit' ] }
                @{ $self->data->{release_ids} },
                @{ $self->data->{new_release_ids} },
        },
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        old_releases => [ map { to_json_object($loaded->{Release}{$_}) } @{ $self->data->{release_ids} } ],
        new_releases => [ map { to_json_object($loaded->{Release}{$_}) } @{ $self->data->{new_release_ids} } ],
        cdtoc        => to_json_object(CDTOC->new( discid => $self->data->{disc_id} )),
    };
}

sub upgrade
{
    my $self = shift;
    $self->data({
        release_ids     => $self->album_release_ids($self->row_id),
        new_release_ids => $self->album_release_ids($self->new_value->{NewAlbumId}),
        full_toc        => $self->new_value->{FullTOC} || '',
        disc_id         => $self->new_value->{DiscId} || $self->new_value->{DiskId},
    });

    return $self;
}

1;
