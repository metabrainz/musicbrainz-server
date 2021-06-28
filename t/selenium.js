#!/usr/bin/env node
/*
 * This file is part of MusicBrainz, the open internet music database.
 * Copyright (C) 2017 MetaBrainz Foundation
 * Licensed under the GPL version 2, or (at your option) any later version:
 * http://www.gnu.org/licenses/gpl-2.0.txt
 */

require('@babel/register');

const argv = require('yargs')
  .option('b', {
    alias: 'browser',
    default: 'chrome',
    describe: 'browser to use (chrome, firefox)',
    type: 'string',
  })
  .option('c', {
    alias: 'coverage',
    default: true,
    describe: 'dump coverage data to .nyc_output/',
    type: 'boolean',
  })
  .option('h', {
    alias: 'headless',
    default: true,
    describe: 'run Chrome in headless mode',
    type: 'boolean',
  })
  .option('s', {
    alias: 'stay-open',
    default: false,
    describe: 'stay logged in and keep the browser open after tests complete',
    type: 'boolean',
  })
  .usage('Usage: $0 [-hs] [file...]')
  .help('help')
  .argv;

const child_process = require('child_process');
const defined = require('defined');
const fs = require('fs');
const http = require('http');
const httpProxy = require('http-proxy');
const JSON5 = require('json5');
const path = require('path');
const test = require('tape');
const TestCls = require('tape/lib/test');
const webdriver = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');
const firefox = require('selenium-webdriver/firefox');
const webdriverProxy = require('selenium-webdriver/proxy');
const {Key} = require('selenium-webdriver/lib/input');
const promise = require('selenium-webdriver/lib/promise');
const until = require('selenium-webdriver/lib/until');

const DBDefs = require('../root/static/scripts/common/DBDefs');
const deepEqual = require('../root/static/scripts/common/utility/deepEqual');
const escapeRegExp =
  require('../root/static/scripts/common/utility/escapeRegExp').default;
const writeCoverage = require('../root/utility/writeCoverage');

function compareEditDataValues(actualValue, expectedValue) {
  if (expectedValue === '$$__IGNORE__$$') {
    return true;
  }
  /*
   * Handle cases where Perl's JSON module serializes numbers in the
   * edit data as strings (something we can't fix easily).
   */
  if (
    (typeof actualValue === 'string' ||
      typeof actualValue === 'number') &&
    (typeof expectedValue === 'string' ||
      typeof expectedValue === 'number')
  ) {
    return String(actualValue) === String(expectedValue);
  }
  // Tells `deepEqual` to perform its default comparison.
  return null;
}

TestCls.prototype.deepEqual2 = function (a, b, msg, extra) {
  this._assert(deepEqual(a, b, compareEditDataValues), {
    message: defined(msg, 'should be equivalent'),
    operator: 'deepEqual2',
    actual: a,
    expected: b,
    extra: extra,
  });
};

function execFile(...args) {
  return new Promise(function (resolve, reject) {
    let exitCode = null;
    let result = null;

    function done() {
      result.code = exitCode;
      if (result.error) {
        reject(result);
      } else {
        resolve(result);
      }
    }

    const child = child_process.execFile(
      ...args,
      function (error, stdout, stderr) {
        result = {error, stdout, stderr};
        if (exitCode !== null) {
          done();
        }
      },
    );

    child.on('exit', function (code) {
      exitCode = code;
      if (result !== null) {
        done();
      }
    });
  });
}

const proxy = httpProxy.createProxyServer({});
let pendingReqs = [];

proxy.on('proxyReq', function (req) {
  pendingReqs.push(req);
});

const customProxyServer = http.createServer(function (req, res) {
  const host = req.headers.host;
  if (host === DBDefs.WEB_SERVER) {
    req.headers['mb-set-database'] = 'SELENIUM';
    req.rawHeaders['mb-set-database'] = 'SELENIUM';
  }
  proxy.web(req, res, {target: 'http://' + host}, function (e) {
    console.error(e);
  });
});

const driver = (x => {
  let options;

  switch (argv.browser) {
    case 'chrome':
      x.forBrowser('chrome');
      options = new chrome.Options();
      options.addArguments(
        'disable-dev-shm-usage',
        'no-sandbox',
        'proxy-server=http://localhost:5051',
      );
      x.setChromeOptions(options);
      break;

    case 'firefox':
      x.forBrowser('firefox');
      options = new firefox.Options();
      options.setPreference('dom.disable_beforeunload', false);
      options.setPreference('network.proxy.allow_hijacking_localhost', true);
      x.setFirefoxOptions(options);
      break;

    default:
      throw new Error('Unsupported browser: ' + argv.browser);
  }

  x.setProxy(webdriverProxy.manual({http: 'localhost:5051'}));

  if (argv.headless) {
    options.headless();
  }

  return x.build();
})(new webdriver.Builder());

