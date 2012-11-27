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

COMMIT;
