package MusicBrainz::Server::Edit::Historic::ChangeWikiDoc;
use Moose;

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';
use MusicBrainz::Server::Translation qw ( l ln );

sub edit_name { l('Change wikidoc') }
sub edit_type { 48 }
sub ngs_class { 'MusicBrainz::Server::Edit::WikiDoc::Change' }

sub do_upgrade
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

1;
