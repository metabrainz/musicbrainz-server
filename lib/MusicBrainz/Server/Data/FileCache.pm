package MusicBrainz::Server::Data::FileCache;
use MooseX::Singleton;
use namespace::autoclean -also => [qw( _expand )];

use DBDefs;
use Digest::MD5::File qw( file_md5_hex );
use File::Find;
use File::Slurp qw( read_file );
use IO::All;
use JSON qw( decode_json );
use List::AllUtils qw( uniq );
use Path::Class qw( file );
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

        my $path = DBDefs->STATIC_FILES_DIR . '/build/rev-manifest.json';
        my @stat = stat($path);
        my $mtime = $stat[9];

        if (defined $mtime && $mtime > $instance->manifest_mtime) {
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
        $instance->file_signatures->{$signature_key} = file_md5_hex(DBDefs->MB_SERVER_ROOT . '/root/' . $template);
    }

    return $instance->file_signatures->{$signature_key};
}

sub path_to {
    my ($self, $manifest) = @_;

    $manifest =~ s/^\///;
    $manifest =~ s/\.js(on)?$//;
    return DBDefs->STATIC_RESOURCES_LOCATION . '/' .
        ($self->manifest_signature($manifest) // $manifest);
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
