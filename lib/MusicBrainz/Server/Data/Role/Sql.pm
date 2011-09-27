package MusicBrainz::Server::Data::Role::Sql;
use Moose::Role;
use namespace::autoclean;

with 'MusicBrainz::Server::Data::Role::Context';

sub sql {
    my $self = shift;
    return $self->c->sql;
}

sub _dbh
{
    shift->c->dbh;
}

1;
