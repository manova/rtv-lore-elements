#!/usr/bin/env python3
"""Verify or reproduce the frozen 0.2.0 VMZ using only allowlisted source files."""
import argparse
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = Path('release/0.2.0/package-manifest.json')


def sha(data):
    return hashlib.sha256(data).hexdigest()


def relative_name(name):
    if not isinstance(name, str) or not name or '\\' in name:
        raise ValueError('Invalid relative path')
    path = PurePosixPath(name)
    if path.is_absolute() or '..' in path.parts or ':' in name or str(path) != name.rstrip('/'):
        raise ValueError('Unsafe relative path: ' + name)
    return path


def load_sources(root=ROOT):
    root = root.resolve()
    manifest = json.loads((root / MANIFEST).read_text(encoding='utf-8'))
    if manifest['schema'] != 1 or manifest['zip'] != {
        'compression': 'DEFLATE', 'compresslevel': -1, 'create_system': 3,
        'create_version': 20, 'extract_version': 20,
    }:
        raise ValueError('Unsupported package recipe')
    names = set()
    sources = set()
    payloads = {}
    for entry in manifest['entries']:
        member = entry['member']
        relative_name(member)
        if member in names:
            raise ValueError('Duplicate archive member: ' + member)
        names.add(member)
        if member.endswith('/'):
            if not member.startswith('rtv-lore-elements/') or 'source' in entry:
                raise ValueError('Unexpected archive directory: ' + member)
            payloads[member] = b''
            continue
        source = entry['source']
        path = root / relative_name(source)
        expected_member = source if source == 'mod.txt' else 'rtv-lore-elements/' + source
        if member != expected_member or source in sources:
            raise ValueError('Invalid source mapping: ' + source)
        sources.add(source)
        if path.is_symlink() or not path.resolve().is_relative_to(root):
            raise ValueError('Source symlink/escape: ' + source)
        data = path.read_bytes()
        if len(data) != entry['size_bytes'] or sha(data) != entry['sha256']:
            raise ValueError('Source changed: ' + source)
        payloads[member] = data
    if len(sources) != manifest['file_count']:
        raise ValueError('Source file count differs')
    return manifest, payloads


def archive_bytes(manifest, payloads):
    buffer = io.BytesIO()
    with zipfile.ZipFile(buffer, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=-1) as archive:
        for entry in manifest['entries']:
            info = zipfile.ZipInfo(entry['member'], tuple(entry['date_time']))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.create_system = manifest['zip']['create_system']
            info.create_version = manifest['zip']['create_version']
            info.extract_version = manifest['zip']['extract_version']
            info.external_attr = entry['external_attr']
            archive.writestr(info, payloads[entry['member']])
    return buffer.getvalue()


def verify_bytes(data, manifest, payloads):
    with zipfile.ZipFile(io.BytesIO(data)) as archive:
        if archive.namelist() != [entry['member'] for entry in manifest['entries']]:
            raise ValueError('Archive members/order differ')
        for entry in archive.infolist():
            if archive.read(entry) != payloads[entry.filename]:
                raise ValueError('Archive payload changed: ' + entry.filename)
    if len(data) != manifest['archive_size_bytes'] or sha(data) != manifest['archive_sha256']:
        raise ValueError('Payload matches but ZIP bytes differ; check the Python/zlib toolchain. '
                         'This is not the frozen release artifact.')


def build(output, root=ROOT):
    manifest, payloads = load_sources(root)
    data = archive_bytes(manifest, payloads)
    verify_bytes(data, manifest, payloads)
    # Exclusive creation: never overwrite the frozen download or another result.
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open('xb') as target:
        target.write(data)
    return manifest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    action = parser.add_mutually_exclusive_group()
    action.add_argument('--output', type=Path, help='create a new exact VMZ; refuses an existing path')
    action.add_argument('--verify-archive', type=Path, help='check an existing VMZ without writing it')
    args = parser.parse_args()
    try:
        if args.output is not None:
            manifest = build(args.output)
        else:
            manifest, payloads = load_sources()
            if args.verify_archive is not None:
                verify_bytes(args.verify_archive.read_bytes(), manifest, payloads)
        print('PASS:', manifest['file_count'], 'allowlisted source files;',
              'exact archive verified' if args.output or args.verify_archive else 'source hashes verified')
        print('Frozen VMZ SHA256:', manifest['archive_sha256'])
    except (ValueError, KeyError, OSError, zipfile.BadZipFile) as error:
        print('FAIL:', error, file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
