SET search_path = musicbrainz, public;

BEGIN;

CREATE OR REPLACE FUNCTION extract_path_value(text, text)
RETURNS TEXT
AS $$
    use strict;
    use Encode;
    use JSON::XS;
    my @path = split '/', $_[1];
    my $obj = decode_json(encode('utf-8', $_[0]));
    while(@path) {
        my $comp = shift(@path);
        if (!exists $obj->{$comp}) {
            return undef;
        }
        elsif (@path && ref($obj->{$comp}) ne 'HASH') {
            return undef;
        }
        else {
            $obj = $obj->{$comp};
        }
    }

    die "Got to end of processing without reaching atomic value" if @path;

    return decode('utf-8', $obj);
$$ LANGUAGE 'plperlu' IMMUTABLE SECURITY DEFINER;

-- Partial indexes for searching inside edit data
CREATE INDEX edit_add_relationship_link_type on EDIT (extract_path_value(data, 'link_type/id')) WHERE type = 90;
CREATE INDEX edit_edit_relationship_link_type_link on EDIT (extract_path_value(data, 'link/link_type/id')) WHERE type = 91;
CREATE INDEX edit_edit_relationship_link_type_new on EDIT (extract_path_value(data, 'new/link_type/id')) WHERE type = 91;
CREATE INDEX edit_edit_relationship_link_type_old on EDIT (extract_path_value(data, 'old/link_type/id')) WHERE type = 91;
CREATE INDEX edit_remove_relationship_link_type on EDIT (extract_path_value(data, 'relationship/link/type/id')) WHERE type = 92;

CREATE OR REPLACE FUNCTION natural_series_sort(integer[], text[])
RETURNS TABLE (relationship integer, text_value text, link_order integer) AS $$
    my ($relationships, $text_values) = @_;

    die "array lengths differ" if @$relationships != @$text_values;

    my %relationships_by_text_value;
    for (my $i = 0; $i < @$relationships; $i++) {
        $relationships_by_text_value{$text_values->[$i]} = $relationships->[$i];
    }

    my @sorted_values = map { $_->[0] } sort {
        my ($a_parts, $b_parts) = ($a->[1], $b->[1]);

        my $max = @$a_parts <= @$b_parts ? @$a_parts : @$b_parts;
        my $order = 0;

        # Use <= and replace undef values with the empty string, so that
        # A1 sorts before A1B1.
        for (my $i = 0; $i <= $max; $i++) {
            my ($a_part, $b_part) = ($a_parts->[$i] // '', $b_parts->[$i] // '');

            my ($a_num, $b_num) = map { $_ =~ /^\d+$/ } ($a_part, $b_part);

            $order = $a_num && $b_num ? ($a_part <=> $b_part) : ($a_part cmp $b_part);
            last if $order;
        }

        $order;
    } map { [$_, [split /(\d+)/, $_]] } keys %relationships_by_text_value;

    my @result_table;
    for (my $i = 0; $i < @sorted_values; $i++) {
        my $text_value = $sorted_values[$i];

        push @result_table, {
            relationship => $relationships_by_text_value{$text_value},
            text_value => $text_value,
            link_order => $i+1,
        };
    }

    return \@result_table;
$$ LANGUAGE plperl IMMUTABLE;

COMMIT;