function quit() {
  proxy.close();
  customProxyServer.close();
  return driver.quit().catch(console.error);
}

async function unhandledRejection(err) {
  console.error(err);
  if (!argv.stayOpen) {
    await quit();
    process.exit(1);
  }
}

process.on('unhandledRejection', unhandledRejection);

function makeLocator(locatorStr) {
  const splitAt = locatorStr.indexOf('=');
  let using = locatorStr.slice(0, splitAt);
  const value = locatorStr.slice(splitAt + 1);

  if (using === 'link') {
    using = 'linkText';
  }

  return webdriver.By[using](value);
}

function findElement(locatorStr) {
  return driver.wait(
    until.elementLocated(makeLocator(locatorStr)),
    30000, // 30 seconds
  );
}

async function getElementText(locatorStr) {
  // The Selenium IDE converts tabs and newlines to normal spaces.
  return (await findElement(locatorStr).getText()).replace(/\s/g, ' ').trim();
}

async function setChecked(element, wantChecked) {
  const checked = await element.isSelected();

  if (checked !== wantChecked) {
    await element.click();
  }
}

async function selectOption(select, optionLocator) {
  await select.click();

  const splitAt = optionLocator.indexOf('=');
  const prefix = optionLocator.slice(0, splitAt);
  let value = optionLocator.slice(splitAt + 1);
  let option;

  switch (prefix) {
    case 'label':
      if (value.startsWith('regexp:')) {
        value = new RegExp(value.slice(7));
      } else {
        value = new RegExp('^\s*' + escapeRegExp(value) + '\s*$');
      }
      option = await select.findElement(function () {
        const options = select.findElements(webdriver.By.tagName('option'));
        return promise.filter(options, function (option) {
          return option.getText().then(x => value.test(x));
        });
      });
      break;

    default:
      throw 'Unsupported select prefix: ' + prefix;
  }

  if (!option) {
    throw 'Option not found: ' + optionLocator;
  }

  return option.click();
}

const KEY_CODES = {
  '${KEY_BKSP}': Key.BACK_SPACE,
  '${KEY_DOWN}': Key.ARROW_DOWN,
  '${KEY_END}': Key.END,
  '${KEY_ENTER}': Key.ENTER,
  '${KEY_ESC}': Key.ESCAPE,
  '${KEY_HOME}': Key.HOME,
  '${KEY_SHIFT}': Key.SHIFT,
  '${KEY_TAB}': Key.TAB,
  '${MBS_ROOT}': DBDefs.MB_SERVER_ROOT.replace(/\/$/, ''),
};

function getPageErrors() {
  return driver.executeScript('return ((window.MB || {}).js_errors || [])');
}

let coverageObjectIndex = 0;
function writeSeleniumCoverage(coverageString) {
  writeCoverage(`selenium-${coverageObjectIndex++}`, coverageString);
}

async function writePreviousSeleniumCoverage() {
  /*
   * `previousCoverage` means for the previous window.
   *
   * We only want to write the __coverage__ object to disk before the page
   * is about to change, for the obvious reason that it's not complete until
   * then, but also because retrieving the large (> 1MB) __coverage__ object
   * from the driver is slow, so we only want to do that when absolutely
   * necessary.
   */
  const previousCoverage = await driver.executeScript(
    `if (!window.__seen__) {
       window.__seen__ = true;
       window.addEventListener('beforeunload', function () {
         sessionStorage.setItem(
           '__previous_coverage__',
           JSON.stringify(window.__coverage__),
         );
       });
       return sessionStorage.getItem('__previous_coverage__');
     }
     return null;`,
  );
  if (previousCoverage) {
    writeSeleniumCoverage(previousCoverage);
  }
}

async function handleCommandAndWait({command, target, value}, t) {
  const newCommand = command.replace(/AndWait$/, '');

  const html = await findElement('css=html');
  await handleCommand({command: newCommand, target, value}, t);
  return driver.wait(until.stalenessOf(html), 30000);
}

