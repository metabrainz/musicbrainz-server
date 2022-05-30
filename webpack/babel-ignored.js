/* eslint-disable import/no-commonjs */

module.exports = [
  /*
   * The modules in the negative-lookahead assertion (?!...) are exceptions
   * to the node_modules exclusion. These most likely use language features
   * that aren't supported in all of our supported browsers.
   */
  /node_modules\/(?!@babel\/runtime|@popperjs|jed|mutate-cow|punycode|react)/,
  /root\/static\/scripts\/tests\/typeInfo\.js/,
  /root\/static\/build\/jed-[A-z_-]+?\.source\.js$/,
];
