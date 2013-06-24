package MusicBrainz::Server::Wizard;
use Moose;
use Carp qw( croak );
use MusicBrainz::DataStore::Redis;
use MusicBrainz::Server::Form::Utils qw( expand_param expand_all_params collapse_param );

has '_datastore' => (
    is => 'rw',
    isa => 'MusicBrainz::DataStore',
    default => sub { return MusicBrainz::DataStore::Redis->new; }
);

has '_current' => (
    is => 'rw',
    isa => 'Int',
    default => 0
);

has '_processed_page' => (
    is => 'rw',
    isa => 'MusicBrainz::Server::Form::Step',
    predicate => '_has_processed_page',
    clearer => '_clear_processed_page',
);

has '_session_id' => (
    is => 'rw',
    isa => 'Str',
);

has 'c' => (
    is => 'rw',
    isa => 'Object'
);

has 'loading' => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
);

has 'submitted' => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
);

has 'cancelled' => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
);

has 'page_number' => (
    is => 'ro',
    isa => 'HashRef',
    lazy => 1,
    default => sub {
        my $self = shift;
        my $max = scalar @{ $self->pages } - 1;
        my %ret;
        for (0..$max)
        {
            $ret{$self->pages->[$_]->{name}} = $_;
        }

        return \%ret;
    },
);

has 'pages' => (
    isa => 'ArrayRef',
    is => 'ro',
    required => 1,
    lazy => 1,
    builder => '_build_pages'
);

has $_ => (
    isa => 'CodeRef',
    traits => [ 'Code' ],
    default => sub { sub {} },
    handles => {
        $_ => 'execute',
    }
) for qw( on_cancel on_submit );

sub skip {
    my $self = shift;

    my $skip = $self->pages->[$self->_current]->{skip};
    return defined $skip ? &$skip : 0;
}

sub valid {
    my ($self, $page) = @_;

    return $page->validated;
}

# The steps a request goes through to render a single page in the wizard:
#
#     [ sub process ]
#
#  1. Process submit data from the previous page
#  2. Save submitted data in session
#  3. Route to the next page (process conditionals)
#
#     [ sub navigate_to_page (also called from _route) ]
#
#  4. Load previously saved data for this page from session
#
#     [ sub render ]
#
#  5. Load form and associated template
#  6. Add tab buttons for each step to the stash

sub _create_new_wizard {
    my ($self, $c) = @_;
    return !$c->form_posted || !$c->req->params->{wizard_session_id};
}

sub process
{
    my ($self) = @_;
    my $page;

    if ($self->_create_new_wizard($self->c)) {
        $self->_new_session;
        $self->load($self->init_object);
        $self->seed($self->c->req->params)
            if $self->c->form_posted;

        $page = $self->navigate_to_page;
    }
    elsif ($self->c->form_posted) {
        $self->_retrieve_wizard_settings;
        $page = $self->_store_page_in_session;
        $page = $self->_route ($page);
    }
    else
    {
        # Shouldn't come here.
        croak "Error processing wizard.";
    }

    $self->render ($page) if $page;
}

sub initialize
{
    my ($self, $init_object) = @_;

    # if init_object is set, load it in _all_ the forms to deflate all fields
    # from the init_object in one go.  For each form store the ->value (deflated)
    # data in the session.
    if ($init_object)
    {
        my $max = scalar @{ $self->pages } - 1;
        $self->_processed_page ($self->_load_page (0, $init_object));

        for (1..$max)
        {
            $self->_load_page ($_, $init_object);
        }
    }
}


sub navigate_to_page
{
    my $self = shift;

    my $prepare = $self->pages->[$self->_current]->{prepare};
    &$prepare if defined $prepare;

    # If we're rendering the same page we processed, re-use the existing form.
    # (otherwise validation errors may get lost).
    return $self->_has_processed_page ? $self->_processed_page :
        $self->_load_page ($self->_current);
}

