use Encode;
use FindBin qw( $Bin );

$ENV{MUSICBRAINZ_RUNNING_TESTS} = 1;

system "$Bin/../script/dump_js_type_info.pl";

# TAP::Harness::JUnit expects output to be UTF-8 encoded:
# https://github.com/jlavallee/tap-harness-junit/blob/master/lib/TAP/Harness/JUnit.pm#L365
print encode('UTF-8', qx{ node "$Bin/../root/static/build/tests.js" });
exit $?;
