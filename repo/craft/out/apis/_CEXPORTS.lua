-- This api only exists to replace the getfenv magic used by craft.lua.
-- This api is not meant to be used by anything else
return {
    paintutils = __LEGACY.paintutils,
    settings = __LEGACY.settings,
    textutils = __LEGACY.textutils,
    help = __LEGACY.help,
    require = __LEGACY.require,
    package = __LEGACY.package
}