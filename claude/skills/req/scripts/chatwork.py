"""Chatwork の依頼を取る（fetch）。承認のあとだけ投稿する（post）。

  python chatwork.py fetch <メッセージのリンク>
  python chatwork.py post <ルーム ID> <本文のファイル> [--reply-to <メッセージ ID>]

fetch は読むだけで、何も書き込まない。
"""
from __future__ import annotations

import argparse
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

from common import ApiError, call, env, read_body, run, to_jst

BASE_URL = "https://api.chatwork.com/v2"
WEB_URL = "https://www.chatwork.com/#!rid{room}-{message}"
LINK = re.compile(r"https://www\.chatwork\.com/#!rid(\d+)(?:-(\d+))?")
# メッセージの一覧の API は、1 ルームにつき直近 100 件までしか返さない
RECENT_LIMIT = 100
# 依頼の前の流れは 10 件まで出す。依頼の意味が決まる直前のやりとりには足り、出力を短く保てる
CONTEXT_BEFORE = 10


def parse_link(link: str) -> tuple[str, str]:
    m = LINK.fullmatch(link.strip())
    if not m:
        raise ApiError("Chatwork のメッセージのリンクではありません")
    if not m.group(2):
        raise ApiError("ルームのリンクです。メッセージのリンク（…#!rid<ルーム>-<メッセージ>）を渡してください")
    return m.group(1), m.group(2)


def _get(path: str, token: str):
    return call("GET", BASE_URL + path, headers={"X-ChatWorkToken": token})


def _message(m: dict, me: int) -> list[str]:
    account = m["account"]
    who = account["name"] + ("（自分）" if account["account_id"] == me else "")
    at = to_jst(datetime.fromtimestamp(m["send_time"], timezone.utc))
    return [f"### {at} {who}（message_id {m['message_id']}, account_id {account['account_id']}）", m["body"], ""]


def fetch(link: str, token: str) -> str:
    room, message = parse_link(link)
    me = _get("/me", token)["account_id"]
    name = _get(f"/rooms/{room}", token)["name"]
    target = _get(f"/rooms/{room}/messages/{message}", token)
    # force=1：Chatwork 側に「前回取得以降の差分」を覚えさせない
    recent = _get(f"/rooms/{room}/messages?force=1", token) or []
    lines = ["# Chatwork の依頼", f"ルーム: {name}（{room}）",
             f"リンク: {WEB_URL.format(room=room, message=message)}", "",
             "## 依頼のメッセージ", *_message(target, me)]
    ids = [m["message_id"] for m in recent]
    if message in ids:
        i = ids.index(message)
        before, after = recent[max(0, i - CONTEXT_BEFORE):i], recent[i + 1:]
        lines.append(f"## 前の流れ（直前 {len(before)} 件）")
        if i < CONTEXT_BEFORE and len(recent) >= RECENT_LIMIT:
            lines.append("これより前は取れていません（直近 100 件の外）")
    else:
        before = []
        after = [m for m in recent if m["send_time"] > target["send_time"]]
        lines += ["## 前の流れ", "前の流れは取れていません（依頼が直近 100 件より古いため）"]
    for m in before:
        lines += _message(m, me)
    lines.append(f"## 後の流れ（{len(after)} 件）")
    if message not in ids:
        lines.append("依頼からここまでのあいだのメッセージは取れていません（直近 100 件しか取れないため）")
    for m in after:
        lines += _message(m, me)
    return "\n".join(lines).rstrip() + "\n"


def post(room: str, body_file: Path, token: str, reply_to: str | None = None) -> str:
    if not room.isdigit():
        raise ApiError("ルーム ID は数字です")
    body = read_body(body_file)
    if reply_to:
        account = _get(f"/rooms/{room}/messages/{reply_to}", token)["account"]
        body = f"[rp aid={account['account_id']} to={room}-{reply_to}]{account['name']}さん\n{body}"
    res = call("POST", f"{BASE_URL}/rooms/{room}/messages", headers={"X-ChatWorkToken": token},
               form={"body": body})
    return "投稿しました: " + WEB_URL.format(room=room, message=res["message_id"])


def main(argv: list[str]) -> None:
    parser = argparse.ArgumentParser(prog="chatwork.py")
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("fetch").add_argument("link")
    p = sub.add_parser("post")
    p.add_argument("room")
    p.add_argument("body_file", type=Path)
    p.add_argument("--reply-to")
    args = parser.parse_args(argv)
    if args.command == "fetch":
        parse_link(args.link)  # トークンより先にリンクを確かめる（どちらが原因かを分かりやすくする）
        print(fetch(args.link, env("CHATWORK_API_TOKEN")), end="")
    else:
        print(post(args.room, args.body_file, env("CHATWORK_API_TOKEN"), args.reply_to))


if __name__ == "__main__":
    sys.exit(run(main))
