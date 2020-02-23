const { parseUrl } = require('mysql/lib/ConnectionConfig');

const defaultCfg = {
  host: '127.0.0.1',
  user: 'root',
  database: 'fivem',
  supportBigNumbers: true,
  multipleStatements: true,
};


function parseConnectingString(connectionString) {
  let cfg = {};
  if (/(?:database|initial\scatalog)=(?:(.*?);|(.*))/gi.test(connectionString)) {
    // replace the old version with the new one
    const connectionStr = connectionString
      .replace(/(?:host|server|data\s?source|addr(?:ess)?)=/gi, 'host=')
      .replace(/(?:port)=/gi, 'port=')
      .replace(/(?:user\s?(?:id|name)?|uid)=/gi, 'user=')
      .replace(/(?:password|pwd)=/gi, 'password=')
      .replace(/(?:database|initial\scatalog)=/gi, 'database=');
    connectionStr.split(';').forEach((el) => {
      const equal = el.indexOf('=');
      const key = (equal > -1) ? el.substr(0, equal) : el;
      const value = (equal > -1) ? el.substr(equal + 1) : '';
      cfg[key] = value;
    });
  } else if (/mysql:\/\//gi.test(connectionString)) {
    cfg = parseUrl(connectionString);
  } else throw new Error('No valid connection string found');

  return Object.assign({}, defaultCfg, cfg);
}

module.exports = parseConnectingString;
