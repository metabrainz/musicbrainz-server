package MusicBrainz::Server::Data::Utils;

use 5.18.2;
use strict;
use warnings;

use base 'Exporter';
use Carp qw( confess croak );
use Try::Tiny;
use Class::MOP;
use Clone qw( clone );
use Data::Compare;
use Data::UUID::MT;
use Math::Random::Secure qw( irand );
use MIME::Base64 qw( encode_base64url );
use JSON::XS;
use List::AllUtils qw( any natatime sort_by );
use MusicBrainz::Server::Constants qw(
    $DARTIST_ID
    $VARTIST_ID
    $NOLABEL_ID
    $DLABEL_ID
    $INSTRUMENT_ROOT_ID
    $VOCAL_ROOT_ID
    %ENTITIES
);
use Readonly;
use Scalar::Util qw( blessed );
use Sql;
use Storable;
use Text::Trim qw();
use Unicode::Normalize qw( NFC );

our @EXPORT_OK = qw(
    add_partial_date_to_row
    add_coordinates_to_row
    artist_credit_to_ref
    boolean_from_json
    boolean_to_json
    check_data
    conditional_merge_column_query
    contains_number
    contains_string
    copy_escape
    coordinates_to_hash
    datetime_to_iso8601
    find_best_primary_alias
    generate_gid
    generate_token
    get_area_containment_join
    hash_structure
    hash_to_row
    is_special_artist
    is_special_label
    is_valid_token
    localized_note
    load_everything_for_edits
    load_meta
    load_subobjects
    map_query
    merge_table_attributes
    merge_string_attributes
    merge_boolean_attributes
    merge_partial_date
    merge_date_period
    model_to_type
    non_empty
    object_to_ids
    order_by
    partial_date_to_hash
    placeholders
    ref_to_type
    remove_equal
    remove_lineformatting_characters
    sanitize
    take_while
    trim
    trim_comment
    trim_multiline_text
    type_to_model
    split_relationship_by_attributes
);

Readonly my %TYPE_TO_MODEL => map { $_ => $ENTITIES{$_}{model} } grep { $ENTITIES{$_}{model} } keys %ENTITIES;

sub copy_escape {
    shift =~ s/\n/\\n/gr
          =~ s/\t/\\t/gr
          =~ s/\r/\\r/gr
          =~ s/\\/\\\\/gr;
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
            },
        );

        push @{ $ret{names} }, \%ac_name;
    }

    return \%ret;
}

sub load_subobjects
{
    my ($data_access, $attr_objs, @objs) = @_;

    @objs = grep { defined } @objs;
    return unless @objs;

    my @ids;
    my %objs;
    if (ref($attr_objs) ne 'ARRAY') {
        $attr_objs = [ $attr_objs ];
    }

    for my $attr_obj (@$attr_objs) {
        my $attr_id = $attr_obj . '_id';
        my @objs_with_id;
        for my $obj (@objs) {
            next unless $obj->can($attr_id);
            my $id = $obj->$attr_id;
            if (defined $id) {
                push @ids, $id;
                push @objs_with_id, $obj;
            }
        }
        $objs{$attr_obj} = \@objs_with_id;
    }

    my $data;
    if (@ids) {
        $data = $data_access->get_by_ids(@ids);
        for my $attr_obj (@$attr_objs) {
            my $attr_id = $attr_obj . '_id';
            for my $obj (@{ $objs{$attr_obj} }) {
                my $entity = $data->{$obj->$attr_id};
                if (defined $entity) {
                    $obj->$attr_obj($entity);
                }
            }
        }
    }
    if (defined $data) {
        return wantarray ? values %{$data} : $data;
    }
    return;
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
             WHERE id IN (" . placeholders(@ids) . ')',
            @ids,
        );
    }) {
        my $obj = $id_to_obj{$row->{id}};
        $builder->($obj, $row);
    }
}

sub partial_date_to_hash
{
    my ($date) = @_;
    return {
        year => $date->year,
        month => $date->month,
        day => $date->day,
    };
}

sub coordinates_to_hash
{
    my ($coordinates) = @_;
    return undef unless defined $coordinates;
    return {
        latitude => $coordinates->latitude,
        longitude => $coordinates->longitude,
    };
}

