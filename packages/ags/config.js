const audio = await Service.import("audio")
const battery = await Service.import("battery")

const WIDGET_SPACING = 24;

const date = Variable("", {
    poll: [1000, 'date "+%H:%M"'],
})




// widgets can be only assigned as a child in one container
// so to make a reuseable widget, make it a function
// then you can simply instantiate one by calling it

function Workspaces() {
    return Widget.Box({
        class_name: "workspaces",
        children: [],
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

    const slider = Widget.Slider({
        hexpand: true,
        draw_value: false,
        on_change: ({ value }) => audio.speaker.volume = value,
        setup: self => self.hook(audio.speaker, () => {
            self.value = audio.speaker.volume || 0
        }),
    })

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
function Left() {
    return Widget.Box({
        spacing: WIDGET_SPACING,
        children: [
            Workspaces(),
        ],
    })
}

function Center() {
    return Widget.Box({
        spacing: WIDGET_SPACING,
        children: [
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
            start_widget: Left(),
            center_widget: Center(),
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
