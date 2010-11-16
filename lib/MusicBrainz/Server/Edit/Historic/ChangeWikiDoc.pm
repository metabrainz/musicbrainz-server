package MusicBrainz::Server::Edit::Historic::ChangeWikiDoc;
use Moose;

use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_name { l('Change wikidoc') }
sub edit_type { 48 }
sub ngs_class { 'MusicBrainz::Server::Edit::WikiDoc::Change' }

augment 'upgrade' => sub
{
    my $self = shift;
    return {
        page        => $self->previous_value->{Page},
        old_version => $self->previous_value->{Rev},
        new_version => $self->new_value->{Rev}
    }
};

no Moose;
__PACKAGE__->meta->make_immutable;
1;
