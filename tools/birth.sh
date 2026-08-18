#!/usr/bin/env bash
# The mechanical half of a birth. Judgment stays with Nova: this script only
# scaffolds. Run it from a local clone of the starter repo.
#
#   bash tools/birth.sh <agent-name> <steward|keeper|host> <destination-dir>
#
# It creates the folders, assembles a draft CLAUDE.md (becoming + role, with
# raiser-facing preambles stripped), copies the library in, seeds pending.md's
# header, and prints every [SLOT] left for Nova to fill. It never overwrites
# an existing CLAUDE.md, and it does not write GRANTS.md, the first memory, or
# pending.md's first real line: those are authored, not scaffolded.
set -euo pipefail

if [ $# -ne 3 ]; then
  echo "usage: bash tools/birth.sh <agent-name> <steward|keeper|host> <destination-dir>" >&2
  exit 2
fi

NAME=$1
ROLE=$2
DEST=$3
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

case "$ROLE" in
  steward|keeper|host) ;;
  *) echo "role must be steward, keeper, or host (got: $ROLE)" >&2; exit 2 ;;
esac

if [ -e "$DEST/CLAUDE.md" ]; then
  echo "refusing: $DEST/CLAUDE.md already exists" >&2
  exit 1
fi

mkdir -p "$DEST/memory" "$DEST/drafts" "$DEST/reports"
cp -R "$REPO_DIR/library" "$DEST/library"

# Assemble the rulebook: title + birth date, then each template with
# everything above its first --- (titles, provenance, raiser preambles)
# removed.
{
  echo "# ${NAME}'s rulebook"
  echo
  echo "Born $(date +%Y-%m-%d)."
  echo
  sed '1,/^---$/d' "$REPO_DIR/templates/becoming.md"
  echo
  sed '1,/^---$/d' "$REPO_DIR/templates/${ROLE}.md"
} > "$DEST/CLAUDE.md"

touch "$DEST/memory/MEMORY.md"

cat > "$DEST/pending.md" <<'EOF'
# Pending

Anything needing the human or a fuller session becomes one dated checkbox
line here, tagged NEEDS <their name> or NEEDS SESSION.
EOF

echo "scaffolded: $DEST"
echo
echo "still Nova's to do:"
echo "  1. fill every slot below, in the human's words"
echo "  2. substitute role vocabulary, prune sections with no referent, fix breakage"
echo "  3. author GRANTS.md, memory/ first memory + MEMORY.md line, pending.md first line"
echo "  4. verify: the two greps below must both come back clean"
echo
echo "slots remaining:"
grep -nE '\[[A-Z]' "$DEST/CLAUDE.md" || echo "  (none found, which is itself suspicious: check the assembly)"
echo
echo "raiser-text check (must print nothing):"
grep -niE 'for the raiser|raising agents starter|nothing in it is theory' "$DEST/CLAUDE.md" || true
