import org.gradle.api.file.Directory

plugins {
    // Apply only the application plugin at the root; library plugin should be applied only in library submodules if any.
    id("com.android.application") version "8.7.3" apply false
    // Kotlin Android plugin version aligned with classpath (2.1.0) to avoid conflicts
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Keep your custom build dir redirection
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
