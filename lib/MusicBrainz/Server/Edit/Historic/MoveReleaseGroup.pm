package MusicBrainz::Server::Edit::Historic::MoveReleaseGroup;
use strict;
use warnings;

use namespace::autoclean;

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_name { 'Move release group' }
sub edit_type { 69 }
sub ngs_class { 'MusicBrainz::Server::Edit::ReleaseGroup::Edit' }

sub _build_related_entities {
    my $self = shift;
    return {
        release_group => [ $self->data->{entity}{id} ],
        artist => [
            $self->data->{new}{artist_credit}[0]{id},
            $self->data->{old}{artist_credit}[0]{id}
        ]
    }
}

sub do_upgrade
{
    my $self = shift;
    return {
        entity => {
            id => $self->row_id,
            name => '[removed]'
        },
        new => {
            artist_credit => [
                { name => $self->new_value->{name},
                  artist => $self->new_value->{artist_id} },
            ]
        },
        old => {
            artist_credit => [
                { name => $self->previous_value,
                  artist => $self->artist_id }
            ]
        }
    };
}

sub deserialize_new_value
{
    my ($self, $value) = @_;
    my ($name, $sort_name, $artist_id) = split /\n/, $value;
    return {
        name => $name,
        sort_name => $sort_name,
        artist_id => $artist_id
    }
}

sub deserialize_previous_value
{
    my ($self, $value) = @_;
    return $value;
}


1;
