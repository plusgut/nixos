import { spawn } from "node:child_process";

const niri = spawn("niri", ["msg", "--json", "event-stream"])

let currentEwwState: EwwState = {
    workspaces: [],
    workspace_active: null
}

let pendingMessage = "";
niri.stdout.on("data", (data) => {
    pendingMessage += data.toString();
    const newEwwState = handleMessage(currentEwwState);
    const changeEwwVariables = Object.entries(newEwwState).flatMap(([key, value]) => {
        const variableState = JSON.stringify(value)
        if (variableState !== JSON.stringify(currentEwwState[key as keyof EwwState])) {
            return [[key, variableState]]
        }
        return []
    })

    if(changeEwwVariables.length > 0) {
        try {
            spawn("eww", ["update", ...changeEwwVariables.map(([key, variable]) => `${key}=${variable}`)]).on("exit", (code) => {
                if (code === 0) {
                    currentEwwState = newEwwState
                } else {
                    console.log(`eww: ${code}`)
                }
            });
        } catch(error) {
            console.error(error);
        }
    }
})

function handleMessage(ewwState: EwwState) {
    const newlinePosition = pendingMessage.indexOf("\n");
    if (newlinePosition !== -1) {
        const firstMessage = pendingMessage.slice(0, newlinePosition)
        pendingMessage = pendingMessage.slice(newlinePosition + 1)

        try {
            const data = JSON.parse(firstMessage);
            for (const key in data) {
                if (key in niriHandler) {
                    ewwState = niriHandler[key](ewwState, data[key])
                } else {
                    console.warn(`${key} is not yet implemented`)
                }
            }
        } catch(error) {
            console.error(error)
        }
        return handleMessage(ewwState)
    }
    return ewwState
}


type WindowsChanged = { windows: Window[] };
type WindowFocusChanged = { id: number | null }
type WindowClosed = { id: number }
type KeyboardLayoutsChanged = { keyboard_layouts: { names: string[] }, current_idx: number }
type WorkspacesChanged = { workspaces: {id: number, idx: number, name: null, output: string, is_active: boolean, is_focused: boolean, active_window_id: number }[]}
type WindowOpenedOrChanged = { window: Window }
type WorkspaceActiveWindowChanged = { workspace_id: number, active_window_id: number }
type WorkspaceActivated = { id: number, focused: boolean }

type Window = { id:number, title: string, app_id: string, workspace_id: number, is_focused: boolean }

type EwwState = {
    workspaces: { id: number, name: string }[]
    workspace_active: number | null
}

const niriHandler: {[niriEvent: string]: (ewwState: EwwState, event: any) =>  EwwState} = {
    WorkspacesChanged(ewwState, data: WorkspacesChanged) {
        return {
            ...ewwState,
            workspaces: data.workspaces
                .sort((a, b) => a.idx - b.idx)
                .map(workspace => ({
                    id: workspace.id,
                    name: `${workspace.name ?? workspace.idx}`,
                    idx: workspace.idx
                })),
            workspace_active: data.workspaces.find(workspace => workspace.is_active)?.idx ?? null
        }
    },
    WindowOpenedOrChanged(ewwState, _data: WindowOpenedOrChanged) {
        return ewwState;
    },
    WindowFocusChanged(ewwState, _data: WindowFocusChanged) {
        return ewwState
    },
    WorkspaceActiveWindowChanged(ewwState, _data: WorkspaceActiveWindowChanged) {
        return ewwState
    },
    WindowsChanged(ewwState, _data: WindowsChanged) {
        return ewwState
    },
    WorkspaceActivated(ewwState, data: WorkspaceActivated) {
        return {
            ...ewwState,
            workspace_active: data.id
        }
    },
    KeyboardLayoutsChanged(ewwState, _data: KeyboardLayoutsChanged) {
        return ewwState
    },
    WindowClosed(ewwState, _data: WindowClosed) {
        return ewwState
    }
}

