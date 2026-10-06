"""Backlog の依頼（課題）を取る（fetch）。承認のあとだけコメントする（comment）。

  python backlog.py fetch <課題のリンク>
  python backlog.py comment <課題のリンク> <本文のファイル>

fetch は読むだけで、何も書き込まない。スペースはリンクのホスト名から決め、
環境変数 BACKLOG_SPACE（例：example.backlog.com。カンマ区切りで複数）に含まれるものだけに送る。
"""
from __future__ import annotations

import argparse
import re
import sys
from datetime import datetime
from pathlib import Path
from urllib.parse import urlencode

from common import ApiError, call, env, read_body, run, to_jst

LINK = re.compile(r"https://([a-z0-9-]+\.backlog\.(?:com|jp))/view/([A-Z0-9][A-Z0-9_]*-\d+)(?:#comment-(\d+))?")
# コメントの一覧の API は 1 回に 100 件まで（API の上限）。それより少なく返ったら最後のページ
COMMENTS_PER_PAGE = 100


def parse_link(link: str) -> tuple[str, str, int | None]:
    m = LINK.fullmatch(link.strip())
    if not m:
        raise ApiError("Backlog の課題のリンクではありません")
    return m.group(1), m.group(2), int(m.group(3)) if m.group(3) else None


def _check_space(host: str) -> None:
    """送り先を、BACKLOG_SPACE に並べたスペースだけに絞る（カンマ区切り）。

    API キーは URL に入るため、本文に混ざった他社のスペースのリンクへ送ると、キーが相手に渡ってしまう。
    """
    allowed = {h.strip().lower() for h in env("BACKLOG_SPACE").split(",") if h.strip()}
    if host.lower() not in allowed:
        raise ApiError(f"許可していない Backlog のスペースです（{host}）")


def _url(host: str, path: str, key: str, params: dict | None = None) -> str:
    # API キーはクエリで渡す（Backlog の方式）。そのため URL はエラーの文言に出さない（common.call）
    return f"https://{host}/api/v2{path}?" + urlencode({"apiKey": key, **(params or {})})


def _comments(host: str, issue_key: str, key: str) -> list[dict]:
    out: list[dict] = []
    min_id = None
    while True:
        params = {"count": COMMENTS_PER_PAGE, "order": "asc"}
        if min_id is not None:
            params["minId"] = min_id
        page = call("GET", _url(host, f"/issues/{issue_key}/comments", key, params)) or []
        out += page
        if len(page) < COMMENTS_PER_PAGE:
            return out
        min_id = page[-1]["id"] + 1


def _name(user: dict | None, empty: str = "不明") -> str:
    return user["name"] if user else empty


def _time(text: str) -> str:
    return to_jst(datetime.fromisoformat(text.replace("Z", "+00:00")))  # 3.9 の fromisoformat は Z を読めない


def _changes(c: dict) -> str:
    items = [f"{x['field']}: {x.get('originalValue') or '-'} → {x.get('newValue') or '-'}"
             for x in c.get("changeLog") or []]
    return "（変更のみ）" + "、".join(items)


def fetch(link: str, key: str) -> str:
    host, issue_key, comment_id = parse_link(link)
    _check_space(host)
    issue = call("GET", _url(host, f"/issues/{issue_key}", key))
    comments = _comments(host, issue_key, key)
    due = (issue.get("dueDate") or "")[:10] or "なし"
    lines = ["# Backlog の依頼", f"課題: {issue['issueKey']} {issue['summary']}", f"リンク: {link.strip()}",
             f"状態: {_name(issue.get('status'))} / 担当: {_name(issue.get('assignee'), '未設定')} / 期限: {due}",
             f"起票: {_name(issue.get('createdUser'))} {_time(issue['created'])}", "",
             "## 課題の本文", issue.get("description") or "（本文なし）", "",
             f"## コメント（古い順、{len(comments)} 件）"]
    if comment_id is not None and all(c["id"] != comment_id for c in comments):
        lines.append(f"リンクのコメント（ID {comment_id}）が見つかりません")
    for c in comments:
        mark = " ← 依頼の本体" if c["id"] == comment_id else ""
        lines += [f"### {_time(c['created'])} {_name(c.get('createdUser'))}（comment_id {c['id']}）{mark}",
                  c.get("content") or _changes(c), ""]
    return "\n".join(lines).rstrip() + "\n"


def comment(link: str, body_file: Path, key: str) -> str:
    host, issue_key, _ = parse_link(link)
    _check_space(host)
    content = read_body(body_file)
    res = call("POST", _url(host, f"/issues/{issue_key}/comments", key), form={"content": content})
    return f"コメントしました: https://{host}/view/{issue_key}#comment-{res['id']}"


def main(argv: list[str]) -> None:
    parser = argparse.ArgumentParser(prog="backlog.py")
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("fetch").add_argument("link")
    c = sub.add_parser("comment")
    c.add_argument("link")
    c.add_argument("body_file", type=Path)
    args = parser.parse_args(argv)
    parse_link(args.link)  # キーより先にリンクを確かめる
    if args.command == "fetch":
        print(fetch(args.link, env("BACKLOG_API_KEY")), end="")
    else:
        print(comment(args.link, args.body_file, env("BACKLOG_API_KEY")))


if __name__ == "__main__":
    sys.exit(run(main))
