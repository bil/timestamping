# Trusted Timestamping for Scientific Research Data

This repository presents a framework for leveraging [trusted timestamping](https://en.wikipedia.org/wiki/Trusted_timestamping) as defined in [RFC 3161](https://www.ietf.org/rfc/rfc3161.txt) in a manner suitable for providing data integrity assurances for scientific research data (or arbitrary files/data).

## Timestamping Website: [timestamp.stanford.edu](https://timestamp.stanford.edu)

A website performing browser-based timestamping is available at [timestamp.stanford.edu](https://timestsamp.stanford.edu).

This website supports the timestamping of files and directories through the browser.

All data hashing is performed in the browser, and the *only* content transmitted to the API is the hash to be timestamped. Critically, **no data or information** is tranmitted to the API (besides the hash, which contains no traceable information). Note, in-browser hashing means that very large data files will take time to process. At the moment, there is a max individual file size constraint due to non-chunked reads (to be fixed). Max individual file sizes vary depending on the browser, but are around 2-4GB.

Hashes and their respective timestamps are stored and made public on a daily basis at `PENDING`.

## Binder Demo [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/bil/timestamping/HEAD)

Choose `Terminal`, under the `Other` section and navigate to the example directory.

From there, execute `./example.sh` to timestamp an example file and `./example.sh DIR` to timestamp an example directory and its contents.

## Timestamping git Repositories

The `post-commit` file in the `hooks` directory supports the addition of trusted timestamps to any git repository with this timestamping installed.

To use, copy the `post-commit` file to the `.git/hooks` directory of a given repository and commit as normal.

Every manual commit will be followed by an automatic timestamp commit against the checksum of the repository HEAD.

A `.timestamps.json` file will be added to the root of the git repository.

Repository timestamps can validated by running `ttsVerifyGit` against any checked out timestamp commit revision.

Revisions to this repository will be timestamped in this manner.
