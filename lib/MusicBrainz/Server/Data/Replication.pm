package MusicBrainz::Server::Data::Replication;
use Moose;
use namespace::autoclean;

use DateTime::Format::Pg;
use MusicBrainz::Server::Types qw( to_DateTime );

with 'MusicBrainz::Server::Data::Role::Sql';

sub last_replication_date {
    my $self = shift;

    return to_DateTime(
        $self->sql->select_single_value(
            'SELECT last_replication_date FROM replication_control'
        )
    );

}

__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

