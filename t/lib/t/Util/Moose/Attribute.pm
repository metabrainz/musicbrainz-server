package t::Util::Moose::Attribute;
use strict;
use warnings;

use Test::More;
use Sub::Exporter -setup => { exports => [qw( attribute_value_is object_attributes )] };

sub object_attributes {
    my $o = shift;
    my $meta = $o->meta;
    return map {
        $meta->get_attribute($_) or die "Could not find attribute '$_'"
      } $meta->get_attribute_list;
}

sub attribute_value_is {
    my ($attribute, $instance, $expected, $msg) = @_;

    if (!$attribute->has_read_method) {
        diag("${attribute->name} has no reader");
    }
    else {
        is($attribute->get_read_method_ref->($instance),
           $expected, $msg);
    }
}

1;
