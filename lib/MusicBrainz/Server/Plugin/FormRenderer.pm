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
    if ($field->required && $type !~ /^hidden|image|submit|reset|button$/) {
        $attrs{required} = "required";
    }
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
        }, '&#xA0;')
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

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2010  MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
