package MusicBrainz::Server::Data::Edit;
use Moose;

use Carp qw( croak );
use DateTime;
use List::MoreUtils qw( uniq zip );
use MusicBrainz::Server::Edit;
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Types qw( $STATUS_APPLIED $STATUS_ERROR $STATUS_FAILEDVOTE );
use MusicBrainz::Server::Data::Utils qw( placeholders query_to_list_limited );
use XML::Simple;

extends 'MusicBrainz::Server::Data::Entity';

sub _table
{
    return 'edit';
}

sub _columns
{
    return 'id, editor, opentime, expiretime, closetime, data, language, type,
            yesvotes, novotes, autoedit';
}

sub _dbh
{
    return shift->c->raw_dbh;
}

sub _new_from_row
{
    my ($self, $row) = @_;

    # Readd the class marker
    my $class = MusicBrainz::Server::Edit->class_from_type($row->{type})
        or die "Could not look up class for type";
    my $data = XMLin($row->{data}, SuppressEmpty => undef, KeyAttr => [], $class->_xml_arguments);

    my $edit = $class->new(
        id => $row->{id},
        yes_votes => $row->{yesvotes},
        no_votes => $row->{novotes},
        editor_id => $row->{editor},
        created_time => $row->{opentime},
        expires_time => $row->{expiretime},
        auto_edit => $row->{autoedit}
    );
    $edit->language_id($row->{language}) if $row->{language};
    $edit->restore($data);
    $edit->close_time($row->{closetime}) if defined $row->{closetime};
    return $edit;
}

sub get_max_id
{
    my ($self) = @_;

    my $sql = Sql->new($self->c->raw_dbh);
    return $sql->SelectSingleValue("SELECT id FROM edit ORDER BY id DESC
                                    LIMIT 1");
}

sub find
{
    my ($self, $p, $limit, $offset) = @_;

    my (@pred, @args);
    for my $type (qw( artist label release release_group recording work)) {
        next unless exists $p->{$type};
        my $ids = delete $p->{$type};

        my @ids = ref $ids ? @$ids : $ids;
        push @args, @ids;

        my $subquery;
        if (@ids == 1) {
            $subquery = "SELECT edit FROM edit_$type WHERE $type = ?";
        }
        else {
            my $placeholders = placeholders(@ids);
            $subquery = "SELECT edit FROM edit_$type
                          WHERE $type IN ($placeholders) 
                       GROUP BY edit HAVING count(*) = ?";
            push @args, scalar @ids;
        }

        push @pred, "id IN ($subquery)";
    }

    my @params = keys %$p;
    push @pred, "$_ = ?" for @params;
    push @args, $p->{$_} for @params;

    my $query = 'SELECT ' . $self->_columns . ' FROM ' . $self->_table;
    $query .= ' WHERE ' . join ' AND ', @pred if @pred;
    $query .= ' ORDER BY id DESC';

    return query_to_list_limited($self->c->raw_dbh, $offset, $limit, sub {
            return $self->_new_from_row(shift);
        }, $query, @args);
}

sub merge_entities
{
    my ($self, $type, $new_id, @old_ids) = @_;
    my $sql = Sql->new($self->c->raw_dbh);
    $sql->Do("DELETE FROM edit_$type
              WHERE edit IN (SELECT edit FROM edit_$type WHERE $type = ?) AND
                    $type IN (".placeholders(@old_ids).")", $new_id, @old_ids);
    $sql->Do("UPDATE edit_$type SET $type = ?
              WHERE $type IN (".placeholders(@old_ids).")", $new_id, @old_ids);
}

sub create
{
    my ($self, %opts) = @_;
    my $sql = Sql->new($self->c->dbh);
    my $sql_raw = Sql->new($self->c->raw_dbh);

    my $type = delete $opts{edit_type} or croak "edit_type required";
    my $editor_id = delete $opts{editor_id} or croak "editor_id required";
    my $class = MusicBrainz::Server::Edit->class_from_type($type);

    my $edit = $class->new( editor_id => $editor_id, c => $self->c );
    $edit->initialize(%opts);
    
    Sql::RunInTransaction(sub {
        $edit->insert;

        # Automatically accept auto-edits on insert
        if($edit->auto_edit)
        {
            my $st = $self->_do_accept($edit);
            $edit->status($st);
        };

        my $now = DateTime->now;
        my $row = {
            editor => $edit->editor_id,
            data => XMLout($edit->to_hash, NoAttr => 1),
            status => $edit->status,
            type => $edit->edit_type,
            opentime => $now,
            expiretime => $now + $edit->edit_voting_period,
        };

        my $edit_id = $sql_raw->InsertRow('edit', $row, 'id');
        $edit->id($edit_id);

        my $ents = $edit->related_entities;
        while (my ($type, $ids) = each %$ents){
            my $query = "INSERT INTO edit_$type (edit, $type) VALUES ";
            $query .= join ", ", ("(?, ?)") x @$ids;
            my @all_ids = ($edit_id) x @$ids;
            $sql_raw->Do($query, zip @all_ids, @$ids); 
        }

        if ($edit->is_open)
        {
            my $to_inc = $edit->alter_edit_pending;
            while( my ($model_name, $ids) = each %$to_inc) {
                my $model = $self->c->model($model_name);
                $model->does('MusicBrainz::Server::Data::Editable')
                    or croak "Model must do MusicBrainz::Server::Data::Editable";
                $model->inc_edits_pending(@$ids);
            }
        }
    }, $sql, $sql_raw);

    return $edit;
}

sub load_all
{
    my ($self, @edits) = @_;
    my @models = uniq map { @{ $_->models } } @edits;
    for my $model (@models) {
        $self->c->model($model)->load(@edits);
    }
}

sub accept
{
    my ($self, $edit) = @_;
    $self->_close($edit, sub { $self->_do_accept(shift) });
}

sub _do_accept
{
    my ($self, $edit) = @_;
    eval { $edit->accept };
    return $@ ? $STATUS_ERROR : $STATUS_APPLIED;
}

sub reject
{
    my ($self, $edit) = @_;
    $self->_close($edit, sub {
        my $edit = shift;
        eval { $edit->reject };
        return $@ ? $STATUS_ERROR : $STATUS_FAILEDVOTE;
   });
}

sub _close
{
    my ($self, $edit, $close_sub) = @_;
    my $sql = Sql->new($self->c->dbh);
    my $sql_raw = Sql->new($self->c->raw_dbh);
    Sql::RunInTransaction(sub {
        my $status = &$close_sub($edit);
        my $query = "UPDATE edit SET status = ? WHERE id = ?";
        $sql_raw->Do($query, $status, $edit->id);

        my $to_dec = $edit->alter_edit_pending;
        while( my ($model_name, $ids) = each %$to_dec) {
            my $model = $self->c->model($model_name);
            $model->does('MusicBrainz::Server::Data::Editable')
                or croak "Model must do MusicBrainz::Server::Data::Editable";
            $model->dec_edits_pending(@$ids);
        }
    }, $sql, $sql_raw);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

