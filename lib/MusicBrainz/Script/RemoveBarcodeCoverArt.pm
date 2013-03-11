package MusicBrainz::Script::RemoveBarcodeCoverArt;
use Moose;

use DBDefs;
use DateTime::Duration;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Log qw( log_debug log_notice );
use MusicBrainz::Server::Data::Utils qw( placeholders query_to_list );

with 'MooseX::Runnable';
with 'MooseX::Getopt';
with 'MusicBrainz::Script::Role::Context';

sub find_releases
{
    my ($self) = @_;

    my @url_types = $self->handled_types;

    # Find all releases that have a cover art URL but no URL relationship
    # that would explain it.
    my $query = "
      SELECT r_id
      FROM (
        SELECT
          release.id AS r_id,
          array_agg(link_type.name) url_link_types
        FROM release
        JOIN release_coverart USING (id)
        LEFT JOIN l_release_url ON (release.id = l_release_url.entity0)
        LEFT JOIN link ON (l_release_url.link = link.id)
        LEFT JOIN link_type ON (link.link_type = link_type.id)
        WHERE cover_art_url IS NOT NULL AND cover_art_url != ''
        GROUP BY release.id
      ) s
      WHERE NOT (url_link_types && ?);
    ";

    return query_to_list($self->c->sql, sub {
        my $row = shift;
        return sub {
            my $release = $self->c->model('Release')->_new_from_row($row, 'r_');
            $release->cover_art(
                MusicBrainz::Server::CoverArt->new()
            );
            return $release;
        }
    }, $query, \@url_types);
}

sub run
{
    my $self = shift;

    my @releases = find_releases($self->c->model('CoverArt'));

    my $completed = 0;
    my $total = @releases;
    my $started_at = DateTime->now;

    my %seen;

    my $seen = 0;
    my $removed = 0;

    while (my $release = shift @releases)
    {
        $release = $release->();
        next if $seen{$release->id};

        $seen++;

        $self->sql->begin;
        $self->c->model('CoverArt')->cache_cover_art($release);
        $self->sql->commit;

        log_debug { sprintf "Cover art removed for %d", $release->id };
        $removed++;

        $seen{$release->id} = 1;
        if ($completed++ % 10 == 0) {
            printf STDERR "%d/%d\r", $completed, $total;
        }
    }
    $self->sql->finish;

    log_notice {
        sprintf "Examined %d (%.2f%%) releases, removed %d cover art urls.",
                $seen,
                $total != 0 ? ($seen / $total) * 100 : 100,
                $removed
        };

    return 0;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
