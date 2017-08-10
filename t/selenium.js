#!/usr/bin/env node
// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2017 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const fs = require('fs');
const jsdom = require('jsdom');
const path = require('path');
const shell = require('shelljs');
const test = require('tape');
const webdriver = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');
const until = require('selenium-webdriver/lib/until');

const testSqlPath = path.resolve(__dirname, 'sql', 'selenium.sql');
const psqlPath = path.resolve(__dirname, '..', 'admin', 'psql');

shell.exec(
  (process.env.PERL_CARTON_PATH ? 'carton exec -- ' : '') +
  psqlPath + ' TEST < ' + testSqlPath,
  {silent: true}
);

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

async function handleCommandAndWait(command, target, value, baseURL, t) {
  command = command.replace(/AndWait$/, '');

  const html = await findElement('css=html');
  await handleCommand(command, target, value, baseURL, t);
  return driver.wait(until.stalenessOf(html), 10000);
}

async function handleCommand(command, target, value, baseURL, t) {
  if (/AndWait$/.test(command)) {
    return handleCommandAndWait.apply(null, arguments);
  }

  switch (command) {
    case 'assertAttribute':
      const splitAt = target.indexOf('@');
      const locator = target.slice(0, splitAt);
      const attribute = target.slice(splitAt + 1);
      const element = await findElement(locator);

      t.equal(await element.getAttribute(attribute), value);
      return;

    case 'assertElementPresent':
      const elements = await driver.findElements(makeLocator(target));
      t.ok(elements.length > 0);
      return;

    case 'assertLocation':
      t.equal(await driver.getCurrentUrl(), target);
      return;

    case 'assertTitle':
      t.equal(await driver.getTitle(), target);
      return;

    case 'check':
      return setChecked(findElement(target), true);

    case 'click':
      return findElement(target).click();

    case 'open':
      return driver.get(baseURL + target);

    case 'runScript':
      return driver.executeScript(target);

    case 'type':
      return findElement(target).sendKeys(value);

    case 'uncheck':
      return setChecked(findElement(target), false);

    default:
      throw 'Unsupported command: ' + command;
  }
}

const tests = [
  'Create_Account.html',
  'Log_Out.html',
  'Log_In.html',
];

async function nextTest(testIndex) {
  const file = path.resolve(__dirname, 'selenium', tests[testIndex]);
  const {document} = new jsdom.JSDOM(fs.readFileSync(file)).window;

  const baseURL = document.querySelector('link[rel=selenium\\.base]').href;
  const title = document.querySelector('title').textContent;
  const tbody = document.querySelector('tbody');
  const rows = Array.prototype.slice.call(tbody.getElementsByTagName('tr'), 0);

  test(title, {timeout: 30000}, async function (t) {
    async function nextRow(index) {
      if (index < rows.length) {
        const cols = rows[index].getElementsByTagName('td');
        const command = cols[0].textContent;
        const target = cols[1].textContent;
        const value = cols[2].textContent;

        await handleCommand(command, target, value, baseURL, t);

        return nextRow(index + 1);
      } else {
        t.end();

        if (testIndex < tests.length - 1) {
          process.nextTick(nextTest, testIndex + 1);
        } else {
          await quit();
        }
      }
    }

    await nextRow(0);
  });
}

nextTest(0);
