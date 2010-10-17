package MusicBrainz::Server::Edit::Historic::MoveReleaseGroup;
use Moose;
use namespace::autoclean;

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_name { 'Move release group' }
sub edit_type { 69 }
sub ngs_class { 'MusicBrainz::Server::Edit::ReleaseGroup::Edit' }

augment 'upgrade' => sub {
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
};

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
