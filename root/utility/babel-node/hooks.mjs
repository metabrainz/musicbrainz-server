/* eslint-disable import/prefer-default-export */

import {transformAsync} from '@babel/core';
import {readFile} from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath} from 'node:url';

const MB_SERVER_ROOT = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  '../../../',
);

const loadResultCache = new Map();

export async function load(url, context, nextLoad) {
  if (!url.startsWith('file:')) {
    return nextLoad(url, context);
  }

  const loadResult = loadResultCache.get(url);
  if (loadResult) {
    return loadResult;
  }

  const filename = fileURLToPath(url);
  const extension = path.extname(filename).toLowerCase();
  let format = context.format;

  switch (extension) {
    case '.cjs': {
      format = 'commonjs';
      break;
    }
    case '.mjs': {
      format = 'module';
      break;
    }
    case '.js': {
      format = context.format ?? 'commonjs';
      break;
    }
    default: {
      return nextLoad(url, context);
    }
  }
  if (format !== 'module' && format !== 'commonjs') {
    throw new Error('Could not determine a module format for ' + url);
  }

  const source = await readFile(filename, 'utf8');
  const transformResult = await transformAsync(source, {
    caller: {
      format,
      name: 'babel-node-loader',
      supportsStaticESM: true,
      supportsTopLevelAwait: true,
      target: 'node',
    },
    cwd: process.cwd(),
    filename,
    root: MB_SERVER_ROOT,
  });
  // transformResult is `null` if the file was ignored
  if (!transformResult) {
    return nextLoad(url, context);
  }

  const result = {
    format,
    shortCircuit: true,
    source: transformResult.code,
  };
  loadResultCache.set(url, result);
  return result;
}
