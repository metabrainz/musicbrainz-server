package MusicBrainz::Server::Edit::Historic::AddDiscID;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_ADD_DISCID );
use MusicBrainz::Server::Edit::Constants qw( %EDIT_KIND_LABELS );
use MusicBrainz::Server::Entity::CDTOC;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_lp );

use MusicBrainz::Server::Edit::Historic::Base;

sub edit_name     { N_lp('Add disc ID', 'edit type') }
sub edit_kind     { $EDIT_KIND_LABELS{'add'} }
sub historic_type { 32 }
sub edit_type     { $EDIT_HISTORIC_ADD_DISCID }
sub edit_template { 'historic/AddDiscId' }

sub _build_related_entities
{
    my $self = shift;
    return {
        artist  => [ $self->artist_id ],
        release => $self->data->{release_ids},
    };
}

sub foreign_keys
{
    my $self = shift;
    return {
        Release => { map { $_ => [ 'ArtistCredit' ] } @{ $self->data->{release_ids} } },
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        releases => [ map { to_json_object($loaded->{Release}{$_}) } @{ $self->data->{release_ids} } ],
        cdtoc => to_json_object(
            MusicBrainz::Server::Entity::CDTOC->new_from_toc($self->data->{full_toc}),
        ),
        full_toc => $self->data->{full_toc},
    };
}

sub upgrade
{
    my $self = shift;
    $self->data({
        release_ids  => $self->album_release_ids($self->new_value->{AlbumId}),
        release_name => $self->new_value->{AlbumName},
        full_toc     => $self->new_value->{FullTOC},
        cdtoc_id     => $self->new_value->{CDTOCId},
    });

    return $self;
}

1;
