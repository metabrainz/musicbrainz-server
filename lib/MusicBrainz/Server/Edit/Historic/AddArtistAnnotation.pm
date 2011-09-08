package MusicBrainz::Server::Edit::Historic::AddArtistAnnotation;
use Moose;

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';
use MusicBrainz::Server::Translation qw ( l ln );

sub edit_name { l('Add artist annotation') }
sub edit_type { 30 }
sub ngs_class { 'MusicBrainz::Server::Edit::Artist::AddAnnotation' }

sub _build_related_entities {
    my $self = shift;
    return {
        artist => [ $self->artist_id ]
    }
}

sub do_upgrade
{
    my $self = shift;
    return {
        editor_id => $self->editor_id,
        text      => $self->new_value->{Text},
        changelog => $self->new_value->{ChangeLog},
        entity    => {
            id   => $self->artist_id,
            name => '[removed]'
        }
    }
};

sub extra_parameters
{
    my $self = shift;
    return (
        annotation_id => $self->resolve_annotation_id($self->id) || 0
    );
}

1;
