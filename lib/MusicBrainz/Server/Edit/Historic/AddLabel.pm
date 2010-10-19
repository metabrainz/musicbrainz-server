package MusicBrainz::Server::Edit::Historic::AddLabel;
use Moose;

use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';
with 'MusicBrainz::Server::Edit::Historic::Label';

sub edit_name { l('Add label') }
sub edit_type { 54 }
sub ngs_class { 'MusicBrainz::Server::Edit::Label::Create' }

augment 'upgrade' => sub
{
    my $self = shift;
    return $self->upgrade_hash($self->new_value);
};

sub extra_parameters
{
    my $self = shift;
    return ( entity_id => $self->row_id );
};

no Moose;
__PACKAGE__->meta->make_immutable;
1;
