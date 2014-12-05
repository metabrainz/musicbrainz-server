package MusicBrainz::Server::Plugin::FormRenderer;

use strict;
use warnings;

use base 'Template::Plugin';

use MusicBrainz::Server::Translation qw( l );

use Clone qw( clone );
use List::Util qw( first );

use Carp;
use HTML::Tiny;

sub new
{
    my ($class, $context, $form, $opts) = @_;
    $opts ||= {};
    return bless {
        form => $form,
        h => HTML::Tiny->new,
        id_prefix => $opts->{id_prefix} || ''
    }, $class;
}

sub form
{
    my $self = shift;
    return $self->{form};
}

sub h
{
    my $self = shift;
    return $self->{h};
}

sub _lookup_field
{
    my ($self, $field) = @_;
    return unless $self->form;
    return ref $field ? $field : $self->form->field($field);
}

sub _id {
    my ($self, $field) = @_;
    return $self->{id_prefix} . "id-" . $field->html_name;
}

sub _render_input
{
    my ($self, $field, $type, %attrs) = @_;
    return unless ref $field;
    $attrs{required} = "required" if $field->required;
    my $class = delete $attrs{class} || '';
    return $self->h->input({
            type => $type,
            id => $self->_id($field),
            value => '' . $field->fif,
            name => $field->html_name,
            class => $class . ($field->has_errors ? ' error' : ''),
            %attrs
        });
}

sub text
{
    my ($self, $field_name, $attrs) = @_;
    my $field = $self->_lookup_field($field_name) or return;
    return $self->_render_input($field, 'text', %$attrs);
}

sub email {
    my ($self, $field_name, $attrs) = @_;
    my $field = $self->_lookup_field($field_name) or return;
    return $self->_render_input($field, 'email', %$attrs);
}

sub url {
    my ($self, $field_name, $attrs) = @_;
    my $field = $self->_lookup_field($field_name) or return;
    return $self->_render_input($field, 'url', %$attrs);
}

sub number {
    my ($self, $field_name, $attrs) = @_;
    my $field = $self->_lookup_field($field_name) or return;
    return $self->_render_input($field, 'number', %$attrs);
}

sub hidden
{
    my ($self, $field_name, $attrs) = @_;
    my $field = $self->_lookup_field($field_name) or return;
    return $self->_render_input($field, 'hidden', %$attrs);
}

sub submit
{
    my ($self, $field_name, $value, $attrs) = @_;

    $attrs ||= {};
    my $field = $self->_lookup_field($field_name) or return;
    return $self->h->input({
            type => 'submit',
            id => $self->_id($field),
            value => $value,
            name => $field->html_name,
            %$attrs
        });
}

sub password
{
    my ($self, $field_name, $attrs) = @_;
    my $field = $self->_lookup_field($field_name) or return;
    return $self->_render_input($field, 'password', %$attrs);
}

sub textarea
{
    my ($self, $field_name, $attrs) = @_;
    my $field = $self->_lookup_field($field_name) or return;
    return $self->h->textarea({
            name => $field->html_name,
            id => $self->_id($field),
            %{ $attrs || {} },
        }, $self->h->entity_encode($field->fif));
}

sub label
{
    my ($self, $field_name, $label, $attrs) = @_;
    $attrs = (ref $attrs eq 'HASH') ? clone ($attrs) : {};

    my $fake_label = delete $attrs->{fake};

    my $field = $self->_lookup_field($field_name) or return;
    my @class;
    push @class, qw(required) if $field->required;
    push @class, qw(inline) if delete $attrs->{inline};
    push @class, delete $attrs->{class} if $attrs->{class};

    if ($fake_label)
    {
        return $self->h->div({
            class => join(' ', 'label', @class),
            id => 'label-' . $self->_id($field),
            %$attrs
        }, $label);
    }
    else
    {
        return $self->h->label({
            id => 'label-' . $self->_id($field),
            for => 'id-' . $field->id,
            class => join(' ', @class) || undef,
            %$attrs
        }, $label);
    }
}

sub inline_label
{
    my ($self, $field_name, $label, $attrs) = @_;
    my $class = delete $attrs->{class} || '';
    return $self->label($field_name, $label, { class => "inline $class", %$attrs });
}