async function handleCommand({command, target, value}, t) {
  if (/AndWait$/.test(command)) {
    return handleCommandAndWait.apply(null, arguments);
  }

  // Wait for all pending network requests before running the next command.
  await driver.wait(function () {
    pendingReqs = pendingReqs.filter(req => !(req.aborted || req.finished));
    return pendingReqs.length === 0;
  });

  t.comment(
    command +
    ' target=' + JSON.stringify(target) +
    ' value=' + JSON.stringify(value),
  );

  let element;
  switch (command) {
    case 'assertArtworkJson':
      const artworkJson = JSON.parse(await driver.executeAsyncScript(`
        var callback = arguments[arguments.length - 1];
        fetch('http://localhost:8081/release/${target}')
          .then(x => x.text().then(callback));
      `));
      t.deepEqual2(artworkJson, value);
      break;

    case 'assertAttribute':
      const splitAt = target.indexOf('@');
      const locator = target.slice(0, splitAt);
      const attribute = target.slice(splitAt + 1);
      element = await findElement(locator);

      t.equal(await element.getAttribute(attribute), value);
      break;

    case 'assertElementPresent':
      const elements = await driver.findElements(makeLocator(target));
      t.ok(elements.length > 0);
      break;

    case 'assertEval':
      t.equal(await driver.executeScript(`return String(${target})`), value);
      break;

    case 'assertEditData':
      const actualEditData = JSON.parse(await driver.executeAsyncScript(`
        var callback = arguments[arguments.length - 1];
        fetch('/edit/${target}/data', {
          credentials: 'same-origin',
          method: 'GET',
          headers: new Headers({'Accept': 'application/json'}),
        }).then(x => x.text().then(callback));
      `));
      t.deepEqual2(actualEditData, value);
      break;

    case 'assertLocationMatches':
      t.ok(new RegExp(target).test(await driver.getCurrentUrl()));
      break;

    case 'assertText':
      target = await getElementText(target);
      t.equal(target, value.trim());
      break;

    case 'assertTextMatches':
      t.ok(new RegExp(value).test(await getElementText(target)));
      break;

    case 'assertTitle':
      t.equal(await driver.getTitle(), target);
      break;

    case 'assertValue':
      t.equal(await findElement(target).getAttribute('value'), value);
      break;

    case 'check':
      return setChecked(findElement(target), true);

    case 'click':
      element = await findElement(target);
      await driver.executeScript('arguments[0].scrollIntoView()', element);
      await element.click();
      break;

    case 'fireEvent':
      await driver.executeScript(
        `arguments[0].dispatchEvent(new Event('${value}'))`,
        await findElement(target),
      );
      break;

    case 'focus':
      await driver.executeScript(
        'arguments[0].focus()',
        await findElement(target),
      );
      break;

    case 'handleAlert':
      await driver.switchTo().alert()[target]();
      break;

    case 'mouseOver':
      await driver.actions()
        .move({origin: await findElement(target)})
        .perform();
      break;

    case 'open':
      await driver.get('http://' + DBDefs.WEB_SERVER + target);
      break;

    case 'pause':
      await driver.sleep(target);
      break;

    case 'runScript':
      await driver.executeScript(target);
      break;

    case 'select':
      await selectOption(await findElement(target), value);
      break;

    case 'sendKeys':
      value = value.split(/(\$\{[A-Z_]+\})/)
        .filter(x => x)
        .map(x => KEY_CODES[x] || x);
      element = await findElement(target);
      await element.sendKeys.apply(element, value);
      break;

    case 'type':
      element = await findElement(target);
      /*
       * XXX *Both* of the next two lines are needed to clear the input
       * in some cases. (Just one or the other won't suffice.) It's not
       * known what module is at fault, but this combination is
       * confirmed to misbehave:
       *
       * Chrome 70.0.3538.110
       * ChromeDriver 2.44.609545
       * chrome-remote-interface 0.27.0
       * selenium-webdriver 3.6.0
       */
      await element.clear();
      await driver.executeScript('arguments[0].value = ""', element);
      await element.sendKeys(value);
      break;

    case 'uncheck':
      await setChecked(findElement(target), false);
      break;

    case 'waitUntilUrlIs':
      await driver.wait(until.urlIs(
        'http://' + DBDefs.WEB_SERVER + target,
      ), 30000);
      break;

    default:
      throw 'Unsupported command: ' + command;
  }
  return null;
}

