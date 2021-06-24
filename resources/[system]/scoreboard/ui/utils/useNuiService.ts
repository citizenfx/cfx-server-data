
import { useEffect } from 'react';
import { eventNameFactory } from './tools/nuiUtils';

interface IOptions {
    capture?: boolean;
    passive?: boolean;
    once?: boolean;
}

export const useNuiService = (options: IOptions = {}) => {
    const { capture, passive, once } = options;
    const eventListener = (event: any) => {
        const { app, method, data } = event.data;
        if (app && method && data !== undefined) {
            window.dispatchEvent(
                new MessageEvent(eventNameFactory(app, method), {
                    data,
                }),
            );
        }
    };
    useEffect(() => {
        const opts = { capture, passive, once };
        window.addEventListener('message', eventListener, opts);
        return () => window.removeEventListener('message', eventListener, opts);
    }, [capture, passive, once]);
};