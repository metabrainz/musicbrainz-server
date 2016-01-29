#!/usr/bin/env perl
use 5.8.8;

use inc::Module::Install;

name 'MusicBrainz-Server';
abstract 'MusicBrainz web server';
author 'MetaBrainz Foundation';
license 'gpl';
version_from 'lib/MusicBrainz/Server.pm';

# Mandatory modules
requires 'Algorithm::Diff'                            => '1.1902';
requires 'Authen::Passphrase'                         => '0.007';
requires 'Cache::Memcached'                           => '1.29';
requires 'Captcha::reCAPTCHA'                         => '0.93';
requires 'Catalyst::Action::RenderView'               => '0.16';
requires 'Catalyst::Plugin::Authentication'           => '0.10017';
requires 'Catalyst::Authentication::Credential::HTTP' => '1.013';
requires 'Catalyst::Plugin::I18N'                     => '0.10';
requires 'Catalyst::Plugin::Cache'                    => '0.10';
requires 'Catalyst::Plugin::Unicode::Encoding'        => '1.3';
requires 'Catalyst::Runtime'                          => '5.90011';
requires 'Catalyst::View::TT'                         => '0.37';
requires 'CGI::Expand'                                => '2.03';
requires 'Class::MOP'                                 => '2.0401';
requires 'Class::Load';
requires 'Clone'                                      => '0.31';
requires 'Cwd'                                        => '3.40';
requires 'Data::Compare'                              => '1.22';
requires 'Data::Dumper::Concise'                      => '2.020';
requires 'Data::OptList'                              => '0.107';
requires 'Data::Page'                                 => '2.02';
requires 'Date::Calc'                                 => '6.3';
requires 'Data::UUID::MT'                             => '0.006';
requires 'DateTime::TimeZone'                         => '1.42';
requires 'DateTime::Format::Pg'                       => '0.16007';
requires 'DateTime::Format::Natural'                  => '0.98';
requires 'DateTime::Format::ISO8601'                  => '0.07';
requires 'DateTime::Format::W3CDTF'                   => '0.06';
requires 'DBIx::Connector'                            => '0.47';
requires 'DBD::Pg'                                    => '2.19.0';
requires 'DBI'                                        => '1.616';
requires 'Digest::HMAC_SHA1'                          => '1.03';
requires 'Digest::MD5'                                => '2.51';
requires 'Digest::SHA'                                => '5.73';
requires 'Email::Address'                             => '1.892';
requires 'Email::MIME'                                => '1.910';
requires 'Email::MIME::Creator'                       => '1.910';
requires 'Email::Sender'                              => '0.120002';
requires 'Email::Valid'                               => '0.185';
requires 'Encode::Detect'                             => '1.01';
requires 'Exception::Class'                           => '1.37';
requires 'File::Spec'                                 => '3.40';
requires 'GnuPG'                                      => '0.18';
requires 'Hash::Merge'                                => '0.12';
requires 'HTML::FormHandler'                          => '0.40016';
requires 'HTML::Tiny'                                 => '1.05';
requires 'HTML::TreeBuilder::XPath'                   => '0.14';
requires 'HTTP::Date'                                 => '6.0';
requires 'IO::All'                                    => '0.44';
requires 'JSON'                                       => '2.59';
requires 'JSON::XS'                                   => '2.32';
requires 'List::AllUtils'                             => '0.02';
requires 'List::MoreUtils'                            => '0.33';
requires 'List::UtilsBy'                              => '0.08';
requires 'LWP::Protocol::https';
requires 'Log::Dispatch'                              => '2.29';
requires 'Math::Random::Secure'                       => '0.06';
requires 'Method::Signatures::Simple'                 => '1.02';
requires 'MIME::Base64'                               => '3.13';
requires 'Module::Pluggable'                          => '3.9';
requires 'Moose'                                      => '2.0401';
requires 'MooseX::ABC'                                => '0.06';
requires 'MooseX::Clone'                              => '0.05';
requires 'MooseX::Getopt'                             => '0.37';
requires 'MooseX::MethodAttributes'                   => '0.25';
requires 'MooseX::Role::Parameterized'                => '1.03';
requires 'MooseX::Runnable'                           => '0.03';
requires 'MooseX::Singleton'                          => '0.29';
requires 'MooseX::Types'                              => '0.31';
requires 'MooseX::Types::Structured'                  => '0.28';
requires 'MooseX::Types::URI'                         => '0.03';
requires 'MRO::Compat'                                => '0.11';
requires 'Net::Amazon::AWSSign'                       => '0.12';
requires 'Unicode::ICU::Collator'                     => '0.002';
requires 'REST::Utils'                                => '0.6';
requires 'Readonly'                                   => '1.03';
requires 'Redis'                                      => '1.926';
requires 'Set::Scalar';
requires 'Statistics::Basic'                          => '1.6601';
requires 'String::CamelCase'                          => '0.02';
requires 'String::ShellQuote'                         => '1.03';
requires 'String::TT'                                 => '0.03';
requires 'Sys::Hostname';
requires 'Template::Plugin::Class'                    => '0.13';
requires 'Template::Plugin::JavaScript'               => '0.02';
requires 'Template::Plugin::JSON::Escape'             => '0.02';
requires 'Text::Diff3'                                => '0.10';
requires 'Text::Markdown'                             => '1.000026';
requires 'Text::WikiFormat'                           => '0.81';
requires 'Text::Unaccent'                             => '1.08';
requires 'Text::Trim'                                 => '1.02';
requires 'Throwable'                                  => '0.102080';
requires 'URI'                                        => '1.59';
requires 'XML::Parser::Lite'                          => '0.714';
requires 'XML::RSS::Parser::Lite'                     => '0.10';
requires 'XML::SemanticDiff'                          => '1.0000';
requires 'XML::Simple'                                => '2.18';
requires 'XML::XPath'                                 => '1.13';

