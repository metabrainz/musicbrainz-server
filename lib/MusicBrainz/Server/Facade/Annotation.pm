package MusicBrainz::Server::Facade::Annotation;

use strict;
use warnings;

use base 'Class::Accessor';

__PACKAGE__->mk_accessors(qw{ last_modified text });

sub short_text_as_html
{
    my $self = shift;
    $self->{_note}->GetShortTextAsHTML;
}

sub as_html
{
    my $self = shift;
    $self->{_note}->text_as_html;
}

sub new_from_annotation
{
    my ($class, $annotation) = @_;

    $class->new({
        _note         => $annotation,

        last_modified => $annotation->GetCreationTime,
        text          => $annotation->text,
    });
}

1;
