package MusicBrainz::Server::Test;

binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

use DBDefs;
use Encode qw( decode encode );
use FindBin '$Bin';
use Getopt::Long;
use HTTP::Headers;
use HTTP::Request;
use List::UtilsBy qw( nsort_by );
use MusicBrainz::Server::CacheManager;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Edit;
use MusicBrainz::Server::Replication ':replication_type';
use MusicBrainz::Server::Test::HTML5 qw( xhtml_ok html5_ok );
use MusicBrainz::WWW::Mechanize;
use Sql;
use Template;
use Test::Builder;
use Test::Differences;
use Test::Mock::Class ':all';
use Test::WWW::Mechanize::Catalyst;
use Test::XML::SemanticCompare;
use Test::XPath;
use XML::LibXML;
use Email::Sender::Transport::Test;
use Try::Tiny;

use Sub::Exporter -setup => {
    exports => [
        qw(
            accept_edit reject_edit xml_ok schema_validator xml_post
            compare_body html_ok test_xpath_html commandline_override
            capture_edits
        ),
        ws_test => \&_build_ws_test,
        ws_test_json => \&_build_ws_test_json,
    ],
};

BEGIN {
    no warnings 'redefine';
    use DBDefs;
    *DBDefs::WEB_SERVER = sub { "localhost" };
    *DBDefs::WEB_SERVER_USED_IN_EMAIL = sub { "localhost" };
    *DBDefs::RECAPTCHA_PUBLIC_KEY = sub { undef };
    *DBDefs::RECAPTCHA_PRIVATE_KEY = sub { undef };
    *DBDefs::OAUTH2_ENFORCE_TLS = sub { 0 };
}

use MusicBrainz::Server::DatabaseConnectionFactory;
MusicBrainz::Server::DatabaseConnectionFactory->connector_class('MusicBrainz::Server::Test::Connector');
MusicBrainz::Server::DatabaseConnectionFactory->alias('READWRITE' => 'TEST');

our $test_context;
our $test_transport = Email::Sender::Transport::Test->new();

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

    # comment PostgreSQL interactive terminal commands.
    $query =~ s/^(\\.*)$/-- $1/mg;

    return decode ("utf-8", $query);
}

sub prepare_test_database
{
    my ($class, $c, $query) = @_;

    $query = $class->_load_query($query, "admin/sql/InsertTestData.sql");

    my $sql = Sql->new($c->conn);
    $sql->auto_commit;
    $sql->do($query);
}

sub prepare_raw_test_database
{
    my ($class, $c, $query) = @_;

    $query = $class->_load_query($query, "t/sql/clean_raw_db.sql");

    my $sql = Sql->new($c->conn);
    $sql->auto_commit;
    $sql->do($query);
}

sub prepare_test_server
{
    {
        no warnings 'redefine';
        *DBDefs::_RUNNING_TESTS = sub { 1 };
        *DBDefs::REPLICATION_TYPE = sub { RT_STANDALONE };
    };

    $test_transport->clear_deliveries;
}

sub get_test_transport {
    return $test_transport;
}

sub get_latest_edit
{
    my ($class, $c) = @_;
    my $ed = MusicBrainz::Server::Data::Edit->new(c => $c);
    my $sql = Sql->new($c->conn);
    my $last_id = $sql->select_single_value("SELECT id FROM edit ORDER BY ID DESC LIMIT 1") or return;
    return $ed->get_by_id($last_id);
}

