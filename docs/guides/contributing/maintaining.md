# Maintainer Guide

This guide is intended for collaborators on this repository, but you could read
it too :D

## Creating a Release

To create a new release, either run the [`scripts/release`](/scripts/release)
bash script or run the `Release` action from the GitHub actions tab
([here](https://github.com/beckn/bap-reference-app/actions)).

All sources will be updated and a release will be created every week on Tuesday
evening (at 17:42) automatically.

## Updating the Sources

To update all the sources, run the [`scripts/sources`](/scripts/sources) bash
script and push the resulting change using `git push`.

## Building the Images

To build any image, run the [`scripts/build`](/scripts/build) script with the
names of the images to build (separated by spaces). If no targets are specified,
then the script builds all of them.

A list of valid image names:

- `bap-base`
- `bap-protocol-helper`
- `bap-client`
- `bap-storefront`
