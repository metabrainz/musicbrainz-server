package MusicBrainz::Server::Data::FileCache;
use Moose;
use namespace::autoclean;

use DBDefs;
use Digest::MD5 qw( md5_hex );
use Javascript::Closure qw( minify );
use IO::All;

with 'MusicBrainz::Server::Data::Role::Context';

sub modified {
    my ($self, $path) = @_;
    $path = DBDefs::STATIC_FILES_DIR . "/$path";
    my $cache = $self->c->cache('file-cache');
    my $key = "mtime:$path";

    my $mtime = $cache->get($key);
    unless (defined $mtime) {
        $mtime = (stat($path))[9];
        $cache->set($key, $mtime);
    }

    return $mtime;
}

sub squash_scripts {
    my ($self, @files) = @_;
    my $hash = md5_hex(join ",", sort @files);
    my $path = DBDefs::STATIC_PREFIX . "/$hash.js";
    my $file = DBDefs::STATIC_FILES_DIR . "/$hash.js";
    unless (-e$file) {
        minify( input => join("\n", map { io($_)->all } @files) ) > io($file);
    }

    return $path;
}

__PACKAGE__->meta->make_immutable;
1;
