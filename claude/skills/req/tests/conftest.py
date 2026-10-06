"""テストの共通部分。scripts/ を import できるようにし、偽の API を用意する。"""
from __future__ import annotations

import json
import sys
import urllib.error
from pathlib import Path
from urllib.parse import parse_qsl, urlencode, urlsplit, urlunsplit

import pytest

SCRIPTS = Path(__file__).resolve().parent.parent / "scripts"
sys.path.insert(0, str(SCRIPTS))


class FakeResponse:
    def __init__(self, body: bytes):
        self._body = body

    def read(self) -> bytes:
        return self._body

    def __enter__(self):
        return self

    def __exit__(self, *exc):
        return False


def route_key(req) -> tuple[str, str]:
    """(メソッド, apiKey を除いた URL)。Backlog の API キーはクエリに入るため、照合からは外す。"""
    parts = urlsplit(req.full_url)
    query = urlencode([(k, v) for k, v in parse_qsl(parts.query) if k != "apiKey"])
    return req.get_method(), urlunsplit(parts._replace(query=query))


class FakeApi:
    """routes の値：dict・list は JSON で返す、None は空の本文、int はその HTTP の状態コードで失敗、例外はそのまま投げる。"""

    def __init__(self, routes: dict[tuple[str, str], object]):
        self.routes = routes
        self.requests = []

    def __call__(self, req, timeout):
        self.requests.append(req)
        key = route_key(req)
        if key not in self.routes:
            raise AssertionError(f"想定していない呼び出し: {key}")
        result = self.routes[key]
        if isinstance(result, BaseException):
            raise result
        if isinstance(result, int):
            raise urllib.error.HTTPError(req.full_url, result, "error", {}, None)
        return FakeResponse(b"" if result is None else json.dumps(result).encode("utf-8"))


@pytest.fixture
def fake_api(monkeypatch):
    """routes を渡すと偽の API を作り、common.urlopen と差し替えて返す。"""
    import common

    def install(routes: dict[tuple[str, str], object]) -> FakeApi:
        api = FakeApi(routes)
        monkeypatch.setattr(common, "urlopen", api)
        return api

    return install


@pytest.fixture
def scripts() -> Path:
    return SCRIPTS
