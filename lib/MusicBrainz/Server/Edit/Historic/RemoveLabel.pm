package MusicBrainz::Server::Edit::Historic::RemoveLabel;
use Moose;

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';
use MusicBrainz::Server::Translation qw ( l ln );

sub ngs_class { 'MusicBrainz::Server::Edit::Label::Delete' }
sub edit_type { 56 }
sub edit_name { l('Remove label') }

sub _build_related_entities {
    my $self = shift;
    return {
        label => [ $self->data->{entity_id} ]
    }
}

sub do_upgrade {
    my $self = shift;
    return {
        entity_id => $self->row_id,
        name      => $self->previous_value
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
