use Test::More;
use Encode;
use Env::Path;
use File::Slurp qw( read_file );
use FindBin qw( $Bin );
use MusicBrainz::Server;

my @phantomjs = Env::Path->PATH->Whence('phantomjs');
my $phantomjs = scalar @phantomjs ? $phantomjs[0] :
    ($ENV{MUSICBRAINZ_PHANTOMJS} ? $ENV{MUSICBRAINZ_PHANTOMJS} :
     $ENV{HOME}.'/opt/phantomjs/bin/phantomjs');

$root = "$Bin/../root";

if (! -x $phantomjs) {
    plan skip_all => "phantomjs not found, please set MUSICBRAINZ_PHANTOMJS or install phantomjs to the default location";
} else {
    # TAP::Harness::JUnit expects output to be UTF-8 encoded:
    # https://github.com/jlavallee/tap-harness-junit/blob/master/lib/TAP/Harness/JUnit.pm#L365
    print encode('UTF-8', qx{ $phantomjs $root/static/build/tests.js });
    exit $?;
}
