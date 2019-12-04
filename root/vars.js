/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/*
 * This file declares variables inserted by Webpack's ProvidePlugin.
 * See /webpack/providePluginConfig.js.
 */

/* eslint no-unused-vars: 0 */

declare var addColon: (variable: Expand2ReactInput) => Expand2ReactOutput;
declare var addColonText: (variable: StrOrNum) => string;
declare var hyphenateTitle: (title: string, subtitle: string) => string;

declare var l: (key: string) => string;
declare var ln: (skey: string, pkey: string, val: number) => string;
declare var lp: (key: string, context: string) => string;

declare var N_l: (key: string) => () => string;
declare var N_ln: (skey: string, pkey: string) => (val: number) => string;
declare var N_lp: (key: string, context: string) => () => string;

declare var l_attributes: typeof l;
declare var lp_attributes: typeof lp;

declare var l_countries: typeof l;

declare var l_instrument_descriptions: typeof l;

declare var l_instruments: typeof l;
declare var lp_instruments: typeof lp;

declare var l_languages: typeof l;

declare var l_relationships: typeof l;

declare var l_scripts: typeof l;

declare var l_statistics: typeof l;

declare var exp: {
  +l: (
    key: string,
    args?: ?{+[string]: Expand2ReactInput, ...},
  ) => Expand2ReactOutput,
  +ln: (
    skey: string,
    pkey: string,
    val: number,
    args?: ?{+[string]: Expand2ReactInput, ...},
  ) => Expand2ReactOutput,
  +lp: (
    key: string,
    context: string,
    args?: ?{+[string]: Expand2ReactInput},
  ) => Expand2ReactOutput,
};

declare var texp: {
  +l: (key: string, args: {+[string]: StrOrNum, ...}) => string,
  +ln: (
    skey: string,
    pkey: string,
    val: number,
    args: {+[string]: StrOrNum, ...},
  ) => string,
  +lp: (
    key: string,
    context: string,
    args: {+[string]: StrOrNum, ...},
  ) => string,
};
