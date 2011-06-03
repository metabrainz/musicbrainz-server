package MusicBrainz::Server::Edit::Historic::EditLabelAlias;
use strict;
use warnings;

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';
use MusicBrainz::Server::Translation qw ( l ln );

sub edit_name { l('Edit label alias') }
sub edit_type { 61 }
sub ngs_class { 'MusicBrainz::Server::Edit::Label::EditAlias' }

sub related_entities {
    my $self = shift;
    return {
        label => [ $self->data->{entity}{id} ]
    }
}

sub do_upgrade
{
    my $self = shift;
    return {
        alias_id  => $self->row_id,
        entity    => {
            id => $self->label_id_from_alias($self->row_id) || 0,
            name => '[removed]',
        },
        old       => { name => $self->previous_value },
        new       => { name => $self->new_value }
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
