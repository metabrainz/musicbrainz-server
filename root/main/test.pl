
use Template::Parser;

use Data::Dumper;

my $parser   = Template::Parser->new();

my $text = <>;

$data = $parser->parse($text) || die $parser->error();

print Dumper($data);


