/**
 * Lazy generic streams
 *
 * @module data.stream/lib/index
 */

var extend = require('xtend');

module.exports = extend(require('./stream'), require('./operations'));
