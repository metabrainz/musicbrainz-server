package MusicBrainz::Server::Plugin::FormRenderer;

use strict;
use warnings;

use base 'Template::Plugin';

use List::Util qw( first );

use Carp;
use HTML::Tiny;

sub new
{
    my ($class, $context, $form) = @_;
    return bless {
        form => $form,
        h => HTML::Tiny->new
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

sub _render_input
{
    my ($self, $field, $type, %attrs) = @_;
    return unless ref $field;
    my $class = delete $attrs{class} || '';
    return $self->h->input({
            type => $type,
            id => "id-" . $field->html_name,
            value => $field->fif,
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
            id => $field->id,
            %{ $attrs || {} },
        }, $field->fif);
}

sub label
{
    my ($self, $field_name, $label, $attrs) = @_;
    my $fake_label = delete $attrs->{fake};

    my $field = $self->_lookup_field($field_name) or return;
    my $class = $field->required ? "required " : "";
    $class .= delete $attrs->{inline} ? "inline " : "";
    if (exists $attrs->{class}) {
        $class .= delete $attrs->{class};
    }

    if ($fake_label)
    {
        return $self->h->div({
            class => "$class label",
            %$attrs
        }, $label);
    }
    else
    {
        return $self->h->label({
            id => 'label-' . $field->id,
            for => $field->id,
            class => $class || undef
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
    my $field = $self->_lookup_field($field_name) or return;

    my @selected = $field->multiple ? @{ $field->value || [] } : ( $field->value );

    my @options = map {
        my $option = $_;
        my $selected = @selected && first { $option->{value} eq $_ } @selected;
        $self->h->option({
            value => $_->{value},
            selected => $selected ? "selected" : undef,
        }, $_->{label})
    } @{ $field->options };

    if (!$field->required)
    {
        unshift @options, $self->h->option({
            selected => !defined $field->value ? "selected" : undef,
        }, ' ')
    }

    return $self->h->select({
        id => "id-" . $field->html_name,
        name => $field->html_name,
        multiple => $field->multiple ? "multiple" : undef,
        %{ $attrs || {} }
    }, \@options);
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
        $self->text($field->field('year'), { size => 4 }), ' - ',
        $self->text($field->field('month'), { size => 2 }), ' - ',
        $self->text($field->field('day'), { size => 2 }),
    ]);
}

sub artist_credit_editor
{
    my ($self, $field_name) = @_;
    my $field = $self->_lookup_field($field_name) or return;

    # Artist credit editor
    my $preview = $field->fif;
    my %gid_id_map = map { $_->artist->id => $_->artist->gid } grep { defined $_->artist } @{ $preview->names };

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

    return $self->h->div({ id => $field->html_name, class => 'artist-credit' }, [
        map {
            $self->h->div({ class => 'credit' }, $_)
        } @credits
    ]);
}

1;
