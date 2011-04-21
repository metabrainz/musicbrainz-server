use strict;
use warnings;

package MusicBrainz::XML::Generator;
use base 'XML::Generator';

sub AUTOLOAD {
    my $self = shift;

    my ($tag) = our $AUTOLOAD =~ /.*::(.*)/;
    $tag =~ s/_/-/g;

    return $self->XML::Generator::util::tag($tag, @_);
}

1;
