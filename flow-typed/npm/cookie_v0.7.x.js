// @flow strict

declare module 'cookie' {
  declare type CookeParseOptions = {
    readonly decode?: (string) => string,
  };

  declare type CookieSerializeOptions = {
    readonly domain?: string,
    readonly encode?: (string) => string,
    readonly expires?: Date,
    readonly httpOnly?: boolean,
    readonly maxAge?: number,
    readonly partitioned?: boolean,
    readonly path?: string,
    readonly priority?: 'low' | 'medium' | 'high',
    readonly sameSite?: boolean | 'lax' | 'none' | 'strict',
    readonly secure?: boolean,
  };

  declare module.exports: {
    parse: (
      str: string,
      options?: CookeParseOptions,
    ) => {[cookieName: string]: string, ...},
    serialize: (
      name: string,
      value: string,
      options?: CookieSerializeOptions,
    ) => string,
  };
}
