import { spawn } from "node:child_process";


const niri = spawn("niri", ["msg", "--json", "event-stream"], { serialization: "json"})

type NiriEvent =
    | { WindowFocusChanged: { id: number }}
    | { WorkspaceActiveWindowChanged: { }}

class UnreachableError extends Error {
    constructor(opt: never) {
        super(`Sould not be possible ${opt}`)
    }
}

let pendingMessage = "";
niri.stdout.on("data", (data) => {
    pendingMessage += data.toString();
    handleMessage();
})

function handleMessage() {
    const newlinePosition = pendingMessage.indexOf("\n");
    if (newlinePosition !== -1) {
        const firstMessage = pendingMessage.slice(0, newlinePosition)
        pendingMessage = pendingMessage.slice(newlinePosition + 1)

        try {
            const data = JSON.parse(firstMessage);
            for (const key in data) {
                if (key in niriHandler) {
                    (niriHandler as any)[key](data[key])
                } else {
                    console.warn(`${key} is not yet implemented`)
                }
            }
        } catch(error) {
            console.error(error)
        }
        handleMessage()
    }
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

const niriHandler = {
    WorkspacesChanged(_data: WorkspacesChanged) {

    },
    WindowOpenedOrChanged(_data: WindowOpenedOrChanged) {

    },
    WindowFocusChanged(_data: WindowFocusChanged) {

    },
    WorkspaceActiveWindowChanged(_data: WorkspaceActiveWindowChanged) {

    },
    WindowsChanged(_data: WindowsChanged) {

    },
    WorkspaceActivated(_data: WorkspaceActivated) {

    },
    KeyboardLayoutsChanged(data: KeyboardLayoutsChanged) {

    },
    WindowClosed(_data: WindowClosed) {

    }
}
