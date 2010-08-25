package MusicBrainz::Server::Test;

use DBDefs;
use FindBin '$Bin';
use MusicBrainz::Server::CacheManager;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Edit;
use MusicBrainz::Server::Replication ':replication_type';
use MusicBrainz::WWW::Mechanize;
use Sql;
use Template;
use Test::Builder;
use Test::Mock::Class ':all';
use Test::WWW::Mechanize::Catalyst;
use Test::XML::SemanticCompare;
use XML::Parser;

use Sub::Exporter -setup => {
    exports => [
        qw( accept_edit reject_edit xml_ok schema_validator ),
        ws_test => \&_build_ws_test,
    ],
};

use MusicBrainz::Server::DatabaseConnectionFactory;
MusicBrainz::Server::DatabaseConnectionFactory->connector_class('MusicBrainz::Server::Test::Connector');

my $test_context;

sub create_test_context
{
    my ($class, %args) = @_;

    $test_context ||= do {
        my $cache_manager = MusicBrainz::Server::CacheManager->new(
            profiles => {
                null => {
                    class => 'Cache::Null',
                    wrapped => 1,
                },
            },
            default_profile => 'null',
        );
        MusicBrainz::Server::Context->new(
            cache_manager => $cache_manager,
            %args
        );
    };

    return $test_context;
}

sub _load_query
{
    my ($class, $query, $default) = @_;

    if (defined $query) {
        if ($query =~ /^\+/) {
            my $file_name = "<t/sql/" . substr($query, 1) . ".sql";
            open(FILE, $file_name) or die "Could not open $file_name";
            $query = do { local $/; <FILE> };
        }
    }
    else {
        open(FILE, "<" . $default);
        $query = do { local $/; <FILE> };
    }

    return $query;
}

sub prepare_test_database
{
    my ($class, $c, $query) = @_;

    $query = $class->_load_query($query, "admin/sql/InsertTestData.sql");

    my $sql = Sql->new($c->dbh);
    $sql->auto_commit;
    $sql->do($query);
}

sub prepare_raw_test_database
{
    my ($class, $c, $query) = @_;

    $query = $class->_load_query($query, "t/sql/clean_raw_db.sql");

    my $sql = Sql->new($c->raw_dbh);
    $sql->auto_commit;
    $sql->do($query);
}

sub prepare_test_server
{
    no warnings 'redefine';
    *DBDefs::_RUNNING_TESTS = sub { 1 };
    *DBDefs::REPLICATION_TYPE = sub { RT_STANDALONE };
}

sub get_latest_edit
{
    my ($class, $c) = @_;
    my $ed = MusicBrainz::Server::Data::Edit->new(c => $c);
    my $sql = Sql->new($c->raw_dbh);
    my $last_id = $sql->select_single_value("SELECT id FROM edit ORDER BY ID DESC LIMIT 1") or return;
    return $ed->get_by_id($last_id);
}

my $Test = Test::Builder->new();

sub diag_lineno
{
    my @lines = split /\n/, $_[0];
    my $line = 1;
    foreach (@lines) {
        diag $line, $_;
        $line += 1;
    }
}

sub xml_ok
{
    my ($content, $message) = @_;

    $message ||= "invalid XML";

    my $parser = XML::Parser->new(Style => 'Tree');
    eval { $parser->parse($content) };
    if ($@) {
        my $error = $@;
        my @lines = split /\n/, $content;
        my $line = 1;
        foreach (@lines) {
            $Test->diag(sprintf "%03d %s", $line, $_);
            $line += 1;
        }
        $Test->diag("XML::Parser error: $error");
        return $Test->ok(0, $message);
    }
    else {
        return $Test->ok(1, $message);
    }
}

sub accept_edit
{
    my ($c, $edit) = @_;

    my $sql = Sql->new($c->dbh);
    my $raw_sql = Sql->new($c->raw_dbh);
    $sql->begin;
    $raw_sql->begin;
    $c->model('Edit')->accept($edit);
    $sql->commit;
    $raw_sql->commit;
}

sub reject_edit
{
    my ($c, $edit) = @_;

    my $sql = Sql->new($c->dbh);
    my $raw_sql = Sql->new($c->raw_dbh);
    $sql->begin;
    $raw_sql->begin;
    $c->model('Edit')->reject($edit);
    $sql->commit;
    $raw_sql->commit;
}

