package MusicBrainz::Server::Edit::Historic::EditReleaseGroupName;
use Moose;

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';
use MusicBrainz::Server::Translation qw ( l ln );

sub edit_name { l('Edit release group name') }
sub edit_type { 65 }
sub ngs_class { 'MusicBrainz::Server::Edit::ReleaseGroup::Edit' }

sub _build_related_entities {
    my $self = shift;
    return {
        release_group => [ $self->data->{entity}{id} ]
    }
}

sub do_upgrade
{
    my ($self) = @_;

    return {
        entity => {
            id => $self->row_id,
            name => $self->previous_value,
        },
        old => {
            name => $self->previous_value,
        },
        new => {
            name => $self->new_value
        }
    }
}

sub deserialize_previous_value {
    my ($self, $previous) = @_;
    return $previous;
}

sub deserialize_new_value {
    my ($self, $previous) = @_;
    return $previous;
}

1;
