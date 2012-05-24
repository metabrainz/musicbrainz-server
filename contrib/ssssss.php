<?php  /*

Sufficiently Sophisticated Simple Storage Service Simulator is a
drop-in replacement for the archive.org S3 service.  It mimics just
enough of the archive.org S3 protocol + service to allow a development
deployment of the MusicBrainz server to upload cover art to a local
folder, instead of the archive.org servers.

----------------------------------------------------------------------

ssssss.php version 1
Copyright (c) 2012  MetaBrainz Foundation

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

function thumb ($filename, $max)
{
    $new = str_replace (".jpg", "_thumb$max.jpg", $filename);
    exec('convert -thumbnail '.$max.'x'.$max." $filename $new");
}

function create_bucket ()
{
    $storage = dirname (__FILE__);
    $bucketdir = $storage."/".$_GET["bucket"];

    if (!is_dir ($bucketdir))
    {
        mkdir ($bucketdir, 0777, true);
        chmod ($bucketdir, 0775);
    }

    return $bucketdir;
}

function handle_post ($bucketdir)
{
    if (!array_key_exists ("key", $_POST))
        return;

    rename ($_FILES["file"]["tmp_name"], $bucketdir."/".$_POST["key"]);
    chmod ($bucketdir."/".$_POST["key"], 0644);

    if (substr ($_POST["key"], -4) == ".jpg")
    {
        thumb ($bucketdir."/".$_POST["key"], 250);
        thumb ($bucketdir."/".$_POST["key"], 500);
    }

    header("HTTP/1.0 303 See Other");
    header("Location: ".$_POST["success_action_redirect"]);
}

function handle_put ($bucketdir)
{
    $filename = basename ($_GET["file"]);

    $requestbody = fopen ("php://input", "r");
    $fp = fopen ("$bucketdir/$filename", "wb");
    while ($data = fread($requestbody, 1024))
        fwrite($fp, $data);
    fclose ($fp);
    fclose ($requestbody);
}

function main ()
{
    $bucketdir = create_bucket ();

    if ($_SERVER["REQUEST_METHOD"] === "PUT")
    {
        handle_put ($bucketdir);
    }
    else if ($_SERVER["REQUEST_METHOD"] === "POST")
    {
        handle_post ($bucketdir);
    }
}

main ();
