export const eventNameFactory = (app: any, method: any) => `${app}:${method}`;
export const eventNameMethod = (name: any) => name.split(':')[1] || null;