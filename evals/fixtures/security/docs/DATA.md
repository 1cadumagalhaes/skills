# Data inventory (eval fixture)

This document describes fictional schema and flows; it contains no real personal data.

| Data | Source | Purpose | Storage | Retention/deletion |
| --- | --- | --- | --- | --- |
| Email, display name | Signup request | Account identity and contact | User database (not implemented in fixture) | Account lifetime; delete on account closure |
| CPF | Signup request | Identity verification (not implemented) | Not persisted by fixture; currently may enter application logs through signup error logging | Logs have no fixture retention policy; block collection and purge on incident |
| Password | Signup request | Authentication bootstrap | Not persisted by fixture; currently may enter application logs | Must never be logged; rotate if exposed |
| Avatar image | Authenticated upload | Profile display | Fictional public object store at assets.example.test | Delete object on account closure; retention period is not configured |
| Token id | Authorization header | Request authentication | In-memory synthetic fixture token table | Request-only; do not log bearer value |

Avatar URLs currently point at a public host and use client-controlled object names. The serving policy, content-disposition, CSP and deletion integration are not configured in this fixture.