sub select
{
    my ($self, $field_name, $attrs) = @_;
    $attrs = (ref $attrs eq 'HASH') ? clone ($attrs) : {};

    my $field = $self->_lookup_field($field_name) or return;

    my @selected = $field->multiple ? @{ $field->value || [] } : ( $field->value );

    my @options;
    my %optgroups;
    my %optgroup_order;

    # Clone options as they get mutated
    for my $option (map { clone($_) } @{ $field->options })
    {
        my $selected = @selected > 0  && first { $_ && $option->{value} && $option->{value} eq $_ } @selected;

        my $label = delete $option->{label};
        my $grp = delete $option->{optgroup};
        my $grp_order = delete $option->{optgroup_order};

        my $option_html = $self->h->option(
            {
                %$option, selected => $selected ? "selected" : undef,
            }, $self->h->entity_encode($label));

        if ($grp)
        {
            $optgroups{grp} ||= [];
            push @{ $optgroups{$grp} }, $option_html;
            $optgroup_order{$grp} = $grp_order;
        }
        else
        {
            push @options, $option_html;
        }
    }

    if (%optgroups)
    {
        for (sort { $optgroup_order{$a} cmp $optgroup_order{$b} } keys %optgroup_order)
        {
            push @options, $self->h->optgroup({ 'label' => $_ }, $optgroups{$_});
        }
    }

    if (!$field->required || delete $attrs->{no_default})
    {
        unshift @options, $self->h->option({
            selected => !defined $field->value ? "selected" : undef,
        }, ' ')
    }

    return $self->h->select({
        id => $self->_id($field),
        name => $field->html_name,
        multiple => $field->multiple ? "multiple" : undef,
        disabled => $field->disabled ? "disabled" : undef,
        class => $attrs->{class},
        %{ $attrs || {} }
    }, \@options);
}

sub radio
{
    my ($self, $field_name, $option, $attrs) = @_;

    my $field = $self->_lookup_field($field_name) or return;
    my $value = $field->options->[$option]->{value};

    return $self->h->input({
        type => 'radio',
        id => $self->_id($field) . "-$option" ,
        name => $field->html_name,
        checked => $field->value && $value eq $field->value ? 'checked' : undef,
        disabled => $field->disabled ? "disabled" : undef,
        value => $value,
        %{ $attrs || {} }
    });
}

sub checkbox
{
    my ($self, $field_name, $attrs) = @_;
    my $field = $self->_lookup_field($field_name) or return;
    return $self->_render_input($field, 'checkbox',
        checked => $field->value ? "checked" : undef,
        value => $field->checkbox_value,
        %$attrs
    );
}

sub date
{
    my ($self, $field_name) = @_;
    my $field = $self->_lookup_field($field_name) or return;
    return $self->h->span({ class => 'partial-date' }, [
        join('-',
             $self->text($field->field('year'),  { maxlength => 4, placeholder => l('YYYY'), size => 4 }),
             $self->text($field->field('month'), { maxlength => 2, placeholder => l('MM'), size => 2 }),
             $self->text($field->field('day'),   { maxlength => 2, placeholder => l('DD'), size => 2 }))
    ]);
}

sub artist_credit_editor
{
    my ($self, $field_name) = @_;
    my $field = $self->_lookup_field($field_name) or return;

    # Artist credit editor
    my $preview = $field->fif;
    my %gid_id_map = map { $_->artist->id => $_->artist->gid } grep { defined $_->artist } @{ $preview->{names} };

    my @credits = map { [
        $self->h->input({
            type => 'hidden',
            class => 'gid',
            value => $gid_id_map{$_->field('artist_id')->value}
        }),
        $self->_render_input($_->field('artist_id'), 'hidden', class => 'id'),
        $self->_render_input($_->field('name'), 'text', class => 'name'),
        $self->_render_input($_->field('join_phrase'), 'text', class => 'join')
    ] } $field->field('names')->fields;

    return $self->h->div({ id => $self->_id($field), class => 'artist-credit' }, [
        map {
            $self->h->div({ class => 'credit' }, $_)
        } @credits
    ]);
}

1;

=head1 COPYRIGHT

Copyright (C) 2009-2010  MetaBrainz Foundation

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
