package MusicBrainz::Server::Data::Utils;

use strict;
use warnings;

use base 'Exporter';
use Carp 'confess';
use Class::MOP;
use Data::Compare;
use Data::UUID::MT;
use Digest::SHA1 qw( sha1_base64 );
use Encode qw( decode encode );
use List::MoreUtils qw( natatime zip );
use MusicBrainz::Server::Constants qw( $DARTIST_ID $VARTIST_ID $DLABEL_ID );
use Readonly;
use Scalar::Util 'blessed';
use Sql;
use Storable;
use Text::Trim qw ();

our @EXPORT_OK = qw(
    add_partial_date_to_row
    artist_credit_to_ref
    check_data
    check_in_use
    copy_escape
    defined_hash
    generate_gid
    hash_structure
    hash_to_row
    insert_and_create
    is_special_artist
    is_special_label
    load_meta
    load_subobjects
    map_query
    merge_table_attributes
    merge_partial_date
    model_to_type
    object_to_ids
    order_by
    partial_date_to_hash
    placeholders
    query_to_list
    query_to_list_limited
    ref_to_type
    remove_equal
    take_while
    trim
    type_to_model
);

Readonly my %TYPE_TO_MODEL => (
    'annotation'    => 'Annotation',
    'artist'        => 'Artist',
    'cdstub'        => 'CDStub',
    'editor'        => 'Editor',
    'freedb'        => 'FreeDB',
    'label'         => 'Label',
    'recording'     => 'Recording',
    'release'       => 'Release',
    'release_group' => 'ReleaseGroup',
    'url'           => 'URL',
    'work'          => 'Work',
);

sub copy_escape {
    my $str = shift;
    $str =~ s/\n/\\n/g;
    $str =~ s/\t/\\t/g;
    $str =~ s/\r/\\r/g;
    $str =~ s/\\/\\\\/g;
    return $str;
}

sub ref_to_type
{
    my $ref = shift;
    my %map = reverse %TYPE_TO_MODEL;
    for (keys %map) {
        return $map{$_}
            if ($ref->isa("MusicBrainz::Server::Entity::$_"))
    }

    return;
}

sub artist_credit_to_ref
{
    my ($artist_credit, $extra_keys) = @_;

    return $artist_credit unless blessed $artist_credit;

    my %ret = ( names => [] );

    for my $ac ($artist_credit->all_names)
    {
        my %ac_name = (
            join_phrase => $ac->join_phrase // '',
            name => $ac->name,
            artist => {
                name => $ac->artist->name,
                id => $ac->artist->id,
            }
        );

        for my $key (@$extra_keys)
        {
            if ($key eq "sortname")
            {
                $ac_name{artist}->{sortname} = $ac->artist->sort_name;
            }
            else
            {
                $ac_name{artist}->{$key} = $ac->artist->{$key};
            }
        }

        push @{ $ret{names} }, \%ac_name;
    }

    return \%ret;
}

sub load_subobjects
{
    my ($data_access, $attr_obj, @objs) = @_;

    @objs = grep { defined } @objs;
    return unless @objs;

    my $attr_id = $attr_obj . "_id";
    @objs = grep { $_->meta->find_attribute_by_name($attr_id) } grep { defined } @objs;
    my %ids = map { ($_->meta->find_attribute_by_name($attr_id)->get_value($_) || "") => 1 } @objs;
    my @ids = grep { $_ } keys %ids;
    my $data;
    if (@ids) {
        $data = $data_access->get_by_ids(@ids);
        foreach my $obj (@objs) {
            my $id = $obj->meta->find_attribute_by_name($attr_id)->get_value($obj);
            if (defined $id && exists $data->{$id}) {
                $obj->meta->find_attribute_by_name($attr_obj)->set_value($obj, $data->{$id});
            }
        }
    }
    return defined $data ? values %{$data} : ();
}

