#!/usr/bin/env node
// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2017 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const argv = require('yargs')
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
const jsdom = require('jsdom');
const isEqualWith = require('lodash/isEqualWith');
const path = require('path');
const shellQuote = require('shell-quote');
const test = require('tape');
const TestCls = require('tape/lib/test');
const utf8 = require('utf8');
const webdriver = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');
const webdriverProxy = require('selenium-webdriver/proxy');
const {UnexpectedAlertOpenError} = require('selenium-webdriver/lib/error');
const {Key} = require('selenium-webdriver/lib/input');
const promise = require('selenium-webdriver/lib/promise');
const until = require('selenium-webdriver/lib/until');

const DBDefs = require('../root/static/scripts/common/DBDefs');
const escapeRegExp = require('../root/static/scripts/common/utility/escapeRegExp');

const IGNORE = Symbol();
const CMD_TIMEOUT = 30000; // 30 seconds

function skipIgnored(a, b) {
  return (a === IGNORE || b === IGNORE) ? true : undefined;
}

TestCls.prototype.deepEqual2 = function (a, b, msg, extra) {
  this._assert(isEqualWith(a, b, skipIgnored), {
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

    const child = child_process.execFile(...args, function (error, stdout, stderr) {
      result = {error, stdout, stderr};
      if (exitCode !== null) {
        done();
      }
    });

    child.on('exit', function (code) {
      exitCode = code;
      if (result !== null) {
        done();
      }
    });
  });
}

const proxy = httpProxy.createProxyServer({});

const customProxyServer = http.createServer(function (req, res) {
  const host = req.headers.host;
  if (host === DBDefs.WEB_SERVER) {
    req.headers['mb-set-database'] = 'SELENIUM';
    req.rawHeaders['mb-set-database'] = 'SELENIUM';
  }
  proxy.web(req, res, {target: 'http://' + host});
});

