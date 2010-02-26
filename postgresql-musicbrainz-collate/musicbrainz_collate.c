
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <sys/stat.h>

#include <unicode/utypes.h>
#include <unicode/ucol.h>
#include <unicode/ustring.h>

#include "postgres.h"
#include "fmgr.h"

PG_MODULE_MAGIC;

Datum musicbrainz_collate (PG_FUNCTION_ARGS);

PG_FUNCTION_INFO_V1(musicbrainz_collate);

static void
warplog (char *msg)
{
    FILE *fp;

    fp = fopen ("/tmp/musicbrainz_collate.log", "ab");
    fwrite (msg, 1, strlen (msg), fp);
    fwrite ("\n", 1, strlen ("\n"), fp);
    fclose (fp);

    chmod ("/tmp/musicbrainz_collate.log", 0777);
}


static UChar *
unicode_from_pg_text (text *pg_input)
{
    UErrorCode status = U_ZERO_ERROR;

    char *input = VARDATA (pg_input);
    int32_t len = VARSIZE (pg_input) - VARHDRSZ;

    UChar *ret;
    int32_t size;

    warplog ("unicode_from_pg_text entered");

    /* get size.  FIXME: should pre-allocate for performance. */
    u_strFromUTF8WithSub (NULL, 0, &size, input, len, 0xFFFD, NULL, &status);
    size += 1;
    ret = (UChar *) malloc (sizeof (UChar) * size);

    status = U_ZERO_ERROR;
    u_strFromUTF8WithSub (ret, size, NULL, input, len, 0xFFFD, NULL, &status);

    warplog ("unicode_from_pg_text exit");

    return ret;
}

static int32_t
sortkey_from_unicode (UChar *input, uint8_t **output)
{
    UErrorCode status = U_ZERO_ERROR;
    UCollator * collator = ucol_openFromShortString ("", FALSE, NULL, &status);
    int32_t size;

    warplog ("sortkey_from_unicode entered");

    /* FIXME: check status here. */

    /* get size.  FIXME: should pre-allocate for performance. */
    size = ucol_getSortKey (collator, input, -1, NULL, 0);
    *output = (uint8_t *) malloc (sizeof (uint8_t) * size);
    ucol_getSortKey (collator, input, -1, *output, size);

    warplog ("sortkey_from_unicode exit");

    return size;
}

Datum
musicbrainz_collate (PG_FUNCTION_ARGS)
{
    UChar *unicode;
    uint8_t *sortkey = NULL;
    int32_t sortkeylen;
    bytea *output;

    warplog ("");
    warplog ("===========================");
    warplog ("musicbrainz_collated started");

    if (PG_ARGISNULL (0)) 
    {
        PG_RETURN_NULL();
    }

    unicode = unicode_from_pg_text (PG_GETARG_TEXT_P(0));
    sortkeylen = sortkey_from_unicode (unicode, &sortkey);

    warplog ("palloc output variable");

    output = (bytea *)palloc (sortkeylen + VARHDRSZ);

    warplog ("SET_VARSIZE on sortkey");

    SET_VARSIZE (output, sortkeylen + VARHDRSZ);

    warplog ("memcpy from sortkey to output");

    memcpy (VARDATA (output), sortkey, sortkeylen);

    warplog ("free memory");

    free (unicode);
    free (sortkey);

    warplog ("return output");

    PG_RETURN_BYTEA_P( output );
}
