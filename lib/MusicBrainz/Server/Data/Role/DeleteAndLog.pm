package MusicBrainz::Server::Data::Role::DeleteAndLog;
use MooseX::Role::Parameterized;
use namespace::autoclean;

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

        my $query = "DELETE FROM $table WHERE id IN (" .placeholders(@ids) . ")
                     RETURNING gid AS entity_gid, id AS entity_id, name AS last_known_name";
        $query .= ", comment AS last_known_comment"
            if $ENTITIES{$type}{disambiguation};

        my @deleted =
            map {
                my $gid = $_->{entity_gid};
                $_->{entity_type} = $type;
                {
                    gid => $gid,
                    data => JSON::XS->new->utf8->encode($_),
                }
            }
            @{ $self->sql->select_list_of_hashes($query, @ids) };
        $self->sql->insert_many("deleted_entity", @deleted);

        return [ map { $_->{gid} } @deleted ];
    };
};

no Moose::Role;
1;
