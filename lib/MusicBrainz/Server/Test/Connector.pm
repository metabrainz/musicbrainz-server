package MusicBrainz::Server::Test::Connector;
use Moose;
use aliased 'MusicBrainz::Server::DatabaseConnectionFactory' => 'Databases';
use 5.10.0;

extends 'MusicBrainz::Server::Connector';

sub _schema { 'musicbrainz_test,' . Databases->get("READWRITE")->schema; }

# *DISABLE* the thread saftey guarantees that DBIx::Connector provides.
#
# ocharles introduced this bit of horrible code, because of Selenium. When we
# run selenium.t, it forks and starts up a new Catalyst server. This should
# share the same connection as the parent thread, so the parent can set up a
# transaction and test data.
#
# The real solution here is to patch Test::WWW::Selenium::Catalyst so that it
# can have init and tear down functions.

{
    no warnings 'redefine';
    *DBIx::Connector::_seems_connected = sub {
        my $self = shift;

        state $warned_about_insanity;

        if (!$warned_about_insanity) {
            say STDERR "\n" . ("*" x 80);
            say STDERR "WARNING!";
            say STDERR "You are running a MusicBrainz server that does not have thread safety.";
            say STDERR "This is because you have included MusicBrainz::Server::Test::Connector";
            say STDERR "This should *never* *ever* happen on a production server";
            say STDERR ("*" x 80) . "\n";
            $warned_about_insanity = 1;
        }

        my $dbh = $self->{_dbh} or return;
        if ( defined $self->{_tid} && $self->{_tid} != threads->tid ) {
            return;
        }

        # Use FETCH() to avoid death when called from during global destruction.
        return $dbh->FETCH('Active') ? $dbh : undef;
    };
}


__PACKAGE__->meta->make_immutable;
no Moose;

1;

