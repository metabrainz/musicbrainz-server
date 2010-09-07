package MusicBrainz::Server::Edit::Historic::EditURL;
use Moose;
use MusicBrainz::Server::Data::Utils qw( remove_equal );

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_name { 'Edit url' }
sub edit_type { 59 }
sub ngs_class { 'MusicBrainz::Server::Edit::URL::Edit' }

augment 'upgrade' => sub
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
        entity_id => $self->resolve_url_id($self->row_id),
        new => $new,
        old => $old
    }
};

no Moose;
__PACKAGE__->meta->make_immutable;
