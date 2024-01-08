from libqtile import hook
from libqtile.command.base import expose_command
from libqtile.layout.base import _ClientList, Layout
from libqtile.layout.base import Layout
from libqtile.backend.base import Window
from libqtile.config import ScreenRect
from libqtile.log_utils import logger
from libqtile.group import _Group

tab_bar_height = 24
tab_bar_background = "ff0000"

class Tab:
    def draw(self, cell, client, left):
        if not cell._root.group.screen:
            return

        cell.layout.text = client.name
        cell.layout.colour = "0000ff"

        cell.layout.width = 100
        framed = cell.layout.framed(
            border_width = 1,
            border_color = "ffffff",
            pad_x = 0,
            pad_y = 0,
        )

        framed.draw_fill(left, 0, rounded=True)

        return left + framed.width

class Cell(_ClientList):
    _root = None
    weight: int
    _tab_bar = None
    _drawer = None
    _tabs = {}
    layout = None

    def __init__(self, root):
        _ClientList.__init__(self)
        self._root = root

    def finalize(self):
        if self._drawer is not None:
            self._drawer.finalize()

    def add_client(self, client: Window):
        self._tabs[client] = Tab()
        _ClientList.add_client(self, client)

    def configure(self, client: Window, screen_rect: ScreenRect):
        tab_screen_rect, client_screen_rect = screen_rect.vsplit(tab_bar_height)

        if self._tab_bar is None:
            self._create_tab_bar(tab_screen_rect)

        for loopedClient in self.clients:
            if loopedClient is client:
                hook.subscribe.client_name_updated(self.draw)
                hook.subscribe.focus_change(self.draw)

                if client is self.clients[self.current_index]:
                    client.place(
                        client_screen_rect.x,
                        client_screen_rect.y,
                        client_screen_rect.width,
                        client_screen_rect.height,
                        0,
                        None
                    )
                    client.unhide()
                else:
                  client.hide()
        self.draw()
        self._tab_bar.place(
                        tab_screen_rect.x,
                        tab_screen_rect.y,
                        tab_screen_rect.width,
                        tab_screen_rect.height,
                        0,
                        None
        )
        self._tab_bar.unhide()

    def _create_tab_bar(self, screen_rect: ScreenRect):
        self._tab_bar = self._root.group.qtile.core.create_internal(
            screen_rect.x, screen_rect.y, screen_rect.width, screen_rect.height,
        )
        self._create_drawer(screen_rect)

    def _create_drawer(self, screen_rect):
        self._drawer = self._tab_bar.create_drawer(
            screen_rect.width,
            screen_rect.height,
        )
        self._drawer.clear(tab_bar_background)
        self.layout = self._drawer.textlayout(
            "", "#ff00ff", "sans", "14", None,
            wrap=False
        )

    def draw(self, *args):
        self._drawer.clear(tab_bar_background)

        left = 0
        for client in self.clients:
            left = self._tabs[client].draw(self, client, left)

        self._drawer.draw(offsetx=0, offsety=0,width = left)


class Row:
    weight: int | None
    _root = None

    current_cell_index = 0
    cells = [];

    def __init__(self, root):
        self._root = root

    def finalize(self):
        for cell in self.cells:
          cell.finalize()

    def add_client(self, client: Window) -> None:
        if self.current_cell is None:
            self.cells.append(Cell(self._root))

        self.current_cell.add_client(client)

    @property
    def current_cell(self) -> Window | None:
        if len(self.cells) <= self.current_cell_index:
            return None

        return self.cells[self.current_cell_index]

    def configure(self, client: Window, screen_rects):
        for (cell, screen_rect) in zip(self.cells, screen_rects):
            cell.configure(client, screen_rect)

class Tabs(Layout):
    defaults = [
    ]
    rows  = []

    current_row_index = 0

    def __init__(self, **config):
        Layout.__init__(self, **config)
        self.add_defaults(Tabs.defaults)

    def finalize(self):
        for row in self.rows:
            row.finalize()

    def add_client(self, client: Window) -> None:
        """Called whenever a window is added to the group

        Called whether the layout is current or not. The layout should just add
        the window to its internal datastructures, without mapping or
        configuring.
        """
        if self.current_row is None:
            self.rows.append(Row(self))

        self.current_row.add_client(client)

    def remove(self, client: Window) -> Window | None:
        """Called whenever a window is removed from the group

        Called whether the layout is current or not. The layout should just
        de-register the window from its data structures, without unmapping the
        window.

        Returns the "next" window that should gain focus or None.
        """
        pass

    def configure(self, client: Window, screen_rect: ScreenRect) -> None:
        """Configure the layout

        This method should:

            - Configure the dimensions and borders of a window using the
              `.place()` method.
            - Call either `.hide()` or `.unhide()` on the window.
        """

        cell_rects = self.calculate_rects(screen_rect)

        for row_index in range(len(self.rows)):
            self.rows[row_index].configure(client, cell_rects[row_index])

    def focus_first(self) -> Window | None:
        """Called when the first client in Layout shall be focused.

        This method should:
            - Return the first client in Layout, if any.
            - Not focus the client itself, this is done by caller.
        """
        pass

    def focus_last(self) -> Window | None:
        """Called when the last client in Layout shall be focused.

        This method should:
            - Return the last client in Layout, if any.
            - Not focus the client itself, this is done by caller.
        """
        pass

    def focus_next(self, win: Window) -> Window | None:
        """Called when the next client in Layout shall be focused.

        This method should:
            - Return the next client in Layout, if any.
            - Return None if the next client would be the first client.
            - Not focus the client itself, this is done by caller.

        Do not implement a full cycle here, because the Groups cycling relies
        on returning None here if the end of Layout is hit,
        such that Floating clients are included in cycle.

        Parameters
        ==========
        win:
            The currently focused client.
        """
        pass

    def focus_previous(self, win: Window) -> Window | None:
        """Called when the previous client in Layout shall be focused.

        This method should:
            - Return the previous client in Layout, if any.
            - Return None if the previous client would be the last client.
            - Not focus the client itself, this is done by caller.

        Do not implement a full cycle here, because the Groups cycling relies
        on returning None here if the end of Layout is hit,
        such that Floating clients are included in cycle.

        Parameters
        ==========
        win:
            The currently focused client.
        """
        pass

    def next(self) -> None:
        pass

    def previous(self) -> None:
        pass

    def calculate_rects(self, screen_rect: ScreenRect):
        row_amount = len(self.rows)

        rects = []
        y = screen_rect.y

        for row in self.rows:
            cells = []
            row_height = int(screen_rect.height / row_amount)
            x = screen_rect.x
            cell_amount = len(row.cells)

            for cell in row.cells:
                cell_width = int(screen_rect.width / cell_amount)
                cells.append(ScreenRect(x, y, cell_width, row_height))
                x = x + cell_width

            rects.append(cells)

            y = y + row_height


        return rects

    @property
    def current_row(self) -> Window | None:
        if len(self.rows) <= self.current_row_index:
            return None

        return self.rows[self.current_row_index]
