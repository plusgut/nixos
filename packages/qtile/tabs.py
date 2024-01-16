from libqtile import hook
from libqtile.command.base import expose_command
from libqtile.layout.base import _ClientList, Layout
from libqtile.layout.base import Layout
from libqtile.backend.base import Window
from libqtile.config import ScreenRect
from libqtile.log_utils import logger
from libqtile.group import _Group

class Tab:
    left = 0
    right = 0
    def draw(self, layout, client, left):
        return left + framed.width

class Cell(_ClientList):
    def __init__(self, root):
        _ClientList.__init__(self)
        self._root = root
        self._tab_bar = None
        self._drawer = None
        self._tabs = {}

    def finalize(self):
        if self._drawer is not None:
            self._drawer.finalize()

    def add_client(self, client: Window):
        self._tabs[client.wid] = Tab()
        hook.subscribe.client_name_updated(self.draw)
        _ClientList.add_client(self, client, 1)

    def configure(self, client: Window, screen_rect: ScreenRect):
        tab_screen_rect, client_screen_rect = screen_rect.vsplit(self._root.tab_bar_height)

        self._create_tab_bar(tab_screen_rect)
        self._tab_bar.place(
            tab_screen_rect.x,
            tab_screen_rect.y,
            tab_screen_rect.width,
            tab_screen_rect.height,
            0,
            None
        )
        self.draw()
        self._tab_bar.unhide()

        if client is self.current_client:
            client.place(
                client_screen_rect.x,
                client_screen_rect.y,
                client_screen_rect.width,
                client_screen_rect.height,
                0,
                None
            )

            client.unhide()
            self.current_client = client
        else:
            client.hide()



    def remove(self, client):
        self._tabs.pop(client.wid)
        _ClientList.remove(self, client)

    def focus_change(self):
        if self._root.group.current_window in self.clients:
            self.current_client = self._root.group.current_window

    def _create_tab_bar(self, screen_rect: ScreenRect):
        if self._tab_bar is None:
            self._tab_bar = self._root.group.qtile.core.create_internal(
                screen_rect.x, screen_rect.y, screen_rect.width, screen_rect.height,
        )
            self._tab_bar.process_button_click = self.process_button_click
        self._create_drawer(screen_rect)

    def _create_drawer(self, screen_rect):
        if self._drawer is not None and (self._drawer.height != screen_rect.height or self._drawer.width != screen_rect.width):
            self._drawer.finalize()
            self._drawer = None

        self._drawer = self._tab_bar.create_drawer(
            screen_rect.width,
            screen_rect.height,
        )
        self._drawer.clear(self._root.tab_bar_background_color)

    def draw(self, *args):
        self._drawer.clear(self._root.tab_bar_background_color)

        left = 0
        for client_index in range(len(self.clients)):
            client = self.clients[client_index]
            layout = self._drawer.textlayout(
                "", self._root.tab_active_font_color, self._root.tab_font, self._root.tab_fontsize, None,
                wrap=False
            )
            layout.colour = self._root.tab_active_font_color if self.current_index is client_index else self._root.tab_inactive_font_color 

            layout.text = client.name

            framed = layout.framed(
                border_width = 1,
                border_color = "000000", # background color
                pad_x = 0,
                pad_y = 0,
            )

            framed.draw_fill(left, 0, rounded=True)


            self._tabs[client.wid].left = left
            self._tabs[client.wid].right = left + framed.width

            left = self._tabs[client.wid].right + self._root.tab_gap

        self._drawer.draw(offsetx=0, offsety=0,width = left)


    def process_button_click(self, x, y, _button):
        pass

    def shuffle_left(self) -> bool:
        if len(self.clients) > 1 and self.current_index > 0:
            self.shuffle_up()
            self.draw()

            return True
        return False

    def shuffle_right(self) -> bool:
        if len(self.clients) > 1 and self.current_index + 1 < len(self.clients):
            self.shuffle_down()

            return True
        return False

