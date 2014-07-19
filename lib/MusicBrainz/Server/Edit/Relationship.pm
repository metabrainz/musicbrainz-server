package MusicBrainz::Server::Edit::Relationship;
use List::UtilsBy qw( sort_by partition_by );
use Moose::Role;
use MusicBrainz::Server::Data::Utils qw( non_empty );
use namespace::autoclean;

use MusicBrainz::Server::Translation 'l';

sub edit_category { l('Relationship') }

sub check_attributes {
    my ($self, $link_type, $attributes) = @_;

    my $link_type_id = $link_type->id;
    my @attribute_gids = map { $_->{type}{gid} } @$attributes;
    my %attributes_by_gid = partition_by { $_->{type}{gid} } @$attributes;

    my %attribute_bounds = map { $_->type_id => [$_->min, $_->max] } $link_type->all_attributes;
    my $link_attribute_types = $self->c->model('LinkAttributeType')->get_by_gids(@attribute_gids);

    my $roots = $self->c->sql->select_list_of_hashes(q{
        SELECT id, name, gid FROM link_attribute_type WHERE id IN (
            SELECT root FROM link_attribute_type WHERE gid = any(?)
        )
    }, \@attribute_gids);

    my %roots_by_id = map { $_->{id} => $_ } @$roots;
    my %attributes_by_root = partition_by { $link_attribute_types->{$_}->root_id } @attribute_gids;

    for my $root_id (keys %attributes_by_root) {
        # If we have some values, make sure this attribute is allowed for
        # the current link type

        unless (exists $attribute_bounds{$root_id}) {
            die "Attribute $root_id is unsupported for link type $link_type_id";
        }
    }

    for my $root_id (keys %attribute_bounds) {
        my @values = @{ $attributes_by_root{$root_id} // [] };

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

        for my $gid (@values) {
            my $lat = $link_attribute_types->{$gid};
            my $root = $roots_by_id{$lat->root_id};
            my $data = $attributes_by_gid{$gid}->[0];

            if ($lat->free_text) {
                die "Attribute $gid requires a text value" unless non_empty($data->{text_value});
            }

            $data->{type} = {
                root_id => $root->{id},
                root_gid => $root->{gid},
                root_name => $root->{name},
                id => $lat->id,
                gid => $lat->gid,
                name => $lat->name,
            };

            delete $data->{text_value} if exists $data->{text_value} && !$lat->free_text;
            delete $data->{credited_as} if exists $data->{credited_as} && !$lat->creditable;
        }
    }
}

sub restore_int_attributes {
    my ($self, $relationship) = @_;

    my $attributes = $relationship->{attributes} // [];
    my $text_values = delete $relationship->{attribute_text_values} // {};

    for (my $i = 0; $i < scalar(@$attributes); $i++) {
        my $id = $attributes->[$i];
        my $text_value = $text_values->{$id};

        $attributes->[$i] = {
            type => { id => $id },
            $text_value ? (text_value => $text_value) : (),
        };
    }
}

sub serialize_link_attributes {
    my ($self, @attributes) = @_;

    return [ sort_by { $_->{type}{id} } map {
        my $type = $_->type;
        my $root = $type->root;
        {
            type => {
                root_name => $root->name,
                root_id => $root->id,
                root_gid => $root->gid,
                name => $type->name,
                id => $type->id,
                gid => $type->gid,
            },
            $type->creditable && non_empty($_->credited_as) ? (credited_as => $_->credited_as) : (),
            # text values are required
            $type->free_text ? (text_value => $_->text_value) : (),
        }
    } @attributes ];
}

1;
