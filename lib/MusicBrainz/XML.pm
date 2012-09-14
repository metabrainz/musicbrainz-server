package MusicBrainz::XML;
use Moose;

sub AUTOLOAD {
    my $self = shift;

    my ($tag) = our $AUTOLOAD =~ /.*::(.*)/;
    $tag =~ s/_/-/g;

    my %attrs = ref($_[0]) eq 'HASH' ? %{ shift() } : ();

    return bless {
        tag => $tag,
        attrs => \%attrs,
        body => [ map {
            ref($_) eq 'MusicBrainz::XML::Element' ||
            ref($_) eq 'MusicBrainz::XML::Raw'
                ? $_
                : bless(\"$_", 'MusicBrainz::XML::Text')
        } @_ ]
    }, 'MusicBrainz::XML::Element';
}

sub _escape {
	my $t = $_[0];

    return '' unless defined($t);

    # Remove control characters as they cause XML to not be parsed
    $t =~ s/[\x00-\x08\x0A-\x0C\x0E-\x1A]//g;

    $t =~ s/\xFFFD//g;             # remove invalid characters
	$t =~ s/&/&amp;/g;             # remove XML entities
	$t =~ s/</&lt;/g;
	$t =~ s/>/&gt;/g;
	$t =~ s/"/&quot;/g;

	return $t;
}

sub BUILDARGS { return () }

package MusicBrainz::XML::Element;
use overload '""' => \&as_string;

sub as_string {
    my $element = shift;
    my $tag = $element->{tag};
    my %attrs = %{ $element->{attrs} };
    my $body = join('', @{ $element->{body} });
    my @attributes =
        map { "$_=" . q{"} . MusicBrainz::XML::_escape($attrs{$_}) . q{"} }
        grep { defined $attrs{$_} } keys %attrs;

    if (defined($body) && $body ne '') {
        return
            q{<} . join(' ', $tag, @attributes) . q{>} .
                $body .
            "</$tag>";
    }
    else {
        return
            q{<} . join(' ', $tag, @attributes) . q{ />};
    }
}

sub evaluate {
    my $self = shift;
    my $v = $self->as_string;
    return bless \$v, 'MusicBrainz::XML::Raw';
}

package MusicBrainz::XML::Text;
use overload '""' => \&as_string;

sub as_string {
    return MusicBrainz::XML::_escape(${ shift() });
}

package MusicBrainz::XML::Raw;
use overload '""' => \&as_string;

sub as_string { return ${ shift() } }

1;
