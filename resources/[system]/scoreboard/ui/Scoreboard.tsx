import { useColumns, usePlayers } from "./context/ScoreboardContext"

export default function Scoreboard() {
	const { columns } = useColumns();
	const { players } = usePlayers()

	if (!columns || !players) return null;

	return (
		<div className="scoreboard">
			<table className="content-table">
				<thead>
					<tr>
						{columns.map((column) => (
							<th key={column?.position}>{column?.friendlyName}</th>
						))}
					</tr>
				</thead>
				<tbody>
					{players.map((player: any[]) => (
						<tr>
							{player.map((data: any) => (
								<td>{data}</td>
							))}
						</tr>
					))}
				</tbody>
			</table>
		</div>
	)
}
