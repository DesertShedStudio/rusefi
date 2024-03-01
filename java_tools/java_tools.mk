JAVA_TOOLS = $(PROJECT_DIR)/../java_tools

# We run multiple processes in parallel by passing the -j option to Make.
# If multiple recipes call Gradle, it is likely that those recipes will be executed in parallel.
# Gradle jobs do not like being run in parallel; it causes all kinds of nonsense errors.
# To solve this, we use flock. Flock checks if a file is locked. If it is, it waits until it isn't.
# Once it isn't locked, it locks it, runs the command, then unlocks it once the command is finished.
# Note that flock doesn't ship on macOS. You can install it with `brew install flock`
# On Windows, flock comes with Cygwin.
FLOCK = flock /tmp/java.lock

FIELDS =   $(PROJECT_DIR)/../java_console/models/src/main/java/com/rusefi/config/generated/Fields.java

CONFIG_DEFINITION = $(JAVA_TOOLS)/configuration_definition/build/libs/config_definition-all.jar
CONFIG_DEFINITION_BASE = $(JAVA_TOOLS)/configuration_definition_base/build/libs/config_definition_base-all.jar
ENUM_TO_STRING = $(JAVA_TOOLS)/enum_to_string/build/libs/enum_to_string-all.jar
CONSOLE_OUT = $(JAVA_TOOLS)/../java_console_binary/rusefi_console.jar
AUTOUPDATE_OUT = $(JAVA_TOOLS)/../java_console_binary/rusefi_autoupdate.jar
TPL_OUT = $(JAVA_TOOLS)/../java_tools/ts_plugin_launcher/build/jar/rusefi_ts_plugin_launcher.jar

# We use .FORCE to always rebuild these tools. Gradle won't actually touch the jars if it doesn't need to,
# so we don't have to worry about triggering rebuilds of things that have these tools as a prerequisite.

$(CONFIG_DEFINITION): .FORCE
	cd $(JAVA_TOOLS) && $(FLOCK) ./gradlew :config_definition:shadowJar

$(CONFIG_DEFINITION_BASE): .FORCE
	cd $(JAVA_TOOLS) && $(FLOCK) ./gradlew :config_definition_base:shadowJar

$(ENUM_TO_STRING): .FORCE
	cd $(JAVA_TOOLS) && $(FLOCK) ./gradlew :enum_to_string:shadowJar

$(TPL_OUT): .FORCE
	cd ../java_tools && $(FLOCK) ./gradlew :ts_plugin_launcher:shadowJar

# The console depends on Fields.java.
$(CONSOLE_OUT): $(FIELDS) .FORCE
	cd ../java_tools && $(FLOCK) ./gradlew :ui:shadowJar

$(AUTOUPDATE_OUT): .FORCE
	cd ../java_tools && $(FLOCK) ./gradlew :autoupdate:jar

.FORCE:

