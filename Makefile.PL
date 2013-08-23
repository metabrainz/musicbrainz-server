#!/usr/bin/env perl
use 5.8.8;

use inc::Module::Install;

name 'MusicBrainz-Server';
abstract 'MusicBrainz web server';
author 'MetaBrainz Foundation';
license 'gpl';
version_from 'lib/MusicBrainz/Server.pm';

# Mandatory modules
requires 'Algorithm::Diff';
requires 'Algorithm::Merge';
requires 'Authen::Passphrase';
requires 'Cache::Memcached';
requires 'Captcha::reCAPTCHA';
requires 'Catalyst::Action::RenderView'               => '0.09';
requires 'Catalyst::Plugin::Authentication'           => '0.10011';
requires 'Catalyst::Authentication::Credential::HTTP' => '1.009';
requires 'Catalyst::Plugin::I18N'                     => '0.09';
requires 'Catalyst::Plugin::Cache';
requires 'Catalyst::Plugin::Unicode::Encoding'        => '1.2';
requires 'Catalyst::Runtime'                          => '5.90007';
requires 'Catalyst::View::TT'                         => '0.29';
requires 'CGI::Expand';
requires 'Class::MOP';
requires 'CSS::Minifier';
requires 'Clone';
requires 'Cwd';
requires 'Data::Compare';
requires 'Data::Dumper::Concise';
requires 'Data::OptList';
requires 'Data::Page'                                 => '2.01';
requires 'Date::Calc'                                 => '5.8';
requires 'Data::UUID::MT'                             => '0.004';
requires 'DateTime::TimeZone';
requires 'DateTime::Format::Duration'                 => '1.03';
requires 'DateTime::Format::Pg'                       => '0.16004';
requires 'DateTime::Format::Natural'                  => '0.96';
requires 'DateTime::Format::ISO8601';
requires 'DBIx::Connector';
requires 'DBD::Pg'                                    => '2.11.8';
requires 'DBI'                                        => '1.607';
requires 'Digest::HMAC_SHA1'                          => '1.03';
requires 'Digest::MD5'                                => '2.36';
requires 'Digest::SHA'                                => '5.73';
requires 'Email::Address';
requires 'Email::Sender';
requires 'Email::MIME';
requires 'Email::MIME::Creator';
requires 'Email::Valid';
requires 'Encode::Detect'                             => '1.01';
requires 'Exception::Class'                           => '1.29';
requires 'File::Spec';
requires 'GnuPG'                                      => '0.17';
requires 'Hash::Merge';
requires 'HTML::FormHandler'                          => '0.40013';
requires 'HTML::Tiny'                                 => '1.05';
requires 'HTML::TreeBuilder::XPath';
requires 'IO::All';
requires 'Javascript::Closure';
requires 'JSON'                                       => '2.14';
requires 'JSON::XS'                                   => '2.27';
requires 'Log::Dispatch';
requires 'List::UtilsBy'                              => '0.06';
requires 'List::MoreUtils'                            => '0.22';
requires 'Method::Signatures::Simple';
requires 'Module::Pluggable'                          => '3.9';
requires 'Moose'                                      => '2.0402';
requires 'MooseX::ABC'                                => '0.05';
requires 'MooseX::Clone';
requires 'MooseX::Getopt';
requires 'MooseX::MethodAttributes'                   => '0.24';
requires 'MooseX::Role::Parameterized'                => '0.16';
requires 'MooseX::Runnable';
requires 'MooseX::Singleton';
requires 'MooseX::Types'                              => '0.16';
requires 'MooseX::Types::Structured'                  => '0.24';
requires 'MooseX::Types::URI'                         => '0.03';
requires 'MRO::Compat'                                => '0.10';
requires 'Net::Amazon::AWSSign';
requires 'Net::Amazon::S3::Policy'                    => '0.1.2';
requires 'Net::CoverArtArchive';
requires 'Unicode::ICU::Collator';
requires 'Package::Stash'                             => '0.29';
requires 'REST::Utils'                                => '0.4';
requires 'Readonly'                                   => '1.03';
requires 'Redis'                                      => '1.961';
requires 'Statistics::Basic'                          => '1.6602';
requires 'String::CamelCase';
requires 'String::ShellQuote'                         => '1.030';
requires 'String::TT'                                 => '0.03';
requires 'Sys::Hostname';
requires 'Template::Plugin::Math';
requires 'Template::Plugin::Class';
requires 'Template::Plugin::JavaScript';
requires 'Template::Plugin::Map';
requires 'Text::WikiFormat'                           => '0.80';
requires 'Text::Unaccent';
requires 'Text::Trim'                                 => '1.02';
requires 'Time::Duration';
requires 'Throwable';
requires 'TryCatch';
requires 'URI'                                        => '1.50';
requires 'XML::Generator';
requires 'XML::Parser::Lite'                          => '0.714';
requires 'XML::RSS::Parser::Lite'                     => '0.10';
requires 'XML::SemanticDiff'                          => '1.0000';
requires 'XML::Simple'                                => '2.14';
requires 'XML::XPath';

feature 'ETag Caching' =>
    -default                        => 1,
    'Catalyst::Plugin::Cache::HTTP' => '0.001',
    ;

feature 'Default caching setup' =>
    -default                 => 1,
    'Cache::Memory'          => '2.04',
    'Cache::Memcached::Fast' => '0.16'
    ;

feature 'Default session store/state management' =>
    -default                                     => 1,
    'Catalyst::Plugin::Session::State::Cookie'   => '0.11',
    'Catalyst::Plugin::Session::Store::FastMmap' => '0.07',
    ;

feature 'Developer features' =>
    -default                           => 1,
    'Catalyst::Plugin::StackTrace'     => '0.09',
    'Catalyst::Devel'                  => '1.25',
    'Plack'                            => '0.9985',
    'Plack::Middleware::Debug'         => '0.14',
    'Catalyst::Runtime'                => '5.9'
    ;

feature 'Production server' =>
    'Digest::MD5::File' => '0.07',
    'Catalyst::Plugin::AutoRestart' => '0.93',
    'Catalyst::Plugin::ErrorCatcher' => '0.0.8.8',
    'Catalyst::Plugin::Session::Store::Memcached' => '0.05',
    'FCGI' => '0',
    'FCGI::ProcManager' => '0.19',
    ;

# These are just for I18N
requires 'Locale::PO';
requires 'Locale::Messages';

author_requires 'Test::NoTabs';
author_requires 'Test::EOL';

test_requires 'Env::Path';
test_requires 'HTML::HTML5::Parser';
test_requires 'HTML::HTML5::Sanity';
test_requires 'HTML::Selector::XPath';
test_requires 'LWP::UserAgent::Mockable';
test_requires 'RDF::Query';
test_requires 'RDF::RDFa::Parser';
test_requires 'Test::Aggregate';
test_requires 'Test::Differences';
test_requires 'Test::Fatal' => '0.006';
test_requires 'Test::JSON';
test_requires 'Test::LongString';
test_requires 'Test::Magpie' => '0.04';
test_requires 'Test::Memory::Cycle';
test_requires 'Test::Mock::Class';
test_requires 'Test::Routine';
test_requires 'Test::XPath';
test_requires 'XML::Parser';
test_requires 'TAP::Parser::SourceHandler::pgTAP';

catalyst;

author_tests 't/author';

install_script glob('script/*.pl');
auto_install;
WriteAll;
