package MusicBrainz::Server::Data::FileCache;
use Moose;
use namespace::autoclean -also => [qw( _expand )];

use DBDefs;
use Digest::MD5 qw( md5_hex );
use Digest::MD5::File qw( file_md5_hex );
use File::Find;
use IO::All;
use List::MoreUtils qw( uniq );
use Path::Class qw( dir file );
use MooseX::Types::Moose qw( Str );
use MooseX::Types::Structured qw( Map );
use Try::Tiny;

has manifest_signatures => (
    isa => Map[Str, Str],
    is => 'ro',
    traits => [ 'Hash' ],
    default => sub { {} }
);

has file_signatures => (
    isa => Map[Str, Str],
    is => 'ro',
    traits => [ 'Hash' ],
    default => sub { {} }
);

sub manifest_signature {
    my ($self, $manifest, $type) = @_;
    unless (exists $self->manifest_signatures->{$manifest}) {
        my $signature = md5_hex(join ',', map {
            join(':', file($_)->basename, file_md5_hex($_));
        } map { DBDefs->STATIC_FILES_DIR . "/$_" }
            $self->manifest_files($manifest, $type));

        $self->manifest_signatures->{$manifest} = $signature;
    }

    return $self->manifest_signatures->{$manifest};
}

sub template_signature {
    my ($self, $template) = @_;
    my $signature_key = 'template' . $template;
    unless (exists $self->file_signatures->{$signature_key}) {
        $self->file_signatures->{$signature_key} = file_md5_hex(DBDefs->MB_SERVER_ROOT . "/root/" . $template);
    }

    return $self->file_signatures->{$signature_key};
}

sub pofile_signature {
    my ($self, $domain, $language) = @_;
    my $signature_key = 'pofile' . $domain . $language;
    unless (exists $self->file_signatures->{$signature_key}) {
        # First try the language as given, then fall back to the language without a country code.
        my $hash = try {
            file_md5_hex(_pofile_path($domain, $language));
        } catch {
            $language =~ s/[-_][A-Za-z]+$//;
            file_md5_hex(_pofile_path($domain, $language));
        };

        $self->file_signatures->{$signature_key} = $hash;
    }

    return $self->file_signatures->{$signature_key};
}

sub _pofile_path
{
    my ($domain, $language) = @_;
    return DBDefs->MB_SERVER_ROOT . "/po/" . $domain . "." . $language . ".po";
}

sub _expand {
    my ($path, $type) = @_;
    if (-d $path) {
        my @items;
        find(sub { push @items, $File::Find::name if $_ =~ /\.$type$/ }, $path);
        return uniq sort @items;
    }
    else {
        return $path =~ /\.$type$/ ? (file($path)->absolute) : ();
    }
}

sub manifest_files {
    my ($self, $manifest, $type) = @_;

    my $relative_to = DBDefs->STATIC_FILES_DIR;

    return
        # Convert paths back to relative paths of the manifest directory
        map  { file($_)->relative($relative_to) }

        # Expand directories to files
        map  { _expand("$relative_to/$_", $type) }

        # Ignore blank lines/comments in the manifest
        grep { !/^(#.*|\s*)$/ }
            io("$relative_to/$manifest")->chomp->slurp;
}

sub squash {
    my ($self, $minifier, $manifest, $type, $prefix) = @_;
    my $hash = $self->manifest_signature($manifest, $type);
    my $filename = DBDefs->STATIC_FILES_DIR . "/$prefix$hash.$type";

    if (!-f $filename) {
        my $input = join("\n",
            map { io($_)->all }
                 map { DBDefs->STATIC_FILES_DIR . "/$_" }
                    $self->manifest_files($manifest, $type));

        printf STDERR "Compiling $manifest...";
        try {
            my $output = $minifier->(input => $input);
            $output > io($filename);
            printf STDERR "OK\n";
        } catch {
            my $err = $_;
            printf STDERR "FAIL\n";
            printf STDERR "Error: $err\n";
            printf STDERR "Deleting $prefix$hash.$type.\n";
            system("rm -f $filename");
        }
    } else {
        printf STDERR "$manifest already compiled.\n";
    }
}

sub compile_javascript_manifest {
    my ($self, $manifest) = @_;
    return $self->squash(DBDefs->MINIFY_SCRIPTS, $manifest, 'js', '');
}

sub compile_css_manifest {
    my ($self, $manifest) = @_;
    return $self->squash(DBDefs->MINIFY_STYLES, $manifest, 'css', 'styles/');
}

__PACKAGE__->meta->make_immutable;
1;
