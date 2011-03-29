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
    check => 'check_ok',
    click => 'click_ok',
    clickAndWait => sub {
        my $sel = shift;
        $sel->click_ok(@_);
        $sel->wait_for_page_to_load_ok(30000)
    },
    fireEvent => 'fire_event_ok',
    focus => 'focus_ok',
    open => 'open_ok',
    select => 'select_ok',
    type => 'type_ok',
    uncheck => 'uncheck_ok',
    verifyElementNotPresent => sub {
        $tb->ok(not shift->is_element_present(@_));
    },
    verifyElementPresent => 'is_element_present_ok',
    verifyText => 'text_is',
    verifyTextNotPresent => sub {
        $tb->ok(not shift->is_text_present(@_));
    },
    verifyTextPresent => 'is_text_present_ok',
    verifyNotVisible => sub {
        $tb->ok(not shift->is_visible(@_));
    },
    verifyVisible => 'is_visible',
    verifyNotValue => sub {
        $tb->ok(not shift->value_is(@_));
    },
    verifyValue => 'value_is',
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
    waitForNotValue => sub {
        my $sel = shift;
      WAIT: {
          for (1..$timeout_in_seconds) {
              if (eval { $_[1] ne $sel->get_value($_[0]) }) {
                  $tb->ok(1, $_[0] . ' does not have value ' . $_[1]);
                  last WAIT
              }
              sleep(1);
          }
          $tb->ok(0, $_[0] . ' has value ' . $_[1]);
        }
    },
    waitForVisible => sub {
        my $sel = shift;
      WAIT: {
          for (1..$timeout_in_seconds) {
              if (eval { $sel->is_visible($_[0]) }) {
                  $tb->ok(1, $_[0] . ' is visible');
                  last WAIT
              }
              sleep(1);
          }
          $tb->ok(0, $_[0] . ' is not visible');
        }
    },
    waitForText => sub {
        my $sel = shift;
      WAIT: {
          for (1..$timeout_in_seconds) {
              if (eval { $_[1] eq $sel->get_text($_[0]) }) {
                  $tb->ok(1, 'Text of ' . $_[0] . ' is ' . $_[1]);
                  last WAIT
              }
              sleep(1);
          }
          $tb->ok(0, "Text of ${_[0]} is ".$sel->get_text($_[0])." but expected ${_[1]}");
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
