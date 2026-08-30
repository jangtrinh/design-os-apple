#!/bin/zsh

set -euo pipefail

project_root=${0:A:h:h}
cd "$project_root"

swift test
swift build -c release -Xswiftc -strict-concurrency=complete -Xswiftc -warnings-as-errors
swift format lint --recursive Sources Tests

print -- "Swift package tests, strict release build, and format passed."