sub render
{
    my ($self, $page) = @_;

    my @steps = map {
        { title => $_->{title}, name => 'step_'.$_->{name} }
    } @{ $self->pages };
    $steps[$self->_current]->{current} = 1;

    $self->c->stash->{template} = $self->pages->[$self->_current]->{template};
    $self->c->stash->{form} = $page;
    $self->c->stash->{wizard} = $self;
    $self->c->stash->{page_id} = $self->_current;
    $self->c->stash->{steps} = \@steps;

    # mark the current page as having been shown to the user.
    $self->shown ($self->_current, 1);
}

sub shown
{
    my ($self, $key, $val) = @_;

    $self->_store ("shown_$key", $val) if $val;

    return $self->_store ("shown_$key");
}

# returns the name of the current page.
sub current_page
{
    my $self = shift;

    return $self->pages->[$self->_current]->{name};
}

sub load_page
{
    my ($self, $step, $init_object) = @_;

    my $page = $self->page_number->{$step};
    $page = $step unless defined $page;

    return $self->_load_page ($page, $init_object);
}

sub _load_page
{
    my ($self, $page, $init_object) = @_;

    if ($init_object)
    {
        my $form = $self->_load_form ($page, init_object => $init_object);

        $form->field('wizard_session_id')->value ($self->_session_id);
        $self->_store ("step_$page", $form->serialize);

        return $form;
    }

    my $serialized = $self->_store ("step_$page") || {};

    return $self->_load_form ($page, serialized => $serialized);
}

sub get_value
{
    my ($self, $page, $key) = @_;

    my $serialized = $self->_store ("step_" . $self->page_number->{$page});

    return expand_param ($serialized->{values}, $key);
}

sub set_value
{
    my ($self, $page, $key, $value) = @_;

    my $serialized = $self->_store ("step_" . $self->page_number->{$page});

    collapse_param ($serialized->{values}, $key, $value);

    $self->_store ("step_" . $self->page_number->{$page}, $serialized);
}

sub value
{
    my ($self) = @_;

    my %data;
    for my $pageno (values %{ $self->page_number })
    {
        my $values = $self->_store ("step_$pageno")->{values};
        my $page_data = expand_all_params ($values);
        while (my ($key, $value) = each %$page_data)
        {
            $data{$key} = $value;
        }
    }

    return \%data;
}

sub _store_page_in_session
{
    my ($self) = @_;

    my $page = $self->_post_to_page( $self->_current, $self->c->request->params );

    # Save the processed page, if we're not navigating away from it we do not
    # want to reload it.
    $self->_processed_page ($page);

    return $page;
}

=method _transform_parameters

Allows wizards to provide their own transformation of parameters before they
are passed into the form. This may allow the wizard to take multiple representations
of POST data, for example (as in the case of the release editor).

=cut

sub _seed_parameters {
    my ($self, $params) = @_;
    return $params;
}

sub seed {
    my ($self, $params) = @_;
    $params = $self->_seed_parameters($params);

    my $max = scalar @{ $self->pages } - 1;
    for (0..$max) {
        $self->_post_to_page($_, $params);
    }

    # Reload page 0 with the seeded data.
    $self->_processed_page ($self->_load_page (0));
}

sub _post_to_page
{
    my ($self, $page_id, $params) = @_;

    # Hard coding this, not too intelligent?
    # It's here so we can call _post_to_page from other stuff and it doesn't
    # have to specify the wizard id...
    $params->{wizard_session_id} ||= $self->_session_id;

    my $page = $self->_load_form ($page_id);
    $page->unserialize ( $self->_store ("step_$page_id"), $params );

    $self->_store ("step_$page_id", $page->serialize);

    return $page;
}

