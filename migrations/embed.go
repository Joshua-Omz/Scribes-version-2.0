package migrations

import "embed"

// Files embeds all SQL migration files from this directory.
//
//go:embed *.sql
var Files embed.FS
