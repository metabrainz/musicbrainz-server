use Test::More;
use Env::Path;
use FindBin qw( $Bin );

my @phantomjs = Env::Path->PATH->Whence('phantomjs');
my $phantomjs = scalar @phantomjs ? $phantomjs[0] :
    ($ENV{MUSICBRAINZ_PHANTOMJS} ? $ENV{MUSICBRAINZ_PHANTOMJS} :
     $ENV{HOME}.'/opt/phantomjs/bin/phantomjs');

$testroot = "$Bin/../root/static/scripts/tests";
$testrunner = "$Bin/../root/static/lib/qunit-tap/sample/js/run_qunit.js";
$testsuite = "$testroot/all.html";

if (! -x $phantomjs)
{
    plan skip_all => "phantomjs not found, please set MUSICBRAINZ_PHANTOMJS or install phantomjs to the default location";
}
else {
    exec ($phantomjs, $testrunner, $testsuite);
}
