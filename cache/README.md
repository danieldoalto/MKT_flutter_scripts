# Cache Directory

This directory contains cached script data from MikroTik routers.

## Purpose

The MikroTik SSH Script Runner caches discovered scripts locally to improve performance and provide offline access to script metadata. Each router has its own cache file containing information about discovered scripts.

## File Structure

```
cache/
├── scripts_[router_name].json    # Cached scripts for each router
└── README.md                     # This documentation file
```

## Cache File Format

Each `scripts_[router_name].json` file contains an array of script objects:

```json
[
  {
    "name": "mkt1_backup_config",
    "description": "Creates system backup with timestamp",
    "level": 1
  },
  {
    "name": "mkt2_reset_config", 
    "description": "Resets configuration (admin only)",
    "level": 2
  }
]
```

## Fields

- **name**: Script name following the `mkt<LEVEL>_` naming convention
- **description**: Script description extracted from MikroTik comment field
- **level**: Access level (1 or 2) determining user permissions

## Automatic Management

- **Creation**: Cache files are automatically created when "Update Scripts" is clicked
- **Updates**: Cache is refreshed each time "Update Scripts" is executed
- **Loading**: Cache is automatically loaded when selecting a router
- **Directory Creation**: The cache directory is created automatically if it doesn't exist

## Benefits

1. **Performance**: Avoids re-querying routers for script lists
2. **Offline Access**: View script names and descriptions without connection
3. **Quick Startup**: Instant script list availability when switching routers
4. **Reduced Network Load**: Minimizes SSH commands to routers

## Maintenance

Cache files can be safely deleted - they will be regenerated the next time "Update Scripts" is clicked for each respective router. The application handles missing cache files gracefully.