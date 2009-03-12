package MusicBrainz::Server::Wizards::AddRelease::ReleaseEvent;
use Moose;
use MooseX::Storage;

with Storage;

use MusicBrainz::Server::ReleaseEvent;

has 'label' => (
    isa => 'Str',
    is  => 'rw',
);

has 'label_id' => (
    isa => 'Int',
    is  => 'rw',
    predicate => 'confirmed',
    clearer => 'clear_label_id',
);

has 'removed' => (
    isa => 'Bool',
    is  => 'rw',
);

has ['barcode', 'format', 'catno', 'country', 'date'] => ( is => 'rw' );

before 'label' => sub
{
    my $self = shift;

    if (@_)
    {
        my $new_name = shift;
        $self->clear_label_id
            if $new_name ne $self->label;
    }
};

sub to_event
{
    my $self = shift;

    return MusicBrainz::Server::ReleaseEvent->new(
        undef,
        releasedate => $self->date,
        barcode => $self->barcode,
        format => $self->format,
        catno => $self->catno,
        country => $self->country,
        _label => MusicBrainz::Server::Label->new(
            undef,
            name => $self->label,
            id => $self->label_id,
        ),
    );
}

1;
