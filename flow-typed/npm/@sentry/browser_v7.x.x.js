// @flow strict

declare module '@sentry/browser' {
    declare export function captureException(
        message: mixed,
        severity?: Severity,
    ): void;

    declare export class Scope {
        setExtra(key: string, extra: any): void;
    }

    declare export function setTag(key: string, value: string): void;
    declare export function setTags(tags: {| [key: string]: string |}): void;
    declare export function setUser(user: User | null): void;
    declare export function withScope(callback: (scope: Scope) => void): void;

    declare export function init(Options): void;

    declare export type Severity =
        | 'fatal'
        | 'error'
        | 'warning'
        | 'log'
        | 'info'
        | 'debug';

    declare export type User = {
        [key: string]: mixed,
        // At least one of these must be present, but there's no way to represent that in Flow without
        // enumerating every possible combination.
        +id?: string | number,
        +username?: string,
        +email?: string,
        +ip_address?: string,
        ...
    };

    declare export type Options = {|
        +dsn?: string,
        +release?: string,
        +environment?: string,
        +denyUrls?: $ReadOnlyArray<string | RegExp>,
        +allowUrls?: $ReadOnlyArray<string | RegExp>,
    |};
}
