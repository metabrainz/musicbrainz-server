// eslint-disable-next-line import/no-dynamic-require
const Benchmark = require(
  process.env.BENCHMARK_PATH || '/usr/lib/node_modules/benchmark',
);

const suite = new Benchmark.Suite();

function createFastObjectCloneFunction(keys) {
  const keyValueItems = [];

  for (const key of keys) {
    const jsonKey = JSON.stringify(key);
    keyValueItems.push(jsonKey + ':o[' + jsonKey + ']');
  }

  return new Function(
    'o',
    'return {' + keyValueItems.join(',') + '}',
  );
}

const sourceObject = {
  '0Ep7cfSoziqJ': 12,
  'ADbltzPWRZF': '1b8f588f-ce91-455a-bcda-3379e0fe32e6',
  'cetWNwNCWf5F0KrUfYp': 19,
  'fJYLgdvn45ODodt5A': null,
  'G5ROBVeBPX1Kv3': 14,
  'gjanvC7dVr1XKBEJ': Symbol(),
  'GstYU9cNWD5U2': 13,
  'JanRE3Y1acx1NBykz0': true,
  'qzyQcXgFxnqqGkL': 1237289132710943112311341432n,
  'tcPhTjhSCGNN68V1u3jT': undefined,
  'V7HJKnDJaH': false,
};

const fastClone = createFastObjectCloneFunction(Object.keys(sourceObject));

let counter = 0;

suite
  .add('spread', function () {
    const clone = {...sourceObject};
    clone.GstYU9cNWD5U2 = counter++;
  })
  .add('fastClone', function () {
    const clone = fastClone(sourceObject);
    clone.GstYU9cNWD5U2 = counter++;
  })
  .on('cycle', function (event) {
    console.log(String(event.target));
  })
  .on('complete', function () {
    console.log('Fastest is ' + this.filter('fastest').map('name'));
  })
  .run({async: true});