feature 'ETag Caching' =>
    -default                        => 1,
    'Catalyst::Plugin::Cache::HTTP' => '0.001000',
    ;

feature 'Default caching setup' =>
    -default                 => 1,
    'Cache::Memory'          => '2.04',
    'Cache::Memcached::Fast' => '0.19'
    ;

feature 'Default session store/state management' =>
    -default                                     => 1,
    'Catalyst::Plugin::Session::State::Cookie'   => '0.17',
    'Catalyst::Plugin::Session::Store::FastMmap' => '0.14',
    ;

feature 'Developer features' =>
    -default                           => 1,
    'Catalyst::Plugin::StackTrace'     => '0.11',
    'Catalyst::Devel'                  => '1.36',
    'Plack'                            => '0.9985',
    'Plack::Middleware::Debug'         => '0.14',
    ;

feature 'Production server' =>
    'Digest::MD5::File' => '0.07',
    'Catalyst::Plugin::AutoRestart' => '0.96',
    'Catalyst::Plugin::ErrorCatcher' => '0.0.8.13',
    'Catalyst::Plugin::Session::Store::Memcached' => '0.05',
    'FCGI' => '0.74',
    'FCGI::ProcManager' => '0.24',
    ;

# These are just for I18N
requires 'Locale::PO';
requires 'Locale::Messages' => '1.20';

author_requires 'Test::NoTabs';
author_requires 'Test::EOL';

test_requires 'Coro';
test_requires 'HTML::HTML5::Parser';
test_requires 'HTML::HTML5::Sanity';
test_requires 'HTML::Selector::XPath';
test_requires 'LWP::UserAgent::Mockable';
test_requires 'Test::Aggregate';
test_requires 'Test::Differences';
test_requires 'Test::Fatal' => '0.006';
test_requires 'Test::JSON';
test_requires 'Test::LongString';
test_requires 'Test::Magpie' => '0.04';
test_requires 'Test::Memory::Cycle';
test_requires 'Test::Mock::Class';
test_requires 'Test::Routine';
test_requires 'Test::WWW::Mechanize::Catalyst' => '0.58';
test_requires 'Test::XPath';
test_requires 'XML::Parser';
test_requires 'TAP::Parser::SourceHandler::pgTAP';

catalyst;

author_tests 't/author';

install_script glob('script/*.pl');
auto_install;
WriteAll;
