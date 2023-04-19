package MusicBrainz::Script::RemoveEmpty;
use Moose;

use DBDefs;
use List::AllUtils qw( any );
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw(
    %ENTITIES
    $EDITOR_MODBOT
    $STATUS_OPEN
    $EDIT_ARTIST_DELETE
    $EDIT_EVENT_DELETE
    $EDIT_LABEL_DELETE
    $EDIT_PLACE_DELETE
    $BOT_FLAG
    $AUTO_EDITOR_FLAG
    $EDIT_WORK_DELETE
    $EDIT_RELEASEGROUP_DELETE
    $EDIT_SERIES_DELETE
);
use MusicBrainz::Server::Log qw( log_info );
use MusicBrainz::Server::Data::Utils qw( localized_note type_to_model );
use MusicBrainz::Server::Data::Utils::Cleanup qw( used_in_relationship );
use MusicBrainz::Server::Translation qw( N_l );

with 'MooseX::Runnable';
with 'MooseX::Getopt';
with 'MusicBrainz::Script::Role::Context';

my %edit_class = (
    artist => $EDIT_ARTIST_DELETE,
    event => $EDIT_EVENT_DELETE,
    label => $EDIT_LABEL_DELETE,
    place => $EDIT_PLACE_DELETE,
    release_group => $EDIT_RELEASEGROUP_DELETE,
    work => $EDIT_WORK_DELETE,
    series => $EDIT_SERIES_DELETE,
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

    my $info;
    unless (defined $entity &&
            defined $ENTITIES{$entity} &&
            defined $ENTITIES{$entity}{removal} &&
            ($info = $ENTITIES{$entity}{removal}{automatic})) {
        $self->usage;
        exit 1;
    }

    log_info { "Finding unused entities of type '$entity'" };

    my $used_in_relationship = used_in_relationship($self->c, $entity => 'T.id');
    my $used_in_extra_fks = '';
    while (my ($fk_table, $fk_column) = each %{ $info->{extra_fks} // {} }) {
        $used_in_extra_fks .= "OR EXISTS (
            SELECT 1
              FROM $fk_table F
             WHERE F.$fk_column = T.id
        ) ";
    }
    my $query =
        "SELECT id
         FROM $entity T
         WHERE edits_pending = 0
           AND (last_updated < now() - '2 day'::interval OR last_updated IS NULL)
           AND NOT (
               EXISTS (
                   SELECT 1
                     FROM edit_$entity E
                     JOIN edit ON edit.id = E.edit
                    WHERE edit.status = $STATUS_OPEN
                      AND E.$entity = T.id
               )
               OR $used_in_relationship
               $used_in_extra_fks
           )";

    my ($count, $removed) = (0, 0);
    my @entities = values %{
        $self->c->model(type_to_model($entity))->get_by_ids(
            @{ $self->c->sql->select_single_column_array($query) }
        )
    };
    my $modbot = $self->c->model('Editor')->get_by_id($EDITOR_MODBOT);

    for my $e (@entities) {
        next if any { $e->id == $_ } @{ $info->{exempt} // [] };
        ++$count;

        if ($self->dry_run) {
            log_info { sprintf "Need to remove $entity gid=%s name=%s",
                $e->id, $e->name }
                    if $self->verbose;

        }
        else {
            if ($entity eq 'url') {
                Sql::run_in_transaction(sub {
                    $self->c->model('URL')->delete($e->id);
                    ++$removed
                }, $self->c->sql);
            } else {
                Sql::run_in_transaction(sub {
                    my $edit = $self->c->model('Edit')->create(
                        edit_type => $edit_class{$entity},
                        to_delete => $e,
                        editor => $modbot,
                        privileges => $BOT_FLAG | $AUTO_EDITOR_FLAG
                    );

                    $self->c->model('EditNote')->add_note(
                        $edit->id,
                        {
                            editor_id => $EDITOR_MODBOT,
                            text => localized_note(
                                N_l('This entity was automatically removed because it was empty: ' .
                                    'it had no relationships associated with it, nor (if ' .
                                    'relevant for the type of entity in question) any recordings, ' .
                                    'releases nor release groups. ' .
                                    'If you consider this was a valid, non-duplicate entry ' .
                                    'that does belong in MusicBrainz, feel free to add it again, ' .
                                    'but please ensure enough data is added to it this time ' .
                                    'to avoid another automatic removal.')
                            )
                        }
                    );

                    ++$removed
                }, $self->c->sql);
            }
        }
    }

    if ($self->summary) {
        log_info { sprintf "Found %d unused $entity%s.",
            $count, ($count==1 ? '' : 's') };
        log_info { sprintf "Successfully removed %d $entity%s",
            $removed, ($removed==1 ? '' : 's') }
                if !$self->dry_run;
    }
}

1;
