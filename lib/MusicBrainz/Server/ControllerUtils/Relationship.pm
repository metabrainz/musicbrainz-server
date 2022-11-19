package MusicBrainz::Server::ControllerUtils::Relationship;
use strict;
use warnings;

use base 'Exporter';
use MusicBrainz::Server::Data::Utils qw( trim non_empty );

our @EXPORT_OK = qw(
    merge_link_attributes
    serialize_link_attribute
    serialize_link_attribute_type
);

sub _clean_link_attribute {
    my ($data) = @_;

    my $credited_as = trim($data->{credited_as});
    my $text_value = trim($data->{text_value});

    return {
        type => { gid => $data->{type}{gid} },
        non_empty($credited_as) ? (credited_as => $credited_as) : (),
        non_empty($text_value) ? (text_value => $text_value) : (),
    };
}

sub merge_link_attributes {
    my ($submitted, $existing) = @_;

    my %new;
    my %existing = map { $_->type->gid => serialize_link_attribute($_) } @$existing;

    for my $attr (@$submitted) {
        my $gid = $attr->{type}{gid} or next;

        if ($attr->{removed}) {
            delete $existing{$gid};
        } else {
            $new{$gid} = _clean_link_attribute($attr);
        }
    }

    while (my ($gid, $attr) = each %existing) {
        $new{$gid} = $attr unless exists $new{$gid};
    }

    return [values %new];
}

sub serialize_link_attribute_type {
    my ($type) = @_;

    return {
        $type->root ? (root => serialize_link_attribute_type($type->root)) : (),
        id => $type->id,
        gid => $type->gid,
        name => $type->name,
    };
}

=method serialize_link_attribute_type

Serializes a blessed Entity::LinkAttribute to a HASH ref in a format used
by the Edit::Relationship classes. This should be phased out in favor of the
format described in Entity::LinkAttribute::TO_JSON, once that's standardized.

=cut

sub serialize_link_attribute {
    my ($a) = @_;

    return {
        type => serialize_link_attribute_type($a->type),
        $a->type->creditable && non_empty($a->credited_as) ? (credited_as => $a->credited_as) : (),
        # text values are required
        $a->type->free_text ? (text_value => $a->text_value) : (),
    };
}
