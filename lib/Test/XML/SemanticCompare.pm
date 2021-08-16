package Test::XML::SemanticCompare;

use strict;
use warnings;

use 5.008;

our $VERSION = '0.01';

use base 'Test::Builder::Module';
our @EXPORT = qw( is_xml_same );

use XML::SemanticDiff;

my $differ = XML::SemanticDiff->new(keepdata => 1);

sub is_xml_same {
    my $tb = __PACKAGE__->builder;
    my ($got, $expected, $msg) = @_;

    my @differences = $differ->compare($got, $expected);
    $tb->ok(@differences == 0, 'XML fragments are identical:');
    for my $difference (@differences) {
        $tb->diag($difference->{message});
        $tb->diag('Old value: ' . $difference->{old_value} )
            if $difference->{old_value};
        $tb->diag('New value: ' . $difference->{new_value} )
            if $difference->{new_value};
    }
}

1;
