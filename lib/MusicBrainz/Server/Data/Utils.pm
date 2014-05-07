package MusicBrainz::Server::Data::Utils;

use strict;
use warnings;

use base 'Exporter';
use Carp qw( confess croak );
use Try::Tiny;
use Class::MOP;
use Data::Compare;
use Data::UUID::MT;
use Math::Random::Secure qw( irand );
use MIME::Base64 qw( encode_base64url );
use Digest::SHA qw( sha1_base64 );
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
    add_coordinates_to_row
    artist_credit_to_ref
    check_data
    check_in_use
    collapse_whitespace
    copy_escape
    coordinates_to_hash
    defined_hash
    generate_gid
    generate_token
    hash_structure
    hash_to_row
    is_special_artist
    is_special_label
    load_everything_for_edits
    load_meta
    load_subobjects
    map_query
    merge_table_attributes
    merge_string_attributes
    merge_boolean_attributes
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
    remove_invalid_characters
    take_while
    trim
    type_to_model
);

Readonly my %TYPE_TO_MODEL => (
    'annotation'    => 'Annotation',
    'artist'        => 'Artist',
    'area'          => 'Area',
    'cdstub'        => 'CDStub',
    'collection'    => 'Collection',
    'editor'        => 'Editor',
    'freedb'        => 'FreeDB',
    'instrument'    => 'Instrument',
    'label'         => 'Label',
    'place'         => 'Place',
    'recording'     => 'Recording',
    'release'       => 'Release',
    'release_group' => 'ReleaseGroup',
    'url'           => 'URL',
    'work'          => 'Work',
    'isrc'          => 'ISRC',
    'iswc'          => 'ISWC'
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
    my ($artist_credit) = @_;

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

        push @{ $ret{names} }, \%ac_name;
    }

    return \%ret;
}

