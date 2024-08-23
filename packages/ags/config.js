const audio = await Service.import("audio")
const battery = await Service.import("battery")

const WIDGET_SPACING = 24;

const date = Variable("", {
    poll: [1000, 'date "+%H:%M"'],
})

const workspaces = Variable([], {
    poll: [1000, ['niri', "msg", "--json", "workspaces"], JSON.parse]
});



// widgets can be only assigned as a child in one container
// so to make a reuseable widget, make it a function
// then you can simply instantiate one by calling it

function WorkspaceNames() {
    return Widget.Box({
        class_name: "workspace_names",
        vertical: true,
        children: workspaces.bind().as(workspaces =>
            workspaces.map(workspace =>
                Widget.Label({
                    label: workspace.name ?? workspace.idx.toString()
                })
            )
        ),
    })
}


function WorkspaceWindows() {
    return Widget.Box({
        class_name: "workspace_windows",
        vertical: true,
        children: workspaces.bind().as(workspaces =>
            workspaces.map((workspace, _index) =>
                Widget.Button({
                    "on-clicked": () => Utils.execAsync(["niri", "msg", "action", "focus-workspace", workspace.name ?? workspace.idx.toString()]),
                    class_name: workspace.is_active ? "focused" : "",
                    child: Widget.Label({
                        label: workspace.name ?? workspace.idx.toString()
                    })
                })
            )
        ),
    })
}
function Clock() {
    return Widget.Label({
        class_name: "clock",
        label: date.bind(),
    })
}

function Volume() {
    const icons = {
        101: "o",
        67: "",
        34: "",
        1: "",
        0: "",
    }

    function getIcon() {
        const icon = audio.speaker.is_muted ? 0 : [101, 67, 34, 1, 0].find(
            threshold => threshold <= audio.speaker.volume * 100)

        return `${audio.speaker.is_muted ? "01" : audio.speaker.volume}% ${icons[icon]}`;
    }

    return Widget.Box({
        class_name: "volume",
        children: [
            Widget.Label({
                css: "font-family: FontAwesome, sans-serif",
                label: getIcon()
            })
        ],
    })
}


function BatteryLabel() {
    const value = battery.bind("percent").as(p => p > 0 ? p / 100 : 0)
    const icon = battery.bind("percent").as(p =>
        `battery-level-${Math.floor(p / 10) * 10}-symbolic`)

    return Widget.Box({
        class_name: "battery",
        visible: battery.bind("available"),
        children: [
            Widget.Icon({ icon: "go-home" }),
            Widget.LevelBar({
                widthRequest: 140,
                vpack: "center",
                value,
            }),
        ],
    })
}

// layout of the bar
function Left(monitor) {
    return Widget.Box({
        spacing: WIDGET_SPACING,
        children: [
            WorkspaceNames(monitor),
        ],
    })
}

function Center(monitor) {
    return Widget.Box({
        spacing: WIDGET_SPACING,
        children: [
            WorkspaceWindows(monitor),
        ],
    })
}

function Right() {
    return Widget.Box({
        hpack: "end",
        spacing: WIDGET_SPACING,
        children: [
            Volume(),
            BatteryLabel(),
            Clock(),
        ],
    })
}

function Bar(monitor = 0) {
    return Widget.Window({
        name: `bar-${monitor}`, // name has to be unique
        class_name: "bar",
        monitor,
        anchor: ["top", "left", "right"],
        exclusivity: "exclusive",
        child: Widget.CenterBox({
            start_widget: Left(monitor),
            center_widget: Center(monitor),
            end_widget: Right(),
        }),
    })
}

App.config({
    style: "./style.css",
    windows: [
        Bar(),

        // you can call it, for each monitor
        // Bar(0),
        // Bar(1)
    ],
})

export { }
