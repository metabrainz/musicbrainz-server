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

$sel->open_ok("/release/3b3d130a-87a8-4a47-b9fb-920f2530d134/edit");
$sel->click_ok("step_tracklist");
$sel->wait_for_page_to_load_ok("30000");
$sel->is_visible_ok("mediums.0.basicdisc");
$sel->text_is("css=div#preview h3:eq(0)", "Disc 1");
$sel->click_ok("css=fieldset#mediums\\.0\\.advanced-disc input.remove-disc");
ok(not $sel->is_visible("mediums.0.basicdisc"));
$sel->text_is("css=div#preview h3:eq(0)", "Disc 1: Chestplate Singles");
$sel->click_ok("step_recordings");
$sel->wait_for_page_to_load_ok("30000");
ok(not $sel->is_element_present("recording-assoc-disc-0"));
$sel->is_element_present_ok("recording-assoc-disc-1");
$sel->click_ok("step_editnote");
$sel->wait_for_page_to_load_ok("30000");
$sel->is_element_present_ok("css=table.remove-medium");
$sel->is_element_present_ok("css=table.edit-medium");
