use Test::More;
use Env::Path;
use File::Slurp qw( read_file );
use FindBin qw( $Bin );
use MusicBrainz::Server;

my @phantomjs = Env::Path->PATH->Whence('phantomjs');
my $phantomjs = scalar @phantomjs ? $phantomjs[0] :
    ($ENV{MUSICBRAINZ_PHANTOMJS} ? $ENV{MUSICBRAINZ_PHANTOMJS} :
     $ENV{HOME}.'/opt/phantomjs/bin/phantomjs');

$root = "$Bin/../root";
$testroot = "$root/static/scripts/tests";
$testrunner = "$root/static/lib/qunit-tap/sample/js/run_qunit.js";
$testsuite = "$testroot/all.html";

sub generate_text_strings {
    my $input = read_file("$root/scripts/text_strings.tt");
    my $output = "";

    my $tt = Template->new(
        INCLUDE_PATH    => "$root",
        PLUGIN_BASE     => "MusicBrainz::Server::Plugin",
        PRE_PROCESS     => [ "components/common-macros.tt" ],
        ENCODING        => "UTF-8",
    );

    $tt->process(\$input, {}, \$output) or die $_;

    open(my $fh, ">$root/static/tests/text.js");
    binmode $fh, ":utf8";
    print $fh $output;
    close $fh;
}

if (! -x $phantomjs)
{
    plan skip_all => "phantomjs not found, please set MUSICBRAINZ_PHANTOMJS or install phantomjs to the default location";
}
else {
    generate_text_strings();
    exec($phantomjs, $testrunner, $testsuite);
}
