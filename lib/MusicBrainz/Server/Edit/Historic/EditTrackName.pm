package MusicBrainz::Server::Edit::Historic::EditTrackName;

use strict;
use warnings;
use MusicBrainz::Server::Edit::Historic::Base;

use aliased 'MusicBrainz::Server::Entity::Recording';

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_EDIT_TRACKNAME );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

sub deserialize_previous_value {
    my ($self, $previous) = @_;
    return $previous;
}

sub deserialize_new_value {
    my ($self, $previous) = @_;
    return $previous;
}

sub edit_name     { N_l('Edit recording') }
sub edit_kind     { 'edit' }
sub historic_type { 4 }
sub edit_type     { $EDIT_HISTORIC_EDIT_TRACKNAME }
sub edit_template { 'EditRecording' }

sub _build_related_entities
{
    my $self = shift;
    return {
        recording => [ $self->data->{recording_id} ]
    }
}

sub foreign_keys
{
    my $self = shift;
    return {
        Recording => { $self->data->{recording_id} => [ 'ArtistCredit' ] },
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        recording => to_json_object(
            $loaded->{Recording}{ $self->data->{recording_id} } ||
            Recording->new( id => $self->data->{recording_id} )
        ),
        name => {
            old => $self->data->{old}{name},
            new => $self->data->{new}{name},
        }
    };
}

sub upgrade
{
    my $self = shift;
    $self->data({
        track_id     => $self->row_id,
        recording_id => $self->resolve_recording_id( $self->row_id ),
        old          => { name => $self->previous_value },
        new          => { name => $self->new_value }
    });

    return $self;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
