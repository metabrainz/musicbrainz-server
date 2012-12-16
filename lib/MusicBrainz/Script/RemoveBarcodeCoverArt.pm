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

has 'max_run_time' => (
    isa      => 'DateTime::Duration',
    is       => 'ro',
    required => 1,
    traits   => [ 'NoGetopt' ],
    default  => sub { DateTime::Duration->new( minutes => 10 ) }
);

sub find_releases
{
    my ($self) = @_;

    my @url_types = $self->handled_types;

    # Find all releases that have a cover art url and barcode, but no
    # URL relationship that would explain the cover art url.
    my $query = '
        SELECT DISTINCT ON (release.id)
            release.id AS r_id
        FROM release
        JOIN release_coverart ON release.id = release_coverart.id
        LEFT JOIN l_release_url l ON ( l.entity0 = release.id )
        LEFT JOIN link ON ( link.id = l.link )
        LEFT JOIN link_type ON (
          link_type.id = link.link_type AND
          link_type.name IN (' . placeholders(@url_types) . ')
        )
        WHERE link_type.name IS NULL AND release.barcode IS NOT NULL
        ORDER BY release.id';

    return query_to_list($self->c->sql, sub {
        my $row = shift;
        return sub {
            my $release = $self->c->model('Release')->_new_from_row($row, 'r_');
            $release->cover_art(
                MusicBrainz::Server::CoverArt->new()
            );
            return $release;
        }
    }, $query, @url_types);
}

sub run
{
    my $self = shift;

    my @releases = find_releases($self->c->model('CoverArt'));

    my $completed = 0;
    my $total = @releases;
    my $started_at = DateTime->now;

    my %seen;

    my ($seen, $removed);

    while (DateTime::Duration->compare(DateTime->now() - $started_at, $self->max_run_time) == -1 &&
               (my $release = shift @releases))
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
                ($seen / $total) * 100,
                $removed
        };

    return 0;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
