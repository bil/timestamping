# Trusted Timestamping for Scientific Research Data

This repository presents a framework for leveraging [trusted timestamping](https://en.wikipedia.org/wiki/Trusted_timestamping) as defined in [RFC 3161](https://www.ietf.org/rfc/rfc3161.txt) in a manner suitable for providing data integrity assurances for scientific research data (or arbitrary files/data).

## Timestamping Website: [timestamp.stanford.edu](https://timestamp.stanford.edu)

A website performing browser-based timestamping is available at [timestamp.stanford.edu](https://timestamp.stanford.edu).

This website supports the timestamping of files and directories through the browser.

All data hashing is performed in the browser, and the *only* content transmitted to the API is the hash to be timestamped.
Critically, **no data or information** is tranmitted to the API (besides the hash, which contains no meaningful information on its own).

Note, in-browser hashing means that very large data files will take time to process.
At the moment, there is a max individual file size constraint due to non-chunked reads (to be fixed).
Max individual file sizes vary depending on the browser, but are around 2-4GB.

Hashes and their respective timestamps submitted to the API are stored and made public on a daily basis at [timestamp-record](https://github.com/bil/timestamp-record).

## Binder Demo [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/bil/timestamping/HEAD)

Choose `Terminal`, under the `Other` section and navigate to the example directory.

From there, execute `./example.sh` to timestamp an example file and `./example.sh DIR` to timestamp an example directory and its contents.

## Timestamping git Repositories

The `post-commit` file in the `hooks` directory supports the addition of trusted timestamps to any git repository with this timestamping installed.

To use, copy the `post-commit` file to the `.git/hooks` directory of a given repository and commit as normal.

Every manual commit will be followed by an automatic timestamp commit against the checksum of the repository HEAD.
A `.timestamps.json` file will be added to the root of the git repository.

Repository timestamps can validated by running `ttsVerifyGit` against any checked out timestamp commit revision.

Revisions to this repository are timestamped in this manner as an example and to validate the temporal history of the repository as of commit ID `395bc18` on Dec 16, 2024.

This framework permits a temporally-verifiable record of a git repository, suitable for an electornic lab notebook or other authoritative archive.
When a common repository is used by multiple individuals (and optionally coupled with [signed commits](https://git-scm.com/book/ms/v2/Git-Tools-Signing-Your-Work)), a cryptographically secure and unique record can be defended so long as at least one of the contributing individuals is truthful (up to the truthful individual's last commit, at least).

## Debian/Ubuntu Package

A Debian/Ubuntu package is available in `build/deb`.

## Docker Container

A docker container is available in Docker Hub at [brainilab/timestamping](https://hub.docker.com/r/brainilab/timestamping) and can be pulled via `docker pull brainilab/timestamping`.

## Default Time Stamp Authority (TSA) Servers

This package ships with six default TSA servers:

* DigiCert
* IdenTrust
* GlobalSign
* Sectigo
* Microsoft
* Apple

All requests are timestamped by all six servers.
This applies to the shell scripts and the timestamping website.

All attempts will be made to maintain current Certificate Authority (CA) and Certificate Revocation Lists (CRLs) for these six TSAs.
Please file an issue if any of these are discovered to be out of date.

Note: Approximately a third to a half of the timestamps signed by the Microsoft TSA throw a `error:1B000068:ESS routines:find:ess cert id not found:../crypto/ess/ess_lib.c:280`.
The reason for this is still being investigated.

## Local Configuration

The shell scripts permit local configuration of TSA servers besides the default ones mentioned above.

A custom `TSA.source` and `CA` directory can be placed in `~/.config/trustedts` and will take priority over the defaults.
See the structure of `trustedtimestamping/etc/trustedts` for the file structure to be replicated.

## JSON Timestamps File Format

The field structure of the timestamps JSON file is mostly self-explanatory. See the `.timestamps.json` as an example for a git-specific timestamp format.

The `format`, `version`, and `timestamps` fields are required. All others are optional.

A hash field is optionally included for convenience of identifiability. A time field was specifically omitted and must be derived from the timestamp replies.

### File Timestamps

File timestamps are derived by calculating the SHA256 hash of the file, generating the respective `sha256sum` compliant string, calculating the SHA256 hash of this string, and using this second hash as the digest for the timestamp request.
This is done to 1) make immutable both the file's contents *and* its name and 2) maintain compatibility with the coreutils package.
The format of this string is: `<32 byte hash in lowercase><two spaces><file name><line feed character (\n)>`.

### Directory Timestamps

Directory timestamps are generated in an identical fashion to file timestamps, except the `shas256sum` compliant string contains multiple lines, one for each file. The order of these lines is important, and is sorted by file name alphabetically, shallow to deep.

### Git Repository Timestamps

Git repositories are timestamped based on their commit id.
The default hash format for a git repository is SHA1, which is then passed through SHA256.
While recent versions of git support SHA256, most git repository servers do not have support for repositories with SHA256 object formats.

SHA1 is not as secure as SHA256, however, this is practically still safe since each commit will have its own timestamp, making the feasibility for a collision that replicates all those hashes difficult.
