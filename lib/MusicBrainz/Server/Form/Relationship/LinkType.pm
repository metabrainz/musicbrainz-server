package MusicBrainz::Server::Form::Relationship::LinkType;
use HTML::FormHandler::Moose::Role;

use Encode;
use MusicBrainz::Server::Translation 'l';
use MusicBrainz::Server::Translation 'l';
use Text::Trim qw( trim );
use Text::Unaccent qw( unac_string_utf16 );

has_field 'link_type_id' => (
    type => 'Select',
    required => 1,
    required_message => l('Link type is required')
);

has attr_tree => (
    is => 'ro',
    required => 1
);

has root => (
    is => 'ro',
    required => 1
);

sub _build_options
{
    my ($self, $root, $attr, $ignore, $indent) = @_;

    my @options;
    if ($root->id && $root->name ne $ignore) {
        push @options, $root->id, $indent . trim($root->$attr) if $root->id;
        $indent .= '&nbsp;&nbsp;&nbsp;';
    }
    foreach my $child ($root->all_children) {
        push @options, $self->_build_options($child, $attr, $ignore, $indent);
    }
    return @options;
}

sub options_link_type_id
{
    my ($self) = @_;

    my $root = $self->root;
    return [ $self->_build_options($root, 'short_link_phrase', 'ROOT', '&nbsp;') ];
}

sub field_list
{
    my ($self) = @_;

    my @fields = ('attrs', { type => 'Compound' }),
    my $attr_tree = $self->attr_tree;
    foreach my $attr ($attr_tree->all_children) {
        if ($attr->all_children) {
            my @options = $self->_build_options($attr, 'name', $attr->name, '');
            my @opts;
            while (@options) {
                my ($value, $label) = (shift(@options), shift(@options));
                push @opts, {
                    value => $value,
                    label => $label,
                    'data-unaccented' => decode("utf-16", unac_string_utf16(encode("utf-16", $label)))
                };
            }
            push @fields, 'attrs.' . $attr->name, { type => 'Repeatable' };
            push @fields, 'attrs.' . $attr->name . '.contains', {
                type => 'Select',
                options => \@opts,
            };
        }
        else {
            push @fields, 'attrs.' . $attr->name, { type => 'Boolean' };
        }
    }
    return \@fields;
}

after validate => sub {
    my ($self) = @_;

    if(my $link_type_id = $self->field('link_type_id')->value) {
        my $link_type = $self->ctx->model('LinkType')->get_by_id($link_type_id);

        if (!$link_type->description) {
            $self->field('link_type_id')->add_error(
                l('This relationship type is used to group other relationships. '.
                  'Please select a subtype of the currently selected '.
                  'relationship type.')
            );
            return;
        }

        my %attribute_bounds = map { $_->type_id => [$_->min, $_->max] }
            $link_type->all_attributes;

        foreach my $attr ($self->attr_tree->all_children) {
            # Try and find the values for the current attribute (attributes may
            # have more than 1 value)
            my @values = ();
            if(my $value = $self->field('attrs')->field($attr->name)->value) {
                @values = $attr->all_children ? @{ $value } : ($attr->id);
            }

            # If we have some values, make sure this attribute is allowed for
            # the current link type
            if (@values && !exists $attribute_bounds{ $attr->id }) {
                $self->field('attrs')->field($attr->name)->add_error(
                    l('This attribute is not supported for the selected relationship type.'));
            }

            # No values, continue if the attribute is not present (no further checks)
            next unless exists $attribute_bounds{ $attr->id };

            # This attribute is allowed on this attirbute, make sure we're
            # within min and max
            my ($min, $max) = @{ $attribute_bounds{$attr->id} };
            if (defined($min) && @values < $min) {
                $self->field('attrs')->field($attr->name)->add_error(
                    l('This attribute is required.'));
            }

            if (defined($max) && scalar(@values) > $max) {
                $self->field('attrs')->field($attr->name)->add_error(
                    l('This attribute can only be specified {max} times. '.
                      'You specified {n}.', {
                          max => $max,
                          n => scalar(@values)
                      }));
            }
        }
    }
};

1;
