package Test::WWW::Selenium::Parser;
use Moose;

use Time::HiRes qw(sleep);
use Test::Builder;
use aliased 'Test::WWW::Selenium::Parser::Test';

my $timeout_in_seconds = 60;

has test_runner => (
    is => 'ro',
    required => 1
);

my $tb = Test::Builder->new;
our %dispatch = (
    assertValue => 'value_is',
    click => 'click_ok',
    clickAndWait => sub {
        my $sel = shift;
        $sel->click_ok(@_);
        $sel->wait_for_page_to_load_ok(30000)
    },
    fireEvent => 'fire_event_ok',
    open => 'open_ok',
    select => 'select_ok',
    type => 'type_ok',
    verifyElementNotPresent => sub {
        $tb->ok(not shift->is_element_present(@_));
    },
    verifyElementPresent => 'is_element_present_ok',
    verifyText => 'text_is',
    verifyTextNotPresent => sub {
        $tb->ok(not shift->is_text_present(@_));
    },
    waitForElementPresent => sub {
        my $sel = shift;
        WAIT: {
              for (1..$timeout_in_seconds) {
                  if (eval { $sel->is_element_present($_[0]) }) {
                      $tb->ok(1, 'Found ' . $_[0]);
                      last WAIT
                  }
                  sleep(1);
              }
              $tb->ok(0, 'Could not find: ' . $_[0]);
          }
    },
);

sub BUILDARGS {
    my ($self, %args) = @_;
    $args{test_runner} ||= Test::WWW::Selenium->new(%args);
    return \%args;
}

sub run_test {
    my ($self, $test) = @_;
    $tb->new->subtest($test->name, sub {
        for my $command ($test->commands) {
            my $method = $dispatch{$command->command}
                or die 'Cannot dispatch ' . $command->command;

            if (ref($method) eq 'CODE') {
                $method->($self->test_runner, $command->args);
            }
            else {
                $self->test_runner->$method($command->args);
            }
        }
    });
}

sub parse {
    my ($self, $file) = @_;
    return Test->new_from_file($file, runner => $self);
}

1;