sub load_meta
{
    my ($c, $table, $builder, @objs) = @_;
    return unless @objs;
    my %id_to_obj = map { $_->id => $_ } @objs;
    my @ids = keys %id_to_obj;
    $c->sql->select("SELECT * FROM $table
                  WHERE id IN (" . placeholders(@ids) . ")", @ids);
    while (1) {
        my $row = $c->sql->next_row_hash_ref or last;
        my $obj = $id_to_obj{$row->{id}};
        $builder->($obj, $row);
    }
    $c->sql->finish;
}

sub check_in_use
{
    my ($sql, %queries) = @_;

    my @queries = keys %queries;
    my $query = join ' UNION ', map { "SELECT 1 FROM $_" } @queries;
    return 1 if $sql->select_single_value($query, map { @{$queries{$_}} } @queries );
    return;
}

sub partial_date_to_hash
{
    my ($date) = @_;
    return {
        year => $date->year,
        month => $date->month,
        day => $date->day
    };
}

sub placeholders
{
    return join ",", ("?") x scalar(@_);
}

sub query_to_list
{
    my ($sql, $builder, $query, @args) = @_;
    $sql->select($query, @args);
    my @result;
    while (1) {
        my $row = $sql->next_row_hash_ref or last;
        my $obj = $builder->($row);
        push @result, $obj;
    }
    $sql->finish;
    return @result;
}

sub query_to_list_limited
{
    my ($sql, $offset, $limit, $builder, $query, @args) = @_;
    $sql->select($query, @args);
    my @result;
    while (!defined($limit) || $limit--) {
        my $row = $sql->next_row_hash_ref or last;
        my $obj = $builder->($row);
        push @result, $obj;
    }
    my $hits = $sql->row_count + $offset;
    $sql->finish;
    return (\@result, $hits);
}

=func hash_structure

Generates a hash code for a particular edited track.  If a track
is moved the hash will remain the same, any other change to the
track will result in a different hash.

=cut

sub hash_structure
{
    sub structure_to_string {
        my $obj = shift;

        if (ref $obj eq "ARRAY")
        {
            my @ret = map { structure_to_string ($_) } @$obj;
            return '[' . join (",", @ret) . ']';
        }
        elsif (ref $obj eq "HASH")
        {
            my @ret = map {
                $_ . ':' . structure_to_string ($obj->{$_})
            } sort keys %$obj;
            return '{' . join (",", @ret) . '}';
        }
        elsif ($obj)
        {
            return $obj;
        }
        else
        {
            return '';
        }
    }

    return sha1_base64 (encode ("utf-8", structure_to_string (shift)));
}

sub insert_and_create
{
    my ($data, @objs) = @_;
    my $class = $data->_entity_class;
    Class::MOP::load_class($class);
    my %map = %{ $data->_attribute_mapping };
    my @ret;
    for my $obj (@objs)
    {
        my %row = map { ($map{$_} || $_) => $obj->{$_} } keys %$obj;
        my $id = $data->sql->insert_row($data->_table, \%row, 'id');
        push @ret, $class->new( id => $id, %$obj);
    }

    return wantarray ? @ret : $ret[0];
}

sub generate_gid
{
    lc(Data::UUID::MT->new( version => 4 )->create_string());
}

sub defined_hash
{
    my %hash = @_;
    return map { $_ => $hash{$_} } grep { defined $hash{$_} } keys %hash;
}

sub hash_to_row
{
    my ($hash, $mapping) = @_;

    my %row;
    foreach my $db_key (keys %$mapping) {
        my $key = $mapping->{$db_key};
        if (exists $hash->{$key}) {
            $row{$db_key} = $hash->{$key};
        }
    }
    return \%row;
}

sub add_partial_date_to_row
{
    my ($row, $date, $prefix) = @_;

    if (defined $date) {
        foreach my $key (qw(year month day)) {
            if (exists $date->{$key}) {
                $row->{$prefix . '_' . $key} = $date->{$key};
            }
        }
    }
}

sub trim {
    # Remove leading and trailing space
    my $t = Text::Trim::trim (shift);

    # Compress whitespace
    $t =~ s/\s+/ /g;

    # Remove non-printable characters.
    $t =~ s/[^[:print:]]//g;

    return $t;
}

sub type_to_model
{
    return $TYPE_TO_MODEL{$_[0]} || die "$_[0] is not a type that has a model";
}

sub model_to_type
{
    my %map = reverse %TYPE_TO_MODEL;
    return $map{$_[0]} || undef;
}

sub object_to_ids
{
    my @objects = @_;
    my %ret;
    foreach my $object (@objects)
    {
        $ret{$object->id} = [] unless $ret{$object->id};
        push @{ $ret{$object->id} }, $object;
    }

    return %ret;
}

sub order_by
{
    my ($order, $default, $map) = @_;

    my $order_by = $map->{$default};
    if ($order) {
        my $desc = 0;
        if ($order =~ /-(.*)/) {
            $desc = 1;
            $order = $1;
        }
        if (exists $map->{$order}) {
            $order_by = $map->{$order};
            if (ref($order_by) eq 'CODE') {
                $order_by = $order_by->();
            }
            if ($desc) {
                my @list = map { "$_ DESC" } split ',', $order_by;
                $order_by = join ',', @list;
            }
        }
    }
    return $order_by;
}

sub remove_equal
{
    my ($old, $new) = @_;

    for my $key (keys %$old) {
        my $n = $new->{$key};
        my $o = $old->{$key};

        if (Compare($n, $o)) {
            delete $old->{$key};
            delete $new->{$key};
        }
    }
}

sub map_query
{
    my ($sql, $key, $value, $query, @bind_params) = @_;
    return {
        map { $_->{$key} => $_->{$value} }
            @{ $sql->select_list_of_hashes($query, @bind_params) }
    }
}

sub check_data
{
    my ($data, @checks) = @_;

    my $it = natatime 2, @checks;
    while (my ($error, $check) = $it->()) {
        MusicBrainz::Server::Exceptions::BadData->throw($error)
            unless $check->($data);
    }
}

sub merge_table_attributes {
    my ($sql, %named_params) = @_;
    my $table = $named_params{table} or confess 'Missing parameter $table';
    my $new_id = $named_params{new_id} or confess 'Missing parameter $new_id';
    my @old_ids = @{ $named_params{old_ids} } or confess 'Missing parameter \@old_ids';
    my @columns = @{ $named_params{columns} } or confess 'Missing parameter \@columns';
    my @all_ids = ($new_id, @old_ids);

    $sql->do(
        "UPDATE $table SET " .
            join(',', map {
                "$_ = (SELECT new_val FROM (
                     SELECT (id = ?) AS first, $_ AS new_val
                       FROM $table
                      WHERE $_ IS NOT NULL
                        AND id IN (" . placeholders(@all_ids) . ")
                   ORDER BY first DESC
                      LIMIT 1
                      ) s)";
            } @columns) . '
            WHERE id = ?',
        (@all_ids, $new_id) x @columns, $new_id
    );
}

