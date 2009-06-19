package MusicBrainz::Server::Data::Edit;
use Moose;

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

sub insert
{
    my ($self, @edits) = @_;
    my $sql = Sql->new($self->c->raw_dbh);
    for my $edit (@edits)
    {
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
    }
    return @edits > 1 ? @edits : $edits[0];
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

