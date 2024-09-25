/*
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import fbFlow from 'eslint-plugin-fb-flow';
import ftFlow from 'eslint-plugin-ft-flow';
import importPlugin from 'eslint-plugin-import';
import reactPlugin from 'eslint-plugin-react';
import reactHooks from 'eslint-plugin-react-hooks';
import simpleImportSort from 'eslint-plugin-simple-import-sort';
import stylisticJs from '@stylistic/eslint-plugin-js';
import stylisticJsx from '@stylistic/eslint-plugin-jsx';
import globals from 'globals';
import hermesParser from 'hermes-eslint';

export default [
  {
    ignores: [
      '.cpanm/**/*',
      'flow-typed/npm/@sentry/*.js',
      'flow-typed/npm/he_*.js',
      'flow-typed/npm/react-dom_*.js',
      'flow-typed/npm/redux_*.js',
      'flow-typed/npm/tape_*.js',
      'perl_modules/**/*',
      'root/static/build/**/*',
      'root/static/lib/**/*',
      'root/static/scripts/common/DBDefs-client.js',
      'root/static/scripts/common/DBDefs-client.mjs',
      'root/static/scripts/common/DBDefs.js',
      'root/static/scripts/common/DBDefs.mjs',
      'root/static/scripts/tests/typeInfo.js',
      't/selenium.js',
      'babel.config.cjs',
      'eslint.config.mjs',
      'webpack/babel-ignored.cjs',
    ],
  },
  {
    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.node,
        ...globals.es2020,

        // Real globals
        $: 'readonly',
        jQuery: 'readonly',

        /*
         * Fake globals; these are auto-imported upon use by Webpack's
         * ProvidePlugin, but look like real globals to eslint
         */
        __webpack_public_path__: 'writable',
        __DEV__: 'readonly',
        GLOBAL_JS_NAMESPACE: 'readonly',
        MUSICBRAINZ_RUNNING_TESTS: 'readonly',
        addColon: 'readonly',
        addColonText: 'readonly',
        addQuotes: 'readonly',
        addQuotesText: 'readonly',      
        empty: 'readonly',
        hydrate: 'readonly',
        hyphenateTitle: 'readonly',
        invariant: 'readonly',
        nonEmpty: 'readonly',
        l: 'readonly',
        ln: 'readonly',
        lp: 'readonly',
        N_l: 'readonly',
        N_ln: 'readonly',
        N_lp: 'readonly',
        exp: 'readonly',
        texp: 'readonly',
        l_admin: 'readonly',
        ln_admin: 'readonly',
        l_attributes: 'readonly',
        ln_attributes: 'readonly',
        lp_attributes: 'readonly',
        l_countries: 'readonly',
        ln_countries: 'readonly',
        lp_countries: 'readonly',
        l_history: 'readonly',
        l_instrument_descriptions: 'readonly',
        ln_instrument_descriptions: 'readonly',
        lp_instrument_descriptions: 'readonly',
        l_instruments: 'readonly',
        ln_instruments: 'readonly',
        lp_instruments: 'readonly',
        l_languages: 'readonly',
        ln_languages: 'readonly',
        lp_languages: 'readonly',
        l_relationships: 'readonly',
        ln_relationships: 'readonly',
        lp_relationships: 'readonly',
        l_scripts: 'readonly',
        ln_scripts: 'readonly',
        lp_scripts: 'readonly',
        l_statistics: 'readonly',
        ln_statistics: 'readonly',
        lp_statistics: 'readonly',
        N_l_statistics: 'readonly',
        N_lp_statistics: 'readonly',
      },
      parser: hermesParser,
    },
    plugins: {
      '@stylistic/js': stylisticJs,
      '@stylistic/jsx': stylisticJsx,
      'import': importPlugin,
      'react': reactPlugin,
      'ft-flow': ftFlow,
      'fb-flow': fbFlow,
      'react-hooks': reactHooks,
      'simple-import-sort': simpleImportSort,
    },
    settings: {
      flowtype: {onlyFilesWithFlowAnnotation: true},
      react: {
        version: 'detect',
        flowVersion: '0.152.0',
      },
    },
    rules: {
      // Possible problems
      'array-callback-return': ['error', {checkForEach: true}],
      'constructor-super': 'error',
      'for-direction': 'error',
      'getter-return': 'off', // We should never use getters
      'no-async-promise-executor': 'error',
      'no-await-in-loop': 'error',
      'no-class-assign': 'error',
      'no-compare-neg-zero': 'off',
      'no-cond-assign': 'warn',
      'no-const-assign': 'error',
      'no-constant-binary-expression': 'error',
      'no-constant-condition': ['error', {checkLoops: false}],
      'no-constructor-return': 'off', // We should aim not to use classes
      'no-control-regex': 'off',
      'no-debugger': 'error',
      'no-dupe-args': 'error',
      'no-dupe-class-members': 'error',
      'no-dupe-else-if': 'error',
      'no-dupe-keys': 'error',
      'no-duplicate-case': 'error',
      /*
       * no-duplicate-imports does not support Flow 'type' imports, so we use
       * the import/no-duplicates rule from eslint-plugin-import instead.
       */
      'no-duplicate-imports': 'off',
      'no-empty-character-class': 'error',
      'no-empty-pattern': 'error',
      'no-ex-assign': 'error',
      'no-fallthrough': 'error',
      'no-func-assign': 'off', // Enforced by Flow
      'no-import-assign': 'off', // Enforced by Flow
      'no-inner-declarations': 'off', // Not needed in ES6+
      'no-invalid-regexp': 'error',
      'no-irregular-whitespace': 'warn',
      'no-loss-of-precision': 'off',
      'no-misleading-character-class': 'error',
      'no-new-native-nonconstructor': 'error',
      'no-obj-calls': 'error',
      'no-promise-executor-return': 'error',
      'no-prototype-builtins': 'warn',
      'no-regex-spaces': 'error',
      'no-self-assign': 'error',
      'no-self-compare': 'error',
      'no-setter-return': 'off', // We should never use setters
      'no-shadow-restricted-names': 'error',
      'no-sparse-arrays': 'error',
      'no-template-curly-in-string': 'warn',
      'no-this-before-super': 'error',
      /*
       * no-undef is mostly superfluous as it is checked by Flow; enabling it
       * actually triggers thousands of false positives because hermes-eslint
       * doesn't track global types (those defined with `declare type`).
       * Ideally we could keep no-undef enabled for files that aren't Flow-
       * typed yet, but we don't maintain a separate config for those.
       */
      'no-undef': 'off',
      'no-unexpected-multiline': 'error',
      'no-unmodified-loop-condition': 'error',
      'no-unreachable-loop': 'error',
      'no-unsafe-finally': 'error',
      'no-unsafe-negation': 'error',
      'no-unsafe-optional-chaining': 'off', // Enforced by Flow
      'no-unused-private-class-members': 'off', // We should aim not to use classes
      'no-unused-vars': ['error', {argsIgnorePattern: '^this$'}],
      'no-use-before-define': 'off',
      'no-useless-backreference': 'off',
      'no-with': 'error',
      'require-atomic-updates': 'error',
      'use-isnan': 'error',
      'valid-typeof': 'error',

      // Suggestions
      'accessor-pairs': 'off', // We should never use setters/getters
      'arrow-body-style': 'off',
      'block-scoped-var': 'warn',
      'camelcase': ['warn', {
        properties: 'never',
        allow: [
          'l_admin',
          'ln_admin',
          'l_attributes',
          'ln_attributes',
          'lp_attributes',
          'l_countries',
          'ln_countries',
          'lp_countries',
          'l_history',
          'l_instrument_descriptions',
          'ln_instrument_descriptions',
          'lp_instrument_descriptions',
          'l_instruments',
          'ln_instruments',
          'lp_instruments',
          'l_languages',
          'ln_languages',
          'lp_languages',
          'l_relationships',
          'ln_relationships',
          'lp_relationships',
          'l_scripts',
          'ln_scripts',
          'lp_scripts',
          'l_statistics',
          'ln_statistics',
          'lp_statistics',
          'N_l',
          'N_ln',
          'N_lp',
          'N_l_statistics',
          'N_lp_statistics',
          '__webpack_public_path__',
        ],
      }],
      'capitalized-comments': 'off',
      'class-methods-use-this': 'off',
      'complexity': 'off',
      'consistent-return': 'error',
      'consistent-this': ['warn', 'self'],
      'curly': ['error', 'all'],
      'default-case': 'off', // Flow enforces this enough for us
      'default-case-last': 'warn',
      'default-param-last': 'warn',
      'dot-location': ['warn', 'property'],
      'dot-notation': ['warn', {allowKeywords: true}],
      'eqeqeq': ['warn', 'smart'],
      'func-name-matching': 'warn',
      'func-names': 'off',
      'func-style': ['warn', 'declaration', {allowArrowFunctions: true}],
      'grouped-accessor-pairs': 'off', // We should never use setters/getters
      'guard-for-in': 'off',
      'id-denylist': 'off',
      'id-length': 'off',
      'id-match': 'off',
      'init-declarations': 'off',
      'logical-assignment-operators': 'warn',
      'max-classes-per-file': 'off', // We should aim not to use classes
      'max-depth': 'off',
      'max-lines': 'off',
      'max-lines-per-function': 'off',
      'max-nested-callbacks': 'warn',
      'max-params': 'off',
      'max-statements': 'off',
      'new-cap': 'off',
      'no-alert': 'off',
      'no-array-constructor': 'warn',
      'no-bitwise': 'off', // We intentionally use bitwise quite a bit
      'no-caller': 'off',
      'no-case-declarations': 'error',
      'no-console': 'off',
      'no-continue': 'off',
      'no-delete-var': 'warn',
      'no-div-regex': 'off',
      'no-else-return': 'warn',
      'no-empty': ['error', {allowEmptyCatch: true}],
      'no-eq-null': 'off',
      'no-eval': 'warn',
      'no-extend-native': 'error',
      'no-extra-bind': 'error',
      'no-extra-boolean-cast': 'warn',
      'no-extra-label': 'off',
      'no-global-assign': 'error',
      'no-implicit-coercion': 'warn',
      'no-implicit-globals': 'off',
      'no-implied-eval': 'warn',
      'no-inline-comments': 'off',
      'no-invalid-this': 'off',
      'no-iterator': 'error',
      'no-label-var': 'warn',
      'no-labels': 'off',
      'no-lone-blocks': 'warn',
      'no-lonely-if': 'warn',
      'no-loop-func': 'warn',
      'no-magic-numbers': 'off',
      'no-multi-assign': 'off',
      'no-multi-str': 'off',
      'no-negated-condition': 'warn',
      'no-nested-ternary': 'off',
      'no-new': 'warn',
      'no-new-func': 'off',
      'no-new-wrappers': 'warn',
      'no-nonoctal-decimal-escape': 'warn',
      'no-object-constructor': 'warn',
      'no-octal': 'warn',
      'no-octal-escape': 'error',
      'no-param-reassign': 'off',
      'no-plusplus': 'off',
      'no-proto': 'error',
      'no-redeclare': 'error',
      'no-regex-spaces': 'warn',
      'no-restricted-exports': 'off',
      'no-restricted-globals': 'off',
      'no-restricted-imports': 'off',
      'no-restricted-properties': 'off',
      'no-restricted-syntax': 'off',
      'no-return-assign': 'error',
      'no-script-url': 'warn',
      'no-sequences': 'warn',
      'no-shadow': 'off',
      'no-shadow-restricted-names': 'warn',
      'no-ternary': 'off',
      'no-throw-literal': 'off',
      'no-undef-init': 'warn',
      'no-undefined': 'off',
      'no-underscore-dangle': 'off',
      'no-unneeded-ternary': 'warn',
      'no-unused-expressions': ['warn', {
        allowShortCircuit: true,
        allowTernary: true,
        enforceForJSX: true,
      }],
      'no-unused-labels': 'warn',
      'no-useless-call': 'warn',
      'no-useless-catch': 'warn',
      'no-useless-computed-key': 'warn',
      'no-useless-concat': 'warn',
      'no-useless-constructor': 'warn',
      'no-useless-escape': 'warn',
      'no-useless-rename': 'warn',
      'no-useless-return': 'warn',
      'no-var': 'warn',
      'no-void': 'warn',
      'no-warning-comments': 'off',
      'no-with': 'off', // Flow probably covers this
      'object-shorthand': ['warn', 'always'],
      'one-var': ['warn', 'never'],
      'operator-assignment': ['warn', 'always'],
      'prefer-arrow-callback': 'off',
      'prefer-const': 'warn',
      'prefer-destructuring': 'off',
      'prefer-exponentiation-operator': 'warn',
      // Needs a lot of work but we might want this eventually:
      'prefer-named-capture-group': 'off',
      'prefer-numeric-literals': 'warn',
      'prefer-object-has-own': 'warn',
      'prefer-object-spread': 'warn',
      'prefer-promise-reject-errors': 'warn',
      'prefer-regex-literals': 'warn',
      'prefer-rest-params': 'warn',
      'prefer-spread': 'warn',
      'prefer-template': 'off',
      'radix': 'warn',
      'require-await': 'warn',
      'require-unicode-regexp': 'off',
      'require-yield': 'error',
      /*
       * sort-imports does not support Flow 'type' imports, so we use the
       * imports rule from simple-import-sort instead.
       */
      'sort-imports': 'off',
      'sort-keys': ['warn', 'asc', {caseSensitive: false, natural: true}],
      'sort-vars': 'off',
      'symbol-description': 'off',
      'vars-on-top': 'off',
      'yoda': 'warn',

      /*
       * Strict Mode
       * It is enforced elsewhere (Webpack) but this tells us off
       * if we add strict where it is not needed to begin with
       */
      'strict': 'warn',

      // eslint-plugin-import
      'import/consistent-type-specifier-style': 'off',
      'import/default': 'off', // Enforced by Flow
      'import/dynamic-import-chunkname': 'off',
      'import/export': 'error',
      'import/exports-last': 'off',
      'import/extensions': ['error', 'ignorePackages'],
      'import/first': 'warn',
      'import/group-exports': 'off',
      'import/max-dependencies': 'off',
      'import/named': 'off', // Enforced by Flow
      'import/namespace': 'off', // Enforced by Flow
      'import/newline-after-import': ['warn', {
        count: 1,
        exactCount: true,
        considerComments: true,
      }],
      'import/no-absolute-path': 'warn',
      'import/no-amd': 'error',
      'import/no-anonymous-default-export': ['warn', {allowObject: true}],
      'import/no-commonjs': 'error',
      'import/no-cycle': 'warn',
      'import/no-default-export': 'off',
      'import/no-deprecated': 'off',
      'import/no-duplicates': 'warn',
      'import/no-dynamic-require': 'error',
      'import/no-empty-named-blocks': 'error',
      'import/no-extraneous-dependencies': 'error',
      'import/no-import-module-exports': 'warn',
      'import/no-internal-modules': 'off',
      // 'import/no-mutable-exports': 'warn',
      // 'import/no-named-as-default': 'warn',
      // 'import/no-named-as-default-member': 'warn',
      'import/no-named-default': 'off',
      'import/no-named-export': 'off',
      'import/no-namespace': 'off',
      'import/no-nodejs-modules': 'off',
      'import/no-relative-packages': 'off',
      'import/no-relative-parent-imports': 'off',
      'import/no-restricted-paths': 'off',
      'import/no-self-import': 'error',
      // Until we get rid of dependencies with side effects:
      'import/no-unassigned-import': 'off',
      'import/no-unresolved': 'error',
      'import/no-unused-modules': 'warn',
      'import/no-useless-path-segments': 'warn',
      'import/no-webpack-loader-syntax': 'error',
      'import/order': 'off',
      'import/prefer-default-export': ['warn', {target: 'single'}],
      'import/unambiguous': 'warn',

      // @stylistic/js
      '@stylistic/js/array-bracket-newline': ['warn', 'consistent'],
      '@stylistic/js/array-bracket-spacing': ['warn', 'never'],
      '@stylistic/js/array-element-newline': ['warn', 'consistent'],
      '@stylistic/js/arrow-parens': 'off',	
      '@stylistic/js/arrow-spacing': 'warn',
      '@stylistic/js/block-spacing': ['warn', 'always'],
      '@stylistic/js/brace-style': ['warn', '1tbs'],
      '@stylistic/js/comma-dangle': ['warn', {
        arrays: 'always-multiline',
        objects: 'always-multiline',
        imports: 'always-multiline',
        exports: 'always-multiline',
        functions: 'always-multiline',
      }],
      '@stylistic/js/comma-spacing': ['warn', {
        before: false,
        after: true,
      }],
      '@stylistic/js/comma-style': ['warn', 'last'],
      '@stylistic/js/computed-property-spacing': ['warn', 'never', {
        enforceForClassMembers: true,
      }],
      '@stylistic/js/dot-location': ['warn', 'property'],
      '@stylistic/js/eol-last': ['warn', 'always'],
      '@stylistic/js/function-call-argument-newline': [
        'warn',
        'consistent',
      ],
      '@stylistic/js/function-call-spacing': ['warn', 'never'],
      '@stylistic/js/function-paren-newline': ['warn', 'consistent'],
      '@stylistic/js/generator-star-spacing': ['warn', 'after'],
      '@stylistic/js/implicit-arrow-linebreak': ['warn', 'beside'],
      '@stylistic/js/indent': ['warn', 2, {
        CallExpression: {arguments: 'first'},
        SwitchCase: 1,
        ignoredNodes: ['JSXElement', 'ArrowFunctionExpression'],
      }],
      '@stylistic/js/jsx-quotes': ['warn', 'prefer-double'],
      '@stylistic/js/key-spacing': ['warn', {mode: 'minimum'}],
      '@stylistic/js/keyword-spacing': ['warn', {before: true, after: true}],
      '@stylistic/js/linebreak-style': ['warn', 'unix'],
      '@stylistic/js/line-comment-position': 'off',
      '@stylistic/js/lines-around-comment': 'off',
      '@stylistic/js/lines-between-class-members': ['warn', 'always'],
      '@stylistic/js/max-len': ['warn', {
        code: 78,
        ignoreUrls: true,
        ignoreStrings: false,
        ignoreTemplateLiterals: false,
        ignoreRegExpLiterals: true,
      }],
      '@stylistic/js/max-statements-per-line': ['warn', {max: 1}],
      '@stylistic/js/multiline-comment-style': ['warn', 'starred-block'],
      '@stylistic/js/multiline-ternary': 'off',
      '@stylistic/js/new-parens': 'warn',
      '@stylistic/js/newline-per-chained-call': ['warn', {
        ignoreChainWithDepth: 3,
      }],
      '@stylistic/js/no-confusing-arrow': 'off',
      '@stylistic/js/no-extra-parens': 'off',
      '@stylistic/js/no-extra-semi': 'warn',
      '@stylistic/js/no-floating-decimal': 'warn',
      '@stylistic/js/no-mixed-operators': 'warn',
      '@stylistic/js/no-mixed-spaces-and-tabs': 'warn',
      '@stylistic/js/no-multi-spaces': ['error', {
        ignoreEOLComments: true,
      }],
      '@stylistic/js/no-multiple-empty-lines': ['warn', {
        max: 2,
        maxBOF: 0,
        maxEOF: 0,
      }],
      '@stylistic/js/no-tabs': 'warn',
      '@stylistic/js/no-trailing-spaces': 'warn',
      '@stylistic/js/no-whitespace-before-property': 'warn',
      '@stylistic/js/nonblock-statement-body-position': 'warn',
      '@stylistic/js/object-curly-newline': ['warn', {
        multiline: true,
        consistent: true,
      }],
      '@stylistic/js/object-curly-spacing': ['warn', 'never'],
      '@stylistic/js/object-property-newline': ['warn', {
        allowAllPropertiesOnSameLine: true,
      }],
      '@stylistic/js/one-var-declaration-per-line': 'warn',
      '@stylistic/js/operator-linebreak': ['warn'],
      '@stylistic/js/padded-blocks': ['warn', 'never'],
      '@stylistic/js/padding-line-between-statements': 'off',
      '@stylistic/js/quote-props': ['warn', 'consistent-as-needed', {
        numbers: true,
      }],
      '@stylistic/js/quotes': ['warn', 'single', {
        avoidEscape: true,
        allowTemplateLiterals: true,
      }],
      '@stylistic/js/rest-spread-spacing': ['warn', 'never'],
      '@stylistic/js/semi': ['warn', 'always', {
        omitLastInOneLineBlock: true,
      }],
      '@stylistic/js/semi-spacing': ['warn', {before: false, after: true}],
      '@stylistic/js/semi-style': ['warn', 'last'],
      '@stylistic/js/space-before-blocks': ['warn', 'always'],
      '@stylistic/js/space-before-function-paren': ['warn', {
        anonymous: 'always',
        named: 'never',
        asyncArrow: 'always',
      }],
      '@stylistic/js/space-in-parens': ['warn', 'never'],
      '@stylistic/js/space-infix-ops': ['warn', {int32Hint: true}],
      '@stylistic/js/space-unary-ops': ['warn', {
        words: true,
        nonwords: false,
      }],
      '@stylistic/js/spaced-comment': ['warn', 'always', {
        block: {balanced: true},
        markers: [':', '::'],
      }],
      '@stylistic/js/switch-colon-spacing': ['warn', {
        after: true,
        before: false,
      }],
      '@stylistic/js/template-curly-spacing': ['warn', 'never'],
      '@stylistic/js/template-tag-spacing': ['warn', 'never'],
      '@stylistic/js/wrap-iife': 'warn',
      '@stylistic/js/wrap-regex': 'off',
      '@stylistic/js/yield-star-spacing': ['warn', 'after'],

      // @stylistic/jsx
      '@stylistic/jsx/jsx-child-element-spacing': 'warn',
      '@stylistic/jsx/jsx-closing-bracket-location': [
        'error',
        'tag-aligned',
      ],
      '@stylistic/jsx/jsx-closing-tag-location': 'error',
      '@stylistic/jsx/jsx-curly-brace-presence': ['error', {
        props: 'never',
        children: 'ignore',
      }],
      '@stylistic/jsx/jsx-curly-newline': 'error',
      '@stylistic/jsx/jsx-curly-spacing': ['error', {
        when: 'never',
        children: true,
      }],
      '@stylistic/jsx/jsx-equals-spacing': ['error', 'never'],
      '@stylistic/jsx/jsx-first-prop-new-line': [
        'error',
        'multiline-multiprop',
      ],
      '@stylistic/jsx/jsx-function-call-newline': ['warn', 'multiline'],
      '@stylistic/jsx/jsx-indent': 'off', // deprecated, use /js/indent
      '@stylistic/jsx/jsx-indent-props': ['error', 2],
      '@stylistic/jsx/jsx-max-props-per-line': ['error', {
        maximum: 1,
        when: 'multiline',
      }],
      '@stylistic/jsx/jsx-newline': 'off',
      '@stylistic/jsx/jsx-one-expression-per-line': ['warn', {
        allow: 'single-line',
      }],
      '@stylistic/jsx/jsx-pascal-case': 'error',
      '@stylistic/jsx/jsx-props-no-multi-spaces': 'off', // in eslint-js
      '@stylistic/jsx/jsx-self-closing-comp': 'error',
      '@stylistic/jsx/jsx-sort-props': 'warn',
      '@stylistic/jsx/jsx-tag-spacing': ['error', {beforeClosing: 'never'}],
      '@stylistic/jsx/jsx-wrap-multilines': ['error', {
        declaration: 'parens-new-line',
        assignment: 'parens-new-line',
        return: 'parens-new-line',
        arrow: 'parens-new-line',
        condition: 'ignore',
        logical: 'ignore',
        prop: 'ignore',
        propertyValue: 'parens',
      }],

      // eslint-plugin-react
      'react/boolean-prop-naming': 'off',
      'react/button-has-type': 'error',
      'react/checked-requires-onchange-or-readonly': 'warn',
      'react/default-props-match-prop-types': 'off',
      'react/destructuring-assignment': 'off',
      'react/display-name': 'off',
      'react/forbid-component-props': 'off',
      'react/forbid-dom-props': 'off',
      'react/forbid-elements': 'off',
      'react/forbid-foreign-prop-types': 'off',
      'react/forbid-prop-types': 'off',
      'react/function-component-definition': 'off',
      'react/hook-use-state': 'warn',
      'react/iframe-missing-sandbox': 'off',
      'react/jsx-boolean-value': ['warn', 'never'],
      'react/jsx-child-element-spacing': 'off', // in eslint-jsx
      'react/jsx-closing-bracket-location': 'off', // in eslint-jsx
      'react/jsx-closing-tag-location': 'off', // in eslint-jsx
      'react/jsx-curly-brace-presence': 'off', // in eslint-jsx
      'react/jsx-curly-newline': 'off', // in eslint-jsx
      'react/jsx-curly-spacing': 'off', // in eslint-jsx
      'react/jsx-equals-spacing': 'off', // in eslint-jsx
      'react/jsx-filename-extension': ['error', {
        extensions: ['.js', '.mjs'],
      }],
      'react/jsx-first-prop-new-line': 'off', // in eslint-jsx
      'react/jsx-fragments': ['warn', 'syntax'],
      'react/jsx-handler-names': 'warn',
      'react/jsx-indent': 'off', // in eslint-jsx
      'react/jsx-indent-props': 'off', // in eslint-jsx
      'react/jsx-key': 'warn',
      'react/jsx-max-depth': 'off',
      'react/jsx-max-props-per-line': 'off', // in eslint-jsx
      'react/jsx-newline': 'off', // in eslint-jsx
      'react/jsx-no-bind': ['warn', {ignoreDOMComponents: true}],
      'react/jsx-no-comment-textnodes': 'warn',
      'react/jsx-no-constructed-context-values': 'error',
      'react/jsx-no-duplicate-props': ['error', {ignoreCase: true}],
      'react/jsx-no-leaked-render': 'off', // false positives
      'react/jsx-no-literals': 'warn',
      'react/jsx-no-script-url': 'error',
      'react/jsx-no-target-blank': 'error',
      'react/jsx-no-undef': ['error', {allowGlobals: true}],
      'react/jsx-no-useless-fragment': 'warn',
      'react/jsx-one-expression-per-line': 'off', // in eslint-jsx
      'react/jsx-pascal-case': 'off', // in eslint-jsx
      'react/jsx-props-no-multi-spaces': 'off', // in eslint-js
      'react/jsx-props-no-spreading': 'off',
      'react/jsx-props-no-spread-multi': 'error',
      'react/jsx-sort-default-props': 'off', // deprecated
      'react/jsx-sort-props': 'off', // in eslint-jsx
      'react/jsx-space-before-closing': 'off', // deprecated
      'react/jsx-tag-spacing': 'off', // in eslint-jsx
      /*
       * jsx-uses-react is not implied since
       * https://reactjs.org/blog/2020/09/22/introducing-the-new-jsx-transform.html
       */
      'react/jsx-uses-react': 'off',
      'react/jsx-uses-vars': 'warn',
      'react/jsx-wrap-multilines': 'off', // in eslint-jsx
      'react/no-access-state-in-setstate': 'error',
      'react/no-adjacent-inline-elements': 'warn',
      'react/no-array-index-key': 'off',
      'react/no-arrow-function-lifecycle': 'off',
      'react/no-children-prop': 'error',
      'react/no-danger': 'off',
      'react/no-danger-with-children': 'error',
      'react/no-deprecated': 'error',
      /*
       * Using setState in componentDidMount is necessary when the state
       * depends on the size/attributes of a DOM node, for example.
       */
      'react/no-did-mount-set-state': 'off',
      'react/no-did-update-set-state': 'error',
      'react/no-direct-mutation-state': 'error',
      'react/no-find-dom-node': 'warn',
      'react/no-invalid-html-attribute': 'warn',
      'react/no-is-mounted': 'warn',
      'react/no-multi-comp': ['warn', {ignoreStateless: true}],
      'react/no-namespace': 'off',
      'react/no-object-type-as-default-prop': 'warn',
      'react/no-redundant-should-component-update': 'error',
      'react/no-render-return-value': 'warn',
      'react/no-set-state': 'off',
      'react/no-string-refs': 'warn',
      'react/no-this-in-sfc': 'error',
      'react/no-typos': 'error',
      'react/no-unescaped-entities': 'error',
      'react/no-unknown-property': 'error',
      'react/no-unsafe': 'off',
      'react/no-unstable-nested-components': 'warn',
      'react/no-unused-class-component-methods': 'off',
      'react/no-unused-prop-types': 'off',
      'react/no-unused-state': 'error',
      'react/no-will-update-set-state': 'error',
      'react/prefer-es6-class': 'off',
      'react/prefer-exact-props': 'off',
      'react/prefer-read-only-props': 'off',
      'react/prefer-stateless-function': 'warn',
      'react/prop-types': 'off',
      /*
       * react-in-jsx-scope is not needed now that we've enabled
       * https://reactjs.org/blog/2020/09/22/introducing-the-new-jsx-transform.html
       */
      'react/react-in-jsx-scope': 'off',
      'react/require-default-props': 'off',
      'react/require-optimization': 'off',
      'react/require-render-return': 'error',
      'react/self-closing-comp': 'off', // in eslint-jsx
      'react/sort-comp': 'off',
      'react/sort-default-props': 'warn',
      'react/sort-prop-types': 'off',
      'react/state-in-constructor': 'off',
      'react/static-property-placement': 'off',
      'react/style-prop-object': 'error',
      'react/void-dom-elements-no-children': 'error',

      // eslint-plugin-ft-flow
      'ft-flow/array-style-complex-type': ['warn', 'verbose'],
      'ft-flow/array-style-simple-type': ['warn', 'verbose'],
      'ft-flow/arrow-parens': 'off', // in eslint-js
      'ft-flow/boolean-style': ['warn', 'boolean'],
      'ft-flow/define-flow-type': 'off',
      'ft-flow/delimiter-dangle': ['warn', 'always-multiline'],
      'ft-flow/enforce-line-break': 'off',
      'ft-flow/enforce-suppression-code': 'warn',
      'ft-flow/generic-spacing': 'off',
      'ft-flow/interface-id-match': 'off',
      'ft-flow/newline-after-flow-annotation': 'off',
      'ft-flow/no-dupe-keys': 'error',
      'ft-flow/no-flow-fix-me-comments': 'off',
      'ft-flow/no-internal-flow-type': 'warn',
      'ft-flow/no-duplicate-type-union-intersection-members': 'warn',
      'ft-flow/no-existential-type': 'warn',
      'ft-flow/no-flow-fix-me-comments': 'error',
      'ft-flow/no-flow-suppressions-in-strict-files': ['warn', {
        "$FlowIssue": false,
      }],
      'ft-flow/no-internal-flow-type': 'warn',
      'ft-flow/no-mixed': 'off',
      'ft-flow/no-mutable-array': 'off',
      'ft-flow/no-primitive-constructor-types': 'error',
      'ft-flow/no-types-missing-file-annotation': 'error',
      'ft-flow/no-unused-expressions': 'off',
      'ft-flow/no-weak-types': 'warn',
      'ft-flow/object-type-curly-spacing': 'warn',
      'ft-flow/object-type-delimiter': ['warn', 'comma'],
      'ft-flow/quotes': ['warn', 'single'],
      'ft-flow/require-compound-type-alias': 'off',
      'ft-flow/require-exact-type': 'off',
      'ft-flow/require-indexer-name': ['warn', 'always'],
      'ft-flow/require-inexact-type': 'off',
      'ft-flow/require-parameter-type':  'off',
      'ft-flow/require-readonly-react-props': 'off', // enforced by component syntax
      'ft-flow/require-return-type': 'off',
      'ft-flow/require-types-at-top': 'off',
      'ft-flow/require-valid-file-annotation': 'off',
      'ft-flow/require-variable-type': 'off',
      'ft-flow/semi': ['warn', 'always'],
      'ft-flow/sort-keys': ['warn', 'asc'],
      'ft-flow/sort-type-union-intersection-members': 'off',
      'ft-flow/space-after-type-colon': ['warn', 'always', {
        allowLineBreak: true,
      }],
      'ft-flow/space-before-generic-bracket': ['warn', 'never'],
      'ft-flow/space-before-type-colon': ['warn', 'never'],
      'ft-flow/spread-exact-type': 'off',
      'ft-flow/type-id-match': 'off',
      'ft-flow/type-import-style': 'off',
      'ft-flow/union-intersection-spacing': ['warn', 'always'],
      'ft-flow/use-flow-type': 'off',
      'ft-flow/use-read-only-spread': 'warn',
      'ft-flow/valid-syntax': 'off',

      // eslint-plugin-fb-flow
      'fb-flow/use-indexed-access-type': 'error',
      'fb-flow/use-exact-by-default-object-type': 'warn',
      'fb-flow/use-flow-enums': 'warn',
      'fb-flow/flow-enums-default-if-possible': 'warn',
      'fb-flow/no-flow-enums-object-mapping': 'off',

      // eslint-plugin-react-hooks
      'react-hooks/exhaustive-deps': 'error',
      'react-hooks/rules-of-hooks': 'off', // Flow takes care of this

      // eslint-plugin-simple-import-sort
      'simple-import-sort/imports': ['warn', {
        groups: [
          /*
           * Node.js builtins. You could also generate this regex if you use a
           * `.js` config. For example:
           * `^(${require("module").builtinModules.join("|")})(/|$)`
           */
          ['^(assert|buffer|child_process|cluster|console|constants|crypto|dgram|dns|domain|events|fs|http|https|module|net|os|path|punycode|readline|repl|stream|string_decoder|sys|timers|tls|tty|url|util|vm|zlib|freelist|v8|process|async_hooks|http2|perf_hooks)(/.*|$)'],
          // Packages.
          ['^@?\\w'],
          // Side effect imports.
          ['^\\u0000'],
          // Parent imports. Put `..` last.
          ['^\\.\\.(?!/?$)', '^\\.\\./?$'],
          // Other relative imports. Put same-folder imports and `.` last.
          ['^\\./(?=.*/)(?!/?$)', '^\\.(?!/?$)', '^\\./?$'],
        ],
      }],
      'simple-import-sort/exports': 'warn',
    },
  },
  {
    files: ['root/static/scripts/tests/**/*', 't/**/*'],
    rules: {
      '@stylistic/js/max-len': ['warn', {
        code: 78,
        ignoreUrls: true,
        ignoreStrings: true,
        ignoreTemplateLiterals: false,
        ignoreRegExpLiterals: true,
      }],
    },
  },
  /*
   * The following sections disable rules we want to enforce, but haven't
   * fixed everywhere, only in files with existing issues. This allows us
   * to enforce them elsewhere in the meantime.
   * If you fix one rule in any of the files in these sections, please remove
   * the file from the list; if you fix the last file, remove the section.
   */
  {
    files: [
      'root/static/scripts/edit/components/withLoadedTypeInfo.js',
      'root/static/scripts/release/components/ReleaseRelationshipEditor.js',
    ],
    rules: {
      'no-await-in-loop': 'off',
    },
  },
  {
    files: [
      'root/static/scripts/common/MB/Control/Autocomplete.js',
      'root/static/scripts/edit/MB/CoverArt.js',
      'root/static/scripts/guess-case/MB/Control/GuessCase.js',
      'root/static/scripts/jquery.flot.musicbrainz_events.js',
      'root/static/scripts/release-editor/**/*',
      'root/static/scripts/timeline.js',
    ],
    rules: {
      'eqeqeq': 'off',
    },
  },
  {
    files: [
      'root/static/scripts/jquery.flot.musicbrainz_events.js',
      'root/static/scripts/timeline.js',
    ],
    rules: {
      '@stylistic/js/wrap-iife': 'off',
    },
  },
  {
    files: [
      'root/static/scripts/common/MB/**/*',
      'root/static/scripts/edit/MB/**/*',
    ],
    rules: {
      'consistent-this': 'off',
    },
  },
  {
    files: [
      'root/static/scripts/common/MB/**/*',
      'root/static/scripts/common/artworkViewer.js',
      'root/static/scripts/common/coverart.js',
      'root/static/scripts/common/utility/request.js',
      'root/static/scripts/edit/MB/**/*',
      'root/static/scripts/edit/forms.js',
      'root/static/scripts/guess-case/MB/Control/GuessCase.js',
      'root/static/scripts/jquery.flot.musicbrainz_events.js',
      'root/static/scripts/release-editor/**/*',
      'root/static/scripts/series/edit.js',
      'root/static/scripts/timeline.js',
    ],
    rules: {
      'no-var': 'off',
    },
  },
  {
    files: [
      'root/static/scripts/common/components/Modal.js',
      'root/static/scripts/edit/ExampleRelationships.js',
    ],
    rules: {
      'prefer-const': 'off',
    },
  },
  {
    files: [
      'root/server/components.mjs',
      'root/static/scripts/common/MB.js',
      'root/static/scripts/common/MB/**/*',
      'root/static/scripts/common/artworkViewer.js',
      'root/static/scripts/common/components/ButtonPopover.js',
      'root/static/scripts/edit/MB/**/*',
      'root/static/scripts/edit/forms.js',
      'root/static/scripts/edit/utility/editDiff.js',
      'root/static/scripts/guess-case/MB/Control/GuessCase.js',
      'root/static/scripts/jquery.flot.musicbrainz_events.js',
      'root/static/scripts/relationship-editor/components/RelationshipDialogContent.js',
      'root/static/scripts/release-editor/**/*',
      'root/static/scripts/release/components/BatchCreateWorksDialog.js',
      'root/static/scripts/series/edit.js',
      'root/static/scripts/timeline.js',
      'root/utility/activeSanitizedEditor.mjs',
    ],
    rules: {
      'sort-keys': 'off',
    },
  },
  {
    files: [
      'root/static/scripts/common/components/TagEditor.js',
      'root/static/scripts/edit/externalLinks.js',
    ],
    rules: {
      'react/no-access-state-in-setstate': 'off',
    },
  },
  {
    files: [
      'root/static/scripts/edit/externalLinks.js',
    ],
    rules: {
      'react/no-multi-comp': 'off',
    },
  },
  {
    files: [
      'root/search/components/ArtistResults.js',
      'root/search/components/InstrumentResults.js',
      'root/search/components/RecordingResults.js',
      'root/search/components/ReleaseResults.js',
      'root/search/components/WorkResults.js',
      'root/static/scripts/account/components/EditProfileForm.js',
      'root/static/scripts/account/components/RegisterForm.js',
      'root/static/scripts/common/components/TagEditor.js',
      'root/static/scripts/edit/check-duplicates.js',
      'root/static/scripts/edit/components/ExternalLinkAttributeDialog.js',
      'root/static/scripts/edit/components/FormRowNameWithGuessCase.js',
      'root/static/scripts/edit/components/FormRowSelectList.js',
      'root/static/scripts/edit/components/ReleaseMergeStrategy.js',
      'root/static/scripts/edit/components/URLInputPopover.js',
      'root/static/scripts/edit/components/UrlRelationshipCreditFieldset.js',
      'root/static/scripts/edit/externalLinks.js',
      'root/static/scripts/event/components/EventEditForm.js',
      'root/static/scripts/recording/components/RecordingEditForm.js',
      'root/static/scripts/relationship-editor/components/DialogPreview.js',
    ],
    rules: {
      'react/jsx-no-bind': 'off',
    },
  },
  {
    files: [
      'root/static/scripts/common/components/Autocomplete2.js',
      'root/static/scripts/common/components/Autocomplete2/recentItems.js',
      'root/static/scripts/common/components/Autocomplete2/searchItems.js',
      'root/static/scripts/common/i18n/expand2.js',
      'root/static/scripts/common/utility/cloneDeep.mjs',
      'root/static/scripts/edit/components/withLoadedTypeInfo.js',
      'root/static/scripts/edit/externalLinks.js',
      'root/static/scripts/relationship-editor/components/DialogEntityCredit.js',
      'root/static/scripts/relationship-editor/components/DialogTargetType.js',
      'root/static/scripts/relationship-editor/components/RelationshipEditor.js',
      'root/static/scripts/relationship-editor/utility/findState.js',
      'root/static/scripts/relationship-editor/utility/updateRelationships.js',
      'root/static/scripts/release/components/ReleaseRelationshipEditor.js',
      'root/static/scripts/release/components/TrackRelationshipEditor.js',
      'root/types/edit.js',
      'root/utility/hydrate.js',
    ],
    rules: {
      'ft-flow/no-weak-types': 'off',
    },
  },
  {
    files: [
      'root/edit/details/AddArt.js',
      'root/edit/details/EditArt.js',
      'root/edit/details/RemoveArt.js',
      'root/edit/details/ReorderArt.js',
      'root/release/DiscIds.js',
      'root/static/scripts/common/components/Autocomplete2.js',
      'root/static/scripts/common/components/Autocomplete2/recentItems.js',
      'root/static/scripts/common/components/Autocomplete2/reducer.js',
      'root/static/scripts/common/components/Autocomplete2/searchItems.js',
      'root/static/scripts/common/components/ButtonPopover.js',
      'root/static/scripts/common/components/EntityLink.js',
      'root/static/scripts/common/i18n/expand2.js',
      'root/static/scripts/common/linkedEntities.mjs',
      'root/static/scripts/common/utility/catalyst.js',
      'root/static/scripts/common/utility/createFastObjectCloneFunction.js',
      'root/static/scripts/edit/components/ArtistCreditEditor.js',
      'root/static/scripts/edit/components/ArtistCreditEditor/utilities.js',
      'root/static/scripts/edit/components/ExternalLinkAttributeDialog.js',
      'root/static/scripts/edit/components/Multiselect.js',
      'root/static/scripts/edit/components/withLoadedTypeInfo.js',
      'root/static/scripts/edit/utility/reducerWithErrorHandling.js',
      'root/static/scripts/edit/utility/subfieldErrors.js',
      'root/static/scripts/guess-case/MB/GuessCase/Main.js',
      'root/static/scripts/relationship-editor/components/DialogAttribute/MultiselectAttribute.js',
      'root/static/scripts/relationship-editor/components/DialogEntityCredit.js',
      'root/static/scripts/relationship-editor/components/DialogTargetEntity.js',
      'root/static/scripts/relationship-editor/components/DialogTargetType.js',
      'root/static/scripts/relationship-editor/components/RelationshipDialogContent.js',
      'root/static/scripts/relationship-editor/components/RelationshipEditor.js',
      'root/static/scripts/relationship-editor/components/RelationshipPhraseGroup.js',
      'root/static/scripts/relationship-editor/hooks/useEntityNameFromField.js',
      'root/static/scripts/relationship-editor/utility/findState.js',
      'root/static/scripts/relationship-editor/utility/getTargetTypeOptions.js',
      'root/static/scripts/relationship-editor/utility/prepareHtmlFormSubmission.js',
      'root/static/scripts/relationship-editor/utility/updateRelationships.js',
      'root/static/scripts/release/components/ReleaseRelationshipEditor.js',
      'root/static/scripts/release/components/TrackRelationshipEditor.js',
      'root/static/scripts/release/components/WorkLanguageMultiselect.js',
      'root/static/scripts/series/components/SeriesRelationshipEditor.js',
      'root/static/scripts/tests/relationship-editor.js',
      'root/static/scripts/url/edit.js',
      'root/user/UserProfile.js',
      'root/utility/chooseLayoutComponent.js',
      'root/utility/compactEntityJson.js',
      'root/utility/tableColumns.js',
    ],
    rules: {
      'ft-flow/no-flow-suppressions-in-strict-files': 'off',
    },
  },

];
