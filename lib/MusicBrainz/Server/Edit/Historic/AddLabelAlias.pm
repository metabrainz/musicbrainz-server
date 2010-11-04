package MusicBrainz::Server::Edit::Historic::AddLabelAlias;
use strict;
use warnings;

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub ngs_class { 'MusicBrainz::Server::Edit::Label::AddAlias' }
sub edit_type { 60 }
sub edit_name { 'Add label alias' }

sub do_upgrade {
    my $self = shift;
    return {
        name      => $self->new_value,
        entity_id => $self->row_id
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
