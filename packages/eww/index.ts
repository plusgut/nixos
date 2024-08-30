import { connect } from "node:net";

const socket = connect(process.env.NIRI_SOCKET as string, () => {
    console.log("socket!")
})

socket.addListener("data", (msg) => {
    console.log(msg)
})
