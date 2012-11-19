package MusicBrainz::Script::RebuildCoverArt;
use Moose;

use DBDefs;
use DateTime::Duration;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Log qw( log_debug log_warning log_notice );

with 'MooseX::Runnable';
with 'MooseX::Getopt';
with 'MusicBrainz::Script::Role::Context';

has 'since' => (
    isa      => 'DateTime::Duration',
    is       => 'ro',
    required => 1,
    traits   => [ 'NoGetopt' ],
    default  => sub { DateTime::Duration->new( weeks => 2 ) }
);

has 'max_run_time' => (
    isa      => 'DateTime::Duration',
    is       => 'ro',
    required => 1,
    traits   => [ 'NoGetopt' ],
    default  => sub { DateTime::Duration->new( minutes => 10 ) }
);

sub ensure_release_cover_art {
    my ($self) = @_;
    $self->c->sql->auto_commit;
    $self->c->sql->do(
        'INSERT INTO release_coverart (id)
         SELECT id FROM release WHERE NOT EXISTS (
             SELECT TRUE FROM release_coverart WHERE id = release.id
         )'
    );
}

sub run
{
    my $self = shift;

    printf STDERR "You do not have both AWS_PUBLIC and AWS_PRIVATE defined in DBDefs.\n" .
        "You will not be able to find artwork from Amazon until these are set."
            unless (DBDefs->AWS_PUBLIC && DBDefs->AWS_PRIVATE);

    $self->ensure_release_cover_art;

    my @releases = $self->c->model('CoverArt')->find_outdated_releases($self->since);

    my $completed = 0;
    my $total = @releases;
    my $started_at = DateTime->now;

    my %seen;

    my ($first, $last, $seen, $updated);

    while (DateTime::Duration->compare(DateTime->now() - $started_at, $self->max_run_time) == -1 &&
               (my $release = shift @releases))
    {
        $release = $release->();
        next if $seen{$release->id};

        $seen++;
        $first //= $release->cover_art->last_updated;
        $last = $release->cover_art->last_updated;

        $self->sql->begin;
        my $art = $self->c->model('CoverArt')->cache_cover_art($release);
        $self->sql->commit;

        if ($art) {
            log_debug { sprintf "Cover art for %d is %s", $release->id, $art->image_uri };
            $updated++;
        }
        else {
            log_warning { sprintf "Could not find cover art for %d", $release->id };
        }

        $seen{$release->id} = 1;
        if ($completed++ % 10 == 0) {
            printf STDERR "%d/%d\r", $completed, $total;
        }
    }
    $self->sql->finish;

    log_notice {
        sprintf "Examined %d (%.2f%%) cover art rows, last updated between %s and %s. ".
                "Updated %d releases.",
                $seen,
                ($seen / $total) * 100,
                ($first // "(never updated)"), ($last // "(never updated)"),
                $updated
        };

    log_notice {
        sprintf "A complete pass of all %d releases will take up to approximately %.2f days.",
            $total, (((($total * 2) / 60) / 60) / 24)
        };

    return 0;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
