package Test::XML::SemanticCompare;

use strict;
use warnings;

use 5.008;

our $VERSION = '0.01';

use base 'Test::Builder::Module';
our @EXPORT = qw( is_xml_same );

use XML::SemanticDiff;

my $differ = XML::SemanticDiff->new;

sub is_xml_same {
    my $tb = __PACKAGE__->builder;
    my ($got, $expected, $msg) = @_;

    my @differences = $differ->compare($expected, $got);
    $tb->ok(@differences == 0, 'XML fragments are identical:');
    $tb->diag(join "\n", map { $_->{message} } @differences) if @differences;
}

1;
