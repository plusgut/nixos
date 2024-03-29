from libqtile import hook
from libqtile.command.base import expose_command
from libqtile.layout.base import _ClientList, Layout
from libqtile.backend.base import Window
from libqtile.config import ScreenRect
from libqtile.log_utils import logger
from libqtile.images import Img
from xdg.IconTheme import getIconPath

LEFT_CLICK = 1
MIDDLE_CLICK = 2
RIGHT_CLICK = 3
SCROLL_UP = 4
SCROLL_DOWN = 5
SCROLL_LEFT = 6
SCROLL_RIGHT = 7


def shrink_rect(screen_rect: ScreenRect, top: int, right: int, bottom: int, left: int) -> ScreenRect:
    return ScreenRect(
        x = screen_rect.x + left,
        y = screen_rect.y + top,
        width = screen_rect.width - left - right,
        height = screen_rect.height - top - bottom,
    )

class Tab:
    def __init__(self, root, drawer, client):
        self._drawer = drawer
        self._client = client
        self._root = root
        self._left = 0
        self._right = 0
        self._icon_surface = self._get_icon()

    def get_title(self):
        return self._client.name

    def _get_icon(self):
        for window_class in self._client.get_wm_class():
            for app in set([window_class, window_class.lower()]):
                icon = getIconPath(app, size=self._root.tab_icon_size, theme=None)
                if icon is not None:
                    img = Img.from_path(icon)
                    img.resize(self._root.tab_icon_size)
                    return img.pattern
                else:
                    continue
            break

        return None


    def draw(self, left, client_index, client_amount, active, focus) -> int:
        self._left = left
        left = self._draw_icon(self._left)
        self._right = self._draw_text(
          left = left,
          client_index = client_index,
          client_amount = client_amount,
          active = active,
          focus = focus
        )

        return self._right

    def _draw_icon(self, left) -> int:
        if self._icon_surface:
            self._drawer.ctx.save()
            self._drawer.ctx.translate(left, 0)
            self._drawer.ctx.set_source(self._icon_surface)
            self._drawer.ctx.paint()
            self._drawer.ctx.restore()

            return left + self._root.tab_icon_size + 4

        else:
            return left

    def _draw_text(self, left, client_index, focus, client_amount, active):
        if self._root.group.current_window is self._client:
            font_color = self._root.tab_active_focus_font_color
            border_color = self._root.tab_active_focus_border_color
        elif active:
            font_color = self._root.tab_active_unfocus_font_color
            border_color = self._root.tab_active_unfocus_border_color
        elif focus:
            font_color = self._root.tab_inactive_focus_font_color
            border_color = self._root.tab_inactive_focus_border_color
        else:
            font_color = self._root.tab_inactive_unfocus_font_color
            border_color = self._root.tab_inactive_unfocus_border_color

        text_layout = self._drawer.textlayout(
            "", font_color, self._root.tab_font, self._root.tab_fontsize, None,
            wrap=False
        )
        text_layout.text = self.get_title()
        max_width = (self._drawer.width - left - self._root.tab_gap) / (client_amount - client_index)

        if text_layout.width > max_width:
            text_layout.width = max_width

        text_layout.draw(left, 0)

        return left + text_layout.width

    def click(self, x, y, button):
        if button is LEFT_CLICK and self._left < x and x < self._right:
            self._root.group.focus(self._client)
            return True
        else:
            return False

