package LocaleSaver;

our $VERSION = '1.00';

=head1 NAME

LocaleSaver - save and restore selected locale

=head1 SYNOPSIS

    use LocaleSaver;
    use POSIX ':locale_h';

    {
       my $saver = new LocaleSaver(TYPE, LOCALE);
       # LOCALE is selected for TYPE
    }
    # previous locale for TYPE is selected

    {
       my $saver = new LocaleSaver(TYPE);
       # new locale for TYPE may be selected, or not
    }
    # previous locale for TYPE is selected

=head1 DESCRIPTION

A C<LocaleSaver> object contains a reference to the locale for TYPE that
was in effect when it was created.  If its C<new> method gets an extra
parameter, then that parameter is set as the current locale for TYPE;
otherwise, the current locale for TYPE remains unchanged.

When a C<LocaleSaver> is destroyed, it re-selects the locale
that was selected when it was created.

=cut

require 5.000;
use Carp;
use Symbol;
use POSIX 'setlocale';

sub new {
    @_ >= 2 && @_ <= 3 or croak 'usage: new LocaleSaver TYPE [,LOCALE]';
    my ($class, $type, $locale) = @_;
    my $old = setlocale($type);
    my $self = bless [$type, $old], $class;
    setlocale($type, $locale)
	or die "setlocale($type, $locale): $!"
	    if @_ == 3;
    $self;
}

sub DESTROY {
    my $this = $_[0];
    setlocale $$this[0], $$this[1];
}

1;
