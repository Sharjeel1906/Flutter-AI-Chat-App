import google.generativeai as genai
from dotenv import load_dotenv
import os
from flask_cors import CORS
from flask import Flask, jsonify, request
from flask_login import UserMixin, login_required, current_user, LoginManager, login_user, logout_user
from google.api_core.exceptions import ResourceExhausted
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.orm import DeclarativeBase, mapped_column, Mapped, relationship
from sqlalchemy import Integer, String, DateTime, ForeignKey
from datetime import datetime, timezone
from flask_migrate import Migrate
from flask_bcrypt import generate_password_hash, check_password_hash
from flask import g

# ---------------- Flask Setup ----------------
app = Flask(__name__)
CORS(app)
app.config['SECRET_KEY'] = os.getenv("FLASK_SECRET") or "supersecretkey"


class Base(DeclarativeBase):
    pass


app.config['SQLALCHEMY_DATABASE_URI'] = "sqlite:///agent_data.db"
db = SQLAlchemy(model_class=Base)
db.init_app(app)
migrate = Migrate(app, db)

# Flask-Login setup
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = "login"


@login_manager.unauthorized_handler
def unauthorized():
    return jsonify({"status": "error", "message": "Unauthorized"}), 401


@login_manager.user_loader
def load_user(user_id):
    return db.session.get(User, int(user_id))


def get_or_create_guest_user():
    """Get or create guest user safely. Should be called during app initialization."""
    guest_user = User.query.filter_by(email="guest@system.local").first()
    if guest_user is None:
        guest_user = User(
            username="Guest",
            email="guest@system.local",
            password=generate_password_hash("guest123").decode('utf-8'),
        )
        db.session.add(guest_user)
        db.session.commit()
    return guest_user


@app.before_request
def attach_user():
    """Attach user to request context without modifying database."""
    if current_user.is_authenticated:
        g.user = current_user
    else:
        # Use guest user - query only, no commits
        guest_user = User.query.filter_by(email="guest@system.local").first()
        if guest_user is None:
            # If guest doesn't exist, create it (shouldn't happen after init)
            try:
                guest_user = get_or_create_guest_user()
            except Exception:
                # If creation fails (e.g., locked), use None and let endpoints handle it
                g.user = None
                return
        g.user = guest_user


# ---------------- Database Models ----------------
class User(UserMixin, db.Model):
    __tablename__ = "users"
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    username: Mapped[str] = mapped_column(String(100))
    email: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    password: Mapped[str] = mapped_column(String(100), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=lambda: datetime.now(timezone.utc),
                                                 onupdate=lambda: datetime.now(timezone.utc))

    sessions = relationship("Session", back_populates="user")


class Session(db.Model):
    __tablename__ = "sessions"
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[int] = mapped_column(Integer, ForeignKey("users.id"), nullable=True)
    title: Mapped[str] = mapped_column(String(200))
    created_at: Mapped[datetime] = mapped_column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=lambda: datetime.now(timezone.utc),
                                                 onupdate=lambda: datetime.now(timezone.utc))

    user = relationship("User", back_populates="sessions")
    messages = relationship("Message", back_populates="session",cascade="all, delete-orphan" )


class Message(db.Model):
    __tablename__ = "messages"
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    session_id: Mapped[int] = mapped_column(Integer, ForeignKey("sessions.id"), nullable=False)
    role: Mapped[str] = mapped_column(String(50))
    message: Mapped[str] = mapped_column(String(100000))
    created_at: Mapped[datetime] = mapped_column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=lambda: datetime.now(timezone.utc),
                                                 onupdate=lambda: datetime.now(timezone.utc))

    session = relationship("Session", back_populates="messages")


with app.app_context():
    db.create_all()
    # Ensure guest user exists at startup
    try:
        get_or_create_guest_user()
    except Exception as e:
        print(f"Warning: Could not create guest user: {e}")

# ---------------- AI Setup ----------------
load_dotenv()
genai.configure(api_key=os.getenv("AI_AGENT_API"))
# Change your model definition to this:
model = genai.GenerativeModel("gemini-2.5-flash-lite")
system_prompt = """
You are an AI assistant designed exclusively for entertainment and stress relief.
Your tone and personality must always be friendly, calm, light-hearted, emotionally understanding, and non-judgmental.
You are allowed to respond only with fun, relaxing, or comforting content such as jokes, humor, stories,
casual conversation, positive affirmations, riddles, games, and cheerful replies.
You must politely refuse and redirect if asked about serious, educational, professional, technical,
medical, legal, financial, political, or academic topics.
Your goal is to make the user feel relaxed, entertained, understood, and stress-free.
if someone is depressed your job is to relieve him from it by discussing great funny things that are ongoing in the world.
also if anybody want to talk about any sports your duty is to give best accurate news and company for this talk. Some 
people wants to chat with ai they share their info so also talk to them nicely and answers them accordingly. Your answer
 should not be too too long or too short your answer should be according to question type and do not give too long messages
"""


