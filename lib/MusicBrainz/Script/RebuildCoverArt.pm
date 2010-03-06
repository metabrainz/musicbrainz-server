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

    my $started_at = DateTime->now;
    $self->sql->begin;
    while (DateTime::Duration->compare(DateTime->now() - $started_at, $self->max_run_time) == -1 &&
               (my $row = shift @$releases))
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