sub _route
{
    my ($self, $page) = @_;

    my $p = $self->c->request->parameters;
    my $previous = $self->_current;
    my $requested = $self->_current;
    my $allow_skip = 1;
    if (defined $p->{next})
    {
        return $self->navigate_to_page unless $self->valid ($page);
        $requested++;
    }
    elsif (defined $p->{previous})
    {
        $requested--;
    }
    elsif (defined $p->{cancel})
    {
        $self->on_cancel($self);
        return;
    }
    elsif (defined $p->{save})
    {
        return $self->navigate_to_page unless $self->valid ($page);
        $self->submitted(1);
        return;
    }
    else
    {
        # Only skip pages when using "Previous" and "Next" buttons, do not
        # allow skipping when a page tab has been clicked directly.
        $allow_skip = 0;
        my $max = scalar @{ $self->pages } - 1;
        for (0..$max)
        {
            $requested = $_;
            last if defined $p->{'step_'.$self->pages->[$_]->{name}};
        }
    }

    # we are already at the requested position.
    return $self->navigate_to_page if $requested == $self->_current;

    if ($requested < $self->_current)
    {
        # navigate to previous pages, skipping pages which need to be skipped.
        while ($requested < $self->_current || ($allow_skip && $self->skip))
        {
            last unless $self->find_previous_page;
            $page = $self->navigate_to_page;
        }
    }
    else
    {
        if (my $submit = $self->pages->[$self->_current]->{submit}) {
            $submit->();
        }

        # validate each page when moving forward.
        # - if a page is not valid, stop there.
        # - if a page should be skipped, skip it.
        while (($allow_skip && $self->skip) ||
               ($self->valid ($page) && $requested > $self->_current))
        {
            last unless $self->find_next_page;
            $page = $self->navigate_to_page;
        }
    }

    if ($requested != $self->_current)
    {
        # The user did not end up on the page s/he requested, perhaps s/he should be
        # informed of this -- otherwise it may be a bit confusing.

        # FIXME: add notification
    }

    if ($previous == $self->_current)
    {
        # We haven't moved away from the current page, which means navigate_to_page
        # hasn't been called yet for this page.
        $page = $self->navigate_to_page;
    }

    return $page;
}

sub find_next_page
{
    my ($self) = @_;

    my $page = $self->_current;
    $self->_current ($page + 1);

    return $self->_current > $page;
}

sub find_previous_page
{
    my ($self) = @_;

    my $page = $self->_current;
    $self->_current ($page - 1);

    return $self->_current < $page;
}

around '_current' => sub {
    my ($orig, $self, $value) = @_;

    return $self->$orig () unless defined $value;

    # navigating away from the page just processed, so clear it.
    $self->_clear_processed_page if $self->$orig () ne $value;

    my $max = scalar @{ $self->pages } - 1;

    $value = 0 if $value < 0;
    $value = $max if $value > $max;

    return $self->$orig ($value);
};

sub _store
{
    my ($self, $key, $value) = @_;

    $key = "wizard:".$self->_session_id.":$key";

    if (defined $value)
    {
        $self->_datastore->set ($key, $value);
        $self->_datastore->expire ($key, DBDefs->SESSION_EXPIRE);
    }
    else
    {
        $value = $self->_datastore->get ($key);
    }

    return $value;
}

sub _retrieve_wizard_settings
{
    my ($self) = @_;

    my $p = $self->c->request->parameters;

    return if $self->_session_id;

    # FIXME: this will break if the form has a name...
    return $self->_new_session unless $p->{wizard_session_id};

    $self->_session_id ($p->{wizard_session_id});
    $self->_current ($p->{wizard_page_id});
}

sub _new_session
{
    my ($self) = @_;

    # In the case that global_wizard_id is undef, set it to 0. ->incr
    # requires an existing, integer valued key.
    $self->_datastore->add('global_wizard_id', 0);
    $self->_session_id($self->_datastore->incr('global_wizard_id'));
    $self->_store ('wizard', 1);
    $self->_current (0);
}

sub _load_form
{
    my ($self, $page, %args) = @_;

    my $form_name = "MusicBrainz::Server::Form::".$self->pages->[$page]->{form};
    Class::MOP::load_class($form_name);

    my $form;
    if (defined $args{init_object})
    {
        $form = $form_name->new (%args, ctx => $self->c );
    }
    else
    {
        $form = $form_name->new ( ctx => $self->c );
        $form->unserialize ( $args{serialized} ) if $args{serialized};
    }

    return $form;
}

=head1 LICENSE

Copyright (C) 2010-2011 MetaBrainz Foundation

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
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=cut

1;

