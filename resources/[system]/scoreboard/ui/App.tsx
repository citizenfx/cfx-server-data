import React from 'react';
import Scoreboard from "./Scoreboard";
import { useScoreboard } from "./context/ScoreboardContext";
import { useNuiService } from "./utils/useNuiService";

function App() {
  useNuiService();
  const { visibility } = useScoreboard();

  /*
  setTimeout(() => {
    window.dispatchEvent(
      new MessageEvent('message', {
        data: {
          app: 'CfxScoreboard',
          method: 'setVisibility',
          data: true
        }
      })
    )
  }, 1000)

  setTimeout(() => {
    window.dispatchEvent(
      new MessageEvent('message', {
        data: {
          app: 'CfxScoreboard',
          method: 'setColumns',
          data: [
            {
              friendlyName: "ID",
              defaultValue: 1,
              position: 0
            },
            {
              friendlyName: "Name",
              defaultValue: "",
              position: 1
            },
          ]
        }
      })
    )
  }, 1000)

  setTimeout(() => {
    window.dispatchEvent(
      new MessageEvent('message', {
        data: {
          app: 'CfxScoreboard',
          method: 'setPlayers',
          data: [
            [
              1,
              "Chip"
            ],
            [
              2,
              "Neco"
            ]
          ]
        }
      })
    )
  }, 1000)
  */

  return (
    <div className="scoreboardWrapper">
      {visibility ? <Scoreboard /> : null}
    </div>
  );
}

export default App;
