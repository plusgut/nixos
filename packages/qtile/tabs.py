from libqtile import hook
from libqtile.command.base import expose_command
from libqtile.layout.base import _ClientList, Layout
from libqtile.layout.base import Layout
from libqtile.log_utils import logger
from libqtile.backend.base import Window
from libqtile.config import ScreenRect

class Cell(_ClientList):
    weight: int
    def __init__(self):
        _ClientList.__init__(self)

class Row:
    weight: int | None

    current_cell_index = 0
    cells = [];

    def __init__(self):
        pass

    def add_client(self, client: Window) -> None:
        if self.current_cell is None:
            self.cells.append(Cell())

        self.current_cell.add_client(client)

    @property
    def current_cell(self) -> Window | None:
        if len(self.cells) <= self.current_cell_index:
            return None

        return self.cells[self.current_cell_index]

class Tabs(Layout):
    defaults = [
    ]
    rows  = []

    current_row_index = 0

    def __init__(self, **config):
        Layout.__init__(self, **config)
        self.add_defaults(Tabs.defaults)

    def add_client(self, client: Window) -> None:
        """Called whenever a window is added to the group

        Called whether the layout is current or not. The layout should just add
        the window to its internal datastructures, without mapping or
        configuring.
        """
        if self.current_row is None:
            self.rows.append(Row())

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

        screen_rects = self.calculate_rects(screen_rect)
        if self.current_row is not None and self.current_row.current_cell is not None and client is self.current_row.current_cell.current_client:
            client.place(
                screen_rect.x, screen_rect.y, screen_rect.width, screen_rect.height, 0, None
            )
            client.unhide()
        else:
            client.hide()

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
            row_height = (screen_rect.height - screen_rect.y) / row_amount
            x = screen_rect.x
            cell_amount = len(row.cells)

            for cell in row.cells:
                cell_width = (screen_rect.width - screen_rect.x) / cell_amount
                cells.append(ScreenRect(x, y, row_height, cell_width))
                x = x + cell_width

            rects.append(cells)

            y = y + row_height

        return rects

    @property
    def current_row(self) -> Window | None:
        if len(self.rows) <= self.current_row_index:
            return None

        return self.rows[self.current_row_index]
