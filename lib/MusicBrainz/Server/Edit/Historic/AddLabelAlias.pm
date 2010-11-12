package MusicBrainz::Server::Edit::Historic::AddLabelAlias;
use Moose;

use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';
with 'MusicBrainz::Server::Edit::Historic::NoSerialization';

sub edit_name { l('Add label alias') }
sub edit_type { 60 }
sub ngs_class { 'MusicBrainz::Server::Edit::Label::AddAlias' }

augment 'upgrade' => sub {
    my $self = shift;
    return {
        name      => $self->new_value,
        entity_id => $self->row_id
    };
};

no Moose;
__PACKAGE__->meta->make_immutable;
1;
