package MusicBrainz::Script::RebuildCoverArt;
use Moose;

use DateTime::Duration;
use MusicBrainz::Server::Context;

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

sub _build_sql
{
    return Sql->new(shift->c->dbh);
}

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

sub run
{
    my $self = shift;

    my $releases = $self->c->model('CoverArt')->find_outdated_releases($self->since);

    my $completed = 0;
    my $total = @$releases;
    my $started_at = DateTime->now;

    printf STDERR "There are %d releases to update\n", $total;

    $self->sql->begin;
    while (DateTime::Duration->compare(DateTime->now() - $started_at, $self->max_run_time) == -1 &&
               (my $row = shift @$releases))
    {
        $self->c->model('CoverArt')->cache_cover_art($row->{release}, $row->{link_type}, $row->{url});
        if ($completed++ % 10 == 0) {
            printf STDERR "%d/%d\r", $completed, $total;
        }
    }
    $self->sql->finish;
    $self->sql->commit;

    printf STDERR "Processed %d, %d still need to be updated\n", $completed, $total - $completed;
    return 0;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