sub placeholders
{
    return join q(,), ('?') x scalar(@_);
}

sub load_everything_for_edits
{
    my ($c, $edits) = @_;

    try {
        $c->model('Edit')->load_all(@$edits);
        $c->model('Vote')->load_for_edits(@$edits);
        $c->model('EditNote')->load_for_edits(@$edits);
        $c->model('Editor')->load(map { ($_, @{ $_->votes }, @{ $_->edit_notes }) } @$edits);
        $c->model('EditNoteChange')->load_latest(map { @{ $_->edit_notes } } @$edits);
    } catch {
        use Data::Dumper;
        croak 'Failed loading edits (' . (join q(, ), map { $_->id } @$edits) . ")\n" .
              "Exception:\n" . Dumper($_) . "\n";
    };
}

sub generate_gid
{
    lc(Data::UUID::MT->new( version => 4 )->create_string());
}

Readonly my $TOKEN_SIZE => 6; # times 32 bits
sub generate_token {
    encode_base64url(
        pack(
            'L' x $TOKEN_SIZE,
            map { irand() } (1 .. $TOKEN_SIZE),
        ));
}

sub is_valid_token {
    my $token = shift;
    # Checks that the input looks like a base64url-encoded string produced by
    # `generate_token`.
    #
    # This doesn't check the length because tokens used to be shorter, and
    # most older OAuth applications still use the shorter token length for
    # their ID/secret.
    defined $token && $token =~ /^[A-Za-z0-9_-]+$/;
}

sub get_area_containment_join {
    my ($sql) = @_;

    CORE::state $has_materialized_data;

    if (!defined $has_materialized_data) {
        $has_materialized_data = $sql->select_single_value(
            'SELECT 1 FROM area_containment LIMIT 1',
        ) ? 1 : 0;
    }

    if ($has_materialized_data) {
        return 'area_containment';
    }

    return <<~'SQL';
        (
            SELECT DISTINCT ON (descendant, parent)
                descendant,
                parent,
                depth
              FROM get_area_parent_hierarchy_rows(NULL)
             ORDER BY descendant, parent, depth
        )
        SQL
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
    shift

    # Replace all spaces with U+0020
    =~ s/\s/ /gr

    # Compress whitespace
    =~ s/\s{2,}/ /gr;
}

sub sanitize {
    my $t = shift;

    return '' unless non_empty($t);

    $t = NFC($t);
    # Before removing invalid characters, convert space control characters
    # into U+0020 (or else they'll be removed).
    $t = collapse_whitespace($t);
    $t = remove_invalid_characters($t);
    $t = remove_lineformatting_characters($t);
    $t = remove_direction_marks($t);
    # Collapse spaces again, since characters may have been removed.
    $t = collapse_whitespace($t);

    return $t;
}

sub trim {
    my $t = shift;

    return '' unless non_empty($t);

    $t = sanitize($t);

    # Remove leading and trailing space
    $t = Text::Trim::trim($t);

    return $t;
}

sub trim_comment {
    my $t = shift;

    return '' unless non_empty($t);

    $t =~ s/^\s*\(([^()]+)\)\s*$/$1/;

    return trim($t);
}

