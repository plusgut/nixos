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

let previousBuffers: Buffer[] = []
niri.stdout.on("data", (data) => {
    previousBuffers.push(data)
    if (data.includes("\n")) {
        const currentBuffer = Buffer.concat(previousBuffers)
        previousBuffers = []
        const msg: NiriEvent = JSON.parse(currentBuffer.toString());

        if ("WindowFocusChanged" in msg) {
            console.log("focus")
        } else if("WorkspaceActiveWindowChanged" in msg) {
            console.log("active")
        } else {
            console.log("sup?")
            throw new UnreachableError(msg)
        }
    }

})
