package MusicBrainz::Server::Edit::Historic::AddArtistAlias;
use Moose;

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';
with 'MusicBrainz::Server::Edit::Historic::NoSerialization';

sub ngs_class { 'MusicBrainz::Server::Edit::Artist::AddAlias' }
sub edit_type { 15 }
sub edit_name { 'Add artist alias' }

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