sub capture_edits (&$)
{
    my ($code, $c) = @_;
    my $current_max = $c->sql->select_single_value('SELECT max(id) FROM edit');
    $code->();
    my $new_max = $c->sql->select_single_value('SELECT max(id) FROM edit');
    return () if $new_max <= $current_max;
    return nsort_by { $_->id } values %{ $c->model('Edit')->get_by_ids(
        ($current_max + 1)..$new_max
    ) };
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

=func test_xpath_html

Instantiate Test::XPath with the html namespace.

=cut

sub test_xpath_html
{
    my $content = shift;

    return Test::XPath->new(
        xml => $content,
        xmlns => { "html" => "http://www.w3.org/1999/xhtml" });
}

=func html_ok

Validate html by checking if it is well-formed XML and validating
HTML5 with validator.nu.

=cut

sub html_ok
{
    my ($content, $message) = @_;

    xhtml_ok ($Test, $content, $message);
    html5_ok ($Test, $content, $message);
}

sub xml_ok
{
    my ($content, $message) = @_;

    $message ||= "well-formed XML";

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

    $c->sql->begin;
    $c->model('Edit')->accept($edit);
    $c->sql->commit;
}

sub reject_edit
{
    my ($c, $edit) = @_;

    $c->sql->begin;
    $c->model('Edit')->reject($edit);
    $c->sql->commit;
}

our $mock;
sub mock_context
{
    $mock ||= do {
        my $meta_c = Test::Mock::Class->create_mock_anon_class();
        $meta_c->add_mock_method('uri_for_action');
        $meta_c->new_object;
    };
    return $mock;
}

our $tt;
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

use File::Basename;
use Cwd;

sub schema_validator
{
    my $version = shift;

    $version = '1.4' if $version == 1;
    $version = '2.0' if $version == 2 or !$version;

    my $mmd_home = $ENV{'MMDSCHEMA'} ||
                   Cwd::realpath( File::Basename::dirname(__FILE__) ) . "/../../../../mmd-schema";

    my $rng_file = "$mmd_home/schema/musicbrainz_mmd-$version.rng";

    my $rngschema;
    eval
    {
        $rngschema = XML::LibXML::RelaxNG->new( location => $rng_file );
    };

    if ($@)
    {
        warn "Cannot find or parse RNG schema. Set environment var MMDSCHEMA to point ".
            "to the mmd-schema directory or check out the mmd-schema in parallel to ".
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

sub _build_ws_test_xml {
    my ($class, $name, $args) = @_;
    my $end_point = '/ws/' . $args->{version};

    my $validator = schema_validator($args->{version});

    return sub {
        my ($msg, $url, $expected, $opts) = @_;
        $opts ||= {};

        my $mech = MusicBrainz::WWW::Mechanize->new(catalyst_app => 'MusicBrainz::Server');
        $mech->default_header ("Accept" => "application/xml");
        $Test->subtest($msg => sub {
            if (exists $opts->{username} && exists $opts->{password}) {
                $mech->credentials('localhost:80', 'musicbrainz.org', $opts->{username}, $opts->{password});
            }

            $Test->plan(tests => 4);

            $mech->get_ok($end_point . $url, 'fetching');
            $validator->($mech->content, 'validating');

            is_xml_same($expected, $mech->content);
            $Test->note($mech->content);
        });
    }
}

sub _build_ws_test_json {
    use Test::JSON import => [ 'is_valid_json', 'is_json' ];

    my ($class, $name, $args) = @_;
    my $end_point = '/ws/' . $args->{version};

    my $mech = MusicBrainz::WWW::Mechanize->new(catalyst_app => 'MusicBrainz::Server');
    $mech->default_header ("Accept" => "application/json");

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

            $Test->plan(tests => 3);

            $mech->get_ok($end_point . $url, 'fetching');
            is_valid_json ($mech->content, "validating (is_valid_json)");

            is_json ($mech->content, $expected);
            $Test->note($mech->content);
        });
    };
}

sub _build_ws_test {
    my ($class, $name, $args) = @_;

    return $args->{version} eq 'js' ? _build_ws_test_json (@_) : _build_ws_test_xml (@_);
}

sub xml_post
{
    my ($url, $content) = @_;

    # $mech->post_ok seems intent on destroying the POST body by trying to
    # encode it as "application/x-www-form-urlencoded".  So create a request
    # by hand, to make sure the body is submitted verbatim.
    my $request = HTTP::Request->new (
        POST => $url,
        HTTP::Headers->new ('Content-Type' => 'application/xml; charset=UTF-8',
                            'Content-Length', length ($content)),
    );

    $request->content ($content);

    return $request;
}

sub compare_body
{
    my ($got, $expected) = @_;

    $got =~ s/[\r\n]+/\n/g;
    $expected =~ s/[\r\n]+/\n/g;
    eq_or_diff($got, $expected);
}

=func commandline_override

Allow the user of an aggregate test file to specify which tests to run.

The "--tests" option can be supplied to a test, it should be followed
by a comma separated list of tests to run.  A default $prefix has to
be specified so that the user does not have to supply the full package
name of a test.

Example:

  prove -l -v t/tests.t :: --tests Entity::Label,Data::Artist

=cut

sub commandline_override
{
    my ($prefix, @default_tests) = @_;

    my $test_re = '';
    GetOptions ("tests=s" => \$test_re);

    return grep { $_ =~ /$test_re/ } @default_tests;
}

1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2011 MetaBrainz Foundation

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
