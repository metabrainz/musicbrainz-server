package MusicBrainz::Script::MigrateEdits;
use Moose;

use DBDefs;
use MooseX::Types::Moose qw( Int );
use MusicBrainz::Server::Context;
use TryCatch;

with 'MooseX::Runnable', 'MooseX::Getopt';

has 'c' => (
    traits => [ 'NoGetopt' ],
    is => 'ro',
    lazy_build => 1
);

sub _build_c
{
    return MusicBrainz::Server::Context->create_script_context;
}

has 'migration' => (
    is => 'ro',
    lazy_build => 1
);

sub _build_migration
{
    my $self = shift;
    return $self->c->model('EditMigration');
}

has 'limit' => (
    isa      => Int,
    is       => 'ro',
    required => 1,
    default  => 1000
);

has 'offset' => (
    isa      => Int,
    is       => 'ro',
    required => 1,
    default  => 0
);

sub run
{
    my $self = shift;
    my @upgraded;
    my $sql = Sql->new($self->c->dbh);

    printf "Upgrading edits!\n";
    $sql->select('SELECT * FROM public.moderation_closed LIMIT ? OFFSET ?', $self->limit, $self->offset);

    printf "Here we go!\n";

    my $i = 0;
    while (my $row = $sql->next_row_hash_ref)
    {
        my $historic = $self->migration->_new_from_row($row)
            or next;

        try {
            my $upgraded = $historic->upgrade;
            push @upgraded, $upgraded;

            printf "Upgraded #%d\n", $upgraded->id;
        }
        catch ($err) {
            printf STDERR "Could not upgrade %d\n", $historic->id;
            printf STDERR "$err\n";
        }

        printf "%d\r", $i++;
    }

    my $raw_sql = Sql->new($self->c->raw_dbh);
    $raw_sql->begin;
    $raw_sql->do('TRUNCATE edit CASCADE');
    $raw_sql->do("TRUNCATE edit_$_ CASCADE") for qw( artist label release release_group work recording );

    for my $upgraded (@upgraded) {
        $self->c->model('Edit')->insert($upgraded);
    }

    $raw_sql->commit;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
