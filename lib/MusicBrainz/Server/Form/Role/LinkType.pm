package MusicBrainz::Server::Form::Role::LinkType;
use HTML::FormHandler::Moose::Role;

use Encode;
use MusicBrainz::Server::Translation 'l';
use Text::Trim qw( trim );
use Text::Unaccent qw( unac_string_utf16 );

has attr_tree => (
    is => 'ro',
    required => 1
);

sub _build_options
{
    my ($self, $root, $attr, $ignore, $indent) = @_;

    my @options;
    if ($root->id && $root->name ne $ignore) {
        my $label = trim($root->$attr);
        my $unac = decode("utf-16", unac_string_utf16(encode("utf-16", $label)));

        if (defined($indent)) {
            $label = $indent . $label;
            $indent .= '&#160;&#160;&#160;';
        }
        push @options, {
            value => $root->id,
            label => $label,
            'data-unaccented' => $unac
        };
    }
    foreach my $child ($root->all_children) {
        push @options, $self->_build_options($child, $attr, $ignore, $indent);
    }
    return @options;
}

sub field_list
{
    my ($self, $prefix, $indent) = @_;

    my @fields;
    foreach my $attr ($self->attr_tree->all_children) {
        if ($attr->all_children) {
            my @options = $self->_build_options($attr, 'l_name', $attr->name, $indent);
            push @fields, $prefix . 'attrs.' . $attr->name, { type => 'Repeatable' };
            push @fields, $prefix . 'attrs.' . $attr->name . '.contains', {
                type => 'Select',
                options => \@options,
            };
        } else {
            push @fields, $prefix . 'attrs.' . $attr->name, { type => 'Boolean' };
        }
    }
    return \@fields;
}

sub validate_link_type
{
    my ($self, $c, $link_type_field, $attrs_field, $allow_deprecated) = @_;

    if(my $link_type_id = $link_type_field->value) {
        my $link_type = $c->model('LinkType')->get_by_id($link_type_id);

        if (!$link_type->description) {
            $link_type_field->add_error(
                l('This relationship type is used to group other relationships. '.
                  'Please select a subtype of the currently selected '.
                  'relationship type.')
            );
            return $link_type;
        } elsif ($link_type->is_deprecated && !$allow_deprecated) {
            $link_type_field->add_error(
                l("This relationship type is deprecated.")
            );
            return $link_type;
        }

        my %attribute_bounds = map { $_->type_id => [$_->min, $_->max] }
            $link_type->all_attributes;

        foreach my $attr ($self->attr_tree->all_children) {
            # Try and find the values for the current attribute (attributes may
            # have more than 1 value)
            my @values = ();
            if(my $value = $attrs_field->field($attr->name)->value) {
                @values = $attr->all_children ? @{ $value } : ($attr->id);
            }

            # If we have some values, make sure this attribute is allowed for
            # the current link type
            if (@values && !exists $attribute_bounds{ $attr->id }) {
                $attrs_field->field($attr->name)->add_error(
                    l('This attribute is not supported for the selected relationship type.'));
            }

            # No values, continue if the attribute is not present (no further checks)
            next unless exists $attribute_bounds{ $attr->id };

            # This attribute is allowed on this attirbute, make sure we're
            # within min and max
            my ($min, $max) = @{ $attribute_bounds{$attr->id} };
            if (defined($min) && @values < $min) {
                $attrs_field->field($attr->name)->add_error(
                    l('This attribute is required.'));
            }

            if (defined($max) && scalar(@values) > $max) {
                $attrs_field->field($attr->name)->add_error(
                    l('This attribute can only be specified {max} times. '.
                      'You specified {n}.', {
                          max => $max,
                          n => scalar(@values)
                      }));
            }
        }
        return $link_type;
    }
}

1;
