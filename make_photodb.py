"""This script is intended to be run on the server.  It will create,
update, analyze, and export the database of photos on the server."""

import sqlite3
import hashlib
import os
from datetime import datetime, timezone


# The root of the photos file system
ROOT = "/Users/regan/Desktop/Photos"  # Testing
# ROOT = "/volume1/share/Photos"  # Production

PHOTO_EXTS = ["jpg", "heic", "jpeg", "png", "bmp", "tif", "tiff", "gif"]

# database name (created in root)
NAME = "photos.db"

CREATE_TABLE = """CREATE TABLE IF NOT EXISTS photos (
    name TEXT,
    ext TEXT,
    path TEXT,
    size INTEGER,
    file_date TEXT,
    exif_date TEXT,
    hash TEXT
);"""
# Use rowid if needed instead an additional column
#    id INTEGER PRIMARY KEY AUTOINCREMENT,
INSERT_TABLE = """INSERT INTO photos
    (name, ext, path, size, file_date, exif_date, hash) VALUES
    (?, ?, ?, ?, ?, ?, ?);"""


def sha256sum(filename):
    """Creates a sha256 checksum for the contents of filename."""
    hasher = hashlib.sha256()
    with open(filename, "rb") as f:
        for chunk in iter(lambda: f.read(128 * hasher.block_size), b""):
            hasher.update(chunk)
    return hasher.hexdigest()


def create():
    """Create and populate a photos database."""
    connection = sqlite3.connect(os.path.join(ROOT, NAME))
    cursor = connection.cursor()
    exists = cursor.execute(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='photos';"
    )
    if exists.fetchall():
        print("photos database already exists")
        cursor.close()
        connection.close()
        return
    cursor.execute(CREATE_TABLE)
    # cursor.close()
    for dirpath, _, filenames in os.walk(ROOT):
        # cursor = connection.cursor()
        print(dirpath)
        for filename in filenames:
            name, ext = os.path.splitext(filename)
            if ext[1:].lower() in PHOTO_EXTS:
                fullname = os.path.join(dirpath, filename)
                file_size = os.path.getsize(fullname)
                timestamp = os.path.getmtime(fullname)
                file_date = datetime.fromtimestamp(
                    timestamp, tz=timezone.utc
                ).isoformat()
                file_hash = sha256sum(fullname)
                cursor.execute(
                    INSERT_TABLE,
                    (name, ext, dirpath, file_size, file_date, None, file_hash),
                )
                # print(name, ext, path, file_size, file_date, None, file_hash)
        # cursor.close()
    connection.commit()
    cursor.close()
    connection.close()


def query():
    """Test the database with a simple query"""
    connection = sqlite3.connect(os.path.join(ROOT, NAME))
    cursor = connection.cursor()
    print(connection.cursor().execute("select count(*) from photos;").fetchall())
    print(connection.cursor().execute("select * from photos limit 1;").fetchall())
    cursor.close()
    connection.close()


def find_dups():
    """Find duplicate checksums in the database.
    Note: the database reports every  dup twice: a,b and b,a.
    We order the pair in the tuple and then store in a set to remove
    the duplicate dups."""
    query = """SELECT p1.path || '/' || p1.name || p1.ext, p2.path || '/' || p2.name || p2.ext
              FROM photos AS p1 JOIN photos AS p2 ON p1.hash = p2.hash
              WHERE p1.rowid <> p2.rowid;"""
    connection = sqlite3.connect(os.path.join(ROOT, NAME))
    cursor = connection.cursor()
    dups = set()
    for a, b in connection.cursor().execute(query).fetchall():
        a = a.replace("/volume1/share/Photos/", "")
        b = b.replace("/volume1/share/Photos/", "")
        # This sort order will put the misc folders before the year photos
        if a > b:
            dups.add((a, b))
        else:
            dups.add((b, a))
    cursor.close()
    connection.close()
    dups = list(dups)
    dups.sort()
    for a, b in dups:
        print(f"{a}  ===  {b}")


if __name__ == "__main__":
    # create()
    # query()
    find_dups()
