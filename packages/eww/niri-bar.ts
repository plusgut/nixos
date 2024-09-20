import { spawn } from "node:child_process";

const niri = spawn("niri", ["msg", "--json", "event-stream"])

let pendingMessage = "";
niri.stdout.on("data", (data) => {
    pendingMessage += data.toString();
    const newEwwState = handleMessage({});
    const changeEwwVariables = Object.entries(newEwwState).flatMap(([key, value]) => {
        const variableState = JSON.stringify(value)
        if (variableState !== currentEwwState[key as keyof EwwState]) {
            return [[key, variableState]]
        }
        return []
    })

    if (changeEwwVariables.length > 0) {
        try {
            spawn("eww", ["update", ...changeEwwVariables.map(([key, variable]) => `${key}=${variable}`)]).on("exit", (code) => {
                if (code === 0) {
                    currentEwwState = {
                        ...currentEwwState,
                        ...Object.fromEntries(changeEwwVariables)
                    }
                } else {
                    console.log(`eww: ${code}`)
                }
            });
        } catch(error) {
            console.error(error);
        }
    }
})

function handleMessage(ewwState: Partial<EwwState>) {
    const newlinePosition = pendingMessage.indexOf("\n");
    if (newlinePosition !== -1) {
        const firstMessage = pendingMessage.slice(0, newlinePosition)
        pendingMessage = pendingMessage.slice(newlinePosition + 1)

        try {
            const data = JSON.parse(firstMessage);
            for (const key in data) {
                if (key in niriHandler) {
                    ewwState = {
                        ...ewwState,
                        ...niriHandler[key](data[key])
                    }
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

let currentEwwState: {[ewwVariable in keyof EwwState]: string} = {
    workspaces: JSON.stringify([]),
    workspace_active: JSON.stringify(null)
}

let workspaces: WorkspacesChanged["workspaces"] = [];
function filterWorkspaces(activeWorkspace: number | null) {
    return workspaces.sort((a, b) => a.idx - b.idx)
        .filter(workspace => workspace.active_window_id !== null || workspace.id === activeWorkspace)
        .map(workspace => ({
            id: workspace.id,
            name: `${workspace.name ?? workspace.idx}`,
            idx: workspace.idx
        })) 
}

const niriHandler: {[niriEvent: string]: (event: any) => Partial<EwwState>} = {
    WorkspacesChanged(data: WorkspacesChanged) {
        workspaces = data.workspaces
        const activeWorkspace = data.workspaces.find(workspace => workspace.is_active)?.id ?? null

        return {
            workspaces: filterWorkspaces(activeWorkspace),
            workspace_active: activeWorkspace
        }
    },
    WindowOpenedOrChanged(_data: WindowOpenedOrChanged) {
        return {};
    },
    WindowFocusChanged(_data: WindowFocusChanged) {
        return {}
    },
    WorkspaceActiveWindowChanged(_data: WorkspaceActiveWindowChanged) {
        return {}
    },
    WindowsChanged(_data: WindowsChanged) {
        return {}
    },
    WorkspaceActivated(data: WorkspaceActivated) {
        return {
            workspace_active: data.id,
            workspaces: filterWorkspaces(data.id)
        }
    },
    KeyboardLayoutsChanged(_data: KeyboardLayoutsChanged) {
        return {}
    },
    WindowClosed(_data: WindowClosed) {
        return {}
    }
}

