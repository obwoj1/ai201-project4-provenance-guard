"""Audit log for Provenance Guard.

Persists every classification to a local ``audit_log.json`` file as an
append-only list of entries, and supports reading the full log back.
"""

import json
import os

LOG_FILE = "audit_log.json"


def write_log(entry: dict):
    """Append a classification entry to the audit log file.

    If ``audit_log.json`` does not exist, it is created with an empty list
    first. The provided ``entry`` dict is appended and the whole file is
    rewritten.
    """
    if not os.path.exists(LOG_FILE):
        with open(LOG_FILE, "w") as f:
            json.dump([], f)

    entries = read_log()
    entries.append(entry)
    with open(LOG_FILE, "w") as f:
        json.dump(entries, f, indent=2)


def read_log():
    """Read and return the full list of audit log entries.

    Returns an empty list if the log file does not exist or cannot be parsed.
    """
    if not os.path.exists(LOG_FILE):
        return []
    try:
        with open(LOG_FILE, "r") as f:
            return json.load(f)
    except (json.JSONDecodeError, ValueError):
        return []
