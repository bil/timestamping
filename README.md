# Trusted Timestamping for Scientific Research Data

This repository presents a [open source](https://en.wikipedia.org/wiki/Open_source) framework for leveraging [trusted timestamping](https://en.wikipedia.org/wiki/Trusted_timestamping) as defined in [RFC 3161](https://www.ietf.org/rfc/rfc3161.txt) in a manner suitable for providing data integrity assurances for scientific research data (or arbitrary files/data).

This frameworks permits a cryptographically secure way to prove that a specific version of a file (or directory of files) existed at the time of timestamping.
This can be helpful in demonstrating that a specific piece of scientific data has not been altered since the timestamp (e.g., shortly after acquisition/creation).
It can also be used to maintain an [electronic lab notebook](https://en.wikipedia.org/wiki/Electronic_lab_notebook) via timestamped git repositories.

## Timestamping Website: [timestamp.stanford.edu](https://timestamp.stanford.edu)

A website performing browser-based timestamping is available at [timestamp.stanford.edu](https://timestamp.stanford.edu).

This website supports the timestamping of files and directories through the browser.

All data hashing is performed in the browser, and the *only* content transmitted to the API is the hash to be timestamped.
Critically, **no data or information** is tranmitted to the API (besides the hash, which contains no meaningful information on its own).

Note, in-browser hashing means that very large data files will take time to process.
At the moment, there is a max individual file size constraint due to non-chunked reads (to be fixed).
Max individual file sizes vary depending on the browser, but are around 2-4GB.

Hashes submitted to the API and their respective timestamps are stored and made public on a daily basis at [timestamp-record](https://github.com/bil/timestamp-record).

## Binder Demo [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/bil/timestamping/HEAD)

A demo of the command-line tools is available via Binder.

Choose `Terminal`, under the `Other` section and navigate to the example directory.

From there, execute `./example.sh` to timestamp an example file and `./example.sh DIR` to timestamp an example directory and its contents.

## Timestamping git Repositories

The `post-commit` files in the `hooks` directory support the timestamping of git repositories.
The `post-commit.local` file performs timestamping locally, and requires the trustedtimestamping scripts to be installed/available on the local system.
The `post-commit.api` file performs timstamping via the API.

To use, copy the desired `post-commit` file to the `.git/hooks` directory of a given repository, ensuring it is named `post-commit`, and commit as normal.

Every manual commit will be followed by an automatic timestamp commit against the checksum of the repository HEAD.
A `.timestamps.json` file will be added to the root of the git repository.

Repository timestamps can validated by running `ttsVerify git` in any checked out timestamp commit revision.

Revisions to this repository are timestamped in this manner as an example and to validate the temporal history of the repository.

This framework permits a temporally-verifiable record of a git repository, suitable for an electornic lab notebook or other authoritative archive.
When a common repository is used by multiple individuals (and optionally coupled with [signed commits](https://git-scm.com/book/ms/v2/Git-Tools-Signing-Your-Work)), a cryptographically secure and unique record can be defended so long as at least one of the contributing individuals is truthful (up to the truthful individual's last commit, at least).

## DOI Integration

These timestamps are small enough that they can be embedded into DOIs for archiving.
An example is `10.25740/jc435yd3521`.
The timestamp associated with this DOI can be retrieved by `ttsDOI 10.25740/jc435yd3521`.

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

The scripts permit local configuration of TSA servers besides the default ones mentioned above.

A custom `TSA.source` and `CA` directory can be placed in `~/.config/trustedts` and will take priority over the defaults.
See the structure of `trustedtimestamping/etc/trustedts` for the file structure to be replicated.

## JSON Timestamps File Format

The field structure of the timestamps JSON file is mostly self-explanatory.
See the `.timestamps.json` as an example for a git-specific timestamp format.

The `format`, `version`, and `timestamps` fields are required.
All others are optional.

A hash field is optionally included for convenience of identifiability.
A time field was specifically omitted and must be derived from the timestamp replies.

### File Timestamps

File timestamps are derived by calculating the SHA256 digest of the file, generating the respective `sha256sum` compliant string, calculating the SHA256 digest of this string, and using this second digest as the value passed to the timestamp request.
This is done to 1) make immutable both the file's contents *and* its name and 2) maintain compatibility with the coreutils package.
The format of this compliant string is: `<32 byte SHA256 hash in lowercase><two spaces, 0x20><file name><line feed character (0x0A, \n)>`.

An example compliant string timestamp a single file appears as:
```
ca043731236ccd44998fb2e6b645a4ffb882a72318b06163a1a0b1d4c5204748  W241130.wav
```

### Directory Timestamps

Directory timestamps are generated in an identical fashion to file timestamps, except the `shas256sum` compliant string to be hashed contains multiple lines, one for each file (including path relative to top-level directory, and inclusive of this).
The hash digest calculation is sensitive to the ordering of these lines.
Thus, to simplify sorting and avoid platform-specific file listing sorting errors, these lines are sorted *by the digest* and not the file/directory name.

An example compliant string timestamp for a single directory with two files appears as:
```
03fb09b0660f246ed683c0c91f49684c203cb2c8f76ec9277f530e45f0fdb8db  W241130/W241130.yaml
ca043731236ccd44998fb2e6b645a4ffb882a72318b06163a1a0b1d4c5204748  W241130/W241130.wav
```

### Git Repository Timestamps

Git repositories are timestamped based on their commit ID.
The default hash format for a git repository is SHA1, which is then passed through SHA256.
While recent versions of git support SHA256, most git repository servers (e.g., GitHub, GitLab, etc) do not have support for repositories with SHA256 object formats.

SHA1 is not as secure as SHA256.
However, this is practically still safe since each commit will have its own timestamp, making the feasibility for a collision that replicates mutliple hashes across many commits difficult.
