package MusicBrainz::Server::Data::Role::Sql;
use Moose::Role;
use namespace::autoclean;

with 'MusicBrainz::Server::Data::Role::Context';

has 'sql' => (
    isa => 'Sql',
    is  => 'ro',
    lazy_build => 1
);

sub _build_sql {
    my $self = shift;
    return Sql->new($self->_dbh);
}

sub _dbh
{
    shift->c->dbh;
}

1;