sub merge_partial_date {
    my ($sql, %named_params) = @_;
    my $table = $named_params{table} or confess 'Missing parameter $table';
    my $new_id = $named_params{new_id} or confess 'Missing parameter $new_id';
    my @old_ids = @{ $named_params{old_ids} } or confess 'Missing parameter \@old_ids';
    my ($year, $month, $day) = map { join('_', $named_params{field}, $_) } qw( year month day );

    $sql->do("
    UPDATE $table SET $day = most_complete.$day,
                      $month = most_complete.$month,
                      $year = most_complete.$year
    FROM (
        SELECT $day, $month, $year,
               (CASE WHEN $year IS NOT NULL THEN 100
                    ELSE 0
               END +
               CASE WHEN $month IS NOT NULL THEN 10
                    ELSE 0
               END +
               CASE WHEN $day IS NOT NULL THEN 1
                    ELSE 0
               END) AS weight
        FROM $table
        WHERE id = any(?)
        ORDER BY weight DESC
        LIMIT 1
    ) most_complete
    WHERE id = ?
      AND $table.$day IS NULL
      AND $table.$month IS NULL
      AND $table.$year IS NULL",
             \@old_ids, $new_id);
}

sub is_special_artist {
    my $artist_id = shift;
    return $artist_id == $VARTIST_ID || $artist_id == $DARTIST_ID;
}

sub is_special_label {
    my $label_id = shift;
    return $label_id == $DLABEL_ID;
}

sub take_while (&@) {
    my $f = shift;
    my @r;
    for my $x (@_) {
        local $_ = $x;
        if ($f->()) {
            push @r, $x;
        }
        else {
            last;
        }
    }
    return @r;
}

1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
