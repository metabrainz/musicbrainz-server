package MusicBrainz::Server::Facade::Label;

use strict;
use warnings;

use base 'Class::Accessor';

__PACKAGE__->mk_accessors(qw{
    dissolved
    founded
    id
    name
    mbid
    resolution
});

sub entity_type { 'label' }

sub get_label { shift->{_l} }

sub subscriber_count
{
    my $self = shift;

    return scalar $self->{_l}->GetSubscribers;
}

sub has_complete_date
{
    my $self = shift;
    return $self->founded && $self->dissolved;
}

sub new_from_label
{
    my ($class, $label) = @_;

    $class->new({
        dissolved  => $label->end_date,
        founded    => $label->begin_date,
        id         => $label->GetId,
        name       => $label->GetName,
        mbid       => $label->GetMBId,
        resolution => $label->resolution,

        _l   => $label,
    });
}
1;
