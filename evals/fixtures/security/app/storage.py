from uuid import UUID


def store_avatar(user_id: UUID, client_filename: str, contents: bytes) -> str:
    """Represent the existing public-object-store write without cloud credentials."""
    if not contents:
        raise ValueError("avatar content cannot be empty")
    # Fixture exposes key and serving choices for security review; no network I/O.
    object_key = f"avatars/{user_id}/{client_filename}"
    return f"https://assets.example.test/{object_key}"
