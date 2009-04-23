#!/usr/bin/perl
use inc::Module::Install;

name 'musicbrainz';
all_from 'lib/MusicBrainz/Server.pm';

requires 'Algorithm::Diff'                             => '1.1902';
requires 'Cache::Memcached'                            => '1.24';
requires 'Cache::Memcached::libmemcached'              => '0.02009';
requires 'Catalyst::Action::RenderView'                => '0.08';
requires 'Catalyst::Component::ACCEPT_CONTEXT'         => '0.05';
requires 'Catalyst::Model::Factory';
requires 'Catalyst::Plugin::Authentication'            => '0.100092';
requires 'Catalyst::Authentication::Credential::HTTP'  => '1.009';
requires 'Catalyst::Plugin::ConfigLoader'              => '0.22';
requires 'Catalyst::Plugin::Cache'                     => '0.08';
requires 'Catalyst::Plugin::Cache::Memcached'          => '';
requires 'Catalyst::Plugin::I18N'                      => '0.08';
requires 'Catalyst::Plugin::Session::State::Cookie'    => '0.09';
requires 'Catalyst::Plugin::StackTrace'                => '0.09';
requires 'Catalyst::Plugin::Static::Simple'            => '0.20';
requires 'Catalyst::Runtime'                           => '5.71000';
requires 'Catalyst::View::Email'                       => '0.11';
requires 'Catalyst::View::JSON'                        => '0.24';
requires 'Catalyst::View::TT'                          => '0.27';
requires 'Data::Page'                                  => '2.01';
requires 'Date::Calc'                                  => '5.4';
requires 'DBD::Pg'                                     => '2.011008';
requires 'DBI'                                         => '1.520';
requires 'Devel::Peek'                                 => '1.030';
requires 'Digest::MD5'                                 => '2.360';
requires 'Digest::SHA1'                                => '2.110';
requires 'Email::Date::Format'                         => '1.002';
requires 'Email::Valid'                                => '0.179';
requires 'Exception::Class'                            => '1.26';
requires 'Form::Processor'                             => '0.190';
requires 'Gravatar::URL';
requires 'JSON'                                        => '2.120';
requires 'Locale::Maketext'                            => '1.090';
requires 'Locale::Maketext::Extract::Plugin::TT2';
requires 'Locale::TextDomain';
requires 'MIME::Lite'                                  => '3.023';
requires 'Moose'                                       => '0.640';
requires 'MooseX::AttributeHelpers'                    => '0.140';
requires 'MooseX::Storage'                             => '0.150';
requires 'OSSP::uuid'                                  => '1.060200';
requires 'Readonly';
requires 'String::ShellQuote'                          => '1.030';
requires 'String::Similarity'                          => '1.030';
requires 'Text::Unaccent'                              => '1.080';
requires 'Text::WikiFormat'                            => '0.790';
requires 'XML::Feed'                                   => '0.410';
requires 'YAML'                                        => '0.680';

recommends 'Apache::Session';
recommends 'Apache::Session::File';
recommends 'Catalyst::Plugin::Session::Store::FastMmap' => '0.05';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