const seleniumTests = [
  {name: 'Create_Account.json5'},
  {name: 'MBS-5387.json5', login: true},
  {name: 'MBS-7456.json5', login: true},
  {name: 'MBS-9548.json5'},
  {name: 'MBS-9669.json5'},
  {name: 'MBS-9941.json5', login: true},
  {name: 'MBS-10188.json5', login: true, sql: 'mbs-10188.sql'},
  {name: 'MBS-10510.json5', login: true, sql: 'mbs-10510.sql'},
  {name: 'MBS-11730.json5', login: true},
  {name: 'MBS-11735.json5', login: true},
  {name: 'Artist_Credit_Editor.json5', login: true},
  {name: 'CAA.json5', login: true},
  {name: 'External_Links_Editor.json5', login: true},
  {name: 'Work_Editor.json5', login: true},
  {name: 'Redirect_Merged_Entities.json5', login: true},
  {name: 'admin/Edit_Banner.json5', login: true},
  {name: 'release-editor/The_Downward_Spiral.json5', login: true},
  {
    name: 'release-editor/Duplicate_Selection.json5',
    login: true,
    sql: 'whatever_it_takes.sql',
  },
  {
    name: 'release-editor/Seeding.json5',
    login: true,
    sql: 'vision_creation_newsun.sql',
  },
  {name: 'release-editor/MBS-4555.json5', login: false},
  {name: 'release-editor/MBS-10221.json5', login: true},
  {name: 'release-editor/MBS-10359.json5', login: true},
  {name: 'release-editor/MBS-11015.json5', login: true},
  {name: 'release-editor/MBS-11114.json5', login: true},
  {name: 'release-editor/MBS-11156.json5', login: true},
  {
    name: 'Check_Duplicates.json5',
    login: true,
    sql: 'duplicate_checker.sql',
  },
];

const testPath = name => path.resolve(__dirname, 'selenium', name);

seleniumTests.forEach(x => {
  x.path = testPath(x.name);
});

function getPlan(file) {
  const document = JSON5.parse(fs.readFileSync(file));
  const commands = document.commands;
  let plan = 0;

  for (let i = 0; i < commands.length; i++) {
    const row = commands[i];

    if (/^assert/.test(row.command)) {
      plan++;
    }

    row.file = file;
  }

  document.plan = plan;
  return document;
}

async function runCommands(commands, t) {
  await driver.manage().window().setRect({height: 768, width: 1024});

  for (let i = 0; i < commands.length; i++) {
    await handleCommand(commands[i], t);

    const nextCommand = i < (commands.length - 1) ? commands[i + 1] : null;

    /*
     * If there's an alert open on the page, we can't execute any scripts;
     * they'll die with an UnexpectedAlertOpenError. Since these must be
     * handled explicitly with the `handleAlert` command, we check if that's
     * the next command before proceeding.
     */
    if (!nextCommand || nextCommand.command !== 'handleAlert') {
      if (argv.coverage) {
        await writePreviousSeleniumCoverage();
      }

      // Die if there are any JS errors on the page since the previous command
      const errors = await getPageErrors();

      if (errors.length) {
        throw new Error(
          'Errors were found on the page ' +
          'since executing the previous command:\n' +
          errors.join('\n\n'),
        );
      }

      // The CATALYST_DEBUG views interfere with our tests. Remove them.
      await driver.executeScript(`
        node = document.getElementById('plDebug');
        if (node) node.remove();
      `);
    }
  }
}

(async function runTests() {
  const TEST_TIMEOUT = 200000; // 200 seconds

  async function cleanSeleniumDb(extraSql) {
    await execFile(
      path.resolve(__dirname, '../script/reset_selenium_env.sh'),
      extraSql ? [path.resolve(__dirname, 'sql', extraSql)] : [],
    );
  }

  const loginPlan = getPlan(testPath('Log_In.json5'));
  const logoutPlan = getPlan(testPath('Log_Out.json5'));
  const testsPathsToRun = argv._.map(x => path.resolve(x));
  const testsToRun = testsPathsToRun.length
    ? seleniumTests.filter(x => testsPathsToRun.includes(x.path))
    : seleniumTests;

  customProxyServer.listen(5051);

  await testsToRun.reduce(function (accum, stest, index) {
    const {commands, plan, title} = getPlan(stest.path);

    const isLastTest = index === testsToRun.length - 1;

    const testOptions = {objectPrintDepth: 10, timeout: TEST_TIMEOUT};

    return new Promise(function (resolve) {
      test(title, testOptions, function (t) {
        t.plan(plan);

        const timeout = setTimeout(resolve, TEST_TIMEOUT);

        accum.then(async function () {
          try {
            await cleanSeleniumDb(stest.sql);

            if (stest.login) {
              await runCommands(loginPlan.commands, t);
            }

            await runCommands(commands, t);

            if (!(isLastTest && argv.stayOpen)) {
              if (stest.login) {
                await runCommands(logoutPlan.commands, t);
              }
            }
          } catch (error) {
            t.fail(
              'caught exception: ' +
              (error && error.stack ? error.stack : error.toString()),
            );
            throw error;
          }

          t.end();
          clearTimeout(timeout);
          resolve();
        });
      });
    });
  }, Promise.resolve());

  if (argv.coverage) {
    const remainingCoverage = await driver.executeScript(
      'return JSON.stringify(window.__coverage__)',
    );
    if (remainingCoverage) {
      writeSeleniumCoverage(remainingCoverage);
    }
  }

  if (!argv.stayOpen) {
    await quit();
  }
}());
