
use Env::Path;
use FindBin qw( $Bin );

my @phantomjs = Env::Path->PATH->Whence('phantomjs');
my $phantomjs = scalar @phantomjs ? $phantomjs[0] :
    $ENV{HOME}.'/opt/phantomjs/bin/phantomjs';

my @xvfb_run = Env::Path->PATH->Whence('xvfb-run');
my $xvfb_run = $xvfb_run[0] if scalar @xvfb_run;

$testroot = "$Bin/../root/static/scripts/tests";
$testrunner = "$testroot/phantom-qunit.js";
$testsuite = "$testroot/all.html";

if (! -x $phantomjs)
{
    print "1..0 # Skipped: phantomjs not found, please set MUSICBRAINZ_PHANTOMJS or install phantomjs to the default locatioun";
}
elsif (! -x $xvfb_run)
{
    # FIXME: not needed if DISPLAY set.
    print "1..0 # Skipped: xvfb-run not found, please install it";
}
else
{
    print `$xvfb_run $phantomjs $testrunner $testsuite`
}
