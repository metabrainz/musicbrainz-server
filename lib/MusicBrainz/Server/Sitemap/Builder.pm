package MusicBrainz::Server::Sitemap::Builder;

use DateTime;
use DateTime::Format::Pg;
use DateTime::Format::W3CDTF;
use DBDefs;
use Digest::MD5 qw( md5_hex );
use File::Slurp qw( read_dir );
use File::Spec;
use List::AllUtils qw( any );
use List::MoreUtils qw( natatime );
use List::UtilsBy qw( sort_by );
use Moose;
use MusicBrainz::Server::Constants qw(
    %ENTITIES
    entities_with
    $MAX_INITIAL_MEDIUMS
);
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Replication qw( REPLICATION_ACCESS_URI );
use MusicBrainz::Server::Sitemap::Constants qw( $MAX_SITEMAP_SIZE );
use MusicBrainz::Server::Sitemap::Utils qw( serialize_sitemap log );
use POSIX qw( ceil );
use Readonly;
use String::ShellQuote qw( shell_quote );
use Try::Tiny;
use URI;
use URI::Escape qw( uri_escape_utf8 );
use WWW::SitemapIndex::XML;

with 'MooseX::Getopt';

Readonly my $DEFAULT_SITEMAPS_DIR => File::Spec->catdir(DBDefs->MB_SERVER_ROOT, 'root/static/sitemaps/');
Readonly my $SITEMAP_INDEX_FILENAME => 'sitemap-index.xml';

sub BUILD {
    my ($self) = @_;

    # These need adding or they'll get deleted by write_index.
    $self->add_sitemap_file($self->index_filename);
    $self->add_sitemap_file('.gitkeep');
}

has compression_enabled => (
    is => 'ro',
    isa => 'Bool',
    default => 1,
    traits => ['Getopt'],
    cmd_flag => 'compress',
    documentation => 'compress with gzip (default: true)',
);

has ping_enabled => (
    is => 'ro',
    isa => 'Bool',
    default => 0,
    traits => ['Getopt'],
    cmd_flag => 'ping',
    documentation => 'ping search engines once built (default: false)',
);

has web_server => (
    is => 'ro',
    isa => 'Str',
    default => DBDefs->CANONICAL_SERVER,
    traits => ['Getopt'],
    cmd_flag => 'web-server',
    documentation => 'web server URL used as a base in sitemap-index files, ' .
                     'without trailing slash (default: DBDefs->CANONICAL_SERVER)',
);

has database => (
    is => 'ro',
    isa => 'Str',
    default => 'MAINTENANCE',
    traits => ['Getopt'],
    documentation => 'database to use (default: MAINTENANCE)',
);

has output_dir => (
    is => 'ro',
    isa => 'Str',
    default => sub { $DEFAULT_SITEMAPS_DIR },
    traits => ['Getopt'],
    cmd_flag => 'output-dir',
    documentation => 'directory to write sitemaps to (default: root/static/sitemaps/)',
);

has replication_access_uri => (
    is => 'ro',
    isa => 'Str',
    default => REPLICATION_ACCESS_URI,
    traits => ['Getopt'],
    cmd_flag => 'replication-access-uri',
    documentation => 'URI to request replication packets from (default: https://metabrainz.org/api/musicbrainz)',
);

has current_time => (
    is => 'ro',
    isa => 'Str',
    default => '',
    traits => ['Getopt'],
    cmd_flag => 'current-time',
    documentation => 'substitute for DateTime::now, for testing purposes (default: \'\')',
);

has index => (
    is => 'ro',
    isa => 'WWW::SitemapIndex::XML',
    default => sub { WWW::SitemapIndex::XML->new },
    traits => ['NoGetopt'],
);

has index_filename => (
    is => 'ro',
    isa => 'Str',
    default => sub {
        my $self = shift;

        my $index_filename = $SITEMAP_INDEX_FILENAME;
        $index_filename .= '.gz' if $self->compression_enabled;

        return $index_filename;
    },
    traits => ['NoGetopt'],
);

has index_localname => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub {
        my $self = shift;

        my $index_localname = File::Spec->catfile($self->output_dir, $SITEMAP_INDEX_FILENAME);
        $index_localname .= '.gz' if $self->compression_enabled;

        return $index_localname;
    },
    traits => ['NoGetopt'],
);

=attribute sitemap_files

Stores the list of sitemap files to build; used to determine which files to
delete during cleanup.

=cut

