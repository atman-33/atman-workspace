# Multi-Repository Code Review Guidelines

Use this checklist when reviewing changes across multiple repositories.

## Cross-Repository Consistency

### API Contract Alignment

- [ ] **Endpoint paths match** - Frontend calls match backend route definitions
- [ ] **HTTP methods consistent** - GET/POST/PUT/DELETE usage aligned across repos
- [ ] **Request payloads** - Frontend request bodies match backend expectations
- [ ] **Response structures** - Backend responses match frontend type definitions
- [ ] **API versioning** - Version numbers aligned across all repos
- [ ] **Error response formats** - Consistent error structure (status codes, messages)

### Type Definitions

- [ ] **Shared types synchronized** - Common types defined consistently
- [ ] **Interface contracts** - TypeScript interfaces match across repos
- [ ] **Enum values** - Enumeration values identical in all repos
- [ ] **Optional vs required fields** - Field requirements consistent
- [ ] **Data validation rules** - Validation logic matches type definitions

### Authentication & Authorization

- [ ] **Auth flow intact** - Login/logout flow works across frontend/backend
- [ ] **Token handling** - JWT/session tokens used consistently
- [ ] **Permission checks** - Authorization checks present in all layers
- [ ] **Redirect behavior** - Auth redirects consistent across repos

## Code Quality Standards

### Security

- [ ] **No hardcoded secrets** - API keys, passwords, tokens not in code
- [ ] **Environment variables** - Sensitive data in env vars, not committed
- [ ] **Input validation** - All user inputs validated
- [ ] **SQL injection protection** - Parameterized queries used
- [ ] **XSS prevention** - Output properly escaped

### Error Handling

- [ ] **Error propagation** - Errors properly caught and logged
- [ ] **User-facing messages** - Friendly error messages for users
- [ ] **Logging standards** - Consistent log levels and formats
- [ ] **Error boundaries** - Frontend error boundaries present

### Performance

- [ ] **Database queries** - No N+1 queries introduced
- [ ] **API response times** - No blocking operations in request handlers
- [ ] **Bundle size** - Frontend bundle size not significantly increased
- [ ] **Caching strategy** - Appropriate use of caching

## Dependency Management

### Version Compatibility

- [ ] **Shared library versions** - Same version of shared libs used across repos
- [ ] **Breaking changes documented** - If shared lib updated, breaking changes noted
- [ ] **Package lock files** - Lock files updated (package-lock.json, yarn.lock)
- [ ] **Peer dependencies** - Peer dependency requirements met

### Deprecations

- [ ] **Deprecated APIs** - No use of deprecated functions/endpoints
- [ ] **Migration path** - If deprecating, migration guide provided

## Integration Points

### Data Flow

- [ ] **Data consistency** - Same data structure through entire flow
- [ ] **State management** - Frontend state matches backend state
- [ ] **Real-time updates** - WebSocket/SSE events handled correctly

### Configuration

- [ ] **Environment consistency** - Config values match across repos (dev/staging/prod)
- [ ] **Feature flags** - Feature flag states synchronized
- [ ] **Service URLs** - Backend URLs configured correctly in frontend

## Testing

- [ ] **Test coverage** - Critical paths have tests
- [ ] **Integration tests** - Cross-repo integration tested
- [ ] **E2E tests** - End-to-end flows verified

## Documentation

- [ ] **API docs updated** - OpenAPI/Swagger specs current
- [ ] **README updated** - Setup instructions accurate
- [ ] **Migration notes** - Breaking changes documented

## Repository-Specific Checks

### Frontend Repository

- [ ] **Component props** - Props match backend response structure
- [ ] **Route definitions** - Routes align with backend endpoints
- [ ] **API client** - HTTP client calls use correct types

### Backend Repository

- [ ] **Route handlers** - Handlers return types matching frontend expectations
- [ ] **Database schema** - Schema changes reflected in API responses
- [ ] **Middleware** - Auth middleware applied consistently

### Shared Repository

- [ ] **Type exports** - All necessary types exported
- [ ] **Breaking changes** - Major version bump if breaking changes
- [ ] **Backward compatibility** - Deprecation warnings for old APIs
