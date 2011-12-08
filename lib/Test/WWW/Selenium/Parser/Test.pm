package Test::WWW::Selenium::Parser::Test;
use Moose;

use autodie;
use XML::LibXML;

has runner => (
    is => 'ro',
);

sub run {
    my $self = shift;
    $self->runner->run_test($self);
}

has name => (
    isa => 'Str',
    required => 1,
    is => 'ro',
);

has commands => (
    isa => 'ArrayRef',
    is => 'bare',
    required => 1,
    traits => [ 'Array' ],
    handles => {
        commands => 'elements',
    }
);

sub new_from_file {
    my ($class, $file, @args) = @_;
    open(my $test_fh, '<', $file);
    my $dom = XML::LibXML->load_html( string => do { local $/ = undef; <$test_fh> } );
    my $xpc = XML::LibXML::XPathContext->new($dom);

    sub node_to_string {
        # FIXME: do some proper html decoding here.
        return join ("", map {
            my $str = $_->toString;
            $str =~ s,&gt;,>,g;
            $str =~ s,<br />,\n,g;
            $str
        } shift->getChildNodes);
    };

    return $class->new(
        name => $file,
        commands => [
            map {
                Test::WWW::Selenium::Parser::Command->new(
                    command => $_->[0]->string_value,
                    args => do {
                        my (undef, @args) = map { node_to_string ($_) } @$_;
                        \@args
                    }
                )
            }
            map +[ $xpc->find('td', $_)->get_nodelist ],
                $xpc->find('//tbody/tr')->get_nodelist
        ],
        @args
    );
}

package Test::WWW::Selenium::Parser::Command;
use Moose;

has command => (
    isa => 'Str',
    required => 1,
    is => 'ro',
);

has args => (
    isa => 'ArrayRef',
    is => 'bare',
    required => 1,
    traits => [ 'Array' ],
    handles => {
        args => 'elements',
    }
);

1;
