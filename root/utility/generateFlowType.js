/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable multiline-comment-style */
/* eslint-disable import/no-commonjs */

const crypto = require('crypto');

const TYPE_STRING = 1;
const TYPE_NUMBER = 2;
const TYPE_BOOLEAN = 4;
const TYPE_NULL = 8;

class TypeInfo {
/*::
  +isEditDataTypeInfo: boolean;
  array: TypeInfo | null;
  count: number;
  object: {
    __proto__: null,
    [property: string]: TypeInfo,
  } | null;
  primitive: number;
*/

  constructor(
    parent/*: TypeInfo | null */,
    isEditDataTypeInfo/*:: ?: boolean */,
  ) {
    this.array = null;
    this.count = 0;
    this.object = null;
    this.isEditDataTypeInfo =
      ((parent != null && isEditDataTypeInfo == null)
        ? parent.isEditDataTypeInfo
        : (isEditDataTypeInfo ?? false));
    this.primitive = 0;
  }

  printTypeInfo(indentation/*: string */)/*: string */ {
    const types = [];
    if ((this.primitive & TYPE_STRING) === TYPE_STRING) {
      types.push('string');
    }
    if ((this.primitive & TYPE_NUMBER) === TYPE_NUMBER) {
      types.push('number');
    }
    if ((this.primitive & TYPE_BOOLEAN) === TYPE_BOOLEAN) {
      types.push('boolean');
    }
    if ((this.primitive & TYPE_NULL) === TYPE_NULL) {
      types.push('null');
    }
    if (this.array) {
      types.push(
        '$ReadOnlyArray<' +
        this.array.printTypeInfo(indentation) +
        '>',
      );
    }
    const objectKeyInfo = this.object;
    if (objectKeyInfo) {
      let typeRepr = '{\n';
      const keys = Object.keys(objectKeyInfo).sort();
      const nextIndentation = indentation + '  ';
      for (let i = 0; i < keys.length; i++) {
        const key = keys[i];
        const keyTypeInfo = objectKeyInfo[key];
        typeRepr += nextIndentation + '+' +
          key + (keyTypeInfo.count < this.count ? '?' : '') + ': ' +
          keyTypeInfo.printTypeInfo(nextIndentation) +
          ',\n';
      }
      typeRepr += indentation + '}';
      types.push(typeRepr);
    }
    return types.join(' | ');
  }

  processTypes(data/*: mixed */)/*: void */ {
    this.count++;
    if (this.isEditDataTypeInfo && data == null) {
      throw new Error('data should not be null');
    }
    switch (typeof data) {
      case 'boolean':
        if (this.isEditDataTypeInfo) {
          throw new Error('Unexpected boolean value');
        } else {
          this.primitive |= TYPE_BOOLEAN;
          return;
        }
      case 'number':
        if (this.isEditDataTypeInfo) {
          switch (data) {
            case TYPE_BOOLEAN:
            case TYPE_NULL:
            case TYPE_NUMBER:
            case TYPE_STRING:
              this.primitive |= data;
              return;
            default:
              throw new Error('Unknown data type: ' + data);
          }
        } else {
          this.primitive |= TYPE_NUMBER;
          return;
        }
      case 'string':
        if (this.isEditDataTypeInfo) {
          throw new Error('Unexpected string value');
        } else {
          this.primitive |= TYPE_STRING;
          return;
        }
      case 'object': {
        if (data == null) {
          this.primitive |= TYPE_NULL;
          return;
        }
        if (Array.isArray(data)) {
          let arrayTypeInfo = this.array;
          if (arrayTypeInfo == null) {
            arrayTypeInfo = this.array = new TypeInfo(this);
          }
          for (let i = 0; i < data.length; i++) {
            arrayTypeInfo.processTypes(data[i]);
          }
        } else {
          let objectKeyInfo = this.object;
          if (objectKeyInfo == null) {
            objectKeyInfo = this.object = Object.create(null);
          }
          for (const key in data) {
            let keyTypeInfo = objectKeyInfo[key];
            if (keyTypeInfo == null) {
              keyTypeInfo = objectKeyInfo[key] = new TypeInfo(this);
            }
            keyTypeInfo.processTypes(data[key]);
          }
        }
        return;
      }
    }
    throw new Error('Unknown value: ' + (JSON.stringify(data) ?? ''));
  }
}

exports.generateFlowType = async function (
  objectStrings/*: AsyncIterable<string> */,
  options/*:: ?: {
    +isEditDataTypeInfo: boolean,
  } */,
)/*: Promise<string> */ {
  const seenTypes = new Set();
  const isEditDataTypeInfo = options && options.isEditDataTypeInfo;
  const rootTypeInfo = new TypeInfo(
    null,
    isEditDataTypeInfo == null ? false : isEditDataTypeInfo,
  );

  for await (const objectString of objectStrings) {
    const hash = crypto.createHash('md5')
      .update(objectString)
      .digest('hex');
    if (!seenTypes.has(hash)) {
      seenTypes.add(hash);
      rootTypeInfo.processTypes(JSON.parse(objectString));
    }
  }

  return rootTypeInfo.printTypeInfo('');
};
