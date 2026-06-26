import libsql_client
import os
import uuid
from datetime import datetime
from typing import Optional, List, Dict
from utils.auth import get_password_hash, verify_password

def get_conn():
    url = os.getenv("TURSO_DATABASE_URL")
    token = os.getenv("TURSO_AUTH_TOKEN")
    # Convert libsql:// to https:// for libsql-client
    if url.startswith("libsql://"):
        url = url.replace("libsql://", "https://")
    return libsql_client.create_client(url=url, auth_token=token)

async def init_db():
    conn = get_conn()
    await conn.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id TEXT PRIMARY KEY,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            username TEXT NOT NULL,
            country TEXT NOT NULL,
            level TEXT NOT NULL,
            points INTEGER NOT NULL DEFAULT 0,
            streak_days INTEGER NOT NULL DEFAULT 0,
            quran_progress REAL NOT NULL DEFAULT 0.0,
            prayers_logged INTEGER NOT NULL DEFAULT 0,
            lessons_completed INTEGER NOT NULL DEFAULT 0,
            avatar TEXT NOT NULL DEFAULT '',
            created TEXT NOT NULL,
            updated TEXT NOT NULL
        )
    """)
    await conn.execute("""
        CREATE TABLE IF NOT EXISTS activities (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            activity_type TEXT NOT NULL,
            points INTEGER NOT NULL,
            metadata TEXT NOT NULL DEFAULT '{}',
            created TEXT NOT NULL
        )
    """)

def row_to_user(row) -> Dict:
    keys = ['id','email','password','username','country','level','points',
            'streak_days','quran_progress','prayers_logged','lessons_completed',
            'avatar','created','updated']
    return dict(zip(keys, row))

class TursoClient:

    async def create_user(self, email: str, password: str, username: str, country: str, level: str) -> Dict:
        conn = get_conn()
        result = await conn.execute("SELECT id FROM users WHERE email = ?", [email])
        if result.rows:
            raise Exception("Email already exists")

        user_id = str(uuid.uuid4())
        now = datetime.utcnow().isoformat()
        hashed = get_password_hash(password)

        await conn.execute(
            "INSERT INTO users VALUES (?,?,?,?,?,?,0,0,0.0,0,0,'',?,?)",
            [user_id, email, hashed, username, country, level, now, now]
        )

        result = await conn.execute("SELECT * FROM users WHERE id = ?", [user_id])
        if not result.rows:
            return {
                'id': user_id, 'email': email, 'password': hashed,
                'username': username, 'country': country, 'level': level,
                'points': 0, 'streak_days': 0, 'quran_progress': 0.0,
                'prayers_logged': 0, 'lessons_completed': 0,
                'avatar': '', 'created': now, 'updated': now
            }
        return row_to_user(result.rows[0])

    async def authenticate_user(self, email: str, password: str) -> Optional[Dict]:
        conn = get_conn()
        result = await conn.execute("SELECT * FROM users WHERE email = ?", [email])
        if not result.rows:
            return None
        user = row_to_user(result.rows[0])
        if not verify_password(password, user['password']):
            return None
        return user

    async def get_user(self, user_id: str) -> Optional[Dict]:
        conn = get_conn()
        result = await conn.execute("SELECT * FROM users WHERE id = ?", [user_id])
        return row_to_user(result.rows[0]) if result.rows else None

    async def update_user(self, user_id: str, data: Dict) -> Dict:
        conn = get_conn()
        data['updated'] = datetime.utcnow().isoformat()
        sets = ', '.join([f"{k} = ?" for k in data.keys()])
        values = list(data.values()) + [user_id]
        await conn.execute(f"UPDATE users SET {sets} WHERE id = ?", values)
        return await self.get_user(user_id)

    async def log_activity(self, user_id: str, activity_type: str, points: int, metadata: Optional[Dict] = None) -> Dict:
        import json
        conn = get_conn()

        # Insert activity log
        await conn.execute(
            "INSERT INTO activities VALUES (?,?,?,?,?,?)",
            [str(uuid.uuid4()), user_id, activity_type, points,
             json.dumps(metadata or {}), datetime.utcnow().isoformat()]
        )

        # Update points and counters
        now = datetime.utcnow().isoformat()
        if activity_type == "quran_read":
            await conn.execute(
                "UPDATE users SET points = points + ?, quran_progress = MIN(100.0, quran_progress + 0.88), updated = ? WHERE id = ?",
                [points, now, user_id]
            )
        elif activity_type == "prayer_logged":
            await conn.execute(
                "UPDATE users SET points = points + ?, prayers_logged = prayers_logged + 1, updated = ? WHERE id = ?",
                [points, now, user_id]
            )
        elif activity_type == "lesson_completed":
            await conn.execute(
                "UPDATE users SET points = points + ?, lessons_completed = lessons_completed + 1, updated = ? WHERE id = ?",
                [points, now, user_id]
            )
        else:
            await conn.execute(
                "UPDATE users SET points = points + ?, updated = ? WHERE id = ?",
                [points, now, user_id]
            )

        # Return updated user
        result = await conn.execute("SELECT * FROM users WHERE id = ?", [user_id])
        return row_to_user(result.rows[0])

    async def get_leaderboard(self, limit: int = 100, country: Optional[str] = None) -> List[Dict]:
        conn = get_conn()
        if country:
            result = await conn.execute(
                "SELECT id,username,country,points,avatar FROM users WHERE country = ? ORDER BY points DESC LIMIT ?",
                [country, limit]
            )
        else:
            result = await conn.execute(
                "SELECT id,username,country,points,avatar FROM users ORDER BY points DESC LIMIT ?",
                [limit]
            )

        return [
            {"rank": i+1, "user_id": r[0], "username": r[1],
             "country": r[2], "points": r[3], "avatar": r[4] or ""}
            for i, r in enumerate(result.rows)
        ]

    async def get_user_rank(self, user_id: str) -> Dict:
        user = await self.get_user(user_id)
        if not user:
            raise Exception("User not found")
        conn = get_conn()
        result = await conn.execute(
            "SELECT COUNT(*) FROM users WHERE points > ?", [user['points']]
        )
        count = result.rows[0][0]
        return {"rank": count + 1, "points": user['points'], "username": user['username']}


turso_client = TursoClient()
