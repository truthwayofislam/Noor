import libsql_experimental as libsql
import os
import uuid
from datetime import datetime
from typing import Optional, List, Dict
from utils.auth import get_password_hash, verify_password

def get_conn():
    url = os.getenv("TURSO_DATABASE_URL")
    token = os.getenv("TURSO_AUTH_TOKEN")
    return libsql.connect(database=url, auth_token=token)

def init_db():
    conn = get_conn()
    conn.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id TEXT PRIMARY KEY,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            username TEXT NOT NULL,
            country TEXT NOT NULL,
            level TEXT DEFAULT 'Beginner',
            points INTEGER DEFAULT 0,
            streak_days INTEGER DEFAULT 0,
            quran_progress REAL DEFAULT 0.0,
            prayers_logged INTEGER DEFAULT 0,
            lessons_completed INTEGER DEFAULT 0,
            avatar TEXT DEFAULT '',
            created TEXT NOT NULL,
            updated TEXT NOT NULL
        )
    """)
    conn.execute("""
        CREATE TABLE IF NOT EXISTS activities (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            activity_type TEXT NOT NULL,
            points INTEGER NOT NULL,
            metadata TEXT DEFAULT '{}',
            created TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id)
        )
    """)
    conn.commit()

def row_to_user(row) -> Dict:
    keys = ['id','email','password','username','country','level','points',
            'streak_days','quran_progress','prayers_logged','lessons_completed',
            'avatar','created','updated']
    return dict(zip(keys, row))

class TursoClient:

    async def create_user(self, email: str, password: str, username: str, country: str, level: str) -> Dict:
        conn = get_conn()
        existing = conn.execute("SELECT id FROM users WHERE email = ?", [email]).fetchone()
        if existing:
            raise Exception("Email already exists")

        user_id = str(uuid.uuid4())
        now = datetime.utcnow().isoformat()
        hashed = get_password_hash(password)

        conn.execute(
            "INSERT INTO users VALUES (?,?,?,?,?,?,0,0,0.0,0,0,'',?,?)",
            [user_id, email, hashed, username, country, level, now, now]
        )
        conn.commit()
        return row_to_user(conn.execute("SELECT * FROM users WHERE id = ?", [user_id]).fetchone())

    async def authenticate_user(self, email: str, password: str) -> Optional[Dict]:
        conn = get_conn()
        row = conn.execute("SELECT * FROM users WHERE email = ?", [email]).fetchone()
        if not row:
            return None
        user = row_to_user(row)
        if not verify_password(password, user['password']):
            return None
        return user

    async def get_user(self, user_id: str) -> Optional[Dict]:
        conn = get_conn()
        row = conn.execute("SELECT * FROM users WHERE id = ?", [user_id]).fetchone()
        return row_to_user(row) if row else None

    async def update_user(self, user_id: str, data: Dict) -> Dict:
        conn = get_conn()
        data['updated'] = datetime.utcnow().isoformat()
        sets = ', '.join([f"{k} = ?" for k in data.keys()])
        values = list(data.values()) + [user_id]
        conn.execute(f"UPDATE users SET {sets} WHERE id = ?", values)
        conn.commit()
        return await self.get_user(user_id)

    async def log_activity(self, user_id: str, activity_type: str, points: int, metadata: Optional[Dict] = None) -> Dict:
        import json
        conn = get_conn()
        conn.execute(
            "INSERT INTO activities VALUES (?,?,?,?,?,?)",
            [str(uuid.uuid4()), user_id, activity_type, points,
             json.dumps(metadata or {}), datetime.utcnow().isoformat()]
        )

        update = {"points": (await self.get_user(user_id))['points'] + points}
        if activity_type == "quran_read":
            user = await self.get_user(user_id)
            update['quran_progress'] = min(100.0, user['quran_progress'] + 0.88)
        elif activity_type == "prayer_logged":
            user = await self.get_user(user_id)
            update['prayers_logged'] = user['prayers_logged'] + 1
        elif activity_type == "lesson_completed":
            user = await self.get_user(user_id)
            update['lessons_completed'] = user['lessons_completed'] + 1

        conn.commit()
        return await self.update_user(user_id, update)

    async def get_leaderboard(self, limit: int = 100, country: Optional[str] = None) -> List[Dict]:
        conn = get_conn()
        if country:
            rows = conn.execute(
                "SELECT id,username,country,points,avatar FROM users WHERE country = ? ORDER BY points DESC LIMIT ?",
                [country, limit]
            ).fetchall()
        else:
            rows = conn.execute(
                "SELECT id,username,country,points,avatar FROM users ORDER BY points DESC LIMIT ?",
                [limit]
            ).fetchall()

        return [
            {"rank": i+1, "user_id": r[0], "username": r[1],
             "country": r[2], "points": r[3], "avatar": r[4] or ""}
            for i, r in enumerate(rows)
        ]

    async def get_user_rank(self, user_id: str) -> Dict:
        user = await self.get_user(user_id)
        if not user:
            raise Exception("User not found")
        conn = get_conn()
        count = conn.execute(
            "SELECT COUNT(*) FROM users WHERE points > ?", [user['points']]
        ).fetchone()[0]
        return {"rank": count + 1, "points": user['points'], "username": user['username']}


turso_client = TursoClient()
