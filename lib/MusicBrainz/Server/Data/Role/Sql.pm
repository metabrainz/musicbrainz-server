package MusicBrainz::Server::Data::Role::Sql;
use Moose::Role;

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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
