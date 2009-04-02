package MusicBrainz::Server::Wizard;
use Moose;
use MooseX::AttributeHelpers;
use MooseX::Storage;

use Carp;
use MusicBrainz::Server::Wizard::Step;

=head1 NAME

    MusicBrainz::Server::Wizard - create multistep wizards with non-deterministic
    movement

=head1 SYNOPSIS

    my $wizard = MusicBrainz::Server::Wizard->new(
        store => MusicBrainz::Server::Wizard::AddRelease,
        steps => [
            'track_count' =>
            'release_data' =>
            'check_duplicates' => {
                skip => sub { shift->not_duplicate },
            }
            'confirm_artists' => {
                skip => sub { !shift->has_unconfirmed_artists },
            },
            'confirm_labels' => {
                skip => sub { !shift->has_unconfirmed_labels }
            },
            'preview'
        ]
    );

=head1 DESCRIPTION

This allows you to create a multistep wizard, and specify conditions to skip
certain stages. Movement through the wizard is done with L<progress>, which
returns the next L<MusicBrainz::Server::Wizard::Step>.

=head1 ATTRIBUTES

=head2 store

An instance of a store - somewhere data is stored as the wizard progresses.

=head2 current_step

The step the wizard is currently on. This may be undefined if the wizard has not
been started (via L<progress>).

=cut

has 'store' => (
    isa => 'Object',
    is  => 'ro',
);

has 'steps' => (
    isa => 'ArrayRef[MusicBrainz::Server::Wizard::Step]',
    is  => 'ro',
    required => 1,
    metaclass => 'Collection::List',
    provides => {
        count => 'total_steps',
    }
);

has 'current_step' => (
    isa => 'MusicBrainz::Server::Wizard::Step',
    is  => 'rw',
);

has 'current_step_index' => (
    isa => 'Int',
    is  => 'rw',
    default => 0,
    metaclass => 'Counter',
    provides => {
        inc => '_next_step',
    },
    trigger => sub {
        my ($self, $new_index) = @_;
        return unless $new_index;

        $self->current_step($self->steps->[$new_index]);
    }
);

=head1 METHODS

=head2 new

=over4

=item steps

A list of steps in the wizard.

Each step is a name, followed by an optional hash reference, that will be passed
to C<MusicBrainz::Server::Wizard::Step::new>.

=back

=cut

sub BUILDARGS
{
    my ($self, %args) = @_;
    my @steps;

    while (my $step = shift @{ $args{steps} })
    {
        if (ref $step && $step->isa('MusicBrainz::Server::Wizard::Step'))
        {
            push @steps, $step;
        }
        else
        {
            my $args = ref $args{steps}->[0] eq 'HASH'
                ? shift @{ $args{steps} }
                : {};

            $args->{action_name} = $step;

            push @steps, MusicBrainz::Server::Wizard::Step->new($args);
        }
    }

    return {
        steps => [ @steps ],
        store => $args{store},
    };
}

sub BUILD
{
    my $self = shift;
    $self->current_step($self->steps->[0]);
}

=head2 progress

Progress the wiard onwards, or start the wizard if it has not been run.

=cut

sub progress
{
    my $self = shift;

    # Make sure we're not already at the last step
    return $self->current_step
        if $self->current_step_index == ($self->total_steps - 1);

    # Move to the next possible step
    $self->_next_step;
    $self->current_step($self->steps->[$self->current_step_index]);

    # Keep skipping steps if we meet the step's skip condition.
    while ($self->current_step->has_skip_condition && &{$self->current_step->skip}($self->store))
    {
        $self->_next_step;
        $self->current_step($self->steps->[$self->current_step_index]);
    };

    return $self->current_step;
}

1;
