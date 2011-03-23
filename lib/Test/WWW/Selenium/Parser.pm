package Test::WWW::Selenium::Parser;
use Moose;

use Time::HiRes qw(sleep);
use Test::Builder;
use Test::WWW::Selenium;
use aliased 'Test::WWW::Selenium::Parser::Test';

has test_runner => (
    is => 'ro',
    required => 1
);

my $tb = Test::Builder->new;
our %dispatch = (
    open => 'open_ok',
    clickAndWait => sub {
        $_->click_ok(@_);
        $_->wait_for_page_to_load_ok(30000)
    },
    verifyElementNotPresent => sub {
        $tb->ok(not $_->is_element_present(@_));
    },
    click => 'click_ok',
    type => 'type_ok',
    verifyText => 'text_is',
    verifyElementPresent => 'is_element_present_ok',
    waitForElementPresent => sub {
        WAIT: {
              for (1..60) {
                  if (eval { $_->is_element_present("css=a.change-recording:eq(2)") }) {
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
    my ($self, @args) = @_;
    return {
        test_runner => Test::WWW::Selenium->new(@args)
    };
}

sub run_test {
    my ($self, $test) = @_;
    $tb->new->subtest($test->name, sub {
        for my $command ($test->commands) {
            my $method = $dispatch{$command->command}
                or die 'Cannot dispatch ' . $command->command;

            if (ref($method) eq 'CODE') {
                local $_ = $self->test_runner;
                $method->($command->args);
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
