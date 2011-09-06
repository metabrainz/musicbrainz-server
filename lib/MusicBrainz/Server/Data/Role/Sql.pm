package MusicBrainz::Server::Data::Role::Sql;
use Moose::Role;
use namespace::autoclean;

with 'MusicBrainz::Server::Data::Role::Context';

sub sql {
    my $self = shift;
    $DB::single=1;
    my $t = $self->c->sql;
    $DB::single=1;
    return $t;
}

sub _dbh
{
    shift->c->dbh;
}

1;
