package MusicBrainz::Server::Data::Role::Sql;
use Moose::Role;
use namespace::autoclean;

with 'MusicBrainz::Server::Data::Role::Context';

sub sql {
    my $self = shift;
    return $self->c->sql;
}

sub ro_sql { shift->c->ro_connector->sql }

sub prefer_ro_sql { shift->c->prefer_ro_sql }

1;
