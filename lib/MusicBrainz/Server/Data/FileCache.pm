package MusicBrainz::Server::Data::FileCache;
use Moose;
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

    $manifest =~ s/\.manifest$//;

    my $path = DBDefs->STATIC_FILES_DIR . "/build/rev-manifest.json";
    my @stat = stat($path);
    my $mtime = $stat[9];

    if ($mtime > $self->manifest_mtime) {
        $self->manifest_mtime($mtime);
        $self->manifest_signatures(decode_json(read_file($path)));
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

__PACKAGE__->meta->make_immutable;
1;
