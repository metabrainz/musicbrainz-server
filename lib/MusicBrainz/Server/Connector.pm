package MusicBrainz::Server::Connector;
use Moose;

use DBIx::Connector;
use Sql;

sub _schema { shift->database->schema }

has 'conn' => (
    isa        => 'DBIx::Connector',
    is         => 'ro',
#    handles    => [qw( dbh )],
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
        $DB::single=1;
        # Sql->new($self->dbh)
        Sql->new(
 #           $self->dbh,
            $self->conn,
        )

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

    $DB::single=1;
    $conn->mode('fixup');
    #warn "PEC TODO setting up ping";

    $conn->run(sub {
                   my $dbh = $_;
                   $dbh->do("SET TIME ZONE 'UTC'");
                   $dbh->do("SET CLIENT_ENCODING = 'UNICODE'");

                   if (my $schema = $self->_schema) {
                       $dbh->do("SET search_path=$schema");
                   }
    });

    return $conn;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
