package MusicBrainz::Server::Edit::Relationship;
use List::UtilsBy qw( partition_by );
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Translation 'l';

sub edit_category { l('Relationship') }

sub check_attributes {
    my ($self, $link_type, @attribute_ids) = @_;

    my $link_type_id = $link_type->id;

    my %attribute_bounds = map { $_->type_id => [$_->min, $_->max] } $link_type->all_attributes;
    my $link_attribute_types = $self->c->model('LinkAttributeType')->get_by_ids(@attribute_ids);
    my %attribute_ids = partition_by { $link_attribute_types->{$_}->root_id } @attribute_ids;

    for my $root_id (keys %attribute_ids) {
        # If we have some values, make sure this attribute is allowed for
        # the current link type

        unless (exists $attribute_bounds{$root_id}) {
            die "Attribute $root_id is unsupported for link type $link_type_id";
        }
    }

    for my $root_id (keys %attribute_bounds) {
        my @values = $attribute_ids{$root_id};

        next unless @values;

        # This attribute is allowed on this link type, make sure we're within
        # min and max
        my ($min, $max) = @{ $attribute_bounds{$root_id} };
        if (defined($min) && @values < $min) {
            die "Attribute $root_id is required for link type $link_type_id";
        }

        if (defined($max) && scalar(@values) > $max) {
            die "Attribute $root_id can only be specified $max times for link type $link_type_id";
        }
    }
}

1;
