import os
import subprocess
import sys
import urllib.error
from urllib.parse import parse_qs

import pytest

import chatwork
from common import ApiError

API = "https://api.chatwork.com/v2"
TOKEN = "dummy-token-123"
LINK = "https://www.chatwork.com/#!rid10-13"
ME = {"account_id": 1}
ROOM = {"room_id": 10, "name": "架空プロジェクト"}
T0 = 1_791_000_000  # 2026-10 ごろの Unix 時間


def msg(n, account_id=2, name="山田", body=None):
    return {"message_id": str(n), "account": {"account_id": account_id, "name": name},
            "body": body or f"本文{n}", "send_time": T0 + n * 60, "update_time": 0}


def routes(target, recent):
    return {
        ("GET", f"{API}/me"): ME,
        ("GET", f"{API}/rooms/10"): ROOM,
        ("GET", f"{API}/rooms/10/messages/{target['message_id']}"): target,
        ("GET", f"{API}/rooms/10/messages?force=1"): recent,
    }


@pytest.fixture
def body(tmp_path):
    path = tmp_path / "body.txt"
    path.write_text("承知しました。\n明日までに対応します。", encoding="utf-8")
    return path


# --- リンク ---

def test_message_link():
    assert chatwork.parse_link(LINK + " ") == ("10", "13")


def test_room_link_is_rejected():
    with pytest.raises(ApiError, match="ルームのリンクです"):
        chatwork.parse_link("https://www.chatwork.com/#!rid10")


def test_other_text_is_rejected():
    with pytest.raises(ApiError, match="Chatwork のメッセージのリンクではありません"):
        chatwork.parse_link("https://example.com/#!rid10-13")


# --- 取得 ---

def test_shows_request_and_context(fake_api):
    recent = [msg(n) for n in range(1, 16)]
    recent[13] = msg(14, account_id=1, name="自分の名前")
    fake_api(routes(msg(13), recent))
    out = chatwork.fetch(LINK, TOKEN)
    assert "ルーム: 架空プロジェクト（10）" in out
    assert "リンク: https://www.chatwork.com/#!rid10-13" in out
    assert "## 依頼のメッセージ" in out
    assert "本文13" in out
    assert "## 前の流れ（直前 10 件）" in out
    assert "本文2\n" not in out  # 11 件前は出さない
    assert "本文3" in out
    assert "## 後の流れ（2 件）" in out
    assert "自分の名前（自分）" in out


def test_token_is_sent_in_header(fake_api):
    api = fake_api(routes(msg(13), [msg(13)]))
    chatwork.fetch(LINK, TOKEN)
    assert {r.get_header("X-chatworktoken") for r in api.requests} == {TOKEN}


def test_request_older_than_recent_messages(fake_api):
    fake_api(routes(msg(13), [msg(n) for n in range(20, 25)]))
    out = chatwork.fetch(LINK, TOKEN)
    assert "前の流れは取れていません（依頼が直近 100 件より古いため）" in out
    assert "## 後の流れ（5 件）" in out
    assert "依頼からここまでのあいだのメッセージは取れていません" in out


def test_no_messages_returns_empty_body(fake_api):
    fake_api(routes(msg(13), None))
    out = chatwork.fetch(LINK, TOKEN)
    assert "前の流れは取れていません" in out
    assert "## 後の流れ（0 件）" in out


def test_earlier_messages_beyond_limit_are_noted(fake_api):
    fake_api(routes(msg(13), [msg(n) for n in range(11, 111)]))  # 100 件ちょうど。依頼は 3 件目
    assert "これより前は取れていません（直近 100 件の外）" in chatwork.fetch(LINK, TOKEN)


def test_http_error_message_has_no_token_or_url(fake_api):
    fake_api({("GET", f"{API}/me"): 403})
    with pytest.raises(ApiError) as e:
        chatwork.fetch(LINK, TOKEN)
    assert str(e.value) == "権限がありません（403）"


def test_network_error(fake_api):
    fake_api({("GET", f"{API}/me"): urllib.error.URLError("timed out")})
    with pytest.raises(ApiError, match="通信できません"):
        chatwork.fetch(LINK, TOKEN)


# --- 投稿 ---

def test_post_returns_link(fake_api, body):
    api = fake_api({("POST", f"{API}/rooms/10/messages"): {"message_id": "99"}})
    assert chatwork.post("10", body, TOKEN) == "投稿しました: https://www.chatwork.com/#!rid10-99"
    assert parse_qs(api.requests[0].data.decode("utf-8")) == {"body": ["承知しました。\n明日までに対応します。"]}


def test_reply_adds_reply_notation(fake_api, body):
    api = fake_api({("GET", f"{API}/rooms/10/messages/13"): msg(13),
                    ("POST", f"{API}/rooms/10/messages"): {"message_id": "99"}})
    chatwork.post("10", body, TOKEN, reply_to="13")
    sent = parse_qs(api.requests[1].data.decode("utf-8"))["body"][0]
    assert sent.startswith("[rp aid=2 to=10-13]山田さん\n承知しました。")


def test_empty_body_is_rejected(body):
    body.write_text("  \n", encoding="utf-8")
    with pytest.raises(ApiError, match="本文が空です"):
        chatwork.post("10", body, TOKEN)


def test_missing_body_file_is_rejected(tmp_path):
    with pytest.raises(ApiError, match="本文のファイルがありません"):
        chatwork.post("10", tmp_path / "none.txt", TOKEN)


def test_room_must_be_number(body):
    with pytest.raises(ApiError, match="ルーム ID は数字です"):
        chatwork.post("abc", body, TOKEN)


# --- コマンドとして動かしたとき ---

def run_script(scripts, args, env):
    return subprocess.run([sys.executable, str(scripts / "chatwork.py"), *args], capture_output=True, env=env)


def test_error_is_one_utf8_line_and_exit_1(scripts):
    env = {k: v for k, v in os.environ.items() if k != "PYTHONIOENCODING"}
    env["CHATWORK_API_TOKEN"] = TOKEN
    done = run_script(scripts, ["fetch", "not-a-link"], env)
    assert done.returncode == 1
    assert done.stderr.decode("utf-8").strip() == "エラー: Chatwork のメッセージのリンクではありません"


def test_missing_token(scripts):
    env = {k: v for k, v in os.environ.items() if k not in ("CHATWORK_API_TOKEN", "PYTHONIOENCODING")}
    done = run_script(scripts, ["fetch", LINK], env)
    assert done.stderr.decode("utf-8").strip() == "エラー: 環境変数 CHATWORK_API_TOKEN がありません"