sub trim_multiline_text {
    my $t = shift;

    return '' unless non_empty($t);

    $t = NFC($t);
    $t = remove_invalid_characters($t);

    # Trimming each line to remove trailing spaces (or similar)
    # - Not trimming starting spaces to avoid breaking
    #   either list formatting in Wikitext
    #   or block in Markdown.
    # - Splitting on \n so that \s doesn’t match any \n
    $t = join ("\n", map { $_ =~ s/\s+$//r } (split /\n/, $t));

    # Merge consecutive blank lines together
    $t =~ s/\n+(\n\n)/$1/g;

    return $t;
}

sub remove_direction_marks {
    my $t = shift;

    # Remove LRM/RLM between strong characters
    #   (start/end of string are treated like strong characters, too)
    $t =~ s {
                 (
                     \A | [\p{Bidi_Class=Left_To_Right}\p{Bidi_Class=Right_To_Left}\p{Bidi_Class=Arabic_Letter}]
                 )
                 [\N{LEFT-TO-RIGHT MARK}\N{RIGHT-TO-LEFT MARK}]+
                 (?= # look-ahead, so that the character is not consumed and can match on the next iteration
                     \z | [\p{Bidi_Class=Left_To_Right}\p{Bidi_Class=Right_To_Left}\p{Bidi_Class=Arabic_Letter}]
                 )
            } {$1}gx;

    # Remove LRM/RLM from strings without RTL characters
    my $stripped = $t =~ s/[\N{LEFT-TO-RIGHT MARK}\N{RIGHT-TO-LEFT MARK}]//gr;
    unless ($stripped =~ /[\p{Bidi_Class=Right_To_Left}\p{Bidi_Class=Arabic_Letter}]/)
        # The test must be done on $stripped because RLM is in Right_To_Left itself.
    {
        return $stripped;
    } else {
        return $t;
    }
}

# https://www.unicode.org/faq/private_use.html#nonchar4
my $noncharacter_pattern = '\x{FDD0}-\x{FDEF}\x{FFFE}\x{FFFF}';
{
    for my $i (1 .. 16) {
        my $hex_i = sprintf('%X', $i);
        $noncharacter_pattern .= "\\x{${hex_i}FFFE}\\x{${hex_i}FFFF}";
    }
}

sub remove_invalid_characters {
    shift
    # trim XML-invalid characters, among them:
    # - Other, surrogate (which are UTF-16, not valid UTF-8)
    =~ s/[^\x09\x0A\x0D\x20-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}]//gor
    # trim other undesirable characters:
    # - bom
    # - Supplementary private use areas
    # - Noncharacters
    =~ s/[\N{ZERO WIDTH NO-BREAK SPACE}\x{F0000}-\x{FFFFF}\x{100000}-\x{10FFFF}${noncharacter_pattern}]//gr;
}

# Keep in sync with invalidEditNote in static/scripts/release-editor/init.js
sub remove_lineformatting_characters {
    shift
    # trim lasting line-formatting characters:
    # - zwsp
    # - shy
    # - Other, control (including TAB \x09, LF \x0A, and CR \x0D)
    =~ s/[\N{ZERO WIDTH SPACE}\N{SOFT HYPHEN}\p{Cc}]//gr;
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
    foreach my $object (grep { defined } @objects)
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
        my @list = map { "$_ DESC" } split /,/, $order_by;
        $order_by = join q(,), @list;
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
            @{ $sql->select_list_of_hashes($query, @bind_params) },
    };
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

sub conditional_merge_column_query {
    my ($table, $column, $new_id, $all_ids, $condition, $default) = @_;

    my @args = ($new_id, $all_ids);
    my $query =
        "(SELECT new_val
            FROM (SELECT (id = ?) AS first, $column AS new_val
                    FROM $table
                   WHERE $column $condition
                     AND id = any(?)
                   ORDER BY first DESC
                   LIMIT 1) s)";
    if (defined $default) {
        $query = "coalesce($query, ?)";
        push @args, $default;
    }
    return ($query, \@args);
}

sub _conditional_merge {
    my ($condition, %opts) = @_;

    return sub {
        my ($table, $new_id, $old_ids, $all_ids, $named_params) = @_;
        my $columns = $named_params->{columns} or confess 'Missing parameter columns';
        my @assignment_args;
        my $column_assignments = join(', ', map {
            my $column = $_;
            my ($column_query, $column_args) =
                conditional_merge_column_query(
                    $table,
                    $column,
                    $new_id,
                    $all_ids,
                    $condition,
                    $opts{default},
                );
            push @assignment_args, @{$column_args};
            "$column = ($column_query)"
         } @$columns);
        ("UPDATE $table SET $column_assignments WHERE id = ?",
            @assignment_args, $new_id);
    };
}

sub merge_table_attributes {
    _merge_attributes(shift, _conditional_merge('IS NOT NULL'), @_);
}

sub merge_string_attributes {
    _merge_attributes(shift, _conditional_merge(q(!= ''), default => ''), @_);
}

