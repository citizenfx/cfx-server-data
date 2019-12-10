const protobuf = require("@citizenfx/protobufjs");

const playerDatas = {};
let slotsUsed = 0;

function assignSlotId() {
	for (let i = 0; i < 32; i++) {
		if (!(slotsUsed & (1 << i))) {
			slotsUsed |= (1 << i);
			return i;
		}
	}
	
	return -1;
}

let hostIndex = -1;

protobuf.load(GetResourcePath(GetCurrentResourceName()) + "/rline.proto", function(err, root) {
	if (err) {
		console.log(err);
		return;
	}
	
	const RpcMessage = root.lookupType("rline.RpcMessage");
	const RpcResponseMessage = root.lookupType("rline.RpcResponseMessage");
	const InitSessionResponse = root.lookupType("rline.InitSessionResponse");
	const InitPlayer2_Parameters = root.lookupType("rline.InitPlayer2_Parameters");
	const InitPlayerResult = root.lookupType("rline.InitPlayerResult");
	const GetRestrictionsResult = root.lookupType("rline.GetRestrictionsResult");
	const QueueForSession_Seamless_Parameters = root.lookupType("rline.QueueForSession_Seamless_Parameters");
	const QueueForSessionResult = root.lookupType("rline.QueueForSessionResult");
	const QueueEntered_Parameters = root.lookupType("rline.QueueEntered_Parameters");
	const scmds_Parameters = root.lookupType("rline.scmds_Parameters");

	function toArrayBuffer(buf) {
		var ab = new ArrayBuffer(buf.length);
		var view = new Uint8Array(ab);
		for (var i = 0; i < buf.length; ++i) {
			view[i] = buf[i];
		}
		return ab;
	}

	function emitMsg(target, data) {
		emitNet('__cfx_internal:pbRlScSession', target, toArrayBuffer(data));
	}

	function emitSessionCmds(target, cmd, cmdname, msg) {
		const stuff = {};
		stuff[cmdname] = msg;
	
		emitMsg(target, RpcMessage.encode({
			Header: {
				MethodName: 'scmds'
			},
			Content: scmds_Parameters.encode({
				sid: {
					value: {
						a: 2,
						b: 2
					}
				},
				ncmds: 1,
				cmds: [
					{
						cmd,
						cmdname,
						...stuff
					}
				]
			}).finish()
		}).finish());
	}

	function emitAddPlayer(target, msg) {
		emitSessionCmds(target, 2, 'AddPlayer', msg);
	}
	
	function emitRemovePlayer(target, msg) {
		emitSessionCmds(target, 3, 'RemovePlayer', msg);
	}
	
	function emitHostChanged(target, msg) {
		emitSessionCmds(target, 5, 'HostChanged', msg);
	}
	
	onNet('playerDropped', () => {
		try {
			const oData = playerDatas[source];
			delete playerDatas[source];

			if (oData && hostIndex === oData.slot) {
				const pda = Object.entries(playerDatas);
				
				if (pda.length > 0) {
					hostIndex = pda[0][1].slot | 0; // TODO: actually use <=31 slot index *and* check for id
					
					for (const [ id, data ] of Object.entries(playerDatas)) {
						emitHostChanged(id, {
							index: hostIndex
						});
					}
				} else {
					hostIndex = -1;
				}
			}
			
			if (!oData) {
				return;
			}
			
			if (oData.slot > -1) {
				slotsUsed &= ~(1 << oData.slot);
			}
		
			for (const [ id, data ] of Object.entries(playerDatas)) {
				emitRemovePlayer(id, {
					id: oData.id
				});
			}
		} catch (e) {
			console.log(e);
			console.log(e.stack);
		}
	});
	
	function makeResponse(type, data) {
		return {
			Header: {
			},
			Container: {
				Content: type.encode(data).finish()
			}
		};
	}

	const handlers = {
		async InitSession(source, data) {
			return makeResponse(InitSessionResponse, {
				sesid: Buffer.alloc(16),
				/*token: {
					tkn: 'ACSTOKEN token="meow",signature="meow"'
				}*/
			});
		},
		
		async InitPlayer2(source, data) {
			const req = InitPlayer2_Parameters.decode(data);
			
			playerDatas[source] = {
				gh: req.gh,
				peerAddress: req.peerAddress,
				discriminator: req.discriminator,
				slot: -1
			};
			
			return makeResponse(InitPlayerResult, {
				code: 0
			});
		},
		
		async GetRestrictions(source, data) {
			return makeResponse(GetRestrictionsResult, {
				data: {
				
				}
			});
		},
		
		async ConfirmSessionEntered(source, data) {
			return {};
		},
		
		async QueueForSession_Seamless(source, data) {
			const req = QueueForSession_Seamless_Parameters.decode(data);
			
			playerDatas[source].req = req.requestId;
			playerDatas[source].id = req.requestId.requestor;
			playerDatas[source].slot = assignSlotId();
			
			setTimeout(() => {
				emitMsg(source, RpcMessage.encode({
					Header: {
						MethodName: 'QueueEntered'
					},
					Content: QueueEntered_Parameters.encode({
						queueGroup: 69,
						requestId: req.requestId,
						optionFlags: req.optionFlags
					}).finish()
				}).finish());
				
				if (hostIndex === -1) {
					hostIndex = playerDatas[source].slot | 0;
				}
				
				emitSessionCmds(source, 0, 'EnterSession', {
					index: playerDatas[source].slot | 0,
					hindex: hostIndex,
					sessionFlags: 0,
					mode: 0,
					size: Object.entries(playerDatas).filter(a => a[1].id).length,
					//size: 2,
					//size: Object.entries(playerDatas).length,
					teamIndex: 0,
					transitionId: {
						value: {
							a: 0,//2,
							b: 0
						}
					},
					sessionManagerType: 0,
					slotCount: 32
				});
				
				setTimeout(() => {
					// tell player about everyone, and everyone about player
					const meData = playerDatas[source];
					
					const aboutMe = {
						id: meData.id,
						gh: meData.gh,
						addr: meData.peerAddress,
						index: playerDatas[source].slot | 0
					};
					
					for (const [ id, data ] of Object.entries(playerDatas)) {
						if (id == source || !data.id) continue;
					
						emitAddPlayer(source, {
							id: data.id,
							gh: data.gh,
							addr: data.peerAddress,
							index: data.slot | 0
						});
						
						emitAddPlayer(id, aboutMe);
					}
				}, 150);
			}, 50);
			
			return makeResponse(QueueForSessionResult, {
				code: 1
			});
		},
	};

	async function handleMessage(source, method, data) {
		if (handlers[method]) {
			return await handlers[method](source, data);
		}

		return {};
	}
	
	onNet('__cfx_internal:pbRlScSession', async (data) => {
		const s = source;
		
		try {
			const message = RpcMessage.decode(new Uint8Array(data));
			const response = await handleMessage(s, message.Header.MethodName, message.Content);
			
			if (!response || !response.Header) {
				return;
			}
			
			response.Header.RequestId = message.Header.RequestId;
			
			emitMsg(s, RpcResponseMessage.encode(response).finish());
		} catch (e) {
			console.log(e);
			console.log(e.stack);
		}
	});
});