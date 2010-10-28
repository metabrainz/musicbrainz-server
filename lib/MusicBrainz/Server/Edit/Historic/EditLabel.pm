package MusicBrainz::Server::Edit::Historic::EditLabel;
use strict;
use warnings;

use MusicBrainz::Server::Data::Utils qw( remove_equal );

use base 'MusicBrainz::Server::Edit::Historic::Label';

sub edit_type { 55 }
sub edit_name { 'Edit label' }
sub ngs_class { 'MusicBrainz::Server::Edit::Label::Edit' }

sub do_upgrade
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
}

1;