const driver = (x => {
  x.forBrowser('chrome');

  x.setProxy(webdriverProxy.manual({http: 'localhost:5050'}));

  if (argv.headless) {
    x.setChromeOptions(
      new chrome.Options()
        .headless()
        .addArguments(
          'no-sandbox',
          'proxy-server=http://localhost:5050',
        )
    );
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
    CMD_TIMEOUT, // 30 seconds
  );
}

async function getElementText(locatorStr) {
  // The Selenium IDE converts tabs and newlines to normal spaces.
  return (await findElement(locatorStr).getText()).replace(/\s/g, ' ').trim();
}

async function setChecked(element, wantChecked) {
  const checked = await element.isSelected();

  if (checked !== wantChecked) {
    return element.click();
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
  '${KEY_END}': Key.END,
  '${KEY_HOME}': Key.HOME,
  '${KEY_SHIFT}': Key.SHIFT,
};

function getPageErrors() {
  return driver.executeScript('return ((window.MB || {}).js_errors || [])');
}

function parseEditData(value) {
  return (new Function('ignore', `return (${value})`))(IGNORE);
}

async function handleCommandAndWait(file, command, target, value, t) {
  command = command.replace(/AndWait$/, '');

  const html = await findElement('css=html');
  await handleCommand(file, command, target, value, t);
  return driver.wait(until.stalenessOf(html), CMD_TIMEOUT);
}

async function handleCommand(file, command, target, value, t) {
  // Die if there are any JS errors on the page since the previous command.
  let errors;
  try {
    errors = await getPageErrors();
  } catch (e) {
    // Handle the "All of your changes will be lost" confirmation dialog in
    // the release editor.
    //  1. Setting the unexpectedAlertBehavior capability on the session
    //     doesn't seem to handle this.
    //  2. The webdriver thinks the alert text is empty, so we don't bother
    //     checking it.
    if (e instanceof UnexpectedAlertOpenError) {
      await driver.switchTo().alert().accept();
      errors = await getPageErrors();
    } else {
      throw e;
    }
  }

  if (errors.length) {
    throw new Error(
      'Errors were found on the page since executing the previous command:\n' +
      errors.join('\n\n')
    );
  }

  if (/AndWait$/.test(command)) {
    return handleCommandAndWait.apply(null, arguments);
  }

  // The CATALYST_DEBUG views interfere with our tests. Remove them.
  await driver.executeScript(`
    node = document.getElementById('plDebug');
    if (node) node.remove();
  `);

  let commentValue;
  switch (command) {
    case 'assertEditData':
      commentValue = parseEditData(value);
      break;
    default:
      commentValue = value;
  }

  t.comment(
    command +
    ' target=' + utf8.encode(JSON.stringify(target)) +
    ' value=' + utf8.encode(JSON.stringify(commentValue))
  );

  let element;
  switch (command) {
    case 'assertAttribute':
      const splitAt = target.indexOf('@');
      const locator = target.slice(0, splitAt);
      const attribute = target.slice(splitAt + 1);
      element = await findElement(locator);

      t.equal(await element.getAttribute(attribute), value);
      return;

    case 'assertElementPresent':
      const elements = await driver.findElements(makeLocator(target));
      t.ok(elements.length > 0);
      return;

    case 'assertEval':
      t.equal(await driver.executeScript(`return String(${target})`), value);
      return;

    case 'assertEditData':
      const actualEditData = JSON.parse(await driver.executeAsyncScript(`
        var callback = arguments[arguments.length - 1];
        fetch('/edit/${target}/data', {
          credentials: 'same-origin',
          method: 'GET',
          headers: new Headers({'Accept': 'application/json'}),
        }).then(x => x.text().then(callback));
      `));
      const expectedEditData = parseEditData(value);
      t.deepEqual2(actualEditData, expectedEditData);
      return;

    case 'assertLocationMatches':
      t.ok(new RegExp(target).test(await driver.getCurrentUrl()));
      return;

    case 'assertText':
      target = await getElementText(target);
      t.equal(target, value.trim());
      return;

    case 'assertTextMatches':
      t.ok(new RegExp(value).test(await getElementText(target)));
      return;

    case 'assertTitle':
      t.equal(await driver.getTitle(), target);
      return;

    case 'assertValue':
      t.equal(await findElement(target).getAttribute('value'), value);
      return;

    case 'check':
      return setChecked(findElement(target), true);

    case 'click':
      element = await findElement(target);
      await driver.executeScript('arguments[0].scrollIntoView()', element);
      await driver.wait(until.elementIsVisible(element), CMD_TIMEOUT);
      return element.click();

    case 'focus':
      return driver.executeScript(
        'arguments[0].focus()',
        await findElement(target)
      );

    case 'mouseOver':
      return driver.actions()
        .mouseMove(await findElement(target))
        .perform();

    case 'open':
      await driver.get('http://' + DBDefs.WEB_SERVER + target);
      return driver.manage().window().setSize(1024, 768);

    case 'openFile':
      await driver.get('file://' + path.resolve(path.dirname(file), target));
      return driver.manage().window().setSize(1024, 768);

    case 'pause':
      return driver.sleep(target);

    case 'runScript':
      return driver.executeScript(target);

    case 'select':
      return selectOption(await findElement(target), value);

    case 'sendKeys':
      value = value.split(/(\$\{[A-Z_]+\})/)
        .filter(x => x)
        .map(x => KEY_CODES[x] || x);
      element = await findElement(target);
      return element.sendKeys.apply(element, value);

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
      return element.sendKeys(value);

    case 'uncheck':
      return setChecked(findElement(target), false);

    case 'waitUntil':
      return driver.wait(
        driver.executeScript(`try { return ${target} } catch (e) { return false }`),
        CMD_TIMEOUT,
      );

    default:
      throw 'Unsupported command: ' + command;
  }
}

const seleniumTests = [
  {name: 'Create_Account.html'},
  {name: 'MBS-7456.html', login: true},
  {name: 'MBS-9548.html'},
  {name: 'MBS-9941.html', login: true},
  {name: 'Artist_Credit_Editor.html', login: true},
  {name: 'External_Links_Editor.html', login: true},
  {name: 'Work_Editor.html', login: true},
  {name: 'Redirect_Merged_Entities.html', login: true},
  {name: 'release-editor/The_Downward_Spiral.html', login: true},
  {name: 'release-editor/Seeding.html', login: true, sql: 'vision_creation_newsun.sql'},
];

const testPath = name => path.resolve(__dirname, 'selenium', name);

seleniumTests.forEach(x => {
  x.path = testPath(x.name);
});

function getPlan(file) {
  const {document} = new jsdom.JSDOM(fs.readFileSync(file)).window;
  const title = document.querySelector('title').textContent;
  const tbody = document.querySelector('tbody');
  const rows = Array.prototype.slice.call(tbody.getElementsByTagName('tr'), 0);
  const commands = [];
  let plan = 0;

  for (let i = 0; i < rows.length; i++) {
    const cols = rows[i].getElementsByTagName('td');
    const command = cols[0].textContent;
    const target = cols[1].textContent;
    const value = cols[2].textContent;

    if (/^assert/.test(command)) {
      plan++;
    }

    commands.push([file, command, target, value]);
  }

  return {commands, plan, title};
}

async function runCommands(commands, t) {
  for (let i = 0; i < commands.length; i++) {
    await handleCommand(...commands[i], t);
  }
}

(async function runTests() {
  const TEST_TIMEOUT = 200000; // 200 seconds

  const cartonPrefix = process.env.PERL_CARTON_PATH
    ? 'carton exec -- '
    : '';

  function pgPasswordEnv(db) {
    if (db.password) {
      return {env: Object.assign({}, process.env, {PGPASSWORD: db.password})};
    }
    return {};
  }

  async function getDbConfig(name) {
    if (name !== 'SYSTEM' && name !== 'TEST') {
      return null;
    }

    const result = (await execFile(
      'sh', [
        '-c',
        `$(${cartonPrefix}./script/database_configuration ${name}) && ` +
        'echo "$PGHOST\n$PGPORT\n$PGDATABASE\n$PGUSER\n$PGPASSWORD"',
      ],
    )).stdout.split('\n').map(x => x.trim());

    return {
      host: result[0],
      port: result[1],
      database: result[2],
      user: result[3],
      password: result[4],
    };
  }

  const sysDb = await getDbConfig('SYSTEM');
  const testDb = await getDbConfig('TEST');

  const hostPort = ['-h', testDb.host, '-p', testDb.port];

  /*
   * In our production tests setup, there exists a musicbrainz_test_template
   * database based on a pristine musicbrainz_test, so that we can run
   * t/tests.t in parallel without having to worry about modifications to
   * musicbrainz_test.
   */
  const testTemplateExists = await dbExists('musicbrainz_test_template');
  const createdbArgs = [
    '-O', testDb.user,
    '-T', testTemplateExists ? 'musicbrainz_test_template' : testDb.database,
    '-U', sysDb.user,
    ...hostPort,
    'musicbrainz_selenium',
  ];

  const dropdbArgs = [...hostPort, '-U', sysDb.user, 'musicbrainz_selenium'];

  function execSql(sqlFile) {
    const args = [
      '-c',
      shellQuote.quote(['cat', path.resolve(__dirname, 'sql', sqlFile)]) +  ' | ' +
      shellQuote.quote(['psql', ...hostPort, '-U', testDb.user, 'musicbrainz_selenium']),
    ];
    return execFile('sh', args, pgPasswordEnv(testDb));
  }

  async function createSeleniumDb() {
    await execFile('createdb', createdbArgs, pgPasswordEnv(sysDb));
    await execSql('selenium.sql');
  }

  function dropSeleniumDb() {
    return execFile('dropdb', dropdbArgs, pgPasswordEnv(sysDb));
  }

  async function dbExists(name) {
    const result = await execFile(
      'psql', [...hostPort, '-U', sysDb.user, '-c', 'SELECT 1', name],
      pgPasswordEnv(sysDb),
    ).catch(x => x);

    if (result.code === 0) {
      return true;
    } else if (result.code !== 2) {
      // An error other than the database not existing occurred.
      throw result.error;
    }
    return false;
  }

  if (await dbExists('musicbrainz_selenium')) {
    await dropSeleniumDb();
  }

  const loginPlan = getPlan(testPath('Log_In.html'));
  const logoutPlan = getPlan(testPath('Log_Out.html'));
  const testsPathsToRun = argv._.map(x => path.resolve(x));
  const testsToRun = testsPathsToRun.length
    ? seleniumTests.filter(x => testsPathsToRun.includes(x.path))
    : seleniumTests;

  customProxyServer.listen(5050);

  await testsToRun.reduce(function (accum, stest, index) {
    const {commands, plan, title} = getPlan(stest.path);

    const isLastTest = index === testsToRun.length - 1;

    return new Promise(function (resolve) {
      test(title, {timeout: TEST_TIMEOUT}, function (t) {
        t.plan(plan);

        const timeout = setTimeout(resolve, TEST_TIMEOUT);

        accum.then(async function () {
          try {
            await createSeleniumDb();

            if (stest.sql) {
              await execSql(stest.sql);
            }

            if (stest.login) {
              await runCommands(loginPlan.commands, t);
            }

            await runCommands(commands, t);

            if (!(isLastTest && argv.stayOpen)) {
              if (stest.login) {
                await runCommands(logoutPlan.commands, t);
              }
              await dropSeleniumDb();
            }
          } catch (error) {
            t.fail(
              'caught exception: ' +
              (error && error.stack ? error.stack : error.toString())
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

  if (!argv.stayOpen) {
    await quit();
  }
}());
