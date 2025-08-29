import {register} from 'node:module';

await register(new URL('./hooks.mjs', import.meta.url));
