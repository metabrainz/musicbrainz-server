/* unaccent.c */

#include <stdio.h>
#include "postgres.h"
#include "fmgr.h"
#include "utils/builtins.h"
#include "mb/pg_wchar.h"
#include "tsearch/ts_public.h"
#include "tsearch/ts_locale.h"

#include "musicbrainz_unaccent_data.h"

PG_MODULE_MAGIC;

PG_FUNCTION_INFO_V1(unaccent);
Datum       unaccent(PG_FUNCTION_ARGS);

PG_FUNCTION_INFO_V1(dunaccentdict_init);
Datum       dunaccentdict_init(PG_FUNCTION_ARGS);

PG_FUNCTION_INFO_V1(dunaccentdict_lexize);
Datum       dunaccentdict_lexize(PG_FUNCTION_ARGS);

#define TextPGetCString(t) DatumGetCString(DirectFunctionCall1(textout, PointerGetDatum(t)))
#define CStringGetTextP(c) DatumGetTextP(DirectFunctionCall1(textin, CStringGetDatum(c)))

/* Encode one Unicode codepoint as UTF-8. It expects that there is
   enough space in the string. */
static int
utf8_encode_char(char *str, unsigned long c)
{
    if (c < 0x80) {
        *str++ = (unsigned char) c;
        return 1;
    }
    else if (c < 0x800) {
        *str++ = 0xc0 | (c >> 6);
        *str++ = 0x80 | (c & 0x3f);
        return 2;
    }
    else if (c < 0x10000) {
        *str++ = 0xe0 | (c >> 12);
        *str++ = 0x80 | ((c >> 6) & 0x3f);
        *str++ = 0x80 | (c & 0x3f);
        return 3;
    }
    else {
        *str++ = 0xf0 | (c >> 18);
        *str++ = 0x80 | ((c >> 12) & 0x3f);
        *str++ = 0x80 | ((c >> 6) & 0x3f);
        *str++ = 0x80 | (c & 0x3f);
        return 4;
    }
}

/* Calculate byte length of one Unicode codepoint encoded as UTF-8. */
static int
utf8_encode_char_len(unsigned long c)
{
    if (c < 0x80) {
        return 1;
    }
    else if (c < 0x800) {
        return 2;
    }
    else if (c < 0x10000) {
        return 3;
    }
    else {
        return 4;
    }
}

/* Decode one Unicode codepoint from UTF-8. */
static unsigned long
utf8_decode_char(const char *str, int len, int *c_len)
{
    uint32 c1, c2, c3, c4;
    unsigned long c;

    if ((*str & 0x80) == 0) {
        c = *str++;
        *c_len = 1;
    }
    else if ((*str & 0xe0) == 0xc0 && len >= 2) {
        c1 = *str++ & 0x1f;
        c2 = *str++ & 0x3f;
        c = (c1 << 6) | c2;
        *c_len = 2;
    }
    else if ((*str & 0xf0) == 0xe0 && len >= 3) {
        c1 = *str++ & 0x0f;
        c2 = *str++ & 0x3f;
        c3 = *str++ & 0x3f;
        c = (c1 << 12) | (c2 << 6) | c3;
        *c_len = 3;
    }
    else if ((*str & 0xf8) == 0xf0 && len >= 4) {
        c1 = *str++ & 0x07;
        c2 = *str++ & 0x3f;
        c3 = *str++ & 0x3f;
        c4 = *str++ & 0x3f;
        c = (c1 << 18) | (c2 << 12) | (c3 << 6) | c4;
        *c_len = 4;
    }
    else {
        c = *str++;
        *c_len = 0;
    }

    return c;
}

/* Look up a character in the unac tables. */
static void
unac_lookup(unsigned long c, unsigned short **conv_data, int *conv_len)
{
    int block, position, pos;
    unsigned char *positions;

    if (c > 0xFFFF) {
        *conv_data = NULL;
        *conv_len = 0;
        return;
    }

    block = unaccent_indexes[c >> UNACCENT_BLOCK_SHIFT];
    position = c & UNACCENT_BLOCK_MASK;

    positions = unaccent_positions[block];
    pos = positions[position];
    *conv_data = &unaccent_data[block][pos];
    *conv_len = positions[position + 1] - pos;
}

