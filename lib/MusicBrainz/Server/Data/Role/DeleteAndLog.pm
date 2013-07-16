package MusicBrainz::Server::Data::Role::DeleteAndLog;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Data::Utils qw( placeholders );

sub delete_returning_gids { }
around delete_returning_gids => sub {
    my ($orig, $self, $table, @ids) = @_;

    my $query = "DELETE FROM $table WHERE id IN (" .placeholders(@ids) . ")
                 RETURNING gid, name AS last_known_name, comment AS last_known_comment";
    my @deleted = @{ $self->sql->select_list_of_hashes($query, @ids) };
    $self->sql->insert_many("${table}_deletion", @deleted);

    return [ map { $_->{gid} } @deleted ];
};

1;
