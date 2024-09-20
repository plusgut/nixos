import { spawn } from "node:child_process";

const NAMESPACE = "org.gnome.Mutter.ScreenCast"
const busctltree = spawn("busctl", ["--user", "tree", "--list", NAMESPACE]);

let hasScreenCast = false;

busctltree.stdout.on("data", (data) => {
    hasScreenCast = data.toString().split("\n").some((data: string) =>
        data.startsWith(`/${NAMESPACE.replaceAll(".", "/")}/Stream/`)
    )
})

busctltree.on("exit", (_code) => {
    console.log(hasScreenCast)

    let pendingMessage = ""

    const busctlmonitor = spawn("busctl", ["--user", "monitor", "--json=short", NAMESPACE])
    busctlmonitor.stdout.on("data", (data) => {
        pendingMessage += data;
        handleMessage()
    })
    function handleMessage() {
        const newlinePosition = pendingMessage.indexOf("\n");
        if (newlinePosition !== -1) {
            const firstMessage = pendingMessage.slice(0, newlinePosition)
            pendingMessage = pendingMessage.slice(newlinePosition + 1)
            try {
                const parsedData = JSON.parse(firstMessage)
                if (parsedData.member === "Start" && hasScreenCast === false) {
                    hasScreenCast = true;
                    console.log(hasScreenCast)
                } else if (parsedData.member === "Stop" && hasScreenCast === true) {
                    hasScreenCast = false;
                    console.log(hasScreenCast)
                }
            } catch (error) {
                console.error(error)
            }
            handleMessage()
        }
    }

    busctlmonitor.on("exit", (code) => {
        console.log(code)
    })
})
