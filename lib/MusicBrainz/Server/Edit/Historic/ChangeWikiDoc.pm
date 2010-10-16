package MusicBrainz::Server::Edit::Historic::ChangeWikiDoc;
use Moose;

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_type { 48 }
sub edit_name { 'Change wikidoc' }
sub ngs_class { 'MusicBrainz::Server::Edit::WikiDoc::Change' }

augment 'upgrade' => sub
{
    my $self = shift;
    my $old = $self->previous_value->{Rev};
    $old = $old ? 0 + $old : undef;

    my $new = $self->new_value->{Rev};
    $new = $new ? 0 + $new : undef;

    return {
        page        => $self->previous_value->{Page},
        old_version => $old,
        new_version => $new
    }
};

no Moose;
__PACKAGE__->meta->make_immutable;
1;
