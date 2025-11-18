#!/usr/bin/env bash
set -euo pipefail

# Generates a skeleton post in _posts/ using the current timestamp
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)
POSTS_DIR="${REPO_ROOT}/_posts"
TITLE="$*"

if [[ ! -d "${POSTS_DIR}" ]]; then
  echo "Posts directory not found: ${POSTS_DIR}" >&2
  exit 1
fi

current_date=$(date +"%Y-%m-%d")
date_suffix=$(date +"%Y%m%d")
timestamp=$(date +"%Y-%m-%d %H:%M:%S %z")
prefix="${current_date}-${date_suffix}"

shopt -s nullglob
max_seq=0
for file in "${POSTS_DIR}/${prefix}"*.markdown; do
  base=$(basename "${file}" .markdown)
  suffix="${base#${prefix}}"
  if [[ "${suffix}" =~ ^[0-9]+$ ]]; then
    value=$((10#${suffix}))
    if (( value > max_seq )); then
      max_seq=${value}
    fi
  fi
done
shopt -u nullglob

next_seq=$(printf "%02d" $((max_seq + 1)))
filename="${prefix}${next_seq}.markdown"
filepath="${POSTS_DIR}/${filename}"

title_line="title:"
if [[ -n "${TITLE}" ]]; then
  title_line="title: ${TITLE}"
fi

cat <<EOF2 > "${filepath}"
---
layout: post
${title_line}
date: ${timestamp}
description:
img:  # Add image post (optional)
tags: [] # add tag
---

EOF2

echo "Created ${filepath}"
