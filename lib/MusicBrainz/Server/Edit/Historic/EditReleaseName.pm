package MusicBrainz::Server::Edit::Historic::EditReleaseName;
use strict;
use warnings;

use MusicBrainz::Server::Edit::Historic::Base;

use MusicBrainz::Server::Translation qw( N_l );
use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_EDIT_RELEASE_NAME );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );

sub edit_name     { N_l('Edit release') }
sub edit_kind     { 'edit' }
sub historic_type { 3 }
sub edit_type     { $EDIT_HISTORIC_EDIT_RELEASE_NAME }
sub edit_template { 'historic/EditReleaseName' }

sub _build_related_entities
{
    my $self = shift;
    return {
        release => $self->data->{release_ids}
    }
}

sub foreign_keys
{
    my $self = shift;
    return {
        Release => { map { $_ => [ 'ArtistCredit' ] } @{ $self->data->{release_ids} } }
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        releases => [ map {
            to_json_object($loaded->{Release}{$_})
        } @{ $self->data->{release_ids} } ],
        name => {
            new => $self->data->{new}{name},
            old => $self->data->{old}{name},
        }
    }
}

sub upgrade
{
    my $self = shift;
    $self->data({
        release_ids => $self->album_release_ids($self->row_id),
        old      => {
            name => $self->previous_value,
        },
        new      => {
            name => $self->new_value
        }
    });

    return $self;
}

sub deserialize_new_value {
    my ($self, $value ) = @_;
    return $value;
}

sub deserialize_previous_value {
    my ($self, $value ) = @_;
    return $value;
}

1;
