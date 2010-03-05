#!/usr/bin/perl
use 5.8.8;

use inc::Module::Install;

name 'MusicBrainz-Server';
abstract 'MusicBrainz web server';
author 'MetaBrainz Foundation';
license 'gpl';
version_from 'lib/MusicBrainz/Server.pm';

# Mandatory modules
requires 'Catalyst::Action::RenderView'                => '0.09';
requires 'Catalyst::Plugin::Authentication'            => '0.10011';
requires 'Catalyst::Authentication::Credential::HTTP'  => '1.009';
requires 'Catalyst::Plugin::I18N'                      => '0.09';
requires 'Catalyst::Plugin::Unicode::Encoding';
requires 'Catalyst::Runtime'                           => '5.80021';
requires 'Catalyst::View::TT'                          => '0.29';
requires 'Class::MOP';
requires 'Clone';
requires 'Data::OptList';
requires 'Data::Page'                                  => '2.01';
requires 'Date::Calc'                                  => '5.8';
requires 'DateTime::TimeZone';
requires 'DateTime::Format::Pg'                        => '0.16004';
requires 'DBIx::Connector';
requires 'DBD::Pg'                                     => '2.11.8';
requires 'DBI'                                         => '1.607';
requires 'Digest::MD5'                                 => '2.36';
requires 'Digest::SHA1'                                => '2.110';
requires 'Email::Address';
requires 'Email::Sender';
requires 'Email::MIME';
requires 'Email::MIME::Creator';
requires 'Exception::Class'                            => '1.29';
requires 'HTML::FormHandler'                           => '0.30001';
requires 'HTML::Tiny'                                  => '1.05';
requires 'JSON'                                        => '2.14';
requires 'Log::Dispatch';
requires 'List::MoreUtils'                             => '0.22';
requires 'Match::Smart';
requires 'Moose'                                       => '0.87';
requires 'MooseX::ABC';
requires 'MooseX::MethodAttributes'                    => '0.14';
requires 'MooseX::Role::Parameterized'                 => '0.16';
requires 'MooseX::Types'                               => '0.16';
requires 'MooseX::Types::Structured'                   => '0.16';
requires 'MRO::Compat'                                 => '0.10';
requires 'Net::Amazon::AWSSign';
requires 'OSSP::uuid'                                  => '1.060200';
requires 'Readonly'                                    => '1.03';
requires 'String::ShellQuote'                          => '1.030';
requires 'Text::WikiFormat'                            => '0.790';
requires 'TryCatch';
requires 'XML::Feed'                                   => '0.410';
requires 'XML::Simple'                                 => '2.14';
requires 'YAML'                                        => '0.680';

feature 'ETag Caching' =>
    -default                        => 1,
    'Catalyst::Plugin::Cache::HTTP' => 1,
    ;

feature 'Default caching setup' =>
    -default                 => 1,
    'Cache::Memory'          => 1,
    'Cache::Memcached::Fast' => '1.24'
    ;

feature 'Default session store/state management' =>
    -default                                     => 1,
    'Catalyst::Plugin::Session::State::Cookie'   => '0.11',
    'Catalyst::Plugin::Session::Store::FastMmap' => '0.07',
    ;

feature 'Developer features' =>
    -default                           => 1,
    'Catalyst::Plugin::StackTrace'     => '0.09',
    'Catalyst::Plugin::Static::Simple' => '0.21',
    ;

# These are just for I18N
requires 'Locale::PO';
requires 'Locale::TextDomain'                          => '1.16';

#author_requires 'Catalyst::Restarter';

test_requires 'LWP::UserAgent::Mockable';
test_requires 'Test::Differences';
test_requires 'Test::Aggregate';
test_requires 'XML::Parser';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
