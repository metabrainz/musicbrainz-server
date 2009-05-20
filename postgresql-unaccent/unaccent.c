/* unaccent.c */

#include "postgres.h"
#include "fmgr.h"
#include "utils/builtins.h"
#include "mb/pg_wchar.h"
#include "tsearch/ts_public.h"

#include <unac.h>

PG_MODULE_MAGIC;

PG_FUNCTION_INFO_V1(unaccent);
Datum		unaccent(PG_FUNCTION_ARGS);

PG_FUNCTION_INFO_V1(dunaccentdict_init);
Datum		dunaccentdict_init(PG_FUNCTION_ARGS);

PG_FUNCTION_INFO_V1(dunaccentdict_lexize);
Datum		dunaccentdict_lexize(PG_FUNCTION_ARGS);

#define TextPGetCString(t) DatumGetCString(DirectFunctionCall1(textout, PointerGetDatum(t)))
#define CStringGetTextP(c) DatumGetTextP(DirectFunctionCall1(textin, CStringGetDatum(c)))

Datum unaccent(PG_FUNCTION_ARGS)
{
	text *result;
	char *input, *output = 0;
	size_t input_len, output_len;

	input = TextPGetCString(PG_GETARG_DATUM(0));
	input_len = strlen(input);

	unac_string(GetDatabaseEncodingName(), input, input_len, &output, &output_len);

	result = CStringGetTextP(output);
	free(output);

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
	int i;
	char *out = NULL, *in = (char *)PG_GETARG_POINTER(1);
	size_t out_len, in_len = PG_GETARG_INT32(2);
	TSLexeme *res = palloc(sizeof(TSLexeme) * 2);

	res[1].lexeme = NULL;
	for (i = 0; i < in_len; i++) {
		if (in[i] & 0x80) {
			if (unac_string(GetDatabaseEncodingName(), in, in_len, &out, &out_len) == 0) {
				res[0].lexeme = lowerstr_with_len(out, out_len);
				free(out);
				PG_RETURN_POINTER(res);
			}
			break;
		}
	}

	res[0].lexeme = lowerstr_with_len(in, in_len);
	PG_RETURN_POINTER(res);
}
