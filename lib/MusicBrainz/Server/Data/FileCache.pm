package MusicBrainz::Server::Data::FileCache;
use MooseX::Singleton;
use namespace::autoclean -also => [qw( _expand )];

use DBDefs;
use Digest::MD5 qw( md5_hex );
use Digest::MD5::File qw( file_md5_hex );
use File::Find;
use File::Slurp qw( read_file );
use IO::All;
use JSON qw( decode_json );
use List::MoreUtils qw( uniq );
use Path::Class qw( dir file );
use MooseX::Types::Moose qw( Str Int );
use MooseX::Types::Structured qw( Map );
use Try::Tiny;

has manifest_mtime => (
    isa => Int,
    is => 'rw',
    default => sub { 0 }
);

has manifest_last_checked => (
    isa => Int,
    is => 'rw',
    default => sub { 0 }
);

has manifest_signatures => (
    isa => Map[Str, Str],
    is => 'rw',
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
    my ($self, $manifest) = @_;

    my $instance = $self->instance;
    my $time = time();
    my $ttl = DBDefs->STAT_TTL // 0;

    if (($time - $instance->manifest_last_checked) > $ttl) {
        $instance->manifest_last_checked($time);

        my $path = DBDefs->STATIC_FILES_DIR . "/build/rev-manifest.json";
        my @stat = stat($path);
        my $mtime = $stat[9];

        if ($mtime > $instance->manifest_mtime) {
            $instance->manifest_mtime($mtime);
            $instance->manifest_signatures(decode_json(read_file($path)));
        }
    }

    return $self->manifest_signatures->{$manifest};
}

sub template_signature {
    my ($self, $template) = @_;
    my $instance = $self->instance;
    my $signature_key = 'template' . $template;
    unless (exists $instance->file_signatures->{$signature_key}) {
        $instance->file_signatures->{$signature_key} = file_md5_hex(DBDefs->MB_SERVER_ROOT . "/root/" . $template);
    }

    return $instance->file_signatures->{$signature_key};
}

sub pofile_signature {
    my ($self, $domain, $language) = @_;
    my $instance = $self->instance;
    my $signature_key = 'pofile' . $domain . $language;
    unless (exists $instance->file_signatures->{$signature_key}) {
        # First try the language as given, then fall back to the language without a country code.
        my $hash = try {
            file_md5_hex(_pofile_path($domain, $language));
        } catch {
            $language =~ s/[-_][A-Za-z]+$//;
            file_md5_hex(_pofile_path($domain, $language));
        };

        $instance->file_signatures->{$signature_key} = $hash;
    }

    return $instance->file_signatures->{$signature_key};
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

__PACKAGE__->meta->make_immutable;
1;
