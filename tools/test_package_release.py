"""Packaging guard tests; temporary fixtures only, no game or saves required."""
import copy
import json
from pathlib import Path
import tempfile
import unittest
import zipfile

import package_release as pack


class PackagingTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.payloads = {'mod.txt': b'[mod]\nversion="test"\n',
                         'rtv-lore-elements/': b'', 'rtv-lore-elements/Main.gd': b'extends Node\n'}
        self.manifest = {
            'schema': 1, 'file_count': 2,
            'zip': {'compression': 'DEFLATE', 'compresslevel': -1, 'create_system': 3,
                    'create_version': 20, 'extract_version': 20}, 'entries': [],
        }
        for name, data in self.payloads.items():
            entry = {'member': name, 'date_time': [2026, 10, 11, 0, 0, 0], 'external_attr': 25165824}
            if not name.endswith('/'):
                source = name.removeprefix('rtv-lore-elements/')
                entry.update(source=source, sha256=pack.sha(data), size_bytes=len(data))
                (self.root / source).write_bytes(data)
            self.manifest['entries'].append(entry)
        data = pack.archive_bytes(self.manifest, self.payloads)
        self.manifest.update(archive_size_bytes=len(data), archive_sha256=pack.sha(data))
        (self.root / pack.MANIFEST).parent.mkdir(parents=True)
        self.save_manifest()

    def save_manifest(self):
        (self.root / pack.MANIFEST).write_text(json.dumps(self.manifest), encoding='utf-8')

    def test_exact_rebuild(self):
        target = self.root / 'build/test.vmz'
        pack.build(target, self.root)
        self.assertEqual(pack.sha(target.read_bytes()), self.manifest['archive_sha256'])
        with zipfile.ZipFile(target) as archive:
            self.assertEqual(archive.namelist(), list(self.payloads))

    def test_ambient_private_file_excluded(self):
        (self.root / 'Character.tres').write_bytes(b'private fixture')
        target = self.root / 'test.vmz'
        pack.build(target, self.root)
        with zipfile.ZipFile(target) as archive:
            self.assertNotIn('Character.tres', archive.namelist())

    def test_changed_source_rejected_before_output(self):
        (self.root / 'Main.gd').write_bytes(b'changed')
        target = self.root / 'test.vmz'
        with self.assertRaisesRegex(ValueError, 'Source changed'):
            pack.build(target, self.root)
        self.assertFalse(target.exists())

    def test_missing_source_rejected(self):
        (self.root / 'Main.gd').unlink()
        with self.assertRaises(FileNotFoundError):
            pack.load_sources(self.root)

    def test_existing_output_preserved(self):
        target = self.root / 'test.vmz'
        target.write_bytes(b'keep')
        with self.assertRaises(FileExistsError):
            pack.build(target, self.root)
        self.assertEqual(target.read_bytes(), b'keep')

    def test_symlink_source_rejected(self):
        (self.root / 'Main.gd').unlink()
        (self.root / 'Main.gd').symlink_to(self.root / 'mod.txt')
        with self.assertRaisesRegex(ValueError, 'symlink'):
            pack.load_sources(self.root)

    def test_duplicate_member_rejected(self):
        self.manifest['entries'].append(copy.deepcopy(self.manifest['entries'][0]))
        self.save_manifest()
        with self.assertRaisesRegex(ValueError, 'Duplicate'):
            pack.load_sources(self.root)

    def test_parent_source_rejected(self):
        self.manifest['entries'][0]['source'] = '../mod.txt'
        self.save_manifest()
        with self.assertRaisesRegex(ValueError, 'Unsafe'):
            pack.load_sources(self.root)

    def test_absolute_member_rejected(self):
        self.manifest['entries'][0]['member'] = '/mod.txt'
        self.save_manifest()
        with self.assertRaisesRegex(ValueError, 'Unsafe'):
            pack.load_sources(self.root)

    def test_archive_extra_member_rejected(self):
        target = self.root / 'test.vmz'
        pack.build(target, self.root)
        with zipfile.ZipFile(target, 'a') as archive:
            archive.writestr('unlisted.txt', 'not allowed')
        with self.assertRaisesRegex(ValueError, 'members/order'):
            pack.verify_bytes(target.read_bytes(), self.manifest, self.payloads)

    def test_wrong_final_hash_rejected_before_output(self):
        self.manifest['archive_sha256'] = '0' * 64
        self.save_manifest()
        target = self.root / 'test.vmz'
        with self.assertRaisesRegex(ValueError, 'ZIP bytes differ'):
            pack.build(target, self.root)
        self.assertFalse(target.exists())


if __name__ == '__main__':
    unittest.main()
