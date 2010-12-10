package MusicBrainz::Server::Controller::ReleaseEditor::Edit;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::ReleaseEditor' }

use aliased 'MusicBrainz::Server::Wizard::ReleaseEditor::Edit'
    => 'ReleaseEditor';

sub edit : Chained('/release/load') Edit RequireAuth
{
    my ($self, $c) = @_;
    my $release = $c->stash->{release};
    ReleaseEditor->new(
        c => $c,
        release => $release
    )->run($c, $release);
}

1;
