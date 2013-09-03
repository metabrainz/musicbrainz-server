#!/usr/bin/env perl
use strict;
use warnings;
use feature "switch";

# Sufficiently Sophisticated Simple Storage Service Slow Down Simulator.

# This script simulates the 503 Slow Down response we occassionally get
# from the archive.org servers.

# Copyright (c) 2013  MetaBrainz Foundation

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

use File::Spec;
use Plack::Request;
use Plack::Response;
use Log::Dispatch;

my $log = Log::Dispatch->new(outputs => [[ 'Screen', min_level => 'info' ]] );

sub handle_other {
    my $request = shift;

    $log->info ("storing request body at /tmp/slowdown.bin\n");

    open (my $fh, ">", "/tmp/slowdown.bin");
    print $fh $request->content;
    close ($fh);

    my $response = $request->new_response (503);

    $response->header ("Server" => "Apache/2.2.22 (Ubuntu)");
    $response->header ("Accept-Ranges" => "bytes");
    $response->header ("Access-Control-Allow-Origin" => "*");
    $response->header ("Access-Control-Allow-Methods" => "GET,POST,PUT,DELETE");
    $response->header ("Access-Control-Allow-Headers" => "authorization,".
                       "x-amz-acl,x-amz-auto-make-bucket,cache-control,".
                       "x-requested-with,x-file-name,x-file-size,".
                       "x-archive-ignore-preexisting-bucket,".
                       "x-archive-interactive-priority,x-archive-meta-title,".
                       "x-archive-meta-description,x-archive-meta-language,".
                       "x-archive-meta-mediatype,x-archive-meta01-subject,".
                       "x-archive-meta02-subject,x-archive-meta03-subject,".
                       "x-archive-meta04-subject,x-archive-meta05-subject,".
                       "x-archive-meta01-collection,x-archive-meta02-collection");
    $response->header ("Connection" => "close");
    $response->header ("Content-Type" => "text/plain");

    $response->body ("<?xml version='1.0' encoding='UTF-8'?>\n".
        "<Error>".
        "<Code>SlowDown</Code>".
        "<Message>Please reduce your request rate.</Message>".
        "<Resource />".
        "<RequestId>75659cc3-6352-42d1-93a7-ce9e4f81374e</RequestId>".
        "</Error>");

    return $response;
}

sub handle_options
{
    my $response = shift->new_response (200);
    $response->content_type ('text/plain');
    $response->headers ({ Allow => 'GET,HEAD,POST,OPTIONS' });
    return $response;
}

sub {
    my $request = Plack::Request->new (shift);

    my $response;

    given ($request->method) {
        when ("PUT")     { $response = handle_other ($request) }
        when ("POST")    { $response = handle_other ($request) }
        when ("OPTIONS") { $response = handle_options ($request) }
    }

    $response->header ("Access-Control-Allow-Origin" => "*");
    return $response->finalize;
}