my $mock;
sub mock_context
{
    $mock ||= do {
        my $meta_c = Test::Mock::Class->create_mock_anon_class();
        $meta_c->add_mock_method('uri_for_action');
        $meta_c->new_object;
    };
    return $mock;
}

my $tt;
sub evaluate_template
{
    my ($class, $template, %vars) = @_;
    $tt ||= Template->new({
        INCLUDE_PATH => "$Bin/../root",
        TEMPLATE_EXTENSION => '.tt',
        PLUGIN_BASE => 'MusicBrainz::Server::Plugin',
        PRE_PROCESS => [
            'components/common-macros.tt',
        ]
    });

    $vars{c} ||= mock_context();

    my $out = '';
    $tt->process(\$template, \%vars, \$out) || die $tt->error();
    return $out;
}

sub mock_search_server
{
    my ($type) = @_;

    $type =~ s/-/_/g;

    local $/;
    my $searchresults = "t/json/search_".lc($type).".json";
    open(JSON, $searchresults) or die ("Could not open $searchresults");
    my $json = <JSON>;
    close(JSON);

    my $mock = mock_class 'LWP::UserAgent' => 'LWP::UserAgent::Mock';
    my $mock_server = $mock->new_object;
    $mock_server->mock_return(
        'get' => sub {
            HTTP::Response->new(200, undef, undef, $json);
        }
    );
}

sub old_edit_row
{
    my ($self, %args) = @_;
    return {
        id         => 11851325,
        moderator  => 395103,
        rowid      => 12345,
        status     => 1,
        yesvotes   => 5,
        novotes    => 3,
        automod    => 1,
        opentime   => '2010-01-22 19:34:17+00',
        closetime  => '2010-01-29 19:34:17+00',
        expiretime => '2010-02-05 19:34:17+00',
        tab        => 'artist',
        col        => 'name',
        %args
    };
}

sub schema_validator
{
    my $version = shift;

    $version = '1.4' if $version == 1;
    $version = '2.0' if $version == 2 or !$version;

    my $rng_file = $ENV{'MMDFILE'};

    if (!$rng_file)
    {
        use File::Basename;
        use Cwd;

        my $base_dir = Cwd::realpath( File::Basename::dirname(__FILE__) );

        $rng_file = "$base_dir/../../../../mmd-schema/schema/musicbrainz_mmd-$version.rng";
    }
    my $rngschema;
    eval
    {
        $rngschema = XML::LibXML::RelaxNG->new( location => $rng_file );
    };

    if ($@)
    {
        warn "Cannot find or parse RNG schema. Set environment var MMDFILE to point ".
            "to the mmd-schema file or check out the mmd-schema in parallel to ".
            "the mb_server source. No schema validation will happen.\n";
        undef $rngschema;
    }

    return sub {
        use Test::More import => [ 'is', 'skip' ];

        my ($xml, $message) = @_;

        $message ||= "Validate against schema";

        xml_ok ($xml, "$message (xml_ok)");

      SKIP: {

          skip "schema not found", 1 unless $rngschema;

          my $doc = XML::LibXML->new()->parse_string($xml);
          eval
          {
              $rngschema->validate( $doc );
          };
          is( $@, '', "$message (validate)");

        }
    };
}

sub _build_ws_test {
    my ($class, $name, $args) = @_;
    my $end_point = '/ws/' . $args->{version};

    my $mech = MusicBrainz::WWW::Mechanize->new(catalyst_app => 'MusicBrainz::Server');
    my $validator = schema_validator($args->{version});

    return sub {
        my ($msg, $url, $expected, $opts) = @_;
        $opts ||= {};

        $Test->subtest($msg => sub {
            if (exists $opts->{username} && exists $opts->{password}) {
                $mech->credentials('localhost:80', 'musicbrainz.org', $opts->{username}, $opts->{password});
            }
            else {
                $mech->clear_credentials;
            }


            $Test->plan(tests => 4);

            $mech->get_ok($end_point . $url, 'fetching');
            $validator->($mech->content, 'validating');

            is_xml_same($mech->content, $expected);
        });
    }
}

1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
