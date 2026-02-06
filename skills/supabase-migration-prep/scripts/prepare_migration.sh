#!/bin/bash
# Supabase Migration Preparation Script
# Creates backup and generates migration file from local-cloud diff

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "$1"
}

# Check if PROJECT_REF is provided
if [ -z "$1" ]; then
    print_error "PROJECT_REF is required"
    echo "Usage: $0 <PROJECT_REF> [migration_name]"
    echo "Example: $0 abcdefghijklmnop add_profile_fields"
    exit 1
fi

PROJECT_REF=$1
MIGRATION_NAME=${2:-"schema_update"}
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

print_info "=========================================="
print_info "Supabase Migration Preparation"
print_info "=========================================="
print_info "PROJECT_REF: $PROJECT_REF"
print_info "MIGRATION_NAME: $MIGRATION_NAME"
print_info "TIMESTAMP: $TIMESTAMP"
print_info ""

# Step 1: Create backup directory
print_info "📁 Creating backup directory..."
mkdir -p supabase/backup
print_success "Backup directory ready"
print_info ""

# Step 2: Login to Supabase (if not already logged in)
print_info "🔐 Checking Supabase authentication..."
if npx supabase projects list &> /dev/null; then
    print_success "Already authenticated"
else
    print_warning "Not authenticated. Please login..."
    npx supabase login
fi
print_info ""

# Step 3: Link project
print_info "🔗 Linking to Supabase project..."
npx supabase link --project-ref "$PROJECT_REF"
print_success "Project linked successfully"
print_info ""

# Step 4: Create full backup
print_info "💾 Creating full backup (roles, schema, data)..."

# Roles
ROLES_FILE="supabase/backup/roles_${TIMESTAMP}.sql"
npx supabase db dump -f "$ROLES_FILE" --role-only
print_success "Roles backup: $ROLES_FILE"

# Schema (default behavior)
SCHEMA_FILE="supabase/backup/schema_${TIMESTAMP}.sql"
npx supabase db dump -f "$SCHEMA_FILE"
print_success "Schema backup: $SCHEMA_FILE"

# Data
DATA_FILE="supabase/backup/data_${TIMESTAMP}.sql"
npx supabase db dump -f "$DATA_FILE" --use-copy --data-only
print_success "Data backup: $DATA_FILE"

print_info ""

# Step 5: Start local Supabase instance
print_info "🚀 Starting local Supabase instance..."
print_warning "This may take a few minutes on first run"
print_warning "If you have docker-compose running, it may cause port conflicts"
npx supabase start
print_success "Local Supabase instance started"
print_info ""

# Step 6: Apply local schema to instance
print_info "🔄 Applying local schema to Supabase instance..."
npx supabase db reset
print_success "Local schema applied"
print_info ""

# Step 7: Check for differences
print_info "🔍 Checking for differences..."
if npx supabase db diff > /dev/null 2>&1; then
    print_warning "No differences detected between local and remote"
    print_info "If you expected changes, make sure to:"
    print_info "  1. Edit local schema files (e.g., supabase/schema.sql)"
    print_info "  2. Run this script again"
else
    # Step 8: Generate migration file
    print_info "📝 Generating migration file..."
    npx supabase db diff -f "$MIGRATION_NAME"

    # Find the generated migration file
    MIGRATION_FILE=$(ls -t supabase/migrations/*_${MIGRATION_NAME}.sql 2>/dev/null | head -n 1)

    if [ -n "$MIGRATION_FILE" ]; then
        print_success "Migration file created: $MIGRATION_FILE"
    else
        print_error "Migration file not found. Check supabase/migrations/ directory"
    fi
fi
print_info ""

# Final summary
print_info "=========================================="
print_info "✅ Migration Preparation Complete"
print_info "=========================================="
print_info "📦 Backups created:"
print_info "  - Roles:  $ROLES_FILE"
print_info "  - Schema: $SCHEMA_FILE"
print_info "  - Data:   $DATA_FILE"
if [ -n "$MIGRATION_FILE" ]; then
    print_info "📝 Migration: $MIGRATION_FILE"
fi
print_info ""
print_warning "⚠️  IMPORTANT: Migration NOT applied yet"
print_info "Please review the migration file before applying"
print_info ""
print_info "Next steps:"
print_info "  1. Review migration file"
print_info "  2. Apply migration: npx supabase db push"
print_info "  3. Stop local instance: npx supabase stop"
print_info ""
