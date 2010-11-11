package MusicBrainz::Server::Edit::Historic::AddLabelAlias;
use strict;
use warnings;

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';
use MusicBrainz::Server::Translation qw ( l ln );

sub edit_name { l('Add label alias') }
sub edit_type { 60 }
sub ngs_class { 'MusicBrainz::Server::Edit::Label::AddAlias' }

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
