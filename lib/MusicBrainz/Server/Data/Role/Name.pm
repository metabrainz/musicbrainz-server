package MusicBrainz::Server::Data::Role::Name;
use MooseX::Role::Parameterized;
use Carp qw( confess );
use Fey::FK;
use Function::Parameters 'f';
use List::Util qw( first );
use List::MoreUtils qw( uniq );
use Moose::Autobox;
use MusicBrainz::Schema qw( schema );

parameter 'name_columns' => (
    default => sub { [qw( name sortname )] }
);

role {
    my $params       = shift;
    my $name_columns = $params->name_columns;

    has 'name_columns' => (
        is      => 'ro',
        lazy    => 1,
        default => sub {
            my $self = shift;
            return {
                $self->_name_constraints->map(f {
                    $_->source_columns->[0]->name =>
                        $_->target_table->column('name');
                })->flatten
            };
        }
    );

    has '_name_table' => (
        is      => 'ro',
        lazy    => 1,
        default => sub {
            my $self = shift;
            return first { defined }
                map { $_->target_table }
                    $self->_name_constraints->flatten;
        }
    );

    has '_name_constraints' => (
        is      => 'ro',
        lazy    => 1,
        default => sub {
            my $self = shift;

            my @fks = $self->table->schema
                ->foreign_keys_for_table($self->table);

            return @fks->grep(f ($fk) {
                my $source_column = $fk->source_columns->[0];
                first { $source_column->name eq $_ } @$name_columns
            })->map(f ($fk) {
                my $source_column = $fk->source_columns->[0];
                Fey::FK->new(
                    source_columns => $fk->source_columns,
                    target_columns => $fk->target_columns->map(f {
                        $_->table->alias($source_column->name)
                            ->column($_->name)
                    })
                )
            });
        }
    );

    around '_build_columns' => sub {
        my $orig = shift;
        my ($self) = @_;
        return $self->$orig->grep(f ($column) {
            !defined first { $_ eq $column->name } @$name_columns;
        });
    };

    around '_select' => sub {
        my $orig = shift;
        my ($self) = @_;
        my $sql = $self->$orig;

        for my $fk ($self->_name_constraints->flatten) {
            my $source_name = $fk->source_columns->[0]->name;
            $sql->select($fk->target_table->column('name')->alias($source_name))
                ->from($self->table, $fk->target_table, $fk);
        }

        return $sql;
    };

    method find_or_insert_names => sub {
        my $self = shift;
        my @names = uniq grep { defined } @_
            or return;

        my $table = $self->_name_table;
        my $query = Fey::SQL->new_select
            ->select($table)->from($table)
            ->where($table->column('name'), 'IN', @names);

        my $found = $self->sql->select_list_of_hashes(
            $query->sql($self->sql->dbh), $query->bind_params);
        my %found_names = map { $_->{name} => $_->{id} } @$found;

        for my $new_name (grep { !exists $found_names{$_} } @names) {
            my $id = $self->sql->insert_row($table->name, {
                    name => $new_name,
                }, 'id');
            $found_names{$new_name} = $id;
        }
        return %found_names;
    };
};

1;