class Cell(_ClientList):
    def __init__(self, root):
        _ClientList.__init__(self)
        hook.subscribe.client_name_updated(self.draw)

        self._root = root
        self._tab_bar = None
        self._drawer = None
        self._tabs = {}

    def finalize(self):
        hook.unsubscribe.client_name_updated(self.draw)
        if self._tab_bar is not None:
            self._tab_bar.kill()
        if self._drawer is not None:
            self._drawer.finalize()

    def add_client(self, client: Window):
        _ClientList.add_client(self, client, 1)

    def configure(self, client: Window, screen_rect: ScreenRect):
        tab_screen_rect, client_screen_rect = screen_rect.vsplit(self._root.tab_bar_height)
        border_color = self._root.window_border_color_focus if self._root.group.current_window is client else self._root.window_border_color_inactive

        self._create_tab_bar(tab_screen_rect)
        self._tab_bar.place(
            x = tab_screen_rect.x,
            y = tab_screen_rect.y,
            width = tab_screen_rect.width,
            height = tab_screen_rect.height,
            borderwidth = 0,
            bordercolor = None
        )
        self.draw()
        self._tab_bar.unhide()

        client.place(
            x = client_screen_rect.x,
            y = client_screen_rect.y,
            width = client_screen_rect.width - self._root.window_border_width * 2,
            height = client_screen_rect.height - self._root.window_border_width * 2,
            bordercolor = border_color,
            borderwidth = self._root.window_border_width
        )

        if client is self.current_client:
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
        if self._drawer is None:
            self._drawer = self._tab_bar.create_drawer(
                screen_rect.width,
                screen_rect.height,
            )
        else:
            if self._drawer.height != screen_rect.height:
                self._drawer.height = screen_rect.height

            if self._drawer.width != screen_rect.width:
                self._drawer.width = screen_rect.width


    def draw(self, *args):
        self._drawer.clear(self._root.tab_bar_background_color)

        client_amount = len(self.clients)
        left = 0
        for client_index in range(client_amount):
            client = self.clients[client_index]
            if client.wid not in self._tabs:
                self._tabs[client.wid] = Tab(root = self._root, drawer = self._drawer, client = client)
            left = self._tabs[client.wid].draw(
                left = left,
                client_index = client_index,
                client_amount = client_amount,
                active = self.current_index is client_index,
                focus = self._root.group.current_window is self.current_client
            ) + self._root.tab_gap 

        self._drawer.draw(offsetx=0, offsety=0, width = self._drawer.width)


    def process_button_click(self, x, y, button):
        for tab_index in self._tabs:
            if self._tabs[tab_index].click(x = x, y = y, button = button) is True:
                return

        result = None
        if button is SCROLL_DOWN or button is SCROLL_RIGHT:
            result = self.focus_next(self.current_client)
        if button is SCROLL_UP or button is SCROLL_LEFT:
            result = self.focus_previous(self.current_client)

        if result is not None:
            self._root.group.focus(result)

    def shuffle_left(self) -> bool:
        if len(self.clients) > 1 and self.current_index > 0:
            self.shuffle_up()

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

    def add_client(self, client: Window, mode = "current") -> None:
        target_cell_index = 0 if self.current_cell_index is None else self.current_cell_index
        create = False

        if self.current_cell_index is None:
            create = True
        elif mode is "previous_cell":
            if target_cell_index is 0:
                create = True

            if create is False:
                target_cell_index -= 1
        elif mode is "next_cell":
            target_cell_index += 1
            if len(self.cells) <= target_cell_index:
                create = True

        if create:
            self.cells.insert(target_cell_index, Cell(self._root))

        self.current_cell_index = target_cell_index

        if client.wid in self._clients:
            self.remove(client)

        self._clients[client.wid] = self.cells[self.current_cell_index]
        self.cells[self.current_cell_index].add_client(client)

    def configure(self, client: Window, screen_rect):
        cell_length = len(self.cells)
        ratio = 1 / cell_length
        screen_size = screen_rect.width if self._root.is_horizontal() else screen_rect.height

        for cell_index in range(cell_length):
            if cell_index + 1 is cell_length:
                cell_rect = screen_rect
            else:
                if self._root.is_horizontal():
                    (cell_rect, screen_rect) = screen_rect.hsplit(int(ratio * screen_size))
                else:
                    (cell_rect, screen_rect) = screen_rect.vsplit(int(ratio * screen_size))

            cell = self.cells[cell_index]
            if cell is self._clients[client.wid]:
                top = 0
                right = 0
                bottom = 0
                left = 0

                if cell_index + 1 is not cell_length:
                    if self._root.is_horizontal():
                        right = self._root.window_gap 
                    else:
                        bottom = self._root.window_gap

                shrinked_rect = shrink_rect(cell_rect, top, right, bottom, left)
                cell.configure(client, shrinked_rect)

    def remove(self, client):
        cell = self._clients[client.wid]

        cell.remove(client)
        self._clients.pop(client.wid)

        if len(cell.clients) == 0:
            cell.finalize()
            cell_index = self.cells.index(cell)

            self.cells.pop(cell_index)
            if self.current_cell_index >= cell_index:
                self.current_cell_index -= 1

    def focus_change(self):
        if self._root.group.current_window.wid in self._clients:
            self.current_cell_index = self.cells.index(self._clients[self._root.group.current_window.wid])

        for cell in self.cells:
            cell.focus_change()

    def focus_next(self, client: Window) -> Window | None:
        cell = self._clients[client.wid]
        result = cell.focus_next(client)

        if result is None and self._root.is_horizontal():
            cell_index = self.cells.index(cell)
            if cell_index + 1 < len(self.cells):
                result = self.cells[cell_index + 1].focus_first()

        return result

    def focus_previous(self, client: Window) -> Window | None:
        cell = self._clients[client.wid]
        result = cell.focus_previous(client)

        if result is None and self._root.is_horizontal():
            cell_index = self.cells.index(cell)
            if cell_index  > 0:
                result = self.cells[cell_index - 1].focus_last()

        return result

    def focus_left(self, client: Window, container) -> Window | None:
        cell = self._clients[client.wid]
        result = cell.focus_previous(client) if container is False else None

        if result is None and self._root.is_horizontal() :
            cell_index = self.cells.index(cell)
            if cell_index  > 0:
                result = self.cells[cell_index - 1].current_client

        return result

    def focus_right(self, client: Window, container) -> Window | None:
        cell = self._clients[client.wid]
        result = cell.focus_next(client) if container is False else None

        if result is None and self._root.is_horizontal():
            cell_index = self.cells.index(cell)
            if cell_index + 1 < len(self.cells):
                result = self.cells[cell_index + 1].current_client
        return result

    def focus_down(self, client: Window) -> Window | None:
        if self._root.is_horizontal() is False and self.current_cell_index + 1 < len(self.cells):
            return self.cells[self.current_cell_index + 1].current_client
        else:
            return None

    def focus_up(self, client: Window) -> Window | None:
        if self._root.is_horizontal() is False and self.current_cell_index > 0:
            return self.cells[self.current_cell_index - 1].current_client
        else:
            return None

    def shuffle_right(self, container) -> bool:
        cell = self.cells[self.current_cell_index]
        result = cell.shuffle_right() if container is False else False

        if result is False and self._root.is_horizontal():
            self.add_client(cell.current_client, "next_cell")

            return True

        return result

    def shuffle_left(self, container) -> bool:
        cell = self.cells[self.current_cell_index]
        result = cell.shuffle_left() if container is False else False

        if result is False and self._root.is_horizontal():
            self.add_client(cell.current_client, "previous_cell")

            return True
        return result

    def shuffle_down(self) -> bool:
        if self._root.is_horizontal() is False:
            cell = self.cells[self.current_cell_index]
            self.add_client(cell.current_client, "next_cell")

            return True

        return False


    def shuffle_up(self) -> bool:
        if self._root.is_horizontal() is False:
            cell = self.cells[self.current_cell_index]
            self.add_client(cell.current_client, "previous_cell")

            return True
        return False

    def get_match(self, needle_client: Window) -> Window:
        (needle_x, needle_y)= needle_client.get_position()
        for cell_index in range(len(self.cells)):
            (heystack_x, heystack_y) = self.cells[cell_index].current_client.get_position()
            (heystack_width, heystack_height) = self.cells[cell_index].current_client.get_size()
            (needle_value, heystack_value) = (needle_x, heystack_x + heystack_width) if self._root.is_horizontal() else (needle_y, heystack_y + heystack_height)
            if needle_value < heystack_value:
                return cell_index
        raise Exception("Could not find matching window")

