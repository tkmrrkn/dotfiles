"""req のスクリプトが共有する、API の呼び出しと出力の処理。

トークンや API キーは、出力にもエラーの文言にも出さない（URL にキーが入る API もあるため、URL も出さない）。
"""
from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.parse
from collections.abc import Callable
from datetime import datetime, timedelta, timezone
from pathlib import Path
from urllib.request import Request, urlopen

# Chatwork・Backlog の API はふだん 1 秒以内に返る。comm-ai と同じ 10 秒で打ち切り、待たせ続けない
TIMEOUT_SECONDS = 10
JST = timezone(timedelta(hours=9))

HTTP_MESSAGES = {
    401: "認証に失敗しました（401）。トークンまたは API キーを確かめてください",
    403: "権限がありません（403）",
    404: "見つかりません（404）。リンクが正しいか、閲覧できるものかを確かめてください",
    429: "API の回数制限に達しました（429）。時間をおいてやり直してください",
}


class ApiError(Exception):
    """利用者に見せてよい文言だけを持つ。"""


def env(name: str) -> str:
    value = os.environ.get(name, "").strip()
    if not value:
        raise ApiError(f"環境変数 {name} がありません")
    return value


def call(method: str, url: str, *, headers: dict[str, str] | None = None,
         form: dict[str, str] | None = None) -> object | None:
    """JSON を返す API を呼ぶ。本文が空（Chatwork の 204 など）なら None を返す。"""
    data = urllib.parse.urlencode(form).encode("utf-8") if form is not None else None
    req = Request(url, data=data, method=method, headers=headers or {})
    try:
        with urlopen(req, timeout=TIMEOUT_SECONDS) as res:
            body = res.read()
    except urllib.error.HTTPError as e:  # URLError の子なので先に受ける
        raise ApiError(HTTP_MESSAGES.get(e.code, f"API がエラーを返しました（HTTP {e.code}）")) from None
    except (urllib.error.URLError, OSError):  # タイムアウトも OSError の子
        raise ApiError("通信できません。ネットワークを確かめてください") from None
    if not body:
        return None
    try:
        return json.loads(body.decode("utf-8"))
    except ValueError:
        raise ApiError("API の応答を読めません") from None


def read_body(path: Path) -> str:
    """投稿する本文を読む。改行や記号でコマンドが壊れないよう、本文はファイルで受け取る。"""
    try:
        text = path.read_text(encoding="utf-8")
    except FileNotFoundError:
        raise ApiError("本文のファイルがありません") from None
    if not text.strip():
        raise ApiError("本文が空です")
    return text.strip("\n")


def to_jst(dt: datetime) -> str:
    return dt.astimezone(JST).strftime("%Y-%m-%d %H:%M")


def run(main: Callable[[list[str]], None]) -> int:
    """出力を UTF-8 にして main を動かす。ApiError は「エラー: 」で始まる 1 行と終了コード 1 にする。"""
    for stream in (sys.stdout, sys.stderr):
        stream.reconfigure(encoding="utf-8")  # Windows の既定（cp932）のままだと Claude が読むときに文字化けする
    try:
        main(sys.argv[1:])
    except ApiError as e:
        print(f"エラー: {e}", file=sys.stderr)
        return 1
    return 0
