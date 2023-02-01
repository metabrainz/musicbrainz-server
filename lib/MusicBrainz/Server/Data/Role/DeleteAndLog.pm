package MusicBrainz::Server::Data::Role::DeleteAndLog;
use MooseX::Role::Parameterized;
use namespace::autoclean;

use 5.18.2;

use MusicBrainz::Server::Constants qw( %ENTITIES );
use MusicBrainz::Server::Data::Utils qw( placeholders );
use JSON::XS;

parameter 'type' => (
    isa => 'Str',
    required => 1,
);

role {
    my $params = shift;
    my $type = $params->type;

    around delete_returning_gids => sub {
        my ($orig, $self, @ids) = @_;

        my $table = $self->_main_table;

        my $query = "DELETE FROM $table WHERE id IN (" .placeholders(@ids) . ')
                     RETURNING gid AS entity_gid, id AS entity_id, name AS last_known_name';
        $query .= ', comment AS last_known_comment'
            if $ENTITIES{$type}{disambiguation};

        state $json = JSON::XS->new;

        my @deleted =
            map {
                my $gid = $_->{entity_gid};
                $_->{entity_type} = $type;
                {
                    gid => $gid,
                    data => $json->encode($_),
                }
            }
            @{ $self->sql->select_list_of_hashes($query, @ids) };
        $self->sql->insert_many('deleted_entity', @deleted);

        return [ map { $_->{gid} } @deleted ];
    };
};

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
