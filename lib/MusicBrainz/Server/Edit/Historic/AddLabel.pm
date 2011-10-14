package MusicBrainz::Server::Edit::Historic::AddLabel;
use Moose;

extends 'MusicBrainz::Server::Edit::Historic::Label';
use MusicBrainz::Server::Translation qw ( l ln );

sub _build_related_entities {
    my $self = shift;
    return {
        label => [ $self->row_id ]
    }
}

sub edit_name { l('Add label') }
sub edit_type { 54 }
sub ngs_class { 'MusicBrainz::Server::Edit::Label::Create' }

sub do_upgrade
{
    my $self = shift;
    return $self->upgrade_hash($self->new_value);
};

sub extra_parameters
{
    my $self = shift;
    return ( entity_id => $self->row_id );
};

1;
