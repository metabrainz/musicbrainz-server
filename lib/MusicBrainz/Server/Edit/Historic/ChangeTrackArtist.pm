package MusicBrainz::Server::Edit::Historic::ChangeTrackArtist;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_CHANGE_TRACK_ARTIST );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_lp );

use MusicBrainz::Server::Edit::Historic::Base;

use aliased 'MusicBrainz::Server::Entity::Artist';
use aliased 'MusicBrainz::Server::Entity::Recording';

sub edit_name     { N_lp('Edit track (historic)', 'edit type') }
sub edit_kind     { 'edit' }
sub edit_type     { $EDIT_HISTORIC_CHANGE_TRACK_ARTIST }
sub historic_type { 10 }
sub edit_template { 'historic/EditTrack' }

sub _build_related_entities {
    my $self = shift;
    return {
        artist    => [ $self->data->{new_artist_id}, $self->data->{old_artist_id} ],
        recording => [ $self->data->{recording_id} ],
    };
}

sub foreign_keys
{
    my $self = shift;
    return {
        Artist    => [ $self->data->{new_artist_id}, $self->data->{old_artist_id} ],
        Recording => [ $self->data->{recording_id} ],
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        recording => to_json_object(
            $loaded->{Recording}{ $self->data->{recording_id} } ||
            Recording->new(
                id => $self->data->{recording_id},
            ),
        ),
        artist => {
            old => to_json_object(
                $loaded->{Artist}{ $self->data->{old_artist_id} } ||
                Artist->new(
                    id => $self->data->{old_artist_id},
                    name => $self->data->{old_artist_name},
                ),
            ),
            new => to_json_object(
                $loaded->{Artist}{ $self->data->{new_artist_id} } ||
                Artist->new(
                    id => $self->data->{new_artist_id},
                    name => $self->data->{new_artist_name},
                ),
            ),
        },
    };
}

sub upgrade
{
    my $self = shift;

    $self->data({
        recording_id    => $self->resolve_recording_id($self->row_id),
        old_artist_id   => $self->artist_id,
        old_artist_name => $self->previous_value,
        new_artist_id   => $self->new_value->{artist_id},
        new_artist_name => $self->new_value->{name},
    });

    return $self;
}

sub deserialize_previous_value { return $_[1] }

sub deserialize_new_value
{
    my ($self, $value) = @_;

    my ($name, $sort_name, $id) = split /\n/, $value;
    return {
        name      => $name,
        sort_name => $sort_name,
        artist_id => $id || 0,  # Some edits appear to lack this - 1792375
    };
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
