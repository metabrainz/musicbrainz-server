package MusicBrainz::Server::Data::Edit;
use Moose;

use Carp qw( croak );
use DateTime;
use List::MoreUtils qw( zip );
use MusicBrainz::Server::Edit;
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Types qw( $STATUS_APPLIED $STATUS_ERROR );
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
    my $data = XMLin($row->{data}, SuppressEmpty => 1);

    my $edit = $class->new(
        id => $row->{id},
        yes_votes => $row->{yesvotes},
        no_votes => $row->{novotes},
        editor_id => $row->{editor},
        created_time => $row->{opentime},
        expires_time => $row->{expiretime},
        language_id => $row->{language},
        auto_edit => $row->{autoedit}
    );
    $edit->restore($data);
    $edit->close_time($row->{closetime}) if defined $row->{closetime};
    return $edit;
}

sub create
{
    my ($self, %opts) = @_;
    my $sql = Sql->new($self->c->raw_dbh);

    my $type = delete $opts{edit_type} or croak "edit_type required";
    my $editor_id = delete $opts{editor_id} or croak "editor_id required";
    my $class = MusicBrainz::Server::Edit->class_from_type($type);

    my $edit = $class->new( editor_id => $editor_id, c => $self->c );
    $edit->initialize(%opts);
    $edit->insert;

    # Automatically accept auto-edits on insert
    if($edit->auto_edit)
    {
        my $status = eval { $edit->accept };
        if ($@)
        {
            # XXX Exception classes should specificy the status
            $edit->status($STATUS_ERROR);
        }
        else
        {
            $edit->status($STATUS_APPLIED);
        }
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

    my $edit_id = $sql->InsertRow('edit', $row, 'id');
    $edit->id($edit_id);

    my $ents = $edit->entities;
    for my $type (keys %$ents)
    {
        my @ids = @{ $ents->{$type} };
        my $query = "INSERT INTO edit_$type (edit, $type) VALUES ";
        $query .= ("(?, ?)" x @ids);
        my @all_ids = ($edit_id) x @ids;
        $sql->Do($query, zip @all_ids, @ids); 
    }

    if (defined $edit->entity_model && $edit->entity_id && $edit->is_open)
    {
        my $model = $self->c->model($edit->entity_model);
        $model->does('MusicBrainz::Server::Data::Editable')
            or croak "Model must do MusicBrainz::Server::Data::Editable";
        $model->inc_edits_pending($edit->entity_id);
    }

    return $edit;
}

sub accept
{
    my ($self, $edit) = @_;
    eval { $edit->accept };
    $self->_close($edit => $@ ? $STATUS_ERROR : $STATUS_APPLIED);
}

sub _close
{
    my ($self, $edit, $status) = @_;
    my $sql = Sql->new($self->c->raw_dbh);
    my $query = "UPDATE edit SET status = ? WHERE id = ?";
    $sql->Do($query, $status, $edit->id);

    if (defined $edit->entity_model && $edit->entity_id)
    {
        my $model = $self->c->model($edit->entity_model);
        $model->does('MusicBrainz::Server::Data::Editable')
            or croak "Model must do MusicBrainz::Server::Data::Editable";
        $model->dec_edits_pending($edit->entity_id);
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

