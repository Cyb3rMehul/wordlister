# Wordlister

A lightweight Bash wordlist builder that extracts useful word candidates from source files, filters noise, removes duplicates, and builds a reusable wordlist.

## Features

* Extracts word-like candidates
* Cleans and filters noise
* Removes duplicates
* Merges with an existing wordlist
* Lightweight and dependency-free beyond standard Unix utilities

## Usage

```bash
chmod +x wordlister.sh
./wordlister.sh source.js
```

Specify a custom output file:

```bash
./wordlister.sh source.js wordlist.txt
```

Default output:

```text
filtered_words.txt
```

## Requirements

* Bash
* `grep`
* `tr`
* `sed`
* `sort`
* `wc`
* `mktemp`

Useful for **bug bounty reconnaissance, fuzzing, and custom wordlist generation**.
