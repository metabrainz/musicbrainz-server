declare module 'jed' {
  declare export type JedOptions = {
    domain?: string,
    locale_data: {
      [string]: {
        '': {
          domain: string,
          lang: string,
          plural_forms: string,
        },
        [string]: Array<string>,
        ...
      },
      ...
    },
    missing_key_callback?: (key: string, domain: string) => void,
  };

  declare class Jed {
    constructor(options: JedOptions): Jed;
    locale?: string,
    options: JedOptions;
    dgettext(domain: string, key: string): string;
    dngettext(
      domain: string,
      singular_key: string,
      plural_key: string,
      value: number,
    ): string;
    dpgettext(domain: string, context: string, key: string): string;
  }

  declare module.exports: typeof Jed;
}
