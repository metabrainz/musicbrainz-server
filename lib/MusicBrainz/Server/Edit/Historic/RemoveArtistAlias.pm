package MusicBrainz::Server::Edit::Historic::RemoveArtistAlias;
use Moose;

use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub ngs_class { 'MusicBrainz::Server::Edit::Artist::DeleteAlias' }
sub edit_type { 14 }
sub edit_name { l('Remove artist alias') }

augment 'upgrade' => sub {
    my $self = shift;
    return {
        entity_id => $self->artist_id,
        alias_id  => $self->row_id,
        name      => $self->previous_value
    }
};

sub deserialize_previous_value { my $self = shift; return shift; }
sub deserialize_new_value      { my $self = shift; return shift; }

no Moose;
__PACKAGE__->meta->make_immutable;
1;
