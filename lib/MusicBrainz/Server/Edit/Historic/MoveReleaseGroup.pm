package MusicBrainz::Server::Edit::Historic::MoveReleaseGroup;
use strict;
use warnings;

use namespace::autoclean;

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_name { 'Move release group' }
sub edit_type { 69 }
sub ngs_class { 'MusicBrainz::Server::Edit::ReleaseGroup::Edit' }

sub related_entities {
    my $self = shift;
    return {
        release_group => [ $self->data->{entity_id} ],
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
        entity_id => $self->row_id,
        new => {
            artist_credit => [
                { name => $self->new_value->{name},
                  id => $self->new_value->{id} },
            ]
        },
        old => {
            artist_credit => [
                { name => $self->previous_value,
                  id => $self->artist_id }
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

1;
