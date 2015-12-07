use Encode;
use FindBin qw( $Bin );

# TAP::Harness::JUnit expects output to be UTF-8 encoded:
# https://github.com/jlavallee/tap-harness-junit/blob/master/lib/TAP/Harness/JUnit.pm#L365
print encode('UTF-8', qx{ node "$Bin/../root/static/scripts/tests/node-runner.js" });
exit $?;
