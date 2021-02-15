package MusicBrainz::Server::Test;

use feature 'state';

binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

use DBDefs;
use Encode qw( encode );
use FindBin '$Bin';
use Getopt::Long;
use HTML::HTML5::Parser;
use HTTP::Headers;
use HTTP::Request;
use JSON qw( decode_json encode_json );
use List::UtilsBy qw( nsort_by );
use MusicBrainz::Server::CacheManager;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Edit;
use MusicBrainz::Server::Replication ':replication_type';
use MusicBrainz::Server::Test::HTML5 qw( html5_ok );
use MusicBrainz::WWW::Mechanize;
use Sql;
use Test::Builder;
use Test::Deep qw( cmp_deeply );
use Test::Differences;
use Test::WWW::Mechanize::Catalyst;
use Test::XML::SemanticCompare;
use Test::XPath;
use XML::LibXML;
use Email::Sender::Transport::Test;
use Try::Tiny;

binmode Test::More->builder->output, ':utf8';
binmode Test::More->builder->failure_output, ':utf8';

use Sub::Exporter -setup => {
    exports => [
        qw(
            accept_edit reject_edit xml_ok schema_validator xml_post
            compare_body html_ok test_xpath_html commandline_override
            capture_edits post_json page_test_jsonld
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

    if (!defined $query || $query =~ /^\+/) {
        # Load query from a file
        my $file_name = defined $query ?
            't/sql/' . substr($query, 1) . '.sql' : $default;

        open my $fh, '< :encoding(UTF-8)', $file_name
            or die "Could not open $file_name";
        $query = do { local $/; <$fh> // die "Error reading $file_name" };
        close $fh or die "Error closing $file_name";
    }

    # comment PostgreSQL interactive terminal commands.
    $query =~ s/^(\\.*)$/-- $1/mg;

    return $query;
}

sub _do_query {
    my ($class, $c, $query, $default) = @_;

    $query = $class->_load_query($query, $default);

    my $sql = Sql->new($c->conn);
    $sql->auto_commit;
    $sql->do($query);
}

sub prepare_test_database {
    my ($class, $c, $query) = @_;

    $class->_do_query($c, $query, 'admin/sql/InsertTestData.sql');
    $class->_do_query($c, undef, 'admin/sql/SetSequences.sql');
}

sub prepare_raw_test_database {
    my ($class, $c, $query) = @_;

    $class->_do_query($c, $query, 't/sql/clean_raw_db.sql');
    $class->_do_query($c, undef, 'admin/sql/SetSequences.sql');
}

sub prepare_test_server
{
    {
        no warnings 'redefine';
        $ENV{MUSICBRAINZ_RUNNING_TESTS} = 1;
        $ENV{PERL_JSON_BACKEND} = 2;
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

    state $parser = HTML::HTML5::Parser->new(no_cache => 1);

    # We don't use $parser->parse_string because it calls parse_byte_string
    # even if you don't specify an encoding, which requires us to
    # unnecessarily re-encode the content first.
    my $errors = ($parser->{errors} = []);
    my $doc = XML::LibXML::Document->createDocument;

    $parser->{parser}->parse_char_string($content, $doc, sub {
        push @{$errors}, HTML::HTML5::Parser::Error->new(@_);
    });

    # Remove the XML namespace so that XPath expressions work.
    my ($html) = $doc->getElementsByTagName('html');
    $html->setAttribute('xmlns', '');

    return Test::XPath->new(doc => $doc);
}

=func html_ok

Validate HTML5 with validator.nu.

=cut

sub html_ok
{
    my ($content) = @_;

    html5_ok($Test, $content);
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
    $version = '2.0' if $version == 2 || !$version;

    my $mmd_root = $ENV{'MMD_SCHEMA_ROOT'} ||
                   Cwd::realpath( File::Basename::dirname(__FILE__) ) . "/../../../../mmd-schema";

    my $rng_file = "$mmd_root/schema/musicbrainz_mmd-$version.rng";

    my $rngschema;
    eval
    {
        $rngschema = XML::LibXML::RelaxNG->new( location => $rng_file );
    };

    if ($@)
    {
        warn "Cannot find or parse RNG schema. Set environment var MMD_SCHEMA_ROOT to point ".
            "to the mmd-schema directory or check out the mmd-schema in parallel to ".
            "the mb_server source. No schema validation will happen.\n";
        undef $rngschema;
    }

    return sub {
        use Test::More import => [ 'is', 'skip' ];

        my ($xml, $message) = @_;

        $message ||= "Validate against schema";

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
        use Test::More;

        my ($msg, $url, $expected, $opts) = @_;
        $opts ||= {};

        my $mech = MusicBrainz::WWW::Mechanize->new(catalyst_app => 'MusicBrainz::Server');
        $mech->default_header("Accept" => "application/xml");
        $Test->subtest($msg => sub {
            if (exists $opts->{username} && exists $opts->{password}) {
                $mech->credentials('localhost:80', 'musicbrainz.org', $opts->{username}, $opts->{password});
            }

            $mech->get($end_point . $url, 'fetching');
            if ($opts->{response_code}) {
                $Test->plan(tests => 2);
                is($mech->res->code, $opts->{response_code});
            } else {
                $Test->plan(tests => 3);
                ok($mech->success);
                # only do this on success, there's no schema for error messages
                $validator->($mech->content, 'validating');
            }

            is_xml_same($expected, $mech->content);
            $Test->note($mech->content);
        });
    }
}

sub _build_ws_test_json {
    my ($class, $name, $args) = @_;
    my $end_point = '/ws/' . $args->{version};

    return sub {
        my ($msg, $url, $expected, $opts) = @_;
        $opts ||= {};

        my $mech = MusicBrainz::WWW::Mechanize->new(catalyst_app => 'MusicBrainz::Server');
        $mech->default_header("Accept" => "application/json");
        $Test->subtest($msg => sub {
            if (exists $opts->{username} && exists $opts->{password}) {
                $mech->credentials('localhost:80', 'musicbrainz.org', $opts->{username}, $opts->{password});
            }
            else {
                $mech->clear_credentials;
            }

            $Test->plan(tests => 2 + ($opts->{extra_plan} // 0));

            $mech->get($end_point . $url, 'fetching');
            if ($opts->{response_code}) {
                is($mech->res->code, $opts->{response_code});
            } else {
                ok($mech->success);
            }

            cmp_deeply(decode_json($mech->content), $expected);

            my $cb = $opts->{content_cb};
            $cb->($mech->content) if $cb;
        });
    };
}

sub _build_ws_test {
    my ($class, $name, $args) = @_;

    return $args->{version} eq 'js' ? _build_ws_test_json(@_) : _build_ws_test_xml(@_);
}

sub xml_post
{
    my ($url, $content) = @_;

    # $mech->post_ok seems intent on destroying the POST body by trying to
    # encode it as "application/x-www-form-urlencoded".  So create a request
    # by hand, to make sure the body is submitted verbatim.
    my $request = HTTP::Request->new(
        POST => $url,
        HTTP::Headers->new('Content-Type' => 'application/xml; charset=UTF-8',
                            'Content-Length', length($content)),
    );

    $request->content($content);

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
    GetOptions("tests=s" => \$test_re);

    return grep { $_ =~ /$test_re/ } @default_tests;
}

sub post_json {
    my ($mech, $uri, $json) = @_;

    my $req = HTTP::Request->new('POST', $uri);

    $req->header('Content-Type' => 'application/json');
    $req->content($json);

    return $mech->request($req);
}

sub page_test_jsonld {
    my ($mech, $expected) = @_;

    my $tx = test_xpath_html($mech->content);
    my $jsonld = encode('UTF-8', $tx->find_value('//script[@type="application/ld+json"]'));

    cmp_deeply(decode_json($jsonld), $expected, 'has expected JSON-LD');
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
