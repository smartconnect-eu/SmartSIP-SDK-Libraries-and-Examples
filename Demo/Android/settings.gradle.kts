pluginManagement {
    repositories {
        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        // Everyone can access this without a token
        maven { url = uri("https://raw.githubusercontent.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples/main/maven-repo") }
        maven { url = uri("https://linphone.org/maven_repository") }
    }
}

rootProject.name = "SmartSipDemo"
include(":app")
 