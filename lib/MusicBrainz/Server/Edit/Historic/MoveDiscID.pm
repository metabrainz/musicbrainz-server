package MusicBrainz::Server::Edit::Historic::MoveDiscID;
use strict;
use warnings;

use aliased 'MusicBrainz::Server::Entity::CDTOC';
use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_MOVE_DISCID );
use MusicBrainz::Server::Translation qw ( N_l );

use MusicBrainz::Server::Edit::Historic::Base;

sub edit_name     { N_l('Move disc ID') }
sub edit_kind     { 'other' }
sub historic_type { 21 }
sub edit_type     { $EDIT_HISTORIC_MOVE_DISCID }
sub edit_template { 'historic/move_disc_id' }

sub _build_related_entities
{
    my $self = shift;
    return {
        release => [
            @{ $self->data->{release_ids} },
            @{ $self->data->{new_release_ids} }
        ]
    }
}

sub foreign_keys
{
    my $self = shift;
    return {
        Release => {
            map { $_ => [ 'ArtistCredit' ] }
                @{ $self->data->{release_ids} },
                @{ $self->data->{new_release_ids} }
        }
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        old_releases => [ map { $loaded->{Release}->{$_} } @{ $self->data->{release_ids} } ],
        new_releases => [ map { $loaded->{Release}->{$_} } @{ $self->data->{new_release_ids} } ],
        cdtoc        => CDTOC->new( discid => $self->data->{disc_id} )
    }
}

sub upgrade
{
    my $self = shift;
    $self->data({
        release_ids     => $self->album_release_ids($self->row_id),
        new_release_ids => $self->album_release_ids($self->new_value->{NewAlbumId}),
        full_toc        => $self->new_value->{FullTOC} || '',
        disc_id         => $self->new_value->{DiscId} || $self->new_value->{DiskId}
    });

    return $self;
}

1;
