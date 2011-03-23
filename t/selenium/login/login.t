use strict;
use warnings;
use Time::HiRes qw(sleep);
use Test::WWW::Selenium;
use Test::More "no_plan";
use Test::Exception;

my $sel = Test::WWW::Selenium->new( host => "localhost", 
                                    port => 4444, 
                                    browser => "*chrome", 
                                    browser_url => "http://localhost:3000/" );

$sel->open_ok("/logout");
ok(not $sel->is_element_present("css=li.editing"));
$sel->click_ok("link=Log In");
$sel->wait_for_page_to_load_ok("30000");
$sel->click_ok("id-remember_me");
$sel->type_ok("id-username", "kuno");
$sel->type_ok("id-password", "byld");
$sel->click_ok("css=span.login button");
$sel->wait_for_page_to_load_ok("30000");
$sel->text_is("css=li.account a", "kuno");
$sel->is_element_present_ok("css=li.editing");
