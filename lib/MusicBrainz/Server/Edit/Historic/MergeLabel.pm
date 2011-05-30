package MusicBrainz::Server::Edit::Historic::MergeLabel;
use strict;
use warnings;

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';
use MusicBrainz::Server::Translation qw ( l ln );

sub edit_type { 58 }
sub edit_name { l('Merge labels') }
sub ngs_class { 'MusicBrainz::Server::Edit::Label::Merge' }

sub related_entities {
    my $self = shift;
    return {
        label => [
            $self->data->{new_entity}{id},
            map { $_->{id} } @{ $self->data->{old_entities} }
        ]
    }
}

sub do_upgrade
{
    my $self = shift;
    return {
        new_entity   => { id => $self->new_value->{LabelId}, name => $self->new_value->{LabelName} },
        old_entities => [ { id => 0, name => $self->previous_value } ],
    };
}

sub deserialize_previous_value { my $self = shift; return shift; }

1;
