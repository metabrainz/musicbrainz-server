package MusicBrainz::Server::Replication::Packet;

use strict;
use warnings;

use base 'Exporter';
use DBDefs;
use File::Temp qw( tempdir );
use GnuPG qw( :algo );
use HTTP::Status qw( RC_NOT_FOUND );
use LWP::UserAgent;
use Try::Tiny;
use URI::Escape qw( uri_escape );

our @EXPORT_OK = qw(
    decompress_packet
    retrieve_remote_file
);

sub decompress_packet {
    my ($template, $tmp_dir, $local_file, $cleanup) = @_;

    $cleanup //= 1;
    my $output_dir = tempdir($template, DIR => $tmp_dir, CLEANUP => $cleanup);

    print localtime() . " : Decompressing $local_file to $output_dir\n";

    my $tar = `which tar`;
    chomp $tar;
    system $tar, '-C', $output_dir, '--bzip2', '-xvf', $local_file;
    exit $? if $?;

    unlink $local_file or warn "unlink $local_file: $!\n";
    return $output_dir;
}

sub retrieve_remote_file {
    my ($url, $file, $verify_signature) = @_;

    # Initialise User Agent
    my $ua = LWP::UserAgent->new(
        agent => '$Id$',
    );
    $ua->env_proxy;
    $ua->ssl_opts(verify_hostname => 0);

    # Fetch the file and inform the user about what is being done
    print localtime() . " : Downloading $url to $file\n";

    my $f_url_token = $url . '?token=' . uri_escape(DBDefs->REPLICATION_ACCESS_TOKEN);
    my $f_resp = $ua->mirror($f_url_token, $file);

    # We do not want to validate signature for non-existent files
    if ($verify_signature && $f_resp->code != RC_NOT_FOUND) {
        # Identify signature URL and Local filename
        $url .= '.asc';
        my $signature = $file . '.asc';

        # Fetch file signature and inform the user about what is being done
        print localtime() . " : Downloading $url to $signature\n";
        my $s_url_token = $url . '?token=' . uri_escape(DBDefs->REPLICATION_ACCESS_TOKEN);
        $ua->mirror($s_url_token, $signature);

        validate_file_signature($file, $signature);
    }

    return $f_resp;
}

sub validate_file_signature {
    my ($file, $signature) = @_;

    # Make sure that the file to be tested exists
    die "Can't find file $file: $!" unless -e $file;

    # Make sure that the signature exists
    unless (-e $signature) {
        # React based on the configured mode for missing signature
        (DBDefs->GPG_MISSING_SIGNATURE_MODE =~ m/FAIL/i)
            ? die "Can't find signature file $file: $!"
            : return;
    }

    # Initialise GnuPG module in local scope
    my $gpg = GnuPG->new;

    # Attempt to verify file signature
    try {
        $gpg->import_keys(keys => [DBDefs->GPG_PUB_KEY]);
        $gpg->verify(signature => $signature, file => $file);
        unlink $signature or warn "unlink $signature: $!\n";
    } catch {
        # Exist with and error if verification failed
        printf STDERR "Failed to verify signature for $file \nGPG returned $_";
        die;
    };
}

1;
