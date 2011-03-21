package MusicBrainz::Server::Edit::Historic::AddArtistAlias;
use strict;
use warnings;

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';
use MusicBrainz::Server::Translation qw ( l ln );

sub edit_name { l('Add artist alias') }
sub edit_type { 15 }
sub ngs_class { 'MusicBrainz::Server::Edit::Artist::AddAlias' }

sub related_entities {
    my $self = shift;
    return {
        artist => [ $self->data->{entity_id} ]
    }
}

sub do_upgrade {
    my $self = shift;
    return {
        name      => $self->new_value,
        entity    => {
            id   => $self->row_id,
            name => $self->previous_value
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
