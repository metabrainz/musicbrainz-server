package MusicBrainz::Server::WebService::2::Representation::XML::DateSpan;
use Moose;
use XML::Tags qw( life_span );

with 'MusicBrainz::Server::WebService::2::Representation::XML::Serializer';

sub element { 'life-span' }

sub predicate {
    my ($self, $span) = @_;

    warn <life_span>, "Hello";
    my ($begin, $end) = @$span;
    return !($begin->is_empty && $end->is_empty);
}

sub serialize_inner {
    my ($self, $span) = @_;
    my ($begin, $end) = @$span;

    return $self->xml->life_span(
        !$begin->is_empty ? $self->xml->begin($begin->format) : (),
        !$end->is_empty ? $self->xml->end($end->format) : (),
    )
}

1;
