/*
 * Modules that are not meant to execute the server yet are imported from
 * isomorphic components are mapped to here. See the
 * `NormalModuleReplacementPlugin` configuration in webpack/server.config.js.
 *
 * The named `noop` exports prevent Webpack from warning about missing
 * exports at build time.
 */
const noop = () => undefined;
export const jedInstance = undefined;
export const loadDomain = noop;
export default {};
