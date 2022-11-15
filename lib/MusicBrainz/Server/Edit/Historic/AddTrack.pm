package MusicBrainz::Server::Edit::Historic::AddTrack;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_ADD_TRACK );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );
use Scalar::Util qw( looks_like_number );

use MusicBrainz::Server::Edit::Historic::Base;

sub edit_name     { N_l('Add track (historic)') }
sub edit_kind     { 'add' }
sub historic_type { 7 }
sub edit_type     { $EDIT_HISTORIC_ADD_TRACK }
sub edit_template { 'historic/AddTrackOld' }

sub _build_related_entities
{
    my $self = shift;
    return {
        release => $self->data->{release_ids}
    }
}

sub release_ids { @{ shift->data->{release_ids} } }

sub foreign_keys
{
    my $self = shift;
    return {
        Release => {
            map { $_ => [ 'ArtistCredit' ] } $self->release_ids
        }
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    return {
        releases => [
            map {
                to_json_object($loaded->{Release}{$_})
            } $self->release_ids
        ],
        position    => $self->data->{position},
        name        => $self->data->{name},
        artist_name => $self->data->{artist_name}
    }
}

sub upgrade
{
    my $self = shift;
    $self->data({
        release_ids => $self->album_release_ids($self->row_id),
        %{ $self->new_value },
    });

    return $self;
}

sub deserialize_new_value
{
    my ($self, $new) = @_;
    my @lines = split /\n/, $new;

    # Some edits (see #650 seem to have position and name swapped round...)
    my ($name, $position) = @lines;
    if (looks_like_number($name) && !looks_like_number($position)) {
        ($name, $position) = ($position, $name);
    }

    my %deserialized = (
        name     => $name,
        position => $position
    );

    $deserialized{artist_name} = $lines[3] if $lines[3];

    return \%deserialized;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
