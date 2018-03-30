#!/usr/bin/env node
// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2017 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const child_process = require('child_process');
const fs = require('fs');
const jsdom = require('jsdom');
const path = require('path');
const shellQuote = require('shell-quote');
const test = require('tape');
const utf8 = require('utf8');
const webdriver = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');
const {UnexpectedAlertOpenError} = require('selenium-webdriver/lib/error');
const {Key} = require('selenium-webdriver/lib/input');
const promise = require('selenium-webdriver/lib/promise');
const until = require('selenium-webdriver/lib/until');

const escapeRegExp = require('../root/static/scripts/common/utility/escapeRegExp');

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

const driver = new webdriver.Builder()
  .forBrowser('chrome')
  .setChromeOptions(
    new chrome.Options()
      .headless()
      .addArguments('no-sandbox')
  )
  .build();

function quit() {
  return driver.quit().catch(console.error);
}

async function unhandledRejection(err) {
  await quit();
  console.error(err);
  process.exit(1);
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
    10000
  );
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

async function handleCommandAndWait(command, target, value, baseURL, t) {
  command = command.replace(/AndWait$/, '');

  const html = await findElement('css=html');
  await handleCommand(command, target, value, baseURL, t);
  return driver.wait(until.stalenessOf(html), 10000);
}

async function handleCommand(command, target, value, baseURL, t) {
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
    var node = document.getElementById('catalyst-stats');
    if (node) node.remove();
    node = document.getElementById('plDebug');
    if (node) node.remove();
  `);

  t.comment(
    command +
    ' target=' + utf8.encode(JSON.stringify(target)) +
    ' value=' + utf8.encode(JSON.stringify(value))
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

    case 'assertLocation':
      t.equal(await driver.getCurrentUrl(), target);
      return;

    case 'assertText':
      // The Selenium IDE converts tabs and newlines to normal spaces.
      target = (await findElement(target).getText()).replace(/\s/g, ' ').trim();
      t.equal(target, value.trim());
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
      return element.click();

    case 'fireEvent':
      return driver.executeScript(
        `arguments[0].dispatchEvent(new Event('${value}'))`,
        await findElement(target)
      );

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
      await driver.get(baseURL + target);
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
      await element.clear();
      return element.sendKeys(value);

    case 'uncheck':
      return setChecked(findElement(target), false);

    default:
      throw 'Unsupported command: ' + command;
  }
}

const seleniumTests = [
  {name: 'Create_Account.html'},
  {name: 'MBS-7456.html', login: true},
  {name: 'MBS-9548.html'},
  {name: 'Artist_Credit_Editor.html', login: true},
  {name: 'External_Links_Editor.html', login: true},
  {name: 'Work_Editor.html', login: true},
];

const testPath = name => path.resolve(__dirname, 'selenium', name);

seleniumTests.forEach(x => {
  x.path = testPath(x.name);
});

function getPlan(file) {
  const {document} = new jsdom.JSDOM(fs.readFileSync(file)).window;
  const baseURL = document.querySelector('link[rel=selenium\\.base]').href;
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

    commands.push([command, target, value, baseURL]);
  }

  return {commands, plan, title};
}

async function runCommands(commands, t) {
  for (let i = 0; i < commands.length; i++) {
    await handleCommand(...commands[i], t);
  }
}

(async function runTests() {
  const TEST_TIMEOUT = 60000; // 60 seconds

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

  const createdbArgs = [
    '-O', testDb.user,
    '-T', testDb.database,
    '-U', sysDb.user,
    ...hostPort,
    'musicbrainz_selenium',
  ];

  const testSqlPath = path.resolve(__dirname, 'sql', 'selenium.sql');
  const sqlInsertionArgs = [
    '-c',
    shellQuote.quote(['cat', testSqlPath]) +  ' | ' +
    shellQuote.quote(['psql', ...hostPort, '-U', testDb.user, 'musicbrainz_selenium']),
  ];

  const dropdbArgs = [...hostPort, '-U', sysDb.user, 'musicbrainz_selenium'];

  async function createSeleniumDb() {
    await execFile('createdb', createdbArgs, pgPasswordEnv(sysDb));
    await execFile('sh', sqlInsertionArgs, pgPasswordEnv(testDb));
  }

  function dropSeleniumDb() {
    return execFile('dropdb', dropdbArgs, pgPasswordEnv(sysDb));
  }

  const seleniumDbCheck = await execFile(
    'psql', [...hostPort, '-U', testDb.user, '-c', 'SELECT 1', 'musicbrainz_selenium'],
    pgPasswordEnv(testDb),
  ).catch(x => x);

  if (seleniumDbCheck.code === 0) {
    await dropSeleniumDb();
  } else if (seleniumDbCheck.code !== 2) {
    // An error other than the database not existing occurred.
    throw seleniumDbCheck.error;
  }

  const loginPlan = getPlan(testPath('Log_In.html'));
  const logoutPlan = getPlan(testPath('Log_Out.html'));
  const testsPathsToRun = process.argv.slice(2).map(x => path.resolve(x));
  const testsToRun = testsPathsToRun.length
    ? seleniumTests.filter(x => testsPathsToRun.includes(x.path))
    : seleniumTests;

  await testsToRun.reduce(function (accum, stest) {
    const {commands, plan, title} = getPlan(stest.path);

    return new Promise(function (resolve) {
      test(title, {timeout: TEST_TIMEOUT}, function (t) {
        t.plan(plan);

        const timeout = setTimeout(resolve, TEST_TIMEOUT);

        accum.then(async function () {
          try {
            await createSeleniumDb();

            if (stest.login) {
              await runCommands(loginPlan.commands, t);
            }

            await runCommands(commands, t);

            if (stest.login) {
              await runCommands(logoutPlan.commands, t);
            }

            await dropSeleniumDb();
          } catch (error) {
            t.fail(JSON.stringify(error, null, 2));
          }

          t.end();
          clearTimeout(timeout);
          resolve();
        });
      });
    });
  }, Promise.resolve());

  await quit();
}());
