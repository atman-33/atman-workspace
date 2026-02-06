#!/usr/bin/env python3
"""Switch oh-my-opencode.json model configurations using YAML-based mapping definitions."""

import json
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("Error: PyYAML is required. Install with: pip install pyyaml", file=sys.stderr)
    sys.exit(1)


def get_config_path():
    """Get the path to oh-my-opencode.json."""
    return Path.home() / ".config" / "opencode" / "oh-my-opencode.json"


def get_mappings_path():
    """Get the path to model-mappings.yml."""
    script_dir = Path(__file__).parent
    return script_dir.parent / "config" / "model-mappings.yml"


def load_mappings(mappings_path):
    """Load model mappings from YAML file."""
    with open(mappings_path, 'r', encoding='utf-8') as f:
        return yaml.safe_load(f)


def apply_mapping(config, section_name, mappings):
    """Apply model mappings to a section (agents or categories).
    
    Args:
        config: The configuration dict
        section_name: 'agents' or 'categories'
        mappings: Dict of model mappings, may contain "*" for wildcard
    """
    if section_name not in config:
        return
    
    # Check if wildcard "*" is used
    if "*" in mappings:
        wildcard_model = mappings["*"]
        for item in config[section_name].values():
            item['model'] = wildcard_model
    else:
        # Apply specific mappings
        for name, model in mappings.items():
            if name in config[section_name]:
                config[section_name][name]['model'] = model


def switch_mode(config_path, mappings_path, mode):
    """Switch to specified mode using mapping definitions.
    
    Args:
        config_path: Path to oh-my-opencode.json
        mappings_path: Path to model-mappings.yml
        mode: Mode name (e.g., 'default', 'economy')
    """
    # Load mappings
    mappings_data = load_mappings(mappings_path)
    
    if 'modes' not in mappings_data or mode not in mappings_data['modes']:
        available_modes = ', '.join(mappings_data.get('modes', {}).keys())
        print(f"Error: Mode '{mode}' not found in mappings.", file=sys.stderr)
        print(f"Available modes: {available_modes}", file=sys.stderr)
        sys.exit(1)
    
    mode_mappings = mappings_data['modes'][mode]
    
    # Load current config
    with open(config_path, 'r', encoding='utf-8') as f:
        config = json.load(f)
    
    # Apply mappings
    if 'agents' in mode_mappings:
        apply_mapping(config, 'agents', mode_mappings['agents'])
    
    if 'categories' in mode_mappings:
        apply_mapping(config, 'categories', mode_mappings['categories'])
    
    # Write updated config
    with open(config_path, 'w', encoding='utf-8') as f:
        json.dump(config, f, indent=2, ensure_ascii=False)
        f.write('\n')
    
    print(f"✓ Switched to {mode} mode")


def list_modes(mappings_path):
    """List available modes."""
    mappings_data = load_mappings(mappings_path)
    modes = mappings_data.get('modes', {}).keys()
    print("Available modes:")
    for mode in modes:
        print(f"  - {mode}")


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print("Usage: switch_models.py [mode_name|--list]", file=sys.stderr)
        print("  mode_name: Name of the mode to switch to (e.g., default, economy)", file=sys.stderr)
        print("  --list: List available modes", file=sys.stderr)
        sys.exit(1)
    
    arg = sys.argv[1]
    config_path = get_config_path()
    mappings_path = get_mappings_path()
    
    # Check if listing modes
    if arg == '--list':
        if not mappings_path.exists():
            print(f"Error: {mappings_path} not found", file=sys.stderr)
            sys.exit(1)
        list_modes(mappings_path)
        return
    
    # Validate paths
    if not config_path.exists():
        print(f"Error: {config_path} not found", file=sys.stderr)
        sys.exit(1)
    
    if not mappings_path.exists():
        print(f"Error: {mappings_path} not found", file=sys.stderr)
        sys.exit(1)
    
    # Switch mode
    switch_mode(config_path, mappings_path, arg)


if __name__ == '__main__':
    main()
