package MusicBrainz::Server::Edit::Historic::EditURL;
use strict;
use warnings;

use MusicBrainz::Server::Data::Utils qw( remove_equal );
use MusicBrainz::Server::Translation qw ( l ln );

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_name { l('Edit url') }
sub edit_type { 59 }
sub ngs_class { 'MusicBrainz::Server::Edit::URL::Edit' }

sub _build_related_entities {
    my $self = shift;
    return {
        url => [ $self->data->{entity}{id} ]
    }
}

sub do_upgrade
{
    my $self = shift;

    my $old = {
        url         => $self->previous_value->{URL},
        description => $self->previous_value->{Desc}
    };

    my $new = {
        url         => $self->new_value->{URL},
        description => $self->new_value->{Desc}
    };

    remove_equal($old, $new);

    return {
        entity => {
            id => $self->resolve_url_id($self->row_id),
            name => '[removed]'
        },
        new => $new,
        old => $old
    }
};

1;
