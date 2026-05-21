# various-scripts
A collection of small utility scripts for everyday tasks.

## Scripts

### [bash/heic-to-jpeg.sh](bash/heic-to-jpeg.sh)
Batch-converts HEIC images to JPEG using `sips` (macOS) and strips all metadata via `exiftool`.

**Dependencies:** `exiftool` (`brew install exiftool`)

```
./heic-to-jpeg.sh <input_folder> <output_folder>
```

---

### [bash/create-test-files.sh](bash/create-test-files.sh)
Creates a given number of files of a specified size, useful for testing storage, transfer, or tooling.

**Options:**

| Flag | Required | Description |
|------|----------|-------------|
| `--count <n>` | Yes | Number of files to create |
| `--size <size>` | Yes | Size per file — no suffix = bytes, `k`/`K` = KB, `m`/`M` = MB (e.g. `1024`, `1k`, `10M`) |
| `--prefix <prefix>` | No | Filename prefix (default: `testfile_`) |
| `--suffix <ext>` | No | File extension without dot (e.g. `txt`, `bin`) — omit for no extension |
| `--content <type>` | No | `pattern` (default) — repeating `0-9 a-z` sequence; `random` — random bytes |
| `--output-dir <dir>` | No | Directory to create files in (default: current directory) |

Files are zero-padded to match the digit width of `--count` (e.g. `--count 25` produces `testfile_01` … `testfile_25`).

```
# 25 files of 1 MB each with a .bin extension
./create-test-files.sh --count 25 --size 1M --suffix bin

# 5 files with a custom prefix and random content
./create-test-files.sh --count 5 --size 512k --prefix my-file- --content random --output-dir /tmp/testdata
```