sub merge_boolean_attributes {
    _merge_attributes(shift, sub {
        my ($table, $new_id, $old_ids, $all_ids, $named_params) = @_;
        my $columns = $named_params->{columns} or confess 'Missing parameter columns';

        return ("UPDATE $table SET " .
            join(q(,), map {
                "$_ = (
                        SELECT bool_or($_)
                        FROM $table
                        WHERE id IN (" . placeholders(@$all_ids) . ')
                      )';
            } @$columns) . '
            WHERE id = ?',
           (@$all_ids) x @$columns, $new_id);
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
                     $old_ids, $new_id);
    }, @_);
}

sub merge_date_period {
    my @args = @_;

    merge_partial_date(@args, field => $_)
        for qw( begin_date end_date );
    merge_boolean_attributes(@args, columns => ['ended']);
}

sub is_special_artist {
    my $artist_id = shift;
    return $artist_id == $VARTIST_ID || $artist_id == $DARTIST_ID;
}

sub is_special_label {
    my $label_id = shift;
    return $label_id == $NOLABEL_ID || $label_id == $DLABEL_ID;
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

sub split_relationship_by_attributes {
    my ($attributes_by_gid, $data) = @_;

    # Make output order deterministic.
    my @attributes = sort_by {
        $attributes_by_gid->{$_->{type}{gid}}->id
    } @{ $data->{attributes} // [] };

    my (@to_split, @others, @new_data);

    for (@attributes) {
        my $root = $attributes_by_gid->{$_->{type}{gid}}->root_id;

        if ($root == $INSTRUMENT_ROOT_ID || $root == $VOCAL_ROOT_ID) {
            push @to_split, $_;
        } else {
            push @others, $_;
        }
    }

    for my $id (@to_split) {
        my $cloned_data = clone($data);
        $cloned_data->{attributes} = [@others, $id];
        push @new_data, $cloned_data;
    }

    push @new_data, $data unless scalar(@new_data);
    return @new_data;
}

sub non_empty {
    my $value = shift;
    return defined($value) && $value ne '';
}

sub boolean_to_json {
    my $bool = shift;

    $bool = ref($bool) ? ${$bool} : $bool;
    return $bool ? \1 : \0;
}

sub boolean_from_json {
    my $bool = shift;

    $bool = ref($bool) ? ${$bool} : $bool;
    return $bool ? 1 : 0;
}

sub datetime_to_iso8601 {
    my $date = shift;

    return undef unless defined $date;

    $date = $date->clone;
    $date->set_time_zone('UTC');
    $date = $date->iso8601 . 'Z';
    return $date;
}

sub localized_note {
    my ($message, %opts) = @_;

    state $json = JSON::XS->new;
    'localize:' . $json->encode({
        message => $message,
        version => 1,
        %opts,
    });
}

sub contains_number {
    my ($array_ref, $number) = @_;

    return 0 unless defined $array_ref;
    return any { $_ == $number } @$array_ref;
}

sub contains_string {
    my ($array_ref, $string) = @_;

    return 0 unless defined $array_ref;
    return any { $_ eq $string } @$array_ref;
}

# Given an array of MusicBrainz::Server::Entity::Alias objects and the UI
# language, try to find a localized primary alias to display to the user.
sub find_best_primary_alias {
    my ($aliases_ref, $lang) = @_;

    my $short_lang = substr($lang, 0, 2);
    my ($best, $fallback);
    foreach my $alias (@$aliases_ref) {
        next if !defined $alias->locale || !$alias->primary_for_locale;

        # If we find an exact match for the user's language, use it.
        return $alias if $alias->locale eq $lang;

        # Otherwise, favor more-generic aliases (e.g. "en" over "en_US").
        if (substr($alias->locale, 0, 2) eq $short_lang &&
            (!defined $best || length($alias->locale) == 2)) {
            $best = $alias;
        }
        # If we find an English alias, use it as a fallback. This is likely
        # better than nothing in many cases, since English aliases often apply
        # to all Latin-script languages.
        if (substr($alias->locale, 0, 2) eq 'en' &&
            (!defined $fallback || length($alias->locale) == 2)) {
            $fallback = $alias;
        }
    }
    return $best || $fallback;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2009-2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
