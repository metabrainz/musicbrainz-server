package MusicBrainz::Server::Connector;
use Moose;

use DBIx::Connector;
use Sql;

sub _schema { shift->database->schema }

has 'conn' => (
    isa        => 'DBIx::Connector',
    is         => 'ro',
    handles    => [qw( dbh )],
    lazy_build => 1,
);

has 'database' => (
    isa => 'MusicBrainz::Server::Database',
    is  => 'rw',
);

has 'sql' => (
    is => 'ro',
    default => sub {
        my $self = shift;
        Sql->new($self->dbh)
    },
    lazy => 1
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
        RaiseError        => 1,
        PrintError        => 0,
    });

    $conn->run(sub {
        my $sql = Sql->new($_);
        $sql->auto_commit(1);
        $sql->do("SET TIME ZONE 'UTC'");
        $sql->auto_commit(1);
        $sql->do("SET CLIENT_ENCODING = 'UNICODE'");

        if (my $schema = $self->_schema) {
            $sql->auto_commit(1);
            $sql->do("SET search_path=$schema");
        }
    });

    return $conn;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