# ---------------- Chat Endpoint ----------------
@app.route("/chat", methods=["POST"])
def chat_endpoint():
    try:
        data = request.get_json(silent=True)
        if not data or "message" not in data:
            return jsonify({"message": "Invalid request", "session_id": None}), 400

        user_input = data["message"]
        session_id = data.get("session_id")

        if not hasattr(g, 'user') or g.user is None:
            return jsonify({"message": "Unauthorized", "session_id": None}), 401

        user_id = g.user.id
        if session_id:
            session_obj = db.session.get(Session, session_id)
            if not session_obj or session_obj.user_id != user_id:
                return jsonify({"message": "Invalid session", "session_id": None}), 400
        else:
            session_obj = Session(
                title=user_input[:50] if user_input else "New Session",
                user_id=user_id,
            )
            db.session.add(session_obj)
            db.session.commit()

        # Save user message
        user_msg = Message(
            session_id=session_obj.id,
            message=user_input,
            role="user"
        )
        db.session.add(user_msg)
        db.session.commit()

        history = [{"role": "model", "parts": [system_prompt]}]

        recent_messages = (
            Message.query
            .filter_by(session_id=session_obj.id)
            .order_by(Message.created_at.desc())
            .limit(10)
            .all()[::-1]
        )

        for msg in recent_messages:
            history.append({"role": msg.role, "parts": [msg.message]})

        # Chat with AI, handle ResourceExhausted
        try:
            chat = model.start_chat(history=history)
            response = chat.send_message(user_input)
            ai_text = response.text or "Sorry, I could not generate a response."
        except ResourceExhausted:
            ai_text = "AI service is temporarily unavailable. Please try again later."

        # Save AI message
        ai_msg = Message(
            session_id=session_obj.id,
            message=ai_text,
            role="model"
        )
        db.session.add(ai_msg)
        db.session.commit()

        return jsonify({
            "message": ai_text,
            "session_id": session_obj.id
        })

    except Exception as e:
        return jsonify({"message": f"Error: {str(e)}", "session_id": None}), 500


# ---------------- Sessions Endpoints ----------------
@app.route("/sessions", methods=["GET"])
@login_required  # ensures only authenticated users can access
def list_sessions():
    # At this point, current_user is guaranteed to be logged in
    sessions = (
        Session.query.filter_by(user_id=current_user.id)
        .order_by(Session.updated_at.desc())
        .all()
    )

    # Convert sessions to list of dicts
    session_list = [
        {
            "id": s.id,
            "title": s.title or f"Session #{s.id}",
            "last_message_time": s.updated_at.astimezone(timezone.utc).isoformat() if s.updated_at else None,
            "messages_count": len(s.messages)  # if you have a relationship
        }
        for s in sessions
    ]

    return jsonify(session_list)


@app.route("/get_sessions_messages/<int:session_id>", methods=["GET"])
def get_session_messages(session_id):
    # Get user (authenticated or guest)
    user = current_user if current_user.is_authenticated else (g.user if hasattr(g, 'user') and g.user else None)
    if not user:
        return jsonify({"message": "User not available"}), 500

    session_obj = Session.query.get_or_404(session_id, )

    # Ensure the session belongs to the current user
    if session_obj.user_id != user.id:
        return jsonify({"message": "Unauthorized access to this session"}), 403

    messages = [
        {"role": m.role, "message": m.message, "time": m.created_at.isoformat(),"id":m.id}
        for m in session_obj.messages
    ]

    return jsonify({
        "session_id": session_obj.id,
        "title": session_obj.title or f"Session #{session_obj.id}",
        "messages": messages
    })


# ---------------- Authentication Endpoints ----------------
@app.route("/register", methods=["POST"])
def register():
    try:
        data = request.get_json()
        username = data.get("name")
        email = data.get("email")
        if not username or not email or not data.get("password"):
            return jsonify({"status": "error", "message": "Missing fields"}), 400

        user = User.query.filter_by(email=email).first()
        if user:
            return jsonify({"status": "error", "message": "Email already registered"}), 400

        hashed_pass = generate_password_hash(data.get("password")).decode('utf-8')
        new_user = User(username=username, email=email, password=hashed_pass)
        db.session.add(new_user)
        db.session.commit()

        return jsonify({"status": "success", "message": "User Registered Successfully!"})

    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


@app.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    email = data.get("email")
    passw = data.get("password")

    if not email or not passw:
        return jsonify({"status": "error", "message": "Missing fields"}), 400

    result = db.session.execute(
        db.select(User).where(User.email == email)
    )
    user = result.scalar_one_or_none()
    if not user:
        return jsonify({
            "status": "error",
            "message": "Email Not Found! Please Register!"
        }), 401

    if not check_password_hash(user.password, passw):
        return jsonify({
            "status": "error",
            "message": "Wrong Password! Please Enter Correct Password!"
        }), 401

    login_user(user)

    return jsonify({
        "status": "success",
        "message": "You have logged in Successfully!",
        "name": user.username,  # ✅ CORRECT
        "id": user.id
    }), 200


@app.route("/logout", methods=['POST'])
def logout():
    logout_user()
    return jsonify({"status": "success", "message": "You have logged out Successfully!"}),200


@app.route("/delete_msg/<int:msg_id>", methods=["GET"])
def delete_msgs(msg_id):
    msg = Message.query.get(msg_id)
    if not msg:
        return jsonify({"message": "Message not found"}), 404

    try:
        db.session.delete(msg)
        db.session.commit()
        return jsonify({"message": "Message deleted successfully"}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"message": f"Error deleting message: {str(e)}"}), 500



@app.route("/delete_session/<int:session_id>", methods=['GET'])
def delete_sessions(session_id):
    session_to_delete = db.get_or_404(Session, session_id)
    db.session.delete(session_to_delete)
    db.session.commit()
    return jsonify({"message": f"Session {session_id} deleted successfully."})


# ---------------- Run App ----------------
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
