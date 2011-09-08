package MusicBrainz::Server::Edit::Historic::AddLabelAlias;
use Moose;

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';
use MusicBrainz::Server::Translation qw ( l ln );

sub edit_name { l('Add label alias') }
sub edit_type { 60 }
sub ngs_class { 'MusicBrainz::Server::Edit::Label::AddAlias' }

sub _build_related_entities {
    my $self = shift;
    return {
        label => [ $self->row_id ]
    }
}

sub do_upgrade {
    my $self = shift;
    return {
        name      => $self->new_value,
        entity    => {
            name => $self->previous_value,
            id   => $self->row_id
        }
    };
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
