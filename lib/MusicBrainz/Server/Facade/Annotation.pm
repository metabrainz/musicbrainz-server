package MusicBrainz::Server::Facade::Annotation;

use strict;
use warnings;

use base 'Class::Accessor';

__PACKAGE__->mk_accessors(qw{ last_modified });

sub short_text_as_html
{
    my $self = shift;
    $self->{_note}->GetShortTextAsHTML;
}

sub as_html
{
    my $self = shift;
    $self->{_note}->GetTextAsHTML;
}

sub new_from_annotation
{
    my ($class, $annotation) = @_;

    $class->new({
        _note         => $annotation,

        last_modified => $annotation->GetCreationTime,
    });
}

1;
