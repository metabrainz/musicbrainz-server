package MusicBrainz::Script::NotifyOfNewReleases;
use Moose;
use namespace::autoclean;

use English;

use aliased 'MusicBrainz::Server::Email';

with 'MooseX::Runnable';
with 'MooseX::Getopt';
with 'MusicBrainz::Script::Role::Context';

has 'verbose' => (
    isa => 'Bool',
    is => 'ro',
    default => sub { -t }
);

has 'emailer' => (
    is => 'ro',
    required => 1,
    lazy_build => 1
);

sub _build_emailer {
    my $self = shift;
    return Email->new(c => $self->c);
}

sub run {
    my ($self, @args) = @_;
    die "Usage error ($PROGRAM_NAME takes no extra arguments)" if @args;

    my @editors = $self->c->model('WatchArtist')->find_editors_to_notify;
    for my $editor (@editors) {
        printf "Checking for new releases for %s\n", $editor->name
            if $self->verbose;

        my @releases = $self->c->model('WatchArtist')->find_new_releases(
            $editor->id) or next;

        printf "Notifying %s of new releases:\n%s\n",
            $editor->name,
            join("\n", map { "\t" . $_->name } @releases)
                if $self->verbose;

        $self->emailer->send_new_releases(
            editor => $editor,
            releases => \@releases);
    }
}

__PACKAGE__->meta->make_immutable;
1;