class Row:
    def __init__(self, root):
        self._root = root
        self._clients = {}
        self.current_cell_index = None
        self.cells = []

    def finalize(self):
        for cell in self.cells:
            cell.finalize()

    def add_client(self, client: Window) -> None:
        target_cell = 0 if self.current_cell_index is None else self.current_cell_index
        self.current_cell_index = target_cell


        if len(self.cells) <= target_cell:
            self.cells.append(Cell(self._root))

        self._clients[client.wid] = target_cell
        self.cells[target_cell].add_client(client)

    def configure(self, client: Window, screen_rect):
        self._screen_rect = screen_rect
        cell_length = len(self.cells)
        cell_amount = cell_length # @TODO add weight of each cell

        for cell_index in range(len(self.cells)):
            if cell_index + 1 is cell_length:
                cell_rect = screen_rect
            else:
                (cell_rect, screen_rect) = screen_rect.hsplit(int((1 / cell_length) * screen_rect.width))

            if cell_index is self._clients[client.wid]:
                self.cells[cell_index].configure(client, cell_rect)

    def configure_all(self):
        for cell in self.cells:
            self.configure(cell.current_client, self._screen_rect)


    def remove(self, client):
        cell_index = self._clients[client.wid]
        cell = self.cells[cell_index]

        cell.remove(client)
        self._clients.pop(client.wid)

        if len(cell.clients) == 0:
            cell.finalize()
            self.cells.pop(cell_index)
            if self.current_cell_index >= cell_index:
                self.current_cell_index -= 1

            for client in self._clients:
                if client >= cell_index:
                    client -= 1

    def focus_change(self):
        if self._root.group.current_window in self._clients:
            self.current_cell_index = self._clients[self._root.group.current_window]

        for cell in self.cells:
            cell.focus_change()

    def focus_previous(self, client: Window) -> Window | None:
        result = self.cells[self._clients[client.wid]].focus_previous(client)

        return result

    def focus_next(self, client: Window) -> Window | None:
        result = self.cells[self._clients[client.wid]].focus_next(client)

        return result

    def shuffle_right(self) -> bool:
        result = self.cells[self.current_cell_index].shuffle_right()

        if result is False and self._root.is_horizontal:
            previous_cell = self.cells[self.current_cell_index]
            client = previous_cell.current_client

            self.current_cell_index = self.current_cell_index + 1

            self.add_client(client)
            previous_cell.remove(client)

            return True

        return result


    def shuffle_left(self) -> None:
        self.cells[self.current_cell_index].shuffle_left()

class Tabs(Layout):
    defaults = [
        ("primary_position", "top", "Position of the primary containers, can be either 'top', 'right', 'bottom' or 'left'"),
        ("primary_weight", 1.5, "Percentage of how the primary containers should be weighted"),
        ("window_gap", 0, "Background between windows"),
        ("tab_bar_height", 24, "Height of the tab bar"),
        ("tab_bar_background_color", "000000", "Background of the tab bar"),
        ("tab_gap", 10, "Gaps between tabs"),
        ("tab_font", "sans", "Font size of tab"),
        ("tab_fontsize", 14, "Font size of tab"),
        ("tab_active_font_color", "ff0000", "Background color of an inactive tab"),
        ("tab_active_border_color", "ff0000", "Background color of an inactive tab"),
        ("tab_active_background_color", "000000", "Background color of an inactive tab"),
        ("tab_inactive_font_color", "ffffff", "Background color of an inactive tab"),
        ("tab_inactive_border_color", "ffffff", "Background color of an inactive tab"),
        ("tab_inactive_background_color", "000000", "Background color of an inactive tab"),
    ]

    def __init__(self, **config):
        Layout.__init__(self, **config)
        self.add_defaults(Tabs.defaults)

    def setup(self):
        self._clients = {}
        self.rows = []
        self.current_row_index = None

    def show(self, screen_rect):
        hook.subscribe.focus_change(self.focus_change)

    def is_horizontal(self):
        return self.primary_position is "top" or self.primary_position is "bottom"

    def finalize(self):
        for row in self.rows:
            row.finalize()

    def add_client(self, client: Window) -> None:
        """Called whenever a window is added to the group

        Called whether the layout is current or not. The layout should just add
        the window to its internal datastructures, without mapping or
        configuring.
        """
        target_row = 0 if self.current_row_index is None else self.current_row_index
        self.current_row_index = target_row

        if len(self.rows) <= target_row:
            self.rows.append(Row(self))

        self._clients[client.wid] = target_row
        self.rows[target_row].add_client(client)

    def focus_change(self):
        if self.group.current_window in self._clients:
            self.current_row_index = self._clients[self.group.current_window]
        for row in self.rows:
            row.focus_change()

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
        row_length = len(self.rows)
        row_amount = row_length # @TODO add weight of each row

        for row_index in range(len(self.rows)):
            if row_index + 1 is row_length:
                row_rect = screen_rect
            else:
                (row_rect, screen_rect) = screen_rect.vsplit(1 / row_length)

            if self._clients[client.wid] is row_index:
                self.rows[row_index].configure(client, row_rect)

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

    def focus_next(self, client: Window) -> Window | None:
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
        client:
            The currently focused client.
        """
        return self.rows[self._clients[client.wid]].focus_next(client)

    def focus_previous(self, client: Window) -> Window | None:
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
        client:
            The currently focused client.
        """
        return self.rows[self._clients[client.wid]].focus_previous(client)
    def clone(self, group):
        clone = Layout.clone(self, group)
        Tabs.setup(clone)
        return clone

    @expose_command()
    def right(self) -> None:
        current_window = self.group.current_window
        if current_window is not None:
            result = self.focus_next(current_window)
            if result is not None:
                self.group.focus(result, True)

    @expose_command()
    def left(self) -> None:
        current_window = self.group.current_window
        if current_window is not None:
            result = self.focus_previous(current_window)
            if result is not None:
                self.group.focus(result, True)

    def next(self) -> None:
        self.right()

    def previous(self) -> None:
        pass

    @expose_command()
    def shuffle_right(self) -> None:
        if self.current_row_index is not None:
            self.rows[self.current_row_index].shuffle_right()
            self.group.layout_all()

    @expose_command()
    def shuffle_left(self) -> None:
        if self.current_row_index is not None:
            self.rows[self.current_row_index].shuffle_left()

