package MusicBrainz::Server::Sitemap::Builder;

use DateTime;
use DateTime::Format::Pg;
use DateTime::Format::W3CDTF;
use DBDefs;
use Digest::MD5 qw( md5_hex );
use File::Slurp qw( read_dir );
use File::Spec;
use Fcntl qw( :flock );
use List::AllUtils qw( any sort_by );
use List::MoreUtils qw( natatime );
use Moose;
use MusicBrainz::Script::Utils qw( log );
use MusicBrainz::Server::Constants qw(
    %ENTITIES
    entities_with
);
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Sitemap::Constants qw( $MAX_SITEMAP_SIZE );
use MusicBrainz::Server::Sitemap::Utils qw(
    serialize_sitemap
    serialize_sitemap_index
);
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
    $self->add_sitemap_file($SITEMAP_INDEX_FILENAME . '.gz');
    $self->add_sitemap_file($SITEMAP_INDEX_FILENAME . '.lock');
    $self->add_sitemap_file($SITEMAP_INDEX_FILENAME);
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

has current_time => (
    is => 'ro',
    isa => 'Str',
    default => '',
    traits => ['Getopt'],
    cmd_flag => 'current-time',
    documentation => q(substitute for DateTime::now, for testing purposes (default: '')),
);

has index => (
    is => 'rw',
    isa => 'ArrayRef[HashRef]',
    default => sub { [] },
    traits => ['Array', 'NoGetopt'],
    handles => {
        add_sitemap => 'push',
        all_sitemaps => 'elements',
    },
);

has index_localname => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub {
        my $self = shift;
        File::Spec->catfile($self->output_dir, $SITEMAP_INDEX_FILENAME);
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

sub read_index {
    my $self = shift;

    my $index = WWW::SitemapIndex::XML->new;

    if (-f $self->index_localname) {
        $index->load(location => $self->index_localname);
    }

    $index;
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
    my $local_xml_filename = $local_filename =~ s/\.gz$//r;
    my $remote_filename = DBDefs->CANONICAL_SERVER . '/' . $filename;
    my $existing_md5;

    if (-f $local_filename) {
        # Determine if the sitemap has changed since the previous build, for
        # insertion to the sitemap index. Since the file's already on disk,
        # outsource the md5 calculation. It'll be faster than having perl read
        # the file into memory to pass to Digest::MD5.
        my $quoted_filename = shell_quote($local_filename);
        chomp (my $md5_bin = `which md5` || `which md5sum`);
        $md5_bin = shell_quote($md5_bin);

        if ($self->compression_enabled) {
            $existing_md5 = `gzip --decompress --stdout $quoted_filename | $md5_bin`;
        } else {
            $existing_md5 = `cat $quoted_filename | $md5_bin`;
        }

        $existing_md5 =~ s/[^0-9a-f]//g;
    }

    local $| = 1; # autoflush stdout
    print localtime() . " : Building $filename...";

    my $data = serialize_sitemap(@urls);
    my $modtime = $self->current_time || DateTime::Format::W3CDTF->new->format_datetime(DateTime->now);
    my $write_sitemap = 1;

    $self->lock_index(sub {
        # Load the old index (if present) to keep track of the modification
        # times of sitemaps, in case they're unchanged.
        my %old_sitemap_modtimes =
            map { $_->loc => $_->lastmod }
            grep { $_->loc && $_->lastmod }
            $self->read_index->sitemaps;

        if ($existing_md5) {
            my $new_md5 = md5_hex($$data);

            if ($existing_md5 eq $new_md5) {
                # Don't write the file to disk unless we have to.
                $write_sitemap = 0;

                if ($old_sitemap_modtimes{$remote_filename}) {
                    print 'using previous modtime, since file unchanged...';
                    $modtime = $old_sitemap_modtimes{$remote_filename};
                }
            }
        }
    });

    if ($write_sitemap) {
        open(my $fh, '>', $local_xml_filename)
            or die "Can't open sitemap: $!";
        print $fh $$data;
        close $fh;

        if ($self->compression_enabled) {
            # --force allows it to overwrite the existing files
            system 'gzip', '--force', $local_xml_filename;
        }
    }

    $self->add_sitemap_file($filename);
    $self->add_sitemap({ loc => $remote_filename, lastmod => $modtime });
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

sub lock_index {
    my ($self, $callback) = @_;

    # A separate lock file is used, because we can't create the sitemap index
    # or check if it exists (required by read_index) until a lock is acquired.
    # And we can't acquire a lock on a non-existent file.

    open(my $index_lock_fh, '>>', $self->index_localname . '.lock')
        or die "Can't open sitemap index lock: $!";
    flock($index_lock_fh, LOCK_EX)
        or die "Can't lock sitemap index: $!";
    $callback->();
    close $index_lock_fh;
}

=method write_index

Writes the sitemap index file to disk and removes any leftover files in
C<output-dir> that aren't contained by the index.

=cut

sub write_index {
    my ($self) = @_;

    $self->lock_index(sub {
        # Preserve entries added by the overall script after running the
        # incremental script, or vice-versa.
        for my $sitemap ($self->read_index->sitemaps) {
            my $already_exists = any { $_->{loc} eq $sitemap->loc } $self->all_sitemaps;

            next if $already_exists;

            my @path = URI->new($sitemap->loc)->path_segments;
            my $file = pop @path;

            if ($self->do_not_delete($file)) {
                $self->add_sitemap({ loc => $sitemap->loc, lastmod => $sitemap->lastmod });
            }
        }

        open(my $index_fh, '>', $self->index_localname)
            or die "Can't open sitemap index: $!";
        my $data = serialize_sitemap_index($self->all_sitemaps);
        print $index_fh $$data;
        close $index_fh;

        if ($self->compression_enabled) {
            # We --keep the index .xml because we'll need to read it during
            # future runs.
            system 'gzip', '--force', '--keep', $self->index_localname;
        }
    });

    log("Built index $SITEMAP_INDEX_FILENAME, deleting outdated files");

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

    my $url = $self->web_server . '/' . $SITEMAP_INDEX_FILENAME;
    $url .= '.gz' if $self->compression_enabled;

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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
