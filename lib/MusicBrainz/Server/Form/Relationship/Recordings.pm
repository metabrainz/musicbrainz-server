package MusicBrainz::Server::Form::Relationship::Recordings;

use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';
with 'MusicBrainz::Server::Form::Role::DatePeriod';

use Text::Trim;

has '+name' => ( default => 'ar' );

has_field 'link_type_id' => (
    type => 'Select',
    required => 1
);

sub field_list
{
    my ($self) = @_;

    my @fields = ('attrs', { type => 'Compound' }),
    my $attr_tree = $self->ctx->stash->{attr_tree};
    foreach my $attr ($attr_tree->all_children) {
        if ($attr->all_children) {
            my @options = $self->_build_options($attr, 'name', $attr->name, '');
            my @opts;
            push @opts, { value => shift @options, label => shift @options } while @options;
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

    my $root = $self->ctx->stash->{root};
    return [ $self->_build_options($root, 'link_phrase', 'ROOT', '&nbsp;') ];
}

sub edit_field_names { qw() }

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
