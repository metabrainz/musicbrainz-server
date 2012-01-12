package MusicBrainz::Server::Data::FileCache;
use Moose;
use namespace::autoclean;

use DBDefs;
use Digest::MD5 qw( md5_hex );
use Digest::MD5::File qw( file_md5_hex );
use File::Find;
use IO::All;
use List::MoreUtils qw( uniq );
use Path::Class qw( dir file );
use MooseX::Types::Moose qw( Str );
use MooseX::Types::Structured qw( Map );

has manifest_signatures => (
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
        } map { DBDefs::STATIC_FILES_DIR . "/$_" }
            @{ $self->manifest_files($manifest, $type) });

        $self->manifest_signatures->{$manifest} = $signature;
    }

    return $self->manifest_signatures->{$manifest};
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

    my $relative_to = DBDefs::STATIC_FILES_DIR;

    return [
        # Convert paths back to relative paths of the manifest directory
        map  { file($_)->relative($relative_to) }

        # Expand directories to files
        map  { _expand("$relative_to/$_", $type) }

        # Ignore blank lines/comments in the manifest
        grep { !/^(#.*|\s*)$/ }
            io("$relative_to/$manifest")->chomp->slurp
    ];
}

sub squash {
    my ($self, $minifier, $manifest, $type, $prefix) = @_;
    my $input = join("\n",
        map { io($_)->all }
             map { DBDefs::STATIC_FILES_DIR . "/$_" }
                @{ $self->manifest_files($manifest, $type) });

    my $hash = $self->manifest_signature($manifest, $type);

    printf STDERR "Compiling $manifest...";
    my $output = $minifier->(input => $input);
    $output > io(DBDefs::STATIC_FILES_DIR . "/$prefix$hash.$type");
    printf STDERR "OK\n";
}

sub compile_javascript_manifest {
    my ($self, $manifest) = @_;
    return $self->squash(DBDefs::MINIFY_SCRIPTS, $manifest, 'js', '');
}

sub compile_css_manifest {
    my ($self, $manifest) = @_;
    return $self->squash(DBDefs::MINIFY_STYLES, $manifest, 'css', 'styles/');
}

__PACKAGE__->meta->make_immutable;
1;
