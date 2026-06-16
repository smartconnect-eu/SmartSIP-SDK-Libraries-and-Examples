// Re-export Linphone binary modules through the `linphonesw` shim target.
// This preserves existing SDK imports: `import linphonesw`.

#if canImport(linphone)
@_exported import linphone
#endif

#if canImport(bellesip)
@_exported import bellesip
#endif

#if canImport(belcard)
@_exported import belcard
#endif

#if canImport(belr)
@_exported import belr
#endif

#if canImport(mediastreamer2)
@_exported import mediastreamer2
#endif

#if canImport(ortp)
@_exported import ortp
#endif
