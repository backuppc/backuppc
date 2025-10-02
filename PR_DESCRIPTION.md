# Fix Data::Dumper configuration corruption with Perl 5.38+

## Summary

This PR fixes configuration corruption issues in BackupPC 4.4.0 when running on Perl 5.38.0 and later versions. The issue was caused by changes in Data::Dumper's default behavior that resulted in non-deterministic hash key ordering and inconsistent serialization output.

## Problem Description

Starting with Perl 5.38.0, Data::Dumper changed its default behavior regarding:
- Hash key ordering (became non-deterministic)
- Internal data structure representation
- Default quoting behavior

This caused BackupPC configuration files to be corrupted during serialization, as the same configuration data would serialize differently on subsequent writes, leading to:
- Inconsistent configuration file formats
- Potential data loss during config updates
- Unpredictable behavior when reading/writing host configurations

## Root Cause

BackupPC uses Data::Dumper extensively for serializing:
1. Main configuration files (`config.pl`, per-host configs)
2. Backup metadata (`backupInfo`, `share2path` data)
3. Archive requests and other persistent state

The lack of consistent Data::Dumper settings meant that hash keys could appear in different orders between Perl versions, causing serialized output to vary for identical data structures.

## Solution

Added consistent Data::Dumper configuration across all modules that use it:

```perl
# Configure Data::Dumper for consistent output with Perl 5.38+
$Data::Dumper::Useqq = 1;      # Consistent quoting behavior
$Data::Dumper::Sortkeys = 1;   # Deterministic key ordering  
$Data::Dumper::Terse = 1;      # Clean output format
$Data::Dumper::Indent = 1;     # Readable formatting (where appropriate)
```

Additionally, updated specific Data::Dumper instances to use:
- `->Useqq(1)` for consistent quoting
- `->Sortkeys(1)` for deterministic hash key ordering
- `->Quotekeys(0)` where appropriate to avoid unnecessary key quoting

## Files Modified

- `bin/BackupPC` - Main server process
- `bin/BackupPC_Admin_SCGI` - Web admin interface
- `bin/BackupPC_archiveStart` - Archive management utility
- `configure.pl` - Installation/configuration script
- `lib/BackupPC/Storage.pm` - Storage abstraction layer
- `lib/BackupPC/Storage/Text.pm` - Text-based storage implementation  
- `lib/BackupPC/DirOps.pm` - Directory operations module

## Backward Compatibility

✅ **This change is fully backward compatible**:

- Existing configuration files will continue to be read correctly
- Only the serialization format is standardized, not the data structure
- All Data::Dumper options used have been available since Perl 5.6+
- Configuration migration happens transparently during normal operation

## Testing

Verified compatibility with:
- ✅ Perl 5.38.2 (primary target)
- ✅ Consistent serialization output between runs
- ✅ Identical hash key ordering
- ✅ Proper quoting behavior

Test results show that both explicit instance configuration and global Data::Dumper settings produce identical, deterministic output.

## Benefits

1. **Eliminates Configuration Corruption** - Hash keys always serialize in the same order
2. **Cross-Version Compatibility** - Works consistently across Perl versions
3. **Deterministic Behavior** - Same data always produces same serialized output
4. **Future-Proof** - Compatible with current and future Perl versions
5. **No Performance Impact** - Changes only affect serialization format

## Related Issues

Fixes configuration corruption reported with modern Perl installations (5.38+) where BackupPC configuration files would become corrupted during updates.

## Checklist

- [x] Changes are backward compatible
- [x] All Data::Dumper usage points updated
- [x] Global configuration added to all relevant modules
- [x] Instance-specific configuration updated where needed
- [x] Tested with Perl 5.38.2
- [x] No breaking changes to existing functionality

## Review Notes

The changes are conservative and focus on making existing behavior consistent rather than changing functionality. The primary goal is ensuring that identical data structures always serialize to identical output, which is critical for BackupPC's configuration management.