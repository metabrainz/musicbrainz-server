package MusicBrainz::Server::Data::FileCache;
use Moose;
use namespace::autoclean;

use DBDefs;
use Digest::MD5 qw( md5_hex );
use JavaScript::Minifier::XS qw( minify );
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
    my $cache = $self->c->cache('file-cache');
    my $key = "squash:$hash";

    my $path = $cache->get($key);
    unless (defined $path) {
        my $js;
        for my $file (@files) {
            io(DBDefs::STATIC_FILES_DIR . "/$file") >> $js;
        }

        $js = minify($js);
        io(DBDefs::STATIC_FILES_DIR . "/$hash.js") < $js;

        $cache->set($key, $hash);
    }

    return DBDefs::STATIC_PREFIX . "/$hash.js";
}

__PACKAGE__->meta->make_immutable;
1;
