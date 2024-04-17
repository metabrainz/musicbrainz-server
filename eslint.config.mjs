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
        hasOwnProp: 'readonly',
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
    // Possible Errors
      'for-direction': 'error',
      'no-async-promise-executor': 'error',
      'no-await-in-loop': 'error',
      'no-cond-assign': 'warn',
      'no-constant-binary-expression': 'error',
      'no-constant-condition': ['error', {checkLoops: false}],
      'no-control-regex': 'off',
      'no-debugger': 'error',
      'no-dupe-args': 'error',
      'no-dupe-keys': 'error',
      'no-duplicate-case': 'error',
      'no-empty-character-class': 'error',
      'no-empty': ['error', {allowEmptyCatch: true}],
      'no-irregular-whitespace': 'warn',
      'no-misleading-character-class': 'error',
      'no-obj-calls': 'error',
      'no-prototype-builtins': 'warn',
      'no-regex-spaces': 'error',
      'no-shadow-restricted-names': 'error',
      'no-sparse-arrays': 'error',
      'no-unexpected-multiline': 'error',
      'no-unreachable': 'off', // Flow takes care of this
      'no-unsafe-finally': 'error',
      'no-unsafe-negation': 'error',
      'no-unused-vars': ['error', {argsIgnorePattern: '^this$'}],
      'no-with': 'error',
      'require-atomic-updates': 'error',
      'use-isnan': 'error',
      'valid-typeof': 'error',

      // Best Practices
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
      'class-methods-use-this': 'off',
      'consistent-return': 'error',
      'consistent-this': ['warn', 'self'],
      'curly': ['error', 'all'],
      'dot-location': ['warn', 'property'],
      'dot-notation': ['warn', {allowKeywords: true}],
      'eqeqeq': ['warn', 'smart'],
      'no-alert': 'off',
      'no-else-return': 'warn',
      'no-eq-null': 'off',
      'no-global-assign': 'error',
      'no-useless-catch': 'warn',
      'no-var': 'warn',
      'prefer-const': 'warn',
      'radix': 'warn',
      'sort-keys': ['warn', 'asc', {caseSensitive: false, natural: true}],

      // Strict Mode
      'strict': 'off',

      /*
       * Variables
       * no-undef is mostly superfluous as it is checked by Flow; enabling it
       * actually triggers thousands of false positives because hermes-eslint
       * doesn't track global types (those defined with `declare type`).
       * Ideally we could keep no-undef enabled for files that aren't Flow-
       * typed yet, but we don't maintain a separate config for those.
       */
      'no-undef': 'off',
      'no-use-before-define': 'off',

      // Stylistic Issues
      'multiline-comment-style': ['warn', 'starred-block'],
      'new-cap': 'off',
      'no-lonely-if': 'warn',
      'no-multi-assign': 'off',
      'no-negated-condition': 'warn',
      'no-nested-ternary': 'off',
      'no-plusplus': 'off',
      'no-ternary': 'off',
      'no-underscore-dangle': 'off',
      'no-unneeded-ternary': 'warn',
      'one-var': ['warn', 'never'],
      'operator-assignment': ['warn', 'always'],

      // ECMAScript 6
      'constructor-super': 'error',
      'no-class-assign': 'error',
      'no-const-assign': 'error',
      'no-dupe-class-members': 'error',
      /*
       * no-duplicate-imports does not support Flow 'type' imports, so we use
       * the import/no-duplicates rule from eslint-plugin-import instead.
       */
      'no-duplicate-imports': 'off',
      'no-new-symbol': 'error',
      'no-this-before-super': 'error',
      'no-useless-constructor': 'warn',
      'no-useless-rename': 'warn',
      'prefer-numeric-literals': 'warn',
      'require-yield': 'error',
      /*
       * sort-imports does not support Flow 'type' imports, so we use the
       * imports rule from simple-import-sort instead.
       */
      'sort-imports': 'off',

      // eslint-plugin-import
      'import/export': 'error',
      'import/extensions': ['error', 'ignorePackages'],
      'import/first': 'warn',
      'import/newline-after-import': ['warn', {
        count: 1,
        exactCount: true,
        considerComments: true,
      }],
      'import/no-commonjs': 'error',
      'import/no-duplicates': 'warn',
      'import/no-dynamic-require': 'error',
      'import/no-unresolved': 'error',

      // @stylistic/js
      '@stylistic/js/array-bracket-newline': ['warn', 'consistent'],
      '@stylistic/js/array-bracket-spacing': ['warn', 'never'],
      '@stylistic/js/array-element-newline': ['warn', 'consistent'],
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
      '@stylistic/js/func-call-spacing': ['warn', 'never'],
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
      '@stylistic/js/lines-between-class-members': ['warn', 'always'],
      '@stylistic/js/max-len': ['warn', {
        code: 78,
        ignoreUrls: true,
        ignoreStrings: false,
        ignoreTemplateLiterals: false,
        ignoreRegExpLiterals: true,
      }],
      '@stylistic/js/max-statements-per-line': ['warn', {max: 1}],
      '@stylistic/js/multiline-ternary': 'off',
      '@stylistic/js/new-parens': 'warn',
      '@stylistic/js/newline-per-chained-call': ['warn', {
        ignoreChainWithDepth: 3,
      }],
      '@stylistic/js/no-extra-semi': 'warn',
      '@stylistic/js/no-floating-decimal': 'warn',
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
      '@stylistic/js/object-curly-newline': ['warn', {
        multiline: true,
        consistent: true,
      }],
      '@stylistic/js/object-curly-spacing': ['warn', 'never'],
      '@stylistic/js/object-property-newline': ['warn', {
        allowAllPropertiesOnSameLine: true,
      }],
      '@stylistic/js/operator-linebreak': ['warn'],
      '@stylistic/js/padded-blocks': ['warn', 'never'],
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

      // eslint-plugin-react
      'react/boolean-prop-naming': 'off',
      'react/button-has-type': 'error',
      'react/default-props-match-prop-types': 'off',
      'react/destructuring-assignment': 'off',
      'react/display-name': 'off',
      'react/forbid-component-props': 'off',
      'react/forbid-dom-props': 'off',
      'react/forbid-elements': 'off',
      'react/forbid-prop-types': 'off',
      'react/forbid-foreign-prop-types': 'off',
      'react/jsx-no-bind': ['warn', {ignoreDOMComponents: true}],
      'react/no-access-state-in-setstate': 'error',
      'react/no-array-index-key': 'off',
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
      'react/no-is-mounted': 'warn',
      'react/no-multi-comp': ['warn', {ignoreStateless: true}],
      'react/no-redundant-should-component-update': 'error',
      'react/no-render-return-value': 'warn',
      'react/no-set-state': 'off',
      'react/no-typos': 'error',
      'react/no-string-refs': 'warn',
      'react/no-this-in-sfc': 'error',
      'react/no-unescaped-entities': 'error',
      'react/no-unknown-property': 'error',
      'react/no-unused-prop-types': 'off',
      'react/no-unused-state': 'error',
      'react/no-will-update-set-state': 'error',
      'react/prefer-es6-class': 'off',
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
      'react/self-closing-comp': 'error',
      'react/sort-comp': 'off',
      'react/sort-default-props': 'warn',
      'react/sort-prop-types': 'off',
      'react/style-prop-object': 'error',
      'react/void-dom-elements-no-children': 'error',

      // JSX-specific rules
      'react/jsx-boolean-value': ['warn', 'never'],
      'react/jsx-closing-bracket-location': ['error', 'tag-aligned'],
      'react/jsx-closing-tag-location': 'error',
      'react/jsx-curly-spacing': ['error', {when: 'never', children: true}],
      'react/jsx-equals-spacing': ['error', 'never'],
      'react/jsx-filename-extension': ['error', {
        extensions: ['.js', '.mjs'],
      }],
      'react/jsx-first-prop-new-line': ['error', 'multiline-multiprop'],
      'react/jsx-handler-names': 'warn',
      'react/jsx-indent': ['error', 2],
      'react/jsx-indent-props': ['error', 2],
      'react/jsx-key': 'warn',
      'react/jsx-max-props-per-line': ['error', {
        maximum: 1,
        when: 'multiline',
      }],
      'react/jsx-no-comment-textnodes': 'warn',
      'react/jsx-no-duplicate-props': ['error', {ignoreCase: true}],
      'react/jsx-no-literals': 'warn',
      'react/jsx-no-target-blank': 'error',
      'react/jsx-no-undef': ['error', {allowGlobals: true}],
      'react/jsx-one-expression-per-line': ['warn', {allow: 'single-child'}],
      'react/jsx-curly-brace-presence': ['error', {
        props: 'never',
        children: 'ignore',
      }],
      'react/jsx-pascal-case': 'error',
      'react/jsx-sort-props': 'warn',
      'react/jsx-tag-spacing': ['error', {beforeClosing: 'never'}],
      /*
       * jsx-uses-react is not implied since
       * https://reactjs.org/blog/2020/09/22/introducing-the-new-jsx-transform.html
       */
      'react/jsx-uses-react': 'off',
      'react/jsx-uses-vars': 'warn',
      'react/jsx-wrap-multilines': ['error', {
        declaration: 'parens-new-line',
        assignment: 'parens-new-line',
        return: 'parens-new-line',
        arrow: 'parens-new-line',
        condition: 'ignore',
        logical: 'ignore',
        prop: 'ignore',
      }],

      // eslint-plugin-ft-flow
      'ft-flow/boolean-style': ['warn', 'boolean'],
      'ft-flow/delimiter-dangle': ['warn', 'always-multiline'],
      'ft-flow/generic-spacing': 'off',
      'ft-flow/no-dupe-keys': 'error',
      'ft-flow/no-flow-fix-me-comments': 'off',
      'ft-flow/no-mutable-array': 'off',
      'ft-flow/no-primitive-constructor-types': 'error',
      'ft-flow/object-type-delimiter': ['warn', 'comma'],
      'ft-flow/require-exact-type': 'off',
      'ft-flow/require-indexer-name': ['warn', 'always'],
      'ft-flow/require-parameter-type': 'off',
      'ft-flow/require-return-type': 'off',
      'ft-flow/require-valid-file-annotation': 'off',
      'ft-flow/semi': ['warn', 'always'],
      'ft-flow/sort-keys': ['warn', 'asc'],
      'ft-flow/space-after-type-colon': ['warn', 'always', {
        allowLineBreak: true,
      }],
      'ft-flow/space-before-generic-bracket': ['warn', 'never'],
      'ft-flow/space-before-type-colon': ['warn', 'never'],
      'ft-flow/union-intersection-spacing': ['warn', 'always'],

      // eslint-plugin-fb-flow
      'fb-flow/use-indexed-access-type': 'error',

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
      'root/static/scripts/relationship-editor/components/DialogPreview.js',
    ],
    rules: {
      'react/jsx-no-bind': 'off',
    },
  },
];
