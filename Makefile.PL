#!/usr/bin/perl
use inc::Module::Install;

name 'musicbrainz';
all_from 'lib/MusicBrainz/Server.pm';

requires 'Algorithm::Diff';
requires 'Apache::AuthDigest';
requires 'Apache::Session';
requires 'Apache::Session::File';
requires 'Cache::Memcached';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::FormBuilder';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'Catalyst::Plugin::StackTrace';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Runtime' => '5.7012';
requires 'Catalyst::View::TT';
requires 'Date::Calc';
requires 'DBD::Pg';
requires 'DBI';
requires 'Devel::Peek';
requires 'Digest::MD5';
requires 'Digest::SHA1';
requires 'Email::Valid';
requires 'Form::Processor';
requires 'JSON';
requires 'MIME::Lite';
requires 'parent';
requires 'String::ShellQuote';
requires 'String::Similarity';
requires 'Text::Unaccent';
requires 'Text::WikiFormat';
requires 'YAML';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
