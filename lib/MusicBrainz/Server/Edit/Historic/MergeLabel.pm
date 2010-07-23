package MusicBrainz::Server::Edit::Historic::MergeLabel;
use Moose;

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_type { 58 }
sub edit_name { 'Merge labels' }
sub ngs_class { 'MusicBrainz::Server::Edit::Label::Merge' }

augment 'upgrade' => sub
{
    my $self = shift;
    return {
        new_entity   => { id => $self->new_value->{LabelId}, name => $self->new_value->{LabelName} },
        old_entities => [ { id => $self->row_id, name => $self->previous_value } ],
    };
};

sub deserialize_previous_value { my $self = shift; return shift; }

no Moose;
__PACKAGE__->meta->make_immutable;
1;
