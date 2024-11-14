package MusicBrainz::Server::Edit::Historic::RemoveDiscID;
use strict;
use warnings;

use aliased 'MusicBrainz::Server::Entity::CDTOC';
use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_REMOVE_DISCID );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_lp );

use MusicBrainz::Server::Edit::Historic::Base;

sub edit_name     { N_lp('Remove disc ID', 'edit type') }
sub edit_kind     { 'remove' }
sub historic_type { 20 }
sub edit_type     { $EDIT_HISTORIC_REMOVE_DISCID }
sub edit_template { 'historic/RemoveDiscId' }

sub _build_related_entities
{
    my $self = shift;
    return {
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
        releases => [ map {
            to_json_object($loaded->{Release}{$_})
        } @{ $self->data->{release_ids} } ],
        cdtoc => {
            entityType => 'cdtoc',
            discid => $self->data->{disc_id},
        },
    };
}

sub upgrade
{
    my $self = shift;
    $self->data({
        release_ids => $self->album_release_ids($self->new_value->{AlbumId}),
        full_toc    => $self->new_value->{FullToc},
        disc_id     => $self->previous_value,
        cdtoc_id    => $self->new_value->{CDTOCId},
    });

    return $self;
}

sub deserialize_previous_value { my $self = shift; return shift; }
sub deserialize_new_value {
    my ($self, $value) = @_;
    if ($value eq 'DELETE') {
        return { FullToc => '', CDTOCId => 0, AlbumId => 0 };
    }
    else {
        $self->deserialize($value);
    }
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
