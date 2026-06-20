# XelBob-tab v2.1.0 - Update Notes

## Major Changes & Improvements

### 1. ESX Initialization (BREAKING CHANGE)
**Old Method Removed:**
- `TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)` for old ESX versions is no longer used
- All ESX initialization now uses the modern export method

**New Method:**
```lua
ESX = exports['es_extended']:getSharedObject()
```

**Impact:** Requires ESX 1.2+ or newer. Old ESX 1.1 is no longer supported.

### 2. Security Fixes
- **XSS Prevention**: Added URL validation for all iframe URLs. Only http/https protocols are allowed.
- **URL Validation**: All web addresses are validated before being displayed.
- **Input Sanitization**: Server-side validation for custom app data before persistence.

### 3. Performance Optimizations
- **Model Loading Timeout**: Added 5-second timeout to prevent infinite loops if model fails to load.
- **Animation Loading Timeout**: Added timeout for animation dictionary loading.
- **Weather Caching**: Weather data is now cached for 30 seconds to reduce processing on every tablet open.
- **Reduced Wait Intervals**: Changed tight loops from `Wait(0)` to `Wait(10)` for better performance.

### 4. Job-Based Access Control (Now Active)
The `jobSites` configuration from config.lua is now properly enforced:
- Players can only see applications for their assigned job
- Police can access "COP app"
- Ambulance can access "SECOURS app"
- Default apps are visible to all jobs

### 5. Configuration Validation
Resource now validates configuration on startup:
- Checks if at least one access method (command or item) is enabled
- Verifies cd_easytime dependency and disables weather if missing
- Logs configuration errors to console

### 6. Keyboard Navigation
- Escape key properly closes the tablet
- Tab key is now intercepted to prevent browser navigation
- All keyboard events are properly handled

### 7. UI State Persistence
- Last viewed application is saved in browser localStorage
- When reopening the tablet, users return to their last viewed app (not always main menu)

### 8. Debug Mode
Added optional debug logging:
```lua
Config.Debug = false
```
Set to `true` to enable console logging for troubleshooting.

---

## File Changes Summary

### Lua Files
- **client.lua**: Complete refactor with error handling, timeouts, weather caching
- **server.lua**: ESX exports, job-based filtering, app persistence, config validation
- **config.lua**: New configurations for timeouts, debug mode, cache TTL

### NUI/Frontend Files
- **nui/assets/index.js**: URL validation, XSS prevention, keyboard navigation, state persistence
- **nui/assets/config.js**: Simplified structure for default apps only
- **nui/assets/style.css**: Complete styling (no changes to visual design)
- **nui/assets/color.css**: Complete color definitions (no changes)
- **nui/index.html**: Clean structure matching new logic

### Configuration Files
- **fxmanifest.lua**: Added data folder for apps_data.json
- **locales.lua**: Base locale initialization
- **locales/en.lua**: Expanded with UI strings
- **locales/fr.lua**: Expanded with UI strings
- **data/apps_data.json**: New file for storing custom apps (auto-created)

---

## New Configuration Options

```lua
Config.Debug = false
Config.ModelLoadTimeout = 5000
Config.AnimLoadTimeout = 5000
Config.WeatherCacheTTL = 30000

Config.DefaultSites = { ... }
Config.jobSites = { ... }
```

---

## Breaking Changes & Migration

### From v2.0.x to v2.1.0

1. **ESX Version Requirement**
   - Old ESX 1.1 is no longer supported
   - Minimum: ESX 1.2 or later

2. **config.js Structure**
   - Remove the old commented-out `sites` and `jobSites` from nui/assets/config.js
   - Replace with the simplified version provided
   - Job filtering is now handled server-side

3. **App Configuration**
   - Instead of manually editing config.js, use the future in-game editor
   - Custom apps are now stored in data/apps_data.json

---

## Installation Steps

1. **Backup old resource** (if updating from v2.0.x)

2. **Replace all files** with the new versions provided:
   - All .lua files
   - All NUI files
   - Updated fxmanifest.lua
   - Replace locale files
   - Keep your images folder (nui/img/*)

3. **Create data folder** (if it doesn't exist):
   ```
   resources/xelbob-tab/data/
   ```

4. **Verify fxmanifest.lua** includes the data folder:
   ```lua
   files {
       'data/apps_data.json'
   }
   ```

5. **Restart resource** and verify console has no errors

6. **Test functionality**:
   - Use command or item to open tablet
   - Check weather displays correctly
   - Verify job-based apps are filtered properly
   - Test closing with ESC key

---

## Known Limitations

- Custom app editor UI is not yet implemented (features ready on backend)
- Job filtering is done server-side, custom apps currently not restricted by job
- Weather display requires cd_easytime resource for real-time weather (optional)

---

## Future Features (Ready for Implementation)

The codebase is now prepared for:
- In-game app editor with save/delete functionality
- Admin-only editor mode
- Module-based architecture for easier maintenance
- Enhanced localization system

---

## Support & Debugging

**Enable debug mode in config.lua:**
```lua
Config.Debug = true
```

**Check console for errors:**
- ESX initialization issues
- Model loading failures
- Animation dictionary failures
- URL validation errors
- Config validation warnings

**Common Issues:**

1. **ESX not found**: Verify es_extended is started before xelbob-tab
2. **Tablet doesn't appear**: Check if prop model exists and animation dict is valid
3. **Apps not showing**: Verify job-based filtering in config.lua jobSites
4. **Weather not updating**: Enable cd_easytime resource and set Config.easytime = true

---

## Version Information

- **Version**: 2.1.0
- **Framework**: FiveM + ESX 1.2+
- **Lua Version**: Lua 5.4
- **Status**: Stable with security improvements

---

## Credits

- Original developers: Xelyos | Bob's&Co
- Security & optimization updates: 2024
