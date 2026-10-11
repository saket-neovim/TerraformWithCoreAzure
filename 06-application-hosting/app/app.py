"""Lab 6 app exercise. Implement the runtime behavior described in README.md."""

# TODO: Serve HTTP on 127.0.0.1:8080 as an unprivileged service account.
# TODO: GET / returns a simple lab/version response.
# TODO: GET /health returns HTTP 200 without calling Key Vault.
# TODO: GET /ready obtains a token from IMDS using the UAMI client ID,
# reads the dummy secret from Key Vault, discards its value, and returns
# only {"secret_read": true} on success (HTTP 200), false on failure (HTTP 503).
# TODO: Use finite network timeouts and bounded retries for transient failures.
# TODO: Log a sanitized status and correlation ID to user-facility syslog.
# Never log tokens, authorization headers, or Key Vault response bodies.
# Do not use developer credentials, az login, or a stored client secret.


if __name__ == "__main__":
    raise SystemExit("Implement the Lab 6 app TODOs before deployment.")