has sitemap_files => (
    is => 'rw',
    isa => 'ArrayRef[Str]',
    default => sub { [] },
    traits => ['Array', 'NoGetopt'],
    handles => {
        add_sitemap_file => 'push',
        all_sitemap_files => 'elements',
    },
);

has old_index => (
    is => 'ro',
    isa => 'WWW::SitemapIndex::XML',
    lazy => 1,
    traits => ['NoGetopt'],
    default => sub {
        my $self = shift;
        my $old_index = WWW::SitemapIndex::XML->new;

        if (-f $self->index_localname) {
            $old_index->load(location => $self->index_localname);
        }

        $old_index;
    },
);

=attribute old_sitemap_modtimes

Loads the old index (if present) to keep track of the modification times of
sitemaps, in case they're unchanged.

=cut

has old_sitemap_modtimes => (
    is => 'ro',
    isa => 'HashRef',
    lazy => 1,
    builder => 'build_old_sitemap_modtimes',
    traits => ['NoGetopt'],
);

sub build_old_sitemap_modtimes {
    my $self = shift;

    my %old_sitemap_modtime =
        map { $_->loc => $_->lastmod }
        grep { $_->loc && $_->lastmod }
        $self->old_index->sitemaps;

    \%old_sitemap_modtime;
}

sub build_page_url {
    my ($self, $entity_type, $id, %suffix_info) = @_;

    my $entity_url = $entity_type;

    if (exists $ENTITIES{$entity_type}) {
        $entity_url = $ENTITIES{$entity_type}{url} // $entity_type;
    }

    my $url = DBDefs->CANONICAL_SERVER . '/' . $entity_url . '/' . $id;
    my $suffix = $suffix_info{suffix};

    if ($suffix) {
        my $suffix_delimiter = $suffix_info{suffix_delimiter} // '/';
        $url .= "${suffix_delimiter}${suffix}";
    }

    return $url;
}

sub create_url_opts($$$$$) {
    my ($self, $c, $entity_type, $url, $suffix_info, $id_info) = @_;

    # Default priority is 0.5, per spec.
    my %add_opts = (loc => $url);
    if ($suffix_info->{priority}) {
        if (ref $suffix_info->{priority} eq 'CODE') {
            $add_opts{priority} = $suffix_info->{priority}->(%{$id_info});
        } else {
            $add_opts{priority} = $suffix_info->{priority};
        }
    }

    if ($suffix_info->{jsonld_markup}) {
        my $last_modified = $c->sql->select_single_value(
            "SELECT last_modified FROM sitemaps.${entity_type}_lastmod WHERE url = ?",
            $url,
        );
        if (defined $last_modified) {
            $add_opts{lastmod} = DateTime::Format::W3CDTF->format_datetime(
                DateTime::Format::Pg->parse_datetime($last_modified)
            );
        }
    }

    return \%add_opts;
}

=method build_one_sitemap

Called by C<build_one_suffix> to build an individual sitemap given a filename,
the sitemap index object, and the list of URLs with appropriate options.

=cut

sub build_one_sitemap {
    my ($self, $filename, @urls) = @_;

    die "Too many URLs for one sitemap: $filename" if scalar @urls > $MAX_SITEMAP_SIZE;

    my $local_filename = File::Spec->catfile($self->output_dir, $filename);
    my $local_xml_filename = $local_filename;
    $local_xml_filename =~ s/\.gz$//;
    my $remote_filename = DBDefs->CANONICAL_SERVER . '/' . $filename;
    my $existing_md5;

    if (-f $local_filename) {
        # Determine if the sitemap has changed since the previous build, for
        # insertion to the sitemap index.
        my $md5 = Digest::MD5->new;

        if ($self->compression_enabled) {
            my $quoted_filename = shell_quote($local_filename);
            $md5->add(`gzip --decompress --stdout $quoted_filename`);
        } else {
            open my $fh, '<', $local_filename;
            $md5->addfile($fh);
            close $fh;
        }

        $existing_md5 = $md5->hexdigest;
    }

    local $| = 1; # autoflush stdout
    print localtime() . " : Building $filename...";

    my $data = serialize_sitemap(@urls);
    open my $fh, '>', $local_xml_filename;
    print $fh $$data;
    close $fh;

    if ($self->compression_enabled) {
        # --force allows it to overwrite the existing files
        system 'gzip', '--force', $local_xml_filename;
    }

    $self->add_sitemap_file($filename);

    my $modtime = $self->current_time || DateTime::Format::W3CDTF->new->format_datetime(DateTime->now);
    my $old_sitemap_modtimes = $self->old_sitemap_modtimes;

    if ($existing_md5 && $existing_md5 eq md5_hex($$data) && $old_sitemap_modtimes->{$remote_filename}) {
        print "using previous modtime, since file unchanged...";
        $modtime = $old_sitemap_modtimes->{$remote_filename};
    }

    $self->index->add(loc => $remote_filename, lastmod => $modtime);
    print " built.\n";
}

