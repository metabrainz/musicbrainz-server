// flow-typed signature: 31778ba57f8af9b5c239b445698a3231
// flow-typed version: b43dff3e0e/he_v1.x.x/flow_>=v0.25.x

declare module 'he' {
  declare type encodeOptions = {
    useNamedReferences?: bool,
    decimal?: bool,
    encodeEverything?: bool,
    strict?: bool,
    allowUnsafeSymbols?: bool,
  };
  declare type decodeOptions = {
    isAttributeValue?: bool,
    strict?: bool,
  };
  declare module.exports: {
    version: string,
    encode: (text: string, options?: encodeOptions) => string & {
      options: encodeOptions,
    },
    decode: (text: string, options?: decodeOptions) => string & {
      options: decodeOptions,
    },
    escape(text: string): string,
    unescape(text: string, options?: encodeOptions): string,
  }
}
