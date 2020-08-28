-------------------------------------------------------------------------------
-- API
-------------------------------------------------------------------------------

--- @class gl
--- @class al
--- @class net
--- @class options

--- @class sasl
--- @field gl gl
--- @field al al
--- @field net net
--- @field options options

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- @class LogLevelID

LOG_DEFAULT = nil
LOG_TRACE = nil
LOG_DEBUG = nil
LOG_INFO = nil
LOG_WARN = nil
LOG_ERROR = nil

--- Writes data to the log file using info-level.
--- @vararg data
function logInfo(data, ...) end;
sasl.logInfo = logInfo;

--- Writes data to the log file using warning-level.
--- @vararg data
function logWarning(data, ...) end;
sasl.logWarning = logInfo;

--- Writes data to the log file using error-level.
--- @vararg data
function logError(data, ...) end;
sasl.logError = logInfo;

--- Writes data to the log file using debug-level.
--- @vararg data
function logDebug(data, ...) end;
sasl.logDebug = logInfo;

--- Writes data to the log file using debug-level.
--- @vararg data
function logTrace(data, ...) end;
sasl.logTrace = logInfo;

--- Returns currently selected log level.
--- @return LogLevelID
function getLogLevel() end;
sasl.getLogLevel = getLogLevel;

--- Sets current log level for logger.
--- @param level LogLevelID
function setLogLevel(level) end;
sasl.setLogLevel = setLogLevel;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Returns value of system environment variable for current process.
--- @param name string
--- @return boolean, string
function getEnvVariable(name) end;
sasl.getEnvVariable = getEnvVariable;

--- Sets value of system environment variable (creates new, if it doesn't exist) for current process.
--- @param name string
--- @param value string
--- @return boolean
function setEnvVariable(name, value) end;
sasl.setEnvVariable = setEnvVariable;

--- Unsets environment variable for current process.
--- @param name string
--- @return boolean
function unsetEnvVariable(name) end;
sasl.unsetEnvVariable = unsetEnvVariable;

--- Returns the identifier of OS.
--- @return string
function getOS() end;
sasl.getOS = getOS;

--- Returns X-Plane version.
--- @return number
function getXPVersion() end;
sasl.getXPVersion = getXPVersion;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- @class FileEntry
--- @field name string
--- @field type string

--- Returns data about directories and files located in the specified path.
--- @param path string
--- @return FileEntry[]
function listFiles(path) end;
sasl.listFiles = listFiles;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------