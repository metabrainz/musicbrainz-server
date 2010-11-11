package MusicBrainz::Server::Edit::Historic::EditLabelAlias;
use Moose;

use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';
with 'MusicBrainz::Server::Edit::Historic::NoSerialization';

sub edit_name { l('Edit label alias') }
sub edit_type { 61 }
sub ngs_class { 'MusicBrainz::Server::Edit::Label::EditAlias' }

augment 'upgrade' => sub
{
    my $self = shift;
    return {
        alias_id  => $self->row_id,
        entity_id => $self->label_id_from_alias($self->row_id) || 0,
        old       => { name => $self->previous_value },
        new       => { name => $self->new_value }
    }
};

no Moose;
__PACKAGE__->meta->make_immutable;
1;
