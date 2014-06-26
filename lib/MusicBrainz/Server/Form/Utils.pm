package MusicBrainz::Server::Form::Utils;

use strict;
use warnings;

use Encode;
use MusicBrainz::Server::Translation qw( l lp );
use Text::Trim qw( trim );
use Text::Unaccent qw( unac_string_utf16 );
use Unicode::ICU::Collator qw( UCOL_NUMERIC_COLLATION UCOL_ON );
use List::UtilsBy qw( sort_by );

use Sub::Exporter -setup => {
    exports => [qw(
                      language_options
                      script_options
                      link_type_options
                      select_options
                      select_options_tree
                      build_grouped_options
                      build_type_info
                      build_attr_info
                      build_options_tree
              )]
};

sub language_options {
    my $c = shift;

    # group list of languages in <optgroups>.
    # most frequently used languages have hardcoded value 2.
    # languages which shouldn't be shown have hardcoded value 0.

    my $frequent = 2;
    my $skip = 0;

    my $coll = $c->get_collator();
    my @sorted = sort_by { $coll->getSortKey($_->{label}) } map {
        {
            'value' => $_->id,
            'label' => $_->l_name,
            'class' => 'language',
            'optgroup' => $_->{frequency} eq $frequent ? lp('Frequently used', 'language optgroup') : lp('Other', 'language optgroup'),
            'optgroup_order' => $_->{frequency} eq $frequent ? 1 : 2,
        }
    } grep { $_->{frequency} ne $skip } $c->model('Language')->get_all;

    return \@sorted;
}

sub script_options {
    my $c = shift;

    # group list of scripts in <optgroups>.
    # most frequently used scripts have hardcoded value 4.
    # scripts which shouldn't be shown have hardcoded value 1.

    my $frequent = 4;
    my $skip = 1;

    my $coll = $c->get_collator();
    my @sorted = sort_by { $coll->getSortKey($_->{label}) } map {
        {
            'value' => $_->id,
            'label' => $_->l_name,
            'class' => 'script',
            'optgroup' => $_->{frequency} eq $frequent ? lp('Frequently used', 'script optgroup') : lp('Other', 'script optgroup'),
            'optgroup_order' => $_->{frequency} eq $frequent ? 1 : 2,
        }
    } grep { $_->{frequency} ne $skip } $c->model('Script')->get_all;
    return \@sorted;
}

sub link_type_options
{
    my ($root, $attr, $ignore, $indent) = @_;

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
        push @options, @{ link_type_options($child, $attr, $ignore, $indent) };
    }
    return \@options;
}

sub select_options
{
    my ($c, $model, %opts) = @_;

    my $model_ref = ref($model) ? $model : $c->model($model);
    my $sort_by_accessor = $opts{sort_by_accessor} // $model_ref->sort_in_forms;
    my $accessor = $opts{accessor} // 'l_name';
    my $coll = $c->get_collator();

    return [ map {
        value => $_->id,
        label => l($_->$accessor)
    }, sort_by {
        $sort_by_accessor ? $coll->getSortKey(l($_->$accessor)) : ''
    } $model_ref->get_all ];
}

sub select_options_tree
{
    my ($c, $model, %opts) = @_;
    my $coll = $c->get_collator();

    my $model_ref = ref($model) ? $model : $c->model($model);
    my $root_option = $model_ref->get_tree;

    return [
        build_options_tree($root_option, 'l_name', $coll)
    ];
}

sub build_options_tree
{
    my ($root, $attr, $coll, $indent) = @_;

    my @options;

    push @options, {
        value => $root->id,
        label => ($indent // '') . $root->$attr,
    } if $root->id;

    $indent .= '&#xa0;&#xa0;&#xa0;' if defined $indent;
    $indent //= ''; # for the first level

    foreach my $child ($root->sorted_children($coll)) {
        push @options, build_options_tree($child, $attr, $coll, $indent);
    }
    return @options;
}


# Used by the relationship and release editors, instead of FormHandler.
sub build_grouped_options
{
    my ($c, $options) = @_;

    my $result = [];
    for my $opt (@$options) {
        my $i = $opt->{optgroup_order} - 1;
        $result->[$i] //= { optgroup => $opt->{optgroup}, options => [] };

        push @{ $result->[$i]->{options} },
              { label => $opt->{label}, value => $opt->{value} };
    }
    return $result;
}

sub build_type_info {
    my ($c, $types, @link_type_tree) = @_;

    sub build_type {
        my $root = shift;

        my %attrs = map {
            $_->type_id => {
                min     => defined $_->min ? 0 + $_->min : undef,
                max     => defined $_->max ? 0 + $_->max : undef,
            }
        } $root->all_attributes;

        my $result = {
            id                  => $root->id,
            gid                 => $root->gid,
            phrase              => $root->l_link_phrase,
            reversePhrase       => $root->l_reverse_link_phrase,
            deprecated          => $root->is_deprecated ? \1 : \0,
            hasDates            => $root->has_dates ? \1 : \0,
            type0               => $root->entity0_type,
            type1               => $root->entity1_type,
            cardinality0        => $root->entity0_cardinality,
            cardinality1        => $root->entity1_cardinality,
            orderableDirection  => $root->orderable_direction,
        };

        $result->{description} = $root->l_description if $root->description;
        $result->{attributes} = \%attrs if %attrs;
        $result->{children} = build_child_info($root, \&build_type) if $root->all_children;

        return $result;
    };

    my %type_info;
    for my $root (@link_type_tree) {
        my $type_key = join('-', $root->entity0_type, $root->entity1_type);
        next if $type_key !~ $types;
        $type_info{ $type_key } = build_child_info($root, \&build_type);
    }
    return \%type_info;
}

sub build_attr_info {
    my $root = shift;

    sub build_attr {
        my $attr = {
            id          => $_->id,
            gid         => $_->gid,
            root_id     => $_->root_id,
            name        => $_->name,
            l_name      => $_->l_name,
            freeText    => $_->free_text ? \1 : \0,
        };

        $attr->{description} = $_->l_description if $_->description;
        $attr->{children} = build_child_info($_, \&build_attr) if $_->all_children;

        my $unac = decode("utf-16", unac_string_utf16(encode("utf-16", $_->l_name)));
        $attr->{unaccented} = $unac if $unac ne $_->l_name;

        return $attr;
    }

    return { map { $_->name => build_attr($_) } $root->all_children };
}

sub build_child_info {
    my ($root, $builder) = @_;

    return [ map { $builder->($_) } $root->all_children ];
}

1;

=head1 COPYRIGHT

Copyright (C) 2011 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