sub load_subobjects
{
    my ($data_access, $attr_obj, @objs) = @_;

    @objs = grep { defined } @objs;
    return unless @objs;

    my @ids;
    my %attr_ids;
    my %objs;
    if (ref($attr_obj) ne 'ARRAY') {
        $attr_obj = [ $attr_obj ];
    }

    for my $obj_type (@$attr_obj) {
        my $attr_id = $obj_type . "_id";
        $attr_ids{$attr_id} = $obj_type;

        $objs{$attr_id} = [ grep { $_->meta->find_attribute_by_name($attr_id) } @objs ];
        my %ids = map { ($_->meta->find_attribute_by_name($attr_id)->get_value($_) || "") => 1 } @{ $objs{$attr_id} };

        @ids = grep { !($ids{$_}) } @ids if scalar @ids;
        push @ids, grep { $_ } keys %ids;
    }

    my $data;
    if (@ids) {
        $data = $data_access->get_by_ids(@ids);
        for my $attr_id (keys %attr_ids) {
            my $attr_obj = $attr_ids{$attr_id};
            for my $obj (@{ $objs{$attr_id} }) {
                my $id = $obj->meta->find_attribute_by_name($attr_id)->get_value($obj);
                if (defined $id && exists $data->{$id}) {
                    $obj->meta->find_attribute_by_name($attr_obj)->set_value($obj, $data->{$id});
                }
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
    for my $row (@{
        $c->sql->select_list_of_hashes(
            "SELECT * FROM $table
             WHERE id IN (" . placeholders(@ids) . ")",
            @ids
        )
    }) {
        my $obj = $id_to_obj{$row->{id}};
        $builder->($obj, $row);
    }
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

sub coordinates_to_hash
{
    my ($coordinates) = @_;
    return undef unless defined $coordinates;
    return {
        latitude => $coordinates->latitude,
        longitude => $coordinates->longitude
    };
}

sub placeholders
{
    return join ",", ("?") x scalar(@_);
}

sub load_everything_for_edits
{
    my ($c, $edits) = @_;

    try {
        $c->model('Edit')->load_all(@$edits);
        $c->model('Vote')->load_for_edits(@$edits);
        $c->model('EditNote')->load_for_edits(@$edits);
        $c->model('Editor')->load(map { ($_, @{ $_->votes }, @{ $_->edit_notes }) } @$edits);
    } catch {
        use Data::Dumper;
        croak "Failed loading edits (" . (join ', ', map { $_->id } @$edits) . ")\n" .
              "Exception:\n" . Dumper($_) . "\n";
    };
}

sub query_to_list
{
    my ($sql, $builder, $query, @args) = @_;
    my @result;
    for my $row (@{ $sql->select_list_of_hashes($query, @args) }) {
        my $obj = $builder->($row);
        push @result, $obj;
    }
    return @result;
}

sub query_to_list_limited
{
    my ($sql, $offset, $limit, $builder, $query, @args) = @_;
    my $wrapping_query = "
        WITH x AS ($query)
        SELECT x.*, c.count AS total_row_count
        FROM x, (SELECT count(*) from x) c";
    if (defined $limit) {
        die "Query limit must be positive" if $limit < 0;
        $wrapping_query = $wrapping_query . " LIMIT $limit";
    }

    my @result;
    my $hits = 0;
    for my $row (@{ $sql->select_list_of_hashes($wrapping_query, @args) }) {
        $hits = $row->{total_row_count};
        my $obj = $builder->($row);
        push @result, $obj;
    }

    $hits = $hits + ($offset || 0);

    return (\@result, $hits);
}

sub generate_gid
{
    lc(Data::UUID::MT->new( version => 4 )->create_string());
}

sub generate_token
{
    encode_base64url(pack('LLLL', irand(), irand(), irand(), irand()));
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

sub add_coordinates_to_row
{
    my ($row, $coordinates, $prefix) = @_;

    $row->{$prefix} = defined $coordinates ?
        ($coordinates->{latitude} . ', ' . $coordinates->{longitude}) :
        undef;
}


sub collapse_whitespace {
    my $t = shift;

    # Compress whitespace
    $t =~ s/\s+/ /g;

    # Remove non-printable characters.
    $t =~ s/[^[:print:]]//g;

    return $t;
}

sub trim {
    # Remove leading and trailing space
    my $t = Text::Trim::trim (shift);

    $t = remove_invalid_characters($t);

    return collapse_whitespace ($t);
}

sub remove_invalid_characters {
    my $t = shift;
    # trim XML-invalid characters
    $t =~ s/[^\x09\x0A\x0D\x20-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}]//go;
    # trim other undesirable characters
    $t =~ s/[\x{200B}\x{00AD}]//go;
    #        zwsp    shy
    return $t
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
    foreach my $object (grep defined, @objects)
    {
        $ret{$object->id} = [] unless $ret{$object->id};
        push @{ $ret{$object->id} }, $object;
    }

    return %ret;
}

sub order_by
{
    my ($order, $default, $map) = @_;

    my $desc = 0;
    my $order_by = $map->{$default};
    if ($order) {
        if ($order =~ /^-(.*)/) {
           $desc = 1;
           $order = $1;
        }
        if (exists $map->{$order}) {
            $order_by = $map->{$order};
        }
        else {
            $desc = 0;
        }
    }

    if (ref($order_by) eq 'CODE') {
        $order_by = $order_by->();
    }

    if ($desc) {
        my @list = map { "$_ DESC" } split ',', $order_by;
        $order_by = join ',', @list;
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

sub _merge_attributes {
    my ($sql, $query_generator, %named_params) = @_;
    my $table = $named_params{table} or confess 'Missing parameter $table';

    my $new_id = $named_params{new_id} or confess 'Missing parameter $new_id';
    my $old_ids = $named_params{old_ids} or confess 'Missing parameter \@old_ids';
    my $all_ids = [$new_id, @$old_ids];

    $sql->do($query_generator->($table, $new_id, $old_ids, $all_ids, \%named_params));
}


sub _conditional_merge {
    my ($condition, %opts) = @_;

    my $wrap_coalesce = sub {
        my ($inner, $wrap) = @_;
        if ($wrap) { return "coalesce(" . $inner . ",?)" }
        else { return $inner }
    };

    return sub {
            my ($table, $new_id, $old_ids, $all_ids, $named_params) = @_;
            my $columns = $named_params->{columns} or confess 'Missing parameter columns';
            ("UPDATE $table SET " .
             join(',', map {
                 "$_ = " . $wrap_coalesce->("(SELECT new_val FROM (
                      SELECT (id = ?) AS first, $_ AS new_val
                        FROM $table
                       WHERE $_ $condition
                         AND id IN (" . placeholders(@$all_ids) . ")
                    ORDER BY first DESC
                       LIMIT 1
                       ) s)", exists $opts{default});
             } @$columns) . '
             WHERE id = ?',
             (@$all_ids, $new_id) x @$columns, (exists $opts{default} ? $opts{default} : ()), $new_id)}
}

sub merge_table_attributes {
    _merge_attributes(shift, _conditional_merge('IS NOT NULL'), @_);
}

sub merge_string_attributes {
    _merge_attributes(shift, _conditional_merge("!= ''", default => ''), @_);
}

sub merge_boolean_attributes {
    _merge_attributes(shift, sub {
        my ($table, $new_id, $old_ids, $all_ids, $named_params) = @_;
        my $columns = $named_params->{columns} or confess 'Missing parameter columns';

        return ("UPDATE $table SET " .
            join(',', map {
                "$_ = (
                        SELECT bool_or($_)
                        FROM $table
                        WHERE id IN (" . placeholders(@$all_ids) . ")
                      )";
            } @$columns) . '
            WHERE id = ?',
           (@$all_ids) x @$columns, $new_id)
    }, @_);
}

sub merge_partial_date {
    _merge_attributes(shift, sub {
        my ($table, $new_id, $old_ids, $all_ids, $named_params) = @_;
        my ($year, $month, $day) = map { join('_', $named_params->{field}, $_) } qw( year month day );
        return ("UPDATE $table SET $day = most_complete.$day,
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
                     $old_ids, $new_id)
    }, @_);
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

Copyright (C) 2009 Lukas Lalinsky, 2009-2013 MetaBrainz Foundation

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
