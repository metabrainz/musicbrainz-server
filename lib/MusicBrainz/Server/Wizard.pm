package MusicBrainz::Server::Wizard;
use Moose;

has 'name' => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has '_current' => (
    is => 'rw',
    isa => 'Int',
    default => 0,
    trigger => \&_set_current,
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
    required => 1
);

sub skip { return 0; }

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
#     [ sub render ]
#
#  4. Load previously saved data for this page from session
#  5. Load form and associated template
#  6. Add tab buttons for each step to the stash

sub process
{
    my ($self) = @_;

    if ($self->c->request->method ne 'POST')
    {
        $self->_new_session;
        return $self->loading (1);
    }

    $self->_retrieve_wizard_settings;
    my $page = $self->_store_page_in_session;
    $self->_route ($page);
    $self->_store_wizard_settings;

    return;
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
        for (0..$max)
        {
            $self->_load_page ($_, $init_object);
        }
    }
}

sub render
{
    my ($self) = @_;

    my $page = $self->_load_page ($self->_current);

    my @steps = map {
        { title => $_->{title}, name => 'step_'.$_->{name} }
    } @{ $self->pages };
    $steps[$self->_current]->{current} = 1;

    $self->c->stash->{template} = $self->pages->[$self->_current]->{template};
    $self->c->stash->{form} = $page;
    $self->c->stash->{wizard} = $self;
    $self->c->stash->{steps} = \@steps;
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
        $self->_store->{"step ".$page} = $form->serialize;
    }

    my $serialized = $self->_store->{"step ".$page} || {};

    return $self->_load_form ($page, serialized => $serialized);
}

sub value
{
    my ($self) = @_;

    my %ret;
    my $max = scalar @{ $self->pages } - 1;
    for (0..$max)
    {
        my $value = $self->_load_page ($_)->value;

        @ret{keys %$value} = values %$value;
    }

    return \%ret;
}

sub _store_page_in_session
{
    my ($self) = @_;

    my $page = $self->_load_form ($self->_current);

    $page->unserialize ( $self->_store->{"step ".$self->_current},
                         $self->c->request->parameters );

    $self->_store->{"step ".$self->_current} = $page->serialize;

    return $page;
}

sub _route
{
    my ($self, $page) = @_;

    my $valid = $self->valid ($page);

    my $p = $self->c->request->parameters;
    if (defined $p->{next} && $valid)
    {
        return $self->find_next_page;
    }
    elsif (defined $p->{previous})
    {
        return $self->find_previous_page;
    }
    elsif (defined $p->{cancel})
    {
        return $self->cancelled (1);
    }
    elsif (defined $p->{save})
    {
        return $self->submitted (1);
    }

    # Don't allow forward movement unless the current page is valid.
    my $max = $valid ? scalar @{ $self->pages } - 1 : $self->_current;

    for (0..$max)
    {
        my $name = 'step_'.$self->pages->[$_]->{name};
        if (defined $p->{$name})
        {
            $self->_current ($_);
            return;
        }
    }
}

sub find_next_page
{
    my ($self) = @_;

    my $page = $self->_current;

    my $max = scalar @{ $self->pages } - 1;

    while ($page < $max)
    {
        $page += 1;

        if (!$self->skip ($page))
        {
            $self->_current ($page);
            return 1;
        }
    }

    # FIXME: should probably notify someone that their form is broken.
    return 0;
}

sub find_previous_page
{
    my ($self) = @_;

    my $page = $self->_current;

    while ($page > 0)
    {
        $page -= 1;

        if (!$self->skip ($page))
        {
            $self->_current ($page);
            return 1;
        }
    }

    # FIXME: should probably notify someone that their form is broken.
    return 0;
}

sub _set_current
{
    my ($self, $value) = @_;

    my $max = scalar @{ $self->pages } - 1;

    $value = 0 if $value < 0;
    $value = $max if $value > $max;

    $self->{_current} = $value;
}

sub _store
{
    my ($self) = @_;

    if (!defined $self->c->session->{wizard}->{$self->_session_id})
    {
        $self->c->session->{wizard}->{$self->_session_id} = {};
    }

    return $self->c->session->{wizard}->{$self->_session_id};
}

sub _retrieve_wizard_settings
{
    my ($self) = @_;

    $self->c->stash->{things} = "";

    my $p = $self->c->request->parameters;

    # FIXME: this will break if the form has a name...
    return $self->_new_session unless $p->{wizard_session_id};

    $self->_session_id ($p->{wizard_session_id});

    $self->_current( $self->_store->{current} ) if defined $self->_store->{current};
}

sub _new_session
{
    my ($self) = @_;

    my $session_id = rand;
    while (defined $self->c->session->{wizard}->{$session_id})
    {
        $session_id = rand;
    }
    $self->c->session->{wizard}->{$session_id} = {};
    $self->_session_id( $session_id );

    $self->_store_wizard_settings;
}

sub _store_wizard_settings
{
    my ($self) = @_;

    $self->_store->{current} = $self->_current;
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

1;
