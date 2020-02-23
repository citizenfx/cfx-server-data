const mysql = require('mysql');

function safeInvoke(callback, args) {
  if (typeof callback === 'function') {
    setImmediate(() => {
      callback(args);
    });
  }
}

function mysqlEscape(parameters, text, key) {
  let result = text;
  if (Object.prototype.hasOwnProperty.call(parameters, key)) {
    result = mysql.escape(parameters[key]);
  } else if (Object.prototype.hasOwnProperty.call(parameters, text)) {
    result = mysql.escape(parameters[text]);
  }
  return result;
}

function prepareQuery(query, parameters) {
  let sql = query;
  if (parameters !== null && typeof parameters === 'object') {
    sql = query.replace(/@(\w+)/g, (txt, key) => mysqlEscape(parameters, txt, key));
  }
  return sql;
}

function typeCast(field, next) {
  let dateString = '';
  switch (field.type) {
    case 'DATETIME':
    case 'DATETIME2':
    case 'TIMESTAMP':
    case 'TIMESTAMP2':
    case 'NEWDATE':
    case 'DATE':
      dateString = field.string();
      if (field.type === 'DATE') dateString += ' 00:00:00';
      return (new Date(dateString)).getTime();
    case 'TINY':
      if (field.length === 1) {
        return (field.string() !== '0');
      }
      return next();
    case 'BIT':
      return Number(field.buffer()[0]);
    default:
      return next();
  }
}

function prepareTransactionLegacyQuery(querys) {
  const sqls = querys;
  sqls.forEach((element, index) => {
    const query = prepareQuery(element.query, element.parameters);
    sqls[index] = query;
  });
  return sqls;
}

function sanitizeTransactionInput(querys, params, callback) {
  let sqls = [];
  let cb = callback;
  // if every query is a string we are dealing with syntax type a
  if (!querys.every(element => typeof element === 'string')) sqls = querys;
  else {
    const values = (typeof params === 'function') ? [] : params;
    querys.forEach((element) => {
      sqls.push({ query: element, parameters: values });
    });
  }
  if (typeof params === 'function') cb = params;
  sqls = prepareTransactionLegacyQuery(sqls);
  return [sqls, cb];
}

module.exports = {
  safeInvoke, prepareQuery, typeCast, sanitizeTransactionInput,
};
