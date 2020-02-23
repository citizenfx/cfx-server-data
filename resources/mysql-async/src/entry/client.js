let isNuiActive = false;

function NuiMessage(msg) {
  window.SendNuiMessage(JSON.stringify(msg));
}

function NuiCallback(name, callback) {
  window.RegisterNuiCallbackType(name);
  window.on(`__cfx_nui:${name}`, (data, cb) => {
    callback(data);
    cb('ok');
  });
}

function setNuiActive(boolean = true) {
  if (boolean !== isNuiActive) {
    if (boolean) {
      window.emitNet('mysql-async:request-data');
    }
    isNuiActive = boolean;
    NuiMessage({ type: 'onToggleShow' });
    window.SetNuiFocus(boolean, boolean);
  }
}

window.RegisterCommand('mysql', () => {
  setNuiActive();
}, true);

NuiCallback('close-explorer', () => {
  setNuiActive(false);
});

window.setInterval(() => {
  if (isNuiActive) {
    window.emitNet('mysql-async:request-data');
  }
}, 300000);

window.onNet('mysql-async:update-resource-data', (resourceData) => {
  let arrayToSortAndMap = [];
  const resources = Object.keys(resourceData);
  for (let i = 0; i < resources.length; i += 1) {
    if (Object.prototype.hasOwnProperty.call(resourceData, resources[i])) {
      if (Object.prototype.hasOwnProperty.call(resourceData[resources[i]], 'totalExecutionTime')) {
        arrayToSortAndMap.push({
          resource: resources[i],
          queryTime: resourceData[resources[i]].totalExecutionTime,
          count: resourceData[resources[i]].queryCount,
        });
      }
    }
  }
  if (arrayToSortAndMap.length > 0) {
    arrayToSortAndMap.sort((a, b) => a.queryTime - b.queryTime);
    const len = arrayToSortAndMap.length;
    arrayToSortAndMap = arrayToSortAndMap.filter((_, index) => index > len - 31);
    arrayToSortAndMap.sort((a, b) => {
      const resourceA = a.resource.toLowerCase();
      const resourceB = b.resource.toLowerCase();
      let result = 0;
      if (resourceA < resourceB) {
        result = -1;
      } else if (resourceA > resourceB) {
        result = 1;
      }
      return result;
    });
    NuiMessage({
      type: 'onResourceLabels',
      resourceLabels: arrayToSortAndMap.map(el => el.resource),
    });
    NuiMessage({
      type: 'onResourceData',
      resourceData: [
        {
          data: arrayToSortAndMap.map(el => el.queryTime),
        },
        {
          data: arrayToSortAndMap.map(el => ((el.count > 0) ? el.queryTime / el.count : 0)),
        },
        {
          data: arrayToSortAndMap.map(el => el.count),
        },
      ],
    });
  }
});

window.onNet('mysql-async:update-time-data', (timeData) => {
  let timeArray = [];
  if (Array.isArray(timeData)) {
    const len = timeData.length;
    timeArray = timeData.filter((_, index) => index > len - 31);
  }
  if (timeArray.length > 0) {
    NuiMessage({
      type: 'onTimeData',
      timeData: [
        {
          data: timeArray.map(el => el.totalExecutionTime),
        },
        {
          data: timeArray.map(el => ((el.queryCount > 0) ? el.totalExecutionTime / el.queryCount
            : 0)),
        },
        {
          data: timeArray.map(el => el.queryCount),
        },
      ],
    });
  }
});

window.onNet('mysql-async:update-slow-queries', (slowQueryData) => {
  const slowQueries = slowQueryData.map((el) => {
    const element = el;
    element.queryTime = Math.round(el.queryTime * 100) / 100;
    return element;
  });
  NuiMessage({
    type: 'onSlowQueryData',
    slowQueries,
  });
});
