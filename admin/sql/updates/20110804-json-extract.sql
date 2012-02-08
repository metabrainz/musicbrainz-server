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

COMMIT;
