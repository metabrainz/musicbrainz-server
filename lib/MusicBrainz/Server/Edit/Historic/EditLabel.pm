package MusicBrainz::Server::Edit::Historic::EditLabel;
use strict;
use warnings;

use MusicBrainz::Server::Data::Utils qw( remove_equal );
use MusicBrainz::Server::Translation qw ( l ln );

use base 'MusicBrainz::Server::Edit::Historic::Label';

sub edit_name { l('Edit label') }
sub edit_type { 55 }
sub ngs_class { 'MusicBrainz::Server::Edit::Label::Edit' }

sub related_entities {
    my $self = shift;
    return {
        label => [ $self->row_id ]
    }
}

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