class Tabs(Layout):
    defaults = [
        ("primary_position", "top", "Position of the primary containers, can be either 'top', 'right', 'bottom' or 'left'"),
        ("primary_weight", 1.3, "Percentage of how the primary containers should be weighted"),
        ("window_gap", 20, "Background between windows"),
        ("window_border_color_focus", "9C9C9C", "Color of the window, when it is focused"),
        ("window_border_color_inactive", "2C2C2C", "Color of the window when it is not focused"),
        ("window_border_width", 1, "Width of border"),
        ("tab_bar_height", 24, "Height of the tab bar"),
        ("tab_bar_background_color", "000000", "Background of the tab bar"),
        ("tab_gap", 10, "Gaps between tabs"),
        ("tab_font", "sans", "Font size of tab"),
        ("tab_fontsize", 14, "Font size of tab"),
        ("tab_icon_size", 24, "icon size"),

        ("tab_active_focus_font_color", "00ff00", "Background color of an focused tab"),
        ("tab_active_focus_border_color", "00ff00", "Background color of an focused tab"),
        ("tab_active_focus_background_color", "000000", "Background color of an focused tab"),

        ("tab_active_unfocus_font_color", "009900", "Background color of an focused tab"),
        ("tab_active_unfocus_border_color", "009900", "Background color of an focused tab"),
        ("tab_active_unfocus_background_color", "000000", "Background color of an focused tab"),

        ("tab_inactive_focus_font_color", "ffffff", "Background color of an focused tab"),
        ("tab_inactive_focus_border_color", "006600", "Background color of an focused tab"),
        ("tab_inactive_focus_background_color", "000000", "Background color of an focused tab"),

        ("tab_inactive_unfocus_font_color", "ffffff", "Background color of an focused tab"),
        ("tab_inactive_unfocus_border_color", "006600", "Background color of an focused tab"),
        ("tab_inactive_unfocus_background_color", "000000", "Background color of an focused tab"),
    ]

    def __init__(self, **config):
        Layout.__init__(self, **config)
        self.add_defaults(Tabs.defaults)

    def setup(self):
        self._clients = {}
        self.rows = []
        self.current_row_index = None

    def show(self, screen_rect):
        for row in self.rows:
            for cell in row.cells:
                if cell._tab_bar is not None:
                    cell._tab_bar.unhide()



    def hide(self):
        for row in self.rows:
            for cell in row.cells:
                if cell._tab_bar is not None:
                    cell._tab_bar.hide()

    def is_horizontal(self):
        return self.primary_position is "top" or self.primary_position is "bottom"

    def finalize(self):
        hook.unsubscribe.focus_change(self.focus_change)
        for row in self.rows:
            row.finalize()

    def add_client(self, client: Window, mode = "current") -> None:
        """Called whenever a window is added to the group

        Called whether the layout is current or not. The layout should just add
        the window to its internal datastructures, without mapping or
        configuring.
        """
        target_row_index = 0 if self.current_row_index is None else self.current_row_index
        create = False

        if self.current_row_index is None:
            create = True
        elif mode is "previous_row":
            if target_row_index is 0:
                create = True

            if create is False:
                target_row_index -= 1
        elif mode is "next_row":
            target_row_index += 1
            if len(self.rows) <= target_row_index:
                create = True

        if create:
            self.rows.insert(target_row_index, Row(self))
        elif mode is "next_row" or mode is "previous_row":
            self.rows[target_row_index].current_cell_index = self.rows[target_row_index].get_match(client)


        self.current_row_index = target_row_index

        if client.wid in self._clients:
            self.remove(client)

        self._clients[client.wid] = self.rows[self.current_row_index]
        self.rows[self.current_row_index].add_client(client)

    def focus_change(self):
        if self.group.current_window is not None:
            if self.group.current_window.wid in self._clients:
                self.current_row_index = self.rows.index(self._clients[self.group.current_window.wid])

            for row in self.rows:
                row.focus_change()

    def remove(self, client: Window) -> Window | None:
        """Called whenever a window is removed from the group

        Called whether the layout is current or not. The layout should just
        de-register the window from its data structures, without unmapping the
        window.

        Returns the "next" window that should gain focus or None.
        """
        row = self._clients[client.wid]

        row.remove(client)
        self._clients.pop(client.wid)

        if len(row.cells) == 0:
            row.finalize()
            row_index = self.rows.index(row)

            self.rows.pop(row_index)

            if len(self.rows) is 0:
                self.current_row_index = None
            elif self.current_row_index >= row_index:
                self.current_row_index -= 1

    def _is_primary(self, row_index: int) -> bool:
        if self.primary_position is "top" or self.primary_position is "left":
            return row_index is 0
        elif self.primary_position is "right" or self.primary_position is "bottom":
            return row_index + 1 is len(self.rows)
        else:
            raise ValueError("Not allowed value")

    def configure(self, client: Window, screen_rect: ScreenRect) -> None:
        """Configure the layout

        This method should:

            - Configure the dimensions and borders of a window using the
              `.place()` method.
            - Call either `.hide()` or `.unhide()` on the window.
        """
        row_length = len(self.rows)
        row_amount = row_length + self.primary_weight - 1
        screen_size = screen_rect.height if self.is_horizontal() else screen_rect.width

        for row_index in range(row_length):
            if row_index + 1 is row_length:
                row_rect = screen_rect
            else:
                weight = self.primary_weight if self._is_primary(row_index) else 1
                ratio = weight / row_amount
                if self.is_horizontal():
                    (row_rect, screen_rect) = screen_rect.vsplit(int(ratio * screen_size))
                else:
                    (row_rect, screen_rect) = screen_rect.hsplit(int(ratio * screen_size))

            row = self.rows[row_index]
            if self._clients[client.wid] is row:
                top = self.window_gap
                right = self.window_gap
                bottom = self.window_gap
                left = self.window_gap

                if row_index is not 0:
                    if self.is_horizontal():
                        top = 0
                    else:
                        left

                shrinked_rect = shrink_rect(row_rect, top, right, bottom, left)
                row.configure(client, shrinked_rect)

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
        row = self._clients[client.wid]
        result = row.focus_next(client)

        return result

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
        result = self._clients[client.wid].focus_previous(client)

        return result

    def clone(self, group):
        clone = Layout.clone(self, group)
        Tabs.setup(clone)
        hook.subscribe.focus_change(clone.focus_change)
        return clone

    @expose_command()
    def right(self, container = False) -> None:
        if self.current_row_index is not None:
            row = self.rows[self.current_row_index]
            client = row.cells[row.current_cell_index].current_client
            result = row.focus_right(client, container = container)

            if result is None and self.is_horizontal() is False and self.current_row_index +1 < len(self.rows):
                next_row = self.rows[self.current_row_index + 1]
                result = next_row.cells[next_row.get_match(client)].current_client

            if result is not None:
                self.group.focus(result, True)

    @expose_command()
    def left(self, container = False) -> None:
        if self.current_row_index is not None:
            row = self.rows[self.current_row_index]
            client = row.cells[row.current_cell_index].current_client
            result = row.focus_left(client, container = container)

            if result is None and self.is_horizontal() is False and self.current_row_index > 0:
                previous_row = self.rows[self.current_row_index - 1]
                result = previous_row.cells[previous_row.get_match(client)].current_client
            if result is not None:
                self.group.focus(result, True)

    @expose_command()
    def down(self) -> None:
        if self.current_row_index is not None:
            row = self.rows[self.current_row_index]
            client = row.cells[row.current_cell_index].current_client
            result = row.focus_down(client)

            if result is None and self.is_horizontal() and self.current_row_index +1 < len(self.rows):
                next_row = self.rows[self.current_row_index + 1]
                result = next_row.cells[next_row.get_match(client)].current_client

            if result is not None:
                self.group.focus(result, True)

    @expose_command()
    def up(self) -> None:
        if self.current_row_index is not None:
            row = self.rows[self.current_row_index]
            client = row.cells[row.current_cell_index].current_client
            result = row.focus_up(client)

            if result is None and self.is_horizontal() and self.current_row_index > 0:
                previous_row = self.rows[self.current_row_index - 1]
                result = previous_row.cells[previous_row.get_match(client)].current_client
            if result is not None:
                self.group.focus(result, True)

    def next(self) -> None:
        pass

    def previous(self) -> None:
        pass


    @expose_command()
    def shuffle_right(self, container = False) -> None:
        if self.current_row_index is not None:
            result = self.rows[self.current_row_index].shuffle_right(container = container)
            if result is False:
                row = self.rows[self.current_row_index]
                client = row.cells[row.current_cell_index].current_client

                self.add_client(client, "next_row")

            self.group.layout_all()

    @expose_command()
    def shuffle_left(self, container = False) -> None:
        if self.current_row_index is not None:
            result = self.rows[self.current_row_index].shuffle_left(container = container)
            if result is False:
                row = self.rows[self.current_row_index]
                client = row.cells[row.current_cell_index].current_client

                self.add_client(client, "previous_row")

            self.group.layout_all()

    @expose_command()
    def shuffle_down(self) -> None:
        if self.current_row_index is not None:
            result = self.rows[self.current_row_index].shuffle_down()
            if result is False:
                row = self.rows[self.current_row_index]
                client = row.cells[row.current_cell_index].current_client

                self.add_client(client, "next_row")

            self.group.layout_all()

    @expose_command()
    def shuffle_up(self) -> None:
        if self.current_row_index is not None:
            result = self.rows[self.current_row_index].shuffle_up()
            if result is False:
                row = self.rows[self.current_row_index]
                client = row.cells[row.current_cell_index].current_client

                self.add_client(client, "previous_row")

            self.group.layout_all()

