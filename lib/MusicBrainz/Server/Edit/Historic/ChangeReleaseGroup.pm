package MusicBrainz::Server::Edit::Historic::ChangeReleaseGroup;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_CHANGE_RELEASE_GROUP );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

use MusicBrainz::Server::Edit::Historic::Base;

use aliased 'MusicBrainz::Server::Entity::ReleaseGroup';

sub edit_name     { N_l('Edit release') }
sub edit_kind     { 'edit' }
sub historic_type { 73 }
sub edit_type     { $EDIT_HISTORIC_CHANGE_RELEASE_GROUP }
sub edit_template_react { 'historic/ChangeReleaseGroup' }

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
                to_json_object($loaded->{Release}{$_})
            } @{ $self->data->{release_ids} }
        ],
        release_group => {
            old => to_json_object(
                $loaded->{ReleaseGroup}{ $self->data->{old}{release_group_id} } ||
                ReleaseGroup->new( id => $self->data->{old}{release_group_id} )
            ),
            new => to_json_object(
                $loaded->{ReleaseGroup}{ $self->data->{new}{release_group_id} } ||
                ReleaseGroup->new( id => $self->data->{new}{release_group_id} )
            ),
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
