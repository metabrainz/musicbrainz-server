package MusicBrainz::Server::Connector;
use Moose;

use DBIx::Connector;
use Sql;

has 'conn' => (
    isa        => 'DBIx::Connector',
    is         => 'ro',
    handles    => [qw( dbh )],
    lazy_build => 1,
    clearer => '_clear_conn'
);

has 'database' => (
    isa => 'MusicBrainz::Server::Database',
    is  => 'rw',
);

has 'sql' => (
    is => 'ro',
    default => sub {
        my $self = shift;
        Sql->new( $self->conn )
    },
    lazy => 1,
    clearer => '_clear_sql'
);

sub _build_conn
{
    my ($self) = @_;

    my $dsn = 'dbi:Pg:dbname=' . $self->database->database;
    $dsn .= ';host=' . $self->database->host if $self->database->host;
    $dsn .= ';port=' . $self->database->port if $self->database->port;

    my $db = $self->database;
    my $conn = DBIx::Connector->new($dsn, $db->username, $db->password, {
        pg_enable_utf8    => 1,
        pg_server_prepare => 0, # XXX Still necessary?
        HandleError       => sub {
            my ($msg, $h) = @_;
            my $state = $h->state;
            my $exception = 'MusicBrainz::Server::Exceptions::DatabaseError';
            $exception .= '::StatementTimedOut'
                if $state eq '57014';
            $exception->throw( sqlstate => $state, message => $msg );
        },
        RaiseError        => 0,
        PrintError        => 0,
    });

    # Make sure we notice the DB going down and attempt to reconnect
    $conn->mode('fixup');

    return $conn;
}

sub _disconnect {
    my ($self) = @_;
    if (my $conn = $self->conn) {
        $conn->disconnect;
    }

    $self->_clear_conn;
    $self->_clear_sql;
}

sub disconnect {
    my $self = shift;
    $self->_disconnect
}

sub refresh {
    my $self = shift;
    $self->disconnect;
    # A connection will be established on demand
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
