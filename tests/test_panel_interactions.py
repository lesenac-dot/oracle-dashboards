from __future__ import annotations

import unittest
from unittest.mock import patch

from textual.app import App, ComposeResult
from textual.widgets import DataTable

from core.cache import MetricsCache
from widgets.explain_screen import ExplainScreen
from widgets.panels import TopSQLPanel


class FakeConnection:
    async def fetch_one(self, _sql: str, _params: dict | None = None) -> dict:
        return {"sql_fulltext": "select * from dual"}

    async def execute_query(self, _sql: str, _params: dict | None = None) -> list[dict]:
        return [{"plan_line_id": 0, "depth": 0, "operation": "SELECT STATEMENT"}]


class TopSQLHarness(App):
    def __init__(self) -> None:
        super().__init__()
        self.cache = MetricsCache()
        self.cache.set("sql.top", [{
            "sql_id": "abc123def4567",
            "parsing_schema_name": "APP",
            "sql_text": "select * from dual",
            "executions": 1,
            "elapsed_secs": 1.0,
            "cpu_secs": 0.5,
            "buffer_gets": 10,
            "disk_reads": 0,
        }], ttl=60)

    def compose(self) -> ComposeResult:
        yield TopSQLPanel(FakeConnection(), self.cache, id="topsql")

    async def on_mount(self) -> None:
        panel = self.query_one(TopSQLPanel)
        await panel.refresh_data()
        panel.query_one("#sql-table", DataTable).focus()


class PanelInteractionTests(unittest.IsolatedAsyncioTestCase):
    async def test_enter_on_top_sql_opens_explain_screen(self) -> None:
        app = TopSQLHarness()
        async with app.run_test() as pilot:
            await pilot.pause()
            table = app.query_one("#sql-table", DataTable)
            self.assertEqual(table.cursor_type, "row")
            await pilot.press("enter")
            await pilot.pause()
            self.assertIsInstance(app.screen, ExplainScreen)

    async def test_c_copies_selected_sql_id(self) -> None:
        app = TopSQLHarness()
        with patch.object(TopSQLPanel, "copy_to_clipboard", return_value=True) as copy:
            async with app.run_test() as pilot:
                await pilot.pause()
                await pilot.press("c")
                await pilot.pause()
                copy.assert_called_once_with("abc123def4567", "SQL ID")


if __name__ == "__main__":
    unittest.main()
