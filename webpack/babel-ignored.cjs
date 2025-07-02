/* eslint-disable import/no-commonjs */

// Note: This file is CommonJS because ESLint doesn't support async parsers.

module.exports = [
  /*
   * The modules in the negative-lookahead assertion (?!...) are exceptions
   * to the node_modules exclusion. These most likely use language features
   * that aren't supported in all of our supported browsers.
   *
   * If we're targeting legacy browsers, process all node_modules to be safe,
   * except for core-js.
   */
  ...(
    process.env.BROWSER_TARGET === 'legacy'
      ? [/node_modules\/core-js/]
      : [/node_modules\/(?!@babel\/runtime|@floating-ui|jed|mutate-cow|punycode|react|weight-balanced-tree)/]
  ),
  /root\/static\/scripts\/tests\/typeInfo\.js/,
  /root\/static\/build\/jed-[A-z0-9_-]+?\.source\.js$/,
];
