package MusicBrainz::Server::Edit::Historic::EditLabel;
use Moose;

use MusicBrainz::Server::Data::Utils qw( remove_equal );
use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';
with 'MusicBrainz::Server::Edit::Historic::Label';

sub edit_name { l('Edit label') }
sub edit_type { 55 }
sub ngs_class { 'MusicBrainz::Server::Edit::Label::Edit' }

augment 'upgrade' => sub
{
    my $self = shift;

    my $old = $self->upgrade_hash($self->previous_value);
    my $new = $self->upgrade_hash($self->new_value);

    remove_equal($old, $new);

    return {
        entity_id => $self->row_id,
        old => $old,
        new => $new
    };
};

no Moose;
__PACKAGE__->meta->make_immutable;
1;
