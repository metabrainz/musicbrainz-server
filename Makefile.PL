#!/usr/bin/perl
use inc::Module::Install;

name 'musicbrainz';
all_from 'lib/MusicBrainz/Server.pm';

requires 'Algorithm::Diff';
requires 'Cache::Memcached';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Component::ACCEPT_CONTEXT';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Form::Processor';
requires 'Catalyst::Plugin::I18N';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'Catalyst::Plugin::StackTrace';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Runtime' => '5.71000';
requires 'Catalyst::View::Email';
requires 'Catalyst::View::JSON';
requires 'Catalyst::View::TT';
requires 'Data::Page';
requires 'Date::Calc';
requires 'DBD::Pg';
requires 'DBI';
requires 'Devel::Peek';
requires 'Digest::MD5';
requires 'Digest::SHA1';
requires 'Email::Date::Format';
requires 'Email::Valid';
requires 'Form::Processor';
requires 'JSON';
requires 'Locale::MakeText';
requires 'Locale::Maketext::Extract::Plugin::TT2';
requires 'MIME::Lite';
requires 'Moose';
requires 'OSSP::uuid';
requires 'parent';
requires 'String::ShellQuote';
requires 'String::Similarity';
requires 'Text::Unaccent';
requires 'Text::WikiFormat';
requires 'XML::Feed';
requires 'YAML';

recommends 'Apache::AuthDigest';
recommends 'Apache::Session';
recommends 'Apache::Session::File';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
