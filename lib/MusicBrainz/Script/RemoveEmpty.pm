package MusicBrainz::Script::RemoveEmpty;
use Moose;

use DBDefs;
use List::AllUtils qw( any );
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants
    qw( $EDITOR_MODBOT $VARTIST_ID $DARTIST_ID $DLABEL_ID $EDIT_ARTIST_DELETE
        $EDIT_LABEL_DELETE $BOT_FLAG $AUTO_EDITOR_FLAG $EDIT_WORK_DELETE $EDIT_RELEASEGROUP_DELETE );
use MusicBrainz::Server::Log qw( log_debug log_warning log_notice );
use MusicBrainz::Server::Data::Utils qw( type_to_model );

with 'MooseX::Runnable';
with 'MooseX::Getopt';
with 'MusicBrainz::Script::Role::Context';

my %entity_query_map = (
    artist => 'SELECT * FROM empty_artists()',
    label => 'SELECT * FROM empty_labels()',
    release_group => 'SELECT * FROM empty_release_groups()',
    work => 'SELECT * FROM empty_works()',
);

my %skip_ids = (
    artist => [ $VARTIST_ID, $DARTIST_ID ],
    label => [ $DLABEL_ID ],
    release_group => [],
    work => []
);

my %edit_class = (
    artist => $EDIT_ARTIST_DELETE,
    label => $EDIT_LABEL_DELETE,
    release_group => $EDIT_RELEASEGROUP_DELETE,
    work => $EDIT_WORK_DELETE,
);

has dry_run => (
    isa => 'Bool',
    is => 'ro',
    default => 0,
    traits => [ 'Getopt' ],
    cmd_flag => 'dry-run'
);

has summary => (
    isa => 'Bool',
    is => 'ro',
    default => 1,
);

has verbose => (
    isa => 'Bool',
    is => 'ro',
    default => 0,
);

sub run {
    my ($self, $entity) = @_;
    my $query = $entity_query_map{$entity} or $self->usage, exit 1;

    print localtime() . " : Finding unused entities of type '$entity'\n";

    my ($count, $removed) = (0, 0);
    my @entities = values %{
        $self->c->model(type_to_model($entity))->get_by_ids(
            @{ $self->c->sql->select_single_column_array($query) }
        )
    };

    for my $e (@entities) {
        next if any { $e->id == $_ } @{ $skip_ids{$entity} // [] };
        ++$count;

        if ($self->dry_run) {
            printf "%s : Need to remove $entity gid=%s name=%s\n",
                scalar localtime, $e->id, $e->name
                    if $self->verbose;

        }
        else {
            Sql::run_in_transaction(sub {
                my $edit = $self->c->model('Edit')->create(
                    edit_type => $edit_class{$entity},
                    to_delete => $e,
                    editor_id => $EDITOR_MODBOT,
                    privileges => $BOT_FLAG | $AUTO_EDITOR_FLAG
                );
                ++$removed
            }, $self->c->sql);
        }
    }

    if ($self->summary) {
        printf "%s : Found %d unused $entity%s.\n",
            scalar localtime,
            $count, ($count==1 ? "" : "s");
        printf "%s : Successfully removed %d $entity%s\n",
            scalar localtime,
            $removed, ($removed==1 ? "" : "s")
                if !$self->dry_run;
    }
}

1;
