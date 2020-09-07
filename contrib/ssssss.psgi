#!/usr/bin/env perl
use strict;
use warnings;
use feature "switch";

# Sufficiently Sophisticated Simple Storage Service Simulator is a
# drop-in replacement for the archive.org S3 service.  It mimics just
# enough of the archive.org S3 protocol + service to allow a development
# deployment of the MusicBrainz server to upload cover art to a local
# folder, instead of the archive.org servers.

# ----------------------------------------------------------------------

# ssssss.psgi version 2
# Copyright (C) 2012  MetaBrainz Foundation

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use File::Copy;
use File::Slurp qw( read_file );
use File::Spec;
use FindBin;
use Plack::Request;
use Plack::Response;
use Log::Dispatch;

my $log = Log::Dispatch->new(outputs => [[ 'Screen', min_level => 'info' ]] );
my $imgext = 'gif|jpg|pdf|png';
my $ssssss_storage = $ENV{SSSSSS_STORAGE}
    ? glob($ENV{SSSSSS_STORAGE})
    : catfile($FindBin::Bin, 'caa');

sub catfile { return File::Spec->catfile(@_); }

sub thumb
{
    my ($filename, $max) = @_;

    my $newfile = $filename;
    $newfile =~ s/.($imgext)$/_thumb$max.jpg/;

    $log->info("Generating ${max}x${max} thumbnail, $newfile\n");

    `convert -thumbnail ${max}x${max} "$filename\[0\]" $newfile`;
}

sub create_bucket
{
    my $bucket = shift;

    my $bucketdir = catfile($ssssss_storage, $bucket);

    `mkdir -p $bucketdir` unless -d $bucketdir;

    return $bucketdir;
}

sub handle_options
{
    my $response = shift->new_response(200);
    $response->content_type('text/plain');
    $response->headers({ Allow => 'GET,HEAD,POST,OPTIONS' });
    return $response;
}

sub handle_put
{
    my ($request) = @_;

    my $bucketdir = create_bucket($request->path_info);
    my $dest = catfile($bucketdir, $request->param('file'));
    $log->info("PUT, storing upload at $dest\n");

    open(my $fh, ">", $dest);
    print $fh $request->content;
    close($fh);

    return $request->new_response(204);
}

sub handle_post
{
    my ($request) = @_;

    my $key = $request->param('key');
    return undef unless $key;

    my $bucketdir = create_bucket($request->path_info);
    my $dest = catfile($bucketdir, $request->param('key'));
    $log->info("POST, storing upload at $dest\n");

    move($request->uploads->{file}->path, $dest);

    if ($key =~ /.($imgext)$/)
    {
        thumb(catfile($bucketdir, $key), 250);
        thumb(catfile($bucketdir, $key), 500);
    }

    my $redirect = $request->param('success_action_redirect');
    my $status = $request->param('success_action_status');

    if ($redirect)
    {
        my $response = $request->new_response(303);
        $response->location($redirect);
        return $response;
    }
    elsif (defined $status && $status eq "200")
    {
        return $request->new_response(200);
    }
    elsif (defined $status && $status eq "201")
    {
        my $response = $request->new_response(201);
        $response->body("<fixme>some xml response goes here. see: http://docs.amazonwebservices.com/AmazonS3/latest/dev/HTTPPOSTForms.html?r=3818</fixme>");
        return $response;
    }
    else
    {
        return $request->new_response(204);
    }
}

my %mime_types = (
    gif => 'image/gif',
    jpg => 'image/jpeg',
    pdf => 'application/pdf',
    png => 'image/png',
);

sub handle_get {
    my ($request) = @_;

    my $filename = catfile($ssssss_storage, $request->path_info);

    if (-f $filename) {
        my ($ext) = $filename =~ m/\.($imgext)$/;
        my $image_data = read_file($filename, {binmode => ':raw'});
        my $response = $request->new_response(200);
        $response->content_type($mime_types{$ext});
        $response->body($image_data);
        return $response;
    }

    return $request->new_response(404);
}

sub {
    my $request = Plack::Request->new(shift);

    my $response;

    given ($request->method) {
        when ("PUT")     { $response = handle_put($request) }
        when ("POST")    { $response = handle_post($request) }
        when ("OPTIONS") { $response = handle_options($request) }
        when ("GET")     { $response = handle_get($request) }
    }

    $response->header("Access-Control-Allow-Origin" => "*");
    return $response->finalize;
}
