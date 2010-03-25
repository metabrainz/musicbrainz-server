package MusicBrainz::Server::Edit::Historic::RemoveLabel;
use Moose;

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';
with 'MusicBrainz::Server::Edit::Historic::NoSerialization';

sub ngs_class { 'MusicBrainz::Server::Edit::Label::Delete' }
sub edit_type { 56 }
sub edit_name { 'Remove label' }

augment 'upgrade' => sub {
    my $self = shift;
    return {
        entity_id => $self->row_id,
        name      => $self->previous_value
    }
};

no Moose;
__PACKAGE__->meta->make_immutable;
1;