/* Calculate byte length of a string with removed accents. */
static int
utf8_unac_len(const char *input, int len)
{
    pg_wchar c;
    unsigned short *conv_data;
    int cnt = 0, conv = 0, conv_len, c_len;

    while (len > 0) {
        /* read the next character */
        c = utf8_decode_char(input, len, &c_len);
        if (c_len <= 0)
            break;

        /* look up the character in the unac tables */
        unac_lookup(c, &conv_data, &conv_len);

        if (conv_len > 0) {
            while (conv_len--) {
                cnt += utf8_encode_char_len(*conv_data++);
            }
            conv = 1;
        }
        else {
            cnt += c_len;
        }

        len -= c_len;
        input += c_len;
    }

    return conv ? cnt : 0;
}

/* Remove accents from a UTF-8 string 'input', store the result in
   'output'. It expects that there is enough space for the unaccented
   string (see utf8_unac_len). */
static void
utf8_unac(const char *input, int len, char *output)
{
    pg_wchar c;
    unsigned short *conv_data;
    int c_len, conv_len;

    while (len > 0) {
        /* read the next character */
        c = utf8_decode_char(input, len, &c_len);
        if (c_len <= 0)
            break;

        /* look up the character in the unac tables */
        unac_lookup(c, &conv_data, &conv_len);

        if (conv_len > 0) {
            /* found an version of the character without accents */
            while (conv_len--) {
                output += utf8_encode_char(output, *conv_data++);
            }
            len -= c_len;
            input += c_len;
        }
        else {
            /* not an accented character, just copy the data */
            len -= c_len;
            while (c_len--) {
                *output++ = *input++;
            }
        }
    }
}

/* Check if the string consists only of ASCII characters. */
static int
is_ascii(const char *input)
{
    while (*input) {
        if (*input & 0x80)
            return 0;
        input++;
    }
    return 1;
}

/* Remove accents from a string in the DB encoding. This might return the original
   pointer, if unaccenting is not necessary. Otherwise it returns a newly palloc'ed
   pointer. */
static char *
unaccent_string(char *input)
{
    char *utf8_output, *utf8_input;
    int utf8_output_len, utf8_input_len, input_len;

    input_len = strlen(input);

    /* check if there are any non-ascii characters in the string */
    if (is_ascii(input)) {
        /* ascii string => nothing to do */
        return input;
    }

    /* convert the input from the DB encoding to UTF-8 */
    utf8_input = (char *)pg_do_encoding_conversion(
        (unsigned char *)input, input_len,
        GetDatabaseEncoding(), PG_UTF8);
    utf8_input_len = strlen(utf8_input);

    /* calculate the length of the unaccented character */
    utf8_output_len = utf8_unac_len(utf8_input, utf8_input_len);
    if (!utf8_output_len) {
        /* no accented character => nothing to do */
        if (utf8_input != input) {
            pfree(utf8_input);
        }
        return input;
    }

    /* allocate memory for the unaccented string */
    utf8_output = palloc(utf8_output_len + 1);
    if (!utf8_output) {
        /* out of memory? */
        if (utf8_input != input) {
            pfree(utf8_input);
        }
        return input;
    }

    /* remove accents */
    utf8_unac(utf8_input, utf8_input_len, utf8_output);
    utf8_output[utf8_output_len] = '\0';
    if (utf8_input != input) {
        pfree(utf8_input);
    }

    /* convert the result from UTF-8 back to the DB encoding */
    return (char *)pg_do_encoding_conversion(
        (unsigned char *)utf8_output, utf8_output_len,
        PG_UTF8, GetDatabaseEncoding());
}

/* PostgreSQL functions */

Datum
unaccent(PG_FUNCTION_ARGS)
{
    char *output, *input;
    text *result;

    input = TextPGetCString(PG_GETARG_DATUM(0));

    output = unaccent_string(input);

    result = CStringGetTextP(output);
    if (input != output)
        pfree(output);

    PG_RETURN_TEXT_P(result);
}

Datum
dunaccentdict_init(PG_FUNCTION_ARGS)
{
    PG_RETURN_POINTER(NULL);
}

Datum
dunaccentdict_lexize(PG_FUNCTION_ARGS)
{
    char *input, *output;
    int input_len;
    TSLexeme *result;

    input = (char *) PG_GETARG_POINTER(1);
    input_len = PG_GETARG_INT32(2);
    input = lowerstr_with_len(input, input_len);

    output = unaccent_string(input);

    result = palloc(sizeof(TSLexeme) * 2);
    result[0].lexeme = output;
    result[1].lexeme = NULL;
    if (input != output)
        pfree(input);

    PG_RETURN_POINTER(result);
}
