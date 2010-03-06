package MusicBrainz::Script::RebuildCoverArt;
use Moose;

use DateTime::Duration;
use DateTime::Format::Pg;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Utils qw( placeholders );

with 'MooseX::Runnable';
with 'MooseX::Getopt';

has 'c' => (
    isa        => 'MusicBrainz::Server::Context',
    is         => 'ro',
    traits     => [ 'NoGetopt' ],
    lazy_build => 1,
);

sub _build_c
{
    return MusicBrainz::Server::Context->create_script_context;
}

has 'sql' => (
    isa        => 'Sql',
    is         => 'ro',
    traits     => [ 'NoGetopt' ],
    lazy_build => 1,
);

has 'since' => (
    isa      => 'DateTime::Duration',
    is       => 'ro',
    required => 1,
    traits   => [ 'NoGetopt' ],
    default  => sub { DateTime::Duration->new( weeks => 2 ) }
);

sub _build_sql
{
    return Sql->new(shift->c->dbh);
}


sub run
{
    my $self = shift;

    my @url_types = ('coverart', 'asin');

    my $query = '
        SELECT url.url, l.entity0 AS release, link_type.name AS link_type
          FROM l_release_url l
          JOIN link      ON l.link = link.id
          JOIN link_type ON link.link_type = link_type.id
          JOIN url       ON l.entity1 = url.id
         WHERE l.entity0 IN (
                 SELECT id FROM release_meta
                  WHERE coverfetched IS NULL
                     OR NOW() - coverfetched > ?
             ) AND
               link_type.name IN ('  . placeholders(@url_types) . ')';

    my $pg_date_formatter = DateTime::Format::Pg->new;
    $self->sql->select($query, $pg_date_formatter->format_duration($self->since),
                       @url_types);

    $self->sql->begin;
    while (my $row = $self->sql->next_row_hash_ref)
    {
        my $cover_art =  $self->c->model('CoverArt')->parse_from_type_url($row->{link_type}, $row->{url})
            or next;

        my $update = $cover_art->cache_data;
        $update->{coverfetched} = DateTime->now;

        $self->sql->update_row('release_meta', $update, { id => $row->{release} });
    }
    $self->sql->finish;
    $self->sql->commit;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
