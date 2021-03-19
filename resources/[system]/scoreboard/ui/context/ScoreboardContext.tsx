import { useContext, createContext, useState } from 'react';
import { useNuiEvent } from "../utils/useNuiEvent";
import { Columns } from "../types/columns";

export const ScoreboardContext = createContext<Context | undefined>(undefined);

export const ScoreboardProvider = ({ children }: { children: React.ReactNode }) => {
	const [visibility, setVisibility] = useState<boolean>(false);
	const [columns, setColumns] = useState(null);
	const [players, setPlayers] = useState(null);

	const removeThemes = () => {
		for (let i = 0; i < document.styleSheets.length; i++) {
			const styleSheet = document.styleSheets[i];
			const node = styleSheet.ownerNode as Element;

			if (node.getAttribute("data-theme")) {
				node.parentNode?.removeChild(node);
			}
		}
	}

	const addThemes = (themes: any[]) => {
		removeThemes();
		for (const [id, data] of Object.entries(themes)) {
			if (data.styleSheet) {
				const link = document.createElement("link");
				link.rel = "stylesheet";
				link.type = "text/css";
				link.href = data.baseUrl + data.styleSheet;
				link.setAttribute("data-theme", id);
				console.log(data.baseUrl + data.styleSheet);
				document.head.appendChild(link);
			}
		}
	}

	useNuiEvent('CfxScoreboard', 'setVisibility', setVisibility);
	useNuiEvent('CfxScoreboard', 'setPlayers', setPlayers);
	useNuiEvent('CfxScoreboard', 'setColumns', setColumns);
	useNuiEvent('CfxScoreboard', 'updateThemes', addThemes);

	const value = {
		visibility,
		setVisibility,
		columns,
		setColumns,
		players,
		setPlayers
	}

	return <ScoreboardContext.Provider value={value}>{children}</ScoreboardContext.Provider>
}

interface Context {
	visibility: boolean;
	setVisibility: (show: boolean) => void;
	columns: Columns[];
	setColumns: (columns: any[]) => void;
	players: any[];
	setPlayers: (players: any) => void;
}

export const useScoreboard = () => {
	const { visibility, setVisibility } = useContext(ScoreboardContext);
	return { visibility, setVisibility };
}

export const useColumns = () => {
	const { columns, setColumns } = useContext(ScoreboardContext);
	return { columns, setColumns };
}

export const usePlayers = () => {
	const { players, setPlayers } = useContext(ScoreboardContext);
	return { players, setPlayers }
}
