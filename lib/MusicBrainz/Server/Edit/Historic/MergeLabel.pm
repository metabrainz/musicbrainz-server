package MusicBrainz::Server::Edit::Historic::MergeLabel;
use strict;
use warnings;

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_type { 58 }
sub edit_name { 'Merge labels' }
sub ngs_class { 'MusicBrainz::Server::Edit::Label::Merge' }

sub do_upgrade
{
    my $self = shift;
    return {
        new_entity   => { id => $self->new_value->{LabelId}, name => $self->new_value->{LabelName} },
        old_entities => [ { id => $self->row_id, name => $self->previous_value } ],
    };
}

sub deserialize_previous_value { my $self = shift; return shift; }

1;
