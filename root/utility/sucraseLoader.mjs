/*
 * MIT License
 *
 * Copyright (c) 2020 Geoffrey Booth and contributors
 * Copyright (c) 2022 MetaBrainz Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
*/

import {promises as fsPromises} from 'fs';
import {dirname, extname, resolve as resolvePath} from 'path';
import {fileURLToPath} from 'url';

import {transform as sucraseTransform} from 'sucrase';

const sucraseOptions = Object.freeze({
  disableESTransforms: true,
  transforms: ['jsx', 'flow'],
});

export async function load(url, context, defaultLoad) {
  if (await isModule(url)) {
    const {source: rawSource} = await defaultLoad(url, {format: 'module'});
    return {
      format: 'module',
      source: sucraseTransform(rawSource.toString(), sucraseOptions).code,
    };
  }
  return defaultLoad(url, context, defaultLoad);
}

export function globalPreload() {
  // Sucrase doesn't implement an automatic React runtime.
  return `\
const {createRequire} = getBuiltin('module');
const {cwd} = getBuiltin('process');
const require = createRequire(cwd() + '/<preload>');
globalThis.React = require('react');\
`;
}

async function isModule(url) {
  const ext = extname(url);
  if (ext === '.cjs') {
    return false;
  }
  if (ext === '.mjs') {
    return true;
  }
  const isFilePath = !!ext;
  const dir = isFilePath
    ? dirname(fileURLToPath(url))
    : url;
  const packagePath = resolvePath(dir, 'package.json');
  const type = await fsPromises.readFile(packagePath, {encoding: 'utf8'})
    .then((filestring) => JSON.parse(filestring).type)
    .catch(function (err) {
      if (err?.code !== 'ENOENT') {
        console.error(err);
      }
    });
  if (type === 'module') {
    return true;
  }
  if (dir.length > 1) {
    return isModule(resolvePath(dir, '..'));
  }
  return false;
}
