package MusicBrainz::Server::Report::LicenseLinks ;
use Moose;

with 'MusicBrainz::Server::Report::URLReport';

sub query {
    my ($self) = @_;

    my @tables = $self->c->model('Relationship')->generate_table_list('url');

    my $inner_table = join(
        ' UNION ',
        map {<<~"SQL"} @tables,
            SELECT link_type.id AS link_type_id,
                   link_type.gid AS link_type_gid,
                   l_table.id AS rel_id,
                   ${\$_->[1]} AS url
              FROM link_type
              JOIN link ON link.link_type = link_type.id
              JOIN ${\$_->[0]} l_table ON l_table.link = link.id
            SQL
    );

    my $query = <<~"SQL";
          SELECT url.id AS url_id,
                 count(*) AS count,
                 row_number() OVER (ORDER BY count(*) ASC, url.id DESC)
            FROM url
            JOIN ($inner_table) l ON l.url = url.id
           WHERE l.link_type_gid IN (
            '004bd0c3-8a45-4309-ba52-fa99f3aa3d50', -- release license
            'f25e301d-b87b-4561-86a0-5d2df6d26c0a', -- recording license
            '770ea9f4-cba0-4194-b77f-fe2740055e34' -- work license
                 )
        GROUP BY url_id
        SQL

    return $query;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
