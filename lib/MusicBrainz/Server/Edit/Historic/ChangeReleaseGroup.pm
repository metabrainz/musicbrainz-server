package MusicBrainz::Server::Edit::Historic::ChangeReleaseGroup;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_CHANGE_RELEASE_GROUP );
use MusicBrainz::Server::Translation qw ( N_l );

use MusicBrainz::Server::Edit::Historic::Base;

sub edit_name     { N_l('Change release group') }
sub edit_kind     { 'other' }
sub historic_type { 73 }
sub edit_type     { $EDIT_HISTORIC_CHANGE_RELEASE_GROUP }
sub edit_template { 'historic/change_release_group' }

sub _release_group_ids
{
    my $self = shift;
    map { $self->data->{$_}{release_group_id} } qw( old new )
}

sub _build_related_entities
{
    my $self = shift;
    return {
        release_group => [
            $self->_release_group_ids
        ],
        release       => $self->data->{release_ids}
    }
}

sub foreign_keys
{
    my $self = shift;
    return {
        Release      => $self->data->{release_ids},
        ReleaseGroup => [ $self->_release_group_ids ],
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    return {
        releases => [
            map {
                $loaded->{Release}{$_}
            } @{ $self->data->{release_ids} }
        ],
        release_group => {
            old => $loaded->{ReleaseGroup}{ $self->data->{old}{release_group_id} },
            new => $loaded->{ReleaseGroup}{ $self->data->{new}{release_group_id} },
        }
    }
}

sub upgrade
{
    my $self = shift;

    $self->data({
        release_ids => $self->album_release_ids($self->row_id),
        old         => { release_group_id => $self->previous_value },
        new         => { release_group_id => $self->new_value },
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
