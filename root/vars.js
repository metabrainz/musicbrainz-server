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

/* eslint-disable no-unused-vars */

// eslint-disable-next-line camelcase
declare var __webpack_public_path__: string;
declare var __DEV__: boolean;
declare var GLOBAL_JS_NAMESPACE: '__MB__';
declare var MUSICBRAINZ_RUNNING_TESTS: false;

declare var addColon: (variable: Expand2ReactInput) => Expand2ReactOutput;
declare var addColonText: (variable: StrOrNum) => string;
declare var hasOwnProp: (
  object: interface {},
  prop: string,
) => boolean;
declare var hydrate: (
  <
    Config: {+$c?: CatalystContextT, ...},
    SanitizedConfig = Config,
  >(
    containerSelector: string,
    Component: React$AbstractComponent<Config | SanitizedConfig, mixed>,
    mungeProps?: (Config) => SanitizedConfig,
  ) => React$AbstractComponent<Config, void>
);
declare var hyphenateTitle: (title: string, subtitle: string) => string;
function nonEmptyFn(value: mixed): boolean %checks {
  return value !== null && value !== undefined && value !== '';
}
declare var nonEmpty: typeof nonEmptyFn;

declare var l: (key: string) => string;
declare var ln: (skey: string, pkey: string, val: number) => string;
declare var lp: (key: string, context: string) => string;

declare var N_l: (key: string) => () => string;
declare var N_ln: (skey: string, pkey: string) => (val: number) => string;
declare var N_lp: (key: string, context: string) => () => string;

declare var l_attributes: typeof l;
declare var ln_attributes: typeof ln;
declare var lp_attributes: typeof lp;

declare var l_countries: typeof l;
declare var ln_countries: typeof ln;
declare var lp_countries: typeof lp;

declare var l_instrument_descriptions: typeof l;
declare var ln_instrument_descriptions: typeof ln;
declare var lp_instrument_descriptions: typeof lp;

declare var l_instruments: typeof l;
declare var ln_instruments: typeof ln;
declare var lp_instruments: typeof lp;

declare var l_languages: typeof l;
declare var ln_languages: typeof ln;
declare var lp_languages: typeof lp;

declare var l_relationships: typeof l;
declare var ln_relationships: typeof ln;
declare var lp_relationships: typeof lp;

declare var l_scripts: typeof l;
declare var ln_scripts: typeof ln;
declare var lp_scripts: typeof lp;

declare var l_statistics: typeof l;
declare var ln_statistics: typeof ln;
declare var lp_statistics: typeof lp;

declare var exp: {
  +l: (
    key: string,
    args?: ?{+[arg: string]: Expand2ReactInput, ...},
  ) => Expand2ReactOutput,
  +ln: (
    skey: string,
    pkey: string,
    val: number,
    args?: ?{+[arg: string]: Expand2ReactInput, ...},
  ) => Expand2ReactOutput,
  +lp: (
    key: string,
    context: string,
    args?: ?{+[arg: string]: Expand2ReactInput},
  ) => Expand2ReactOutput,
};

declare var texp: {
  +l: (
    key: string,
    args: {+[arg: string]: StrOrNum, ...},
  ) => string,
  +ln: (
    skey: string,
    pkey: string,
    val: number,
    args: {+[arg: string]: StrOrNum, ...},
  ) => string,
  +lp: (
    key: string,
    context: string,
    args: {+[arg: string]: StrOrNum, ...},
  ) => string,
};

// https://flow.org/en/docs/tips/switch-statement-exhaustiveness/
declare var exhaustive: (action: empty) => void;

// root/utility/invariant.js
declare var invariant: (cond: mixed, msg?: string) => empty;