=method build_one_suffix

Called by C<build_one_batch> to build an individual suffix's sitemaps given the
necessary information to build the sitemap.

=cut

sub build_one_suffix {
    my ($self, $entity_type, $minimum_batch_number, $urls, %opts) = @_;

    my $base_filename = "sitemap-$entity_type-$minimum_batch_number";
    if ($opts{suffix} || $opts{filename_suffix}) {
        my $filename_suffix = $opts{filename_suffix} // $opts{suffix};
        $base_filename .= "-$filename_suffix";
    }

    my @base_urls = @{ $urls->{base} };
    my @paginated_urls = @{ $urls->{paginated} };

    # If we can fit all the paginated stuff into the main sitemap file, why not do it?
    if (@paginated_urls && scalar @base_urls + scalar @paginated_urls <= $MAX_SITEMAP_SIZE) {
        log("Paginated plus base urls are fewer than 50k for $base_filename, combining into one...");
        push(@base_urls, @paginated_urls);
        @paginated_urls = ();
    }

    my $ext = $self->compression_enabled ? '.xml.gz' : '.xml';
    my $filename = $base_filename . $ext;

    if (@base_urls) {
        $self->build_one_sitemap($filename, @base_urls);
    }

    if (@paginated_urls) {
        my $iter = natatime $MAX_SITEMAP_SIZE, @paginated_urls;
        my $page_number = 1;
        while (my @urls = $iter->()) {
            my $paginated_filename = $base_filename . "-$page_number" . $ext;
            $self->build_one_sitemap($paginated_filename, @urls);
            $page_number++;
        }
    }

    return;
}

=method write_index

Writes the sitemap index file to disk and removes any leftover files in
C<output-dir> that aren't contained by the index.

=cut

sub write_index {
    my ($self) = @_;

    # Preserve entries added by the overall script after running the
    # incremental script, or vice-versa.
    for my $sitemap ($self->old_index->sitemaps) {
        my $already_exists = any { $_->loc eq $sitemap->loc } $self->index->sitemaps;

        next if $already_exists;

        my @path = URI->new($sitemap->loc)->path_segments;
        my $file = pop @path;

        if ($self->do_not_delete($file)) {
            $self->index->add(loc => $sitemap->loc, lastmod => $sitemap->lastmod);
        }
    }

    $self->index->write($self->index_localname);
    log('Built index ' . $self->index_filename . ', deleting outdated files');

    my @files = read_dir($self->output_dir);
    for my $file (@files) {
        unless ($self->do_not_delete($file)) {
            log("Removing $file");
            unlink File::Spec->catfile($self->output_dir, $file);
        }
    }
}

=method ping_search_engines

Use the context's LWP to ping each appropriate search engine URL, given the
remove URL of the sitemap index.

=cut

sub ping_search_engines($) {
    my ($self, $c) = @_;

    return unless $self->ping_enabled;

    log('Pinging search engines');

    my $url = $self->web_server . '/' . $self->index_filename;

    my @sitemap_prefixes = (
        'http://www.google.com/webmasters/tools/ping?sitemap=',
        'http://www.bing.com/webmaster/ping.aspx?siteMap='
    );

    for my $prefix (@sitemap_prefixes) {
        try {
            my $ping_url = $prefix . uri_escape_utf8($url);
            $c->lwp->get($ping_url);
        } catch {
            log("Failed to ping $prefix.");
        }
    }

    return;
}

=method do_not_delete

Determines whether a specific file in C<output-dir> should be deleted during
cleanup, after writing the index file.

=cut

sub do_not_delete {
    my ($self, $file) = @_;

    any { $_ eq $file } $self->all_sitemap_files;
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;

=head1 COPYRIGHT

This file is part of MusicBrainz, the open internet music database.
Copyright (C) 2014 MetaBrainz Foundation
Licensed under the GPL version 2, or (at your option) any later version:
http://www.gnu.org/licenses/gpl-2.0.txt

=cut
