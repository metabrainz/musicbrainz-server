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

    my $model_ref = ref($model) ? $model : $c->model($model);
    my $root_option = $model_ref->get_tree;
#    my $root_option = $c->model($model)->get_tree;

    return [
        map {
            _build_options_tree($_, 'l_name', '')
        } $root_option->all_children
    ];
}

sub _build_options_tree
{
    my ($root, $attr, $indent) = @_;

    my @options;

    push @options, {
        value => $root->id,
        label => $indent . $root->$attr,
    } if $root->id;

    $indent .= '&#xa0;&#xa0;&#xa0;';

    foreach my $child ($root->all_children) {
        push @options, _build_options_tree($child, $attr, $indent);
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
