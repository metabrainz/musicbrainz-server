// @flow strict

declare module '@sentry/browser' {
    declare export function captureException(
        message: unknown,
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
        [key: string]: unknown,
        // At least one of these must be present, but there's no way to represent that in Flow without
        // enumerating every possible combination.
        readonly id?: string | number,
        readonly username?: string,
        readonly email?: string,
        readonly ip_address?: string,
        ...
    };

    declare export type Options = {|
        readonly dsn?: string,
        readonly release?: string,
        readonly environment?: string,
        readonly denyUrls?: ReadonlyArray<string | RegExp>,
        readonly allowUrls?: ReadonlyArray<string | RegExp>,
    |};
}
